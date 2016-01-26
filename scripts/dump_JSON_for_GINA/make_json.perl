#!/opt/local/bin/perl

# Dump the processed transcriptions for a voyage to an JSON file

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
my $StartAsset = '50874d7409d4090755002f67';
my $EndAsset = '50874d7a09d4090755003585';
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

        #if($Asset->{done}) { push @AssetIds, $Asset->{_id}; }
	if(($Asset->{_id} cmp $StartAsset) < 0 || ($Asset->{_id} cmp $EndAsset) >0 ) { next; }
        push @AssetIds, $Asset->{_id};

    }
}
else {                          # only one id - for debugging
    push @AssetIds, MongoDB::OID->new( value => $Id );
}

# Prune all the date guff to get the JSON down to reasonable size
sub prune_dates {
    my $Asset=shift();
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

# JSON header
print "{\"pages\":\n[";
my $count=0;
foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );
    $Asset = prune_dates($Asset);

    # Print as JSON
    if($count++ > 0) { print ","; }
    print $Asset->to_JSON();

}

# JSON footer
print "]}\n";
