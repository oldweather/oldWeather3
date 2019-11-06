#!/opt/local/bin/perl

# Get cannonical positions (and dates) for a voyage

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

        #if($Asset->{done}) { push @AssetIds, $Asset->{_id}; }
        push @AssetIds, $Asset->{_id};

    }
}
else {    # only one id - for debugging
    push @AssetIds, MongoDB::OID->new( value => $Id );
}

my $Date;
my $DateOS; # Old-style data - for comparison with last time
#foreach my $AssetId (@AssetIds) {
for(my $i=0;$i<scalar(@AssetIds);$i++) {
    my $AssetId = $AssetIds[$i];

    printf "%s\t", $AssetId;

    my $Asset = asset_read( $AssetId, $db );
    if ( defined( $Asset->{CDate}->{data}->{date} )
        && $Asset->{CDate}->{data}->{date} =~ /\w/ )
    {
        $Date = $Asset->{CDate}->{data}->{date};
	$DateOS = $Asset->{CDate}->{data}->{date};
    }
    elsif($i+1<scalar(@AssetIds)) { # Todays date is often on the next (facing) page
	my $A2 = asset_read( $AssetIds[$i+1], $db );
	if ( defined( $A2->{CDate}->{data}->{date} )
	    && $A2->{CDate}->{data}->{date} =~ /\w/ )
	{
	    $Date = $A2->{CDate}->{data}->{date};
	}
    }

    if ( defined($DateOS) ) {
	printf "%12s\t", $DateOS;
    }
    else { print "          NA\t"; }
    if ( defined($Date) ) {
	printf "%12s\t", $Date;
    }
    else { print "          NA\t"; }
    foreach my $Var (qw(latitude longitude portlat portlon)) {
        if ( defined( $Asset->{CPosition}->{data}->{$Var} ) ) {
            printf "%10s\t", $Asset->{CPosition}->{data}->{$Var};
        }
        else { print "        NA\t"; }
    }
    if ( defined( $Asset->{CPosition}->{data}->{port} ) ) {
        printf "%25s\t", $Asset->{CPosition}->{data}->{port};
    }
    else { printf "%25s\t", 'NA'; }
    if ( defined( $Asset->{CPosition}->{data}->{portname} ) ) {
        printf "%25s\t", $Asset->{CPosition}->{data}->{portname};
    }
    else { printf "%25s\t", 'NA'; }
    print "\n";
}

