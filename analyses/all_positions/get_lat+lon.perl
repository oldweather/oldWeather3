#!/opt/local/bin/perl

# Get all available lat-lon pairs.

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;
use Getopt::Long;

my $Ship_name  = undef;
my $Id         = undef;    # If selected, only do this page
my $Only       = undef;    # If selected, only show this transcription
my $VoyageN    = 1;
my $LastFile;
GetOptions(
    "ship=s"   => \$Ship_name,
    "voyage=i" => \$VoyageN,
    "id=s"     => \$Id,
    "only=i"   => \$Only
);

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

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

my $PagesTotal=0;
my $PagesDone=0;
while ( my $Asset = $assetI->next ) {

    if($Asset->{done}) { $PagesDone++; }
    $PagesTotal++;

}

printf "Total pages: %d (%d completed)\n",$PagesTotal,$PagesDone;

my $annotationsI = $db->get_collection('annotations')->find();

while ( my $Annotation = $annotationsI->next ) {
    unless(defined($Annotation->{data}) &&
           exists($Annotation->{data}->{latitude}) &&
           exists($Annotation->{data}->{longitude}) &&
           $Annotation->{data}->{latitude} =~ /\S/ &&
           $Annotation->{data}->{longitude} =~ /\S/) { next; }
    my $Lat = $Annotation->{data}->{latitude};
    unless($Lat =~ /(\d+)\D+(\d+).*([nNsS])/) { next; }
    $Lat = $1+$2/60;
    if($3 eq 's' || $3 eq 'S') { $Lat *= -1; }
    my $Lon = $Annotation->{data}->{longitude};
    unless($Lon =~ /(\d+)\D+(\d+).*([eEwW])/) { next; }
    $Lon = $1+$2/60;
    if($3 eq 'w' || $3 eq 'W') { $Lon *= -1; }

    printf "%6.1f %5.1f\n",$Lon,$Lat;
}

