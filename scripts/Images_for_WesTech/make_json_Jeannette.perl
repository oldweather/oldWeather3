#!/opt/local/bin/perl

# Dump the processed transcriptions for a voyage to an JSON file
# Modify to suit the high-resolution images for Wes Tech.

use strict;
use warnings;
use MongoDB;
#use MongoDB::Connection;
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

# Open the database connection (default port, default server)
my $conn = MongoDB::MongoClient->new( query_timeout => -1 )
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

# Prune all the guff to get the JSON down to minimum size
sub prune_unwanted {
    my $Asset=shift();
    if(exists($Asset->{CWeather})) { delete($Asset->{CWeather}); }
    if(exists($Asset->{CDate})) { delete($Asset->{CDate}); }
    if(exists($Asset->{CPosition})) { delete($Asset->{CPosition}); }

    if(exists($Asset->{created_at})) { delete($Asset->{created_at}); }
    if(exists($Asset->{updated_at})) { delete($Asset->{updated_at}); }
    foreach my $Transcription ( @{ $Asset->{transcriptions} } ) {
       if(exists($Transcription->{created_at})) { delete($Transcription->{created_at}); }
       if(exists($Transcription->{updated_at})) { delete($Transcription->{updated_at}); }
       foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
          if(exists($Annotation->{created_at})) { delete($Annotation->{created_at}); }
          if(exists($Annotation->{updated_at})) { delete($Annotation->{updated_at}); }
       }
    }
    return($Asset);
}

# Is this page one for which we have the high resolution image ready?
# If so return the filename
sub have_image {
    my $Asset = shift();
    if(defined($Asset->{'location'})) {
	my $ln=basename($Asset->{'location'});
	#$ln =~ s/of0/of/;
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


# JSON header
print "{\"pages\":\n[";
my $count=0;
foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );
    my $Img = have_image($Asset);
    if($Img eq '') { next; }
    $Asset->{'location'} = $Img;
    #unless(have_weather($Asset)) { next; }
    $Asset = prune_unwanted($Asset);

    # Print as JSON
    if($count++ > 0) { print ","; }
    print $Asset->to_JSON();

}

# JSON footer
print "]}\n";
