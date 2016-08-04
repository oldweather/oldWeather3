#!/opt/local/bin/perl

# Make a limited subset of Jeannette images - only those with weather data.

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

my $Id         = undef;    # If selected, only do this page
my $Only       = undef;    # If selected, only show this transcription
my $VoyageN    = 1;
my $ImageCount = 0;
my $LastFile;

my $Ship_name='Jeannette';

my @Image_files=glob('/Users/philip/LocalData/oW3_logbooks/NARA/Jeannette.split.bw/*.jpg');
my %Image_files;
foreach my $Ifile (@Image_files) {
    chomp($Ifile);
    $Image_files{basename($Ifile)}=1;
}
my $Source_dir='/Users/philip/LocalData/oW3_logbooks/NARA/Jeannette.split.bw/';
my $Final_dir='/Users/philip/LocalData/oW3_logbooks/NARA/Jeannette.final';

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

my @AssetIds;    # Assets to process

if ( !defined($Id) ) {

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

        push @AssetIds, $Asset->{_id};

    }
}
else {                          # only one id - for debugging
    push @AssetIds, MongoDB::OID->new( value => $Id );
}


# Is this page one for which we have the high resolution image ready?
# If so return the filename
sub have_image {
    my $Asset = shift();
    if(defined($Asset->{'location'})) {
	my $ln=basename($Asset->{'location'});
	if(exists($Image_files{$ln})) { 
            return($ln); 
        }
    }
    return('');
}

# Does this page have any weather data?
sub have_weather {
    my $Asset = shift();
    if(defined($Asset->{'CWeather'})) { return(1); }
    return(0);
}	

foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );
    my $Img = have_image($Asset);
    if($Img eq '') { next; }
    unless(have_weather($Asset)) { next; }
    system(sprintf("cp %s/%s %s",$Source_dir,$Img,$Final_dir));

}

