#!/opt/local/bin/perl

# Make transcription images for a voyage

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;
use FindBin;
use File::Basename;
use lib "$FindBin::Bin/../../Modules";
use Asset;
use Getopt::Long;
use Data::Dumper;

my $Ship_name  = undef;
my $Id         = undef;    # If selected, only do this page
my $Only       = undef;    # If selected, only show this transcription
my $VoyageN    = 1;
my $ImageCount = 0;
my $LastFile;
GetOptions(
    "ship=s"   => \$Ship_name,
    "voyage=i" => \$VoyageN,
    "id=s"     => \$Id,
    "only=i"   => \$Only
);
unless ( defined($Ship_name) ) { die "Usage: --ship=<ship.name>"; }

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

my @AssetIds;    # Assets to process

# Make the output directories
my $Ship_dir = $Ship_name;
$Ship_dir =~ s/\s+/_/g;
$Ship_dir =~ s/[\(\)]//g;
my $Dir = sprintf( "%s/../../asset_files/%s/voyage_%03d",
    $FindBin::Bin, $Ship_dir, $VoyageN );
unless ( -d $Dir ) {
    system("mkdir -p $Dir");
}

if ( !defined($Id) ) {

    # Clean up previous attempts
    if ( -r "$Ship_dir.mp4" ) { unlink("$Ship_dir.mp4"); }
    system("find $Dir -type f -name '*.png' -exec /bin/rm {} \\;");

    # Get the ship record
    my $ships = $db->get_collection('ships')->find( { "name" => $Ship_name } )
      or die "No such ship: $Ship_name";
    my $Ship = $ships->next;    # Assume there's only one

    my $voyageI = $db->get_collection('voyages')->find( { "ship_id" => $Ship->{_id} } );

    my $Voyage;
    my $Count = 0;
    while ( $Count++ < $VoyageN ) { $Voyage = $voyageI->next; }

    # Get all the pages (assets) for this voyage
    my $assetI = $db->get_collection('assets')->find( { "voyage_id" => $Voyage->{_id} } );

    while ( my $Asset = $assetI->next ) {

        #if($Asset->{done}) { push @AssetIds, $Asset->{_id}; }
        push @AssetIds, $Asset->{_id};

    }
}
else {                          # only one id - for debugging
    push @AssetIds, MongoDB::OID->new( value => $Id );
}

foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );

    # Download the image
    my $Fname = basename( $Asset->{location} );
    unless ( -r "$Dir/$Fname" ) {

        #next;    # While offline - skip these images.
        system("wget \"$Asset->{location}\"") == 0 or die;
        system("mv \"$Fname\" $Dir") == 0          or die;
    }

    # Make appropriately sized background file
    unless ( system("convert -geometry x627 \"$Dir/$Fname\" tmp.jpg") == 0 ) {
        warn("Bad image $Dir/$Fname");
        next;
    }
    system(
"composite -geometry +46+46 tmp.jpg ../../static_data/background.png tmp.png"
      ) == 0
      or die;

    # Plot the data
    open( DOUT, ">tst.js" ) or die "Can't open JS file";
    print DOUT $Asset->to_JSON();
    close(DOUT);
    unlink( glob("$FindBin::Bin/images/*.png") );
    system("R --no-save < plot_asset_sequence.R") == 0 or die;
    my @Files = glob("$FindBin::Bin/images/*.png");
    for ( my $i = 0 ; $i < scalar(@Files) ; $i++ ) {
        my $OFName = sprintf( "%s/%05d.png", $Dir, $ImageCount++ );
        if ( defined($Id) ) {
            $OFName =
              sprintf( "%s/%05d.2.png", "$FindBin::Bin/images", $ImageCount );
        }
        system("composite $Files[$i] tmp.png $OFName") == 0 or die;
        if ( defined($LastFile) && -s $LastFile == -s $OFName ) {
            unlink($OFName);    # Skip identical frames
            $ImageCount--;
        }
        else { $LastFile = $OFName; }
    }
    unless ( defined($LastFile) ) { next; }
    if     ( defined($Id) )       { die; }
    for ( my $i = 0 ; $i < 10 ; $i++ )
    {                           # Duplicate end of page image for pause in video
        my $CFName = sprintf( "%s/%05d.png", $Dir, $ImageCount++ );
        system("cp $LastFile $CFName") == 0 or die;
    }
}

#die;
system(
"ffmpeg -r 10 -i $Dir/%05d.png -c:v libx264  -preset fast -pix_fmt yuv420p -crf 22 -c:a copy $Ship_dir.mp4"
  ) == 0
  or die "Can't make movie";
