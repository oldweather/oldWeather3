#!/opt/local/bin/perl

# Make basic ship history for a given voyage

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

#Default hemisphere flags
my $nS = 1;    # North
my $eW = 1;    # East

if ( !defined($Id) ) {

    # Clean up previous attempts
    if ( -r "$Ship_dir.mp4" ) { unlink("$Ship_dir.mp4"); }
    system("find $Dir -type f -name '*.png' -exec /bin/rm {} \\;");

    # Get the ship record
    my $ships = $db->ships->find( { "name" => $Ship_name } )
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
else {    # only one id - for debugging
    push @AssetIds, MongoDB::OID->new( value => $Id );
}

foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );

    print "\n$Asset->{_id}: ";
    print "($Asset->{location})\n";

    if ( defined( $Asset->{CDate}->{data}->{date} ) ) {
        printf "\nDate: %s\n", $Asset->{CDate}->{data}->{date};
    }

    if ( defined( $Asset->{CPosition} ) ) {
        print "Position: ";
        my $LonSource = "";
        foreach my $v ( 'longitude', 'portlon' ) {
            if ( defined( $Asset->{CPosition}->{data}->{$v} )
                && length( $Asset->{CPosition}->{data}->{$v} ) > 2 )
            {
                $LonSource = $v;
                last;
            }
        }
        my $LatSource = "";
        foreach my $v ( 'latitude', 'portlat' ) {
            if ( defined( $Asset->{CPosition}->{data}->{$v} )
                && length( $Asset->{CPosition}->{data}->{$v} ) > 2 )
            {
                $LatSource = $v;
                last;
            }
        }
        if ( defined( $Asset->{CPosition}->{data}->{portlat} )
            && $Asset->{CPosition}->{data}->{portlat} < 0 )
        {
            $nS = -1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{latitude} )
            && lc( $Asset->{CPosition}->{data}->{latitude} ) =~ /s/ )
        {
            $nS = -1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{latitude} )
            && lc( $Asset->{CPosition}->{data}->{latitude} ) =~ /n/ )
        {
            $nS = 1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{latitude} )
            && $Asset->{CPosition}->{data}->{latitude} =~
            /\D*(\d+)\D*(\d+)\D*(\d*)/ )
        {
            #print "L1: $Asset->{CPosition}->{data}->{latitude}  ";
            $Asset->{CPosition}->{data}->{latitude} = $1 + $2 / 60;
            if ( defined($3) && length($3) > 0 ) {
                $Asset->{CPosition}->{data}->{latitude} += $3 / 360;
            }
            $Asset->{CPosition}->{data}->{latitude} *= $nS;
            $Asset->{CPosition}->{data}->{latitude} = sprintf "%6.2f",
              $Asset->{CPosition}->{data}->{latitude};
            #print "$Asset->{CPosition}->{data}->{latitude}\n";
        }
        if ( defined( $Asset->{CPosition}->{data}->{portlon} )
            && $Asset->{CPosition}->{data}->{portlon} < 0 )
        {
            $eW = -1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{longitude} )
            && lc( $Asset->{CPosition}->{data}->{longitude} ) =~ /w/ )
        {
            $eW = -1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{longitude} )
            && lc( $Asset->{CPosition}->{data}->{longitude} ) =~ /e/ )
        {
            $eW = 1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{longitude} )
            && $Asset->{CPosition}->{data}->{longitude} =~
            /\D*(\d+)\D*(\d+)\D*(\d*)/ )
        {
            #print "L2: $Asset->{CPosition}->{data}->{longitude}  ";
            $Asset->{CPosition}->{data}->{longitude} = $1 + $2 / 60;
            if ( defined($3) && length($3) > 0 ) {
                $Asset->{CPosition}->{data}->{longitude} += $3 / 360;
            }
            $Asset->{CPosition}->{data}->{longitude} *= $eW;
            $Asset->{CPosition}->{data}->{longitude} = sprintf "%7.2f",
              $Asset->{CPosition}->{data}->{longitude};
            #print "$Asset->{CPosition}->{data}->{longitude}\n";
        }
        foreach my $v ( $LatSource, $LonSource, 'port' ) {
            if ( defined( $Asset->{CPosition}->{data}->{$v} )
                && length( $Asset->{CPosition}->{data}->{$v} ) > 2 )
            {
                printf "%s ", $Asset->{CPosition}->{data}->{$v};
            }
        }
        print "\n";
    }

    foreach my $Transcription ( @{ $Asset->{transcriptions} } ) {
        foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
            if ( defined( $Annotation->{data}->{undefined} ) ) {
                printf "%s\n", $Annotation->{data}->{undefined};
            }
            if ( defined( $Annotation->{data}->{mention_type} ) ) {
                printf "%s - %s\n", $Annotation->{data}->{mention_name},
                  $Annotation->{data}->{mention_context};
            }
            if ( defined( $Annotation->{data}->{fuel_type} ) ) {
                printf "%s: %s - %s\n",
                  $Annotation->{data}->{fuel_type},
                  $Annotation->{data}->{fuel_ammount},
                  $Annotation->{data}->{fuel_additional_info};
            }
            if ( defined( $Annotation->{data}->{animal_type} ) ) {
                printf "%s - %s\n", $Annotation->{data}->{animal_type},
                  $Annotation->{data}->{animal_amount};
            }
            if ( defined( $Annotation->{data}->{event} ) ) {
                printf "%s\n", $Annotation->{data}->{event};
            }

        }
    }
}
