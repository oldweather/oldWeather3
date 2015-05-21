#!/opt/local/bin/perl

# Get cannonical observation of thermometer and barometer obs (and dates) for a voyage

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
        push @AssetIds, $Asset->{_id};

    }
}
else {    # only one id - for debugging
    push @AssetIds, MongoDB::OID->new( value => $Id );
}

my $Date;
foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );
    if ( defined( $Asset->{CDate}->{data}->{date} )
        && $Asset->{CDate}->{data}->{date} =~ /\w/ )
    {
        $Date = $Asset->{CDate}->{data}->{date};
    }

    for ( my $Hour = 1 ; $Hour <= 24 ; $Hour++ ) {
	if ( defined($Date) ) {
	    printf "%12s\t", $Date;
	}
	else { print "          NA\t"; }
        printf "%2d\t",$Hour;
        foreach my $WhichOb ('air_temperature','sea_temperature',
                             'height_2','height_1') {
	    if ( defined( $Asset->{CWeather}[$Hour]->{data}->{$WhichOb} ) &&
		 $Asset->{CWeather}[$Hour]->{data}->{$WhichOb} =~ /\d/) {
		printf "%s\t", $Asset->{CWeather}[$Hour]->{data}->{$WhichOb};
	    }
	    else { print "NA\t"; }
	}
        print "\n";
    }

}

