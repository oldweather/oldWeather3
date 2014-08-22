#!/opt/local/bin/perl

# Count the total number of weather observations transcribed

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
my $Weather=0;
my $Chars=0;
my %Elements;
my $Transcriptions=0;
my %People;

while ( my $Asset = $assetI->next ) {

    if($Asset->{done}) { $PagesDone++; }
    $PagesTotal++;

}

my $transcriptionsI = $db->get_collection('transcriptions')->find( 
		 { "voyage_id" => $Voyage->{_id} } );
while ( my $Transcription = $transcriptionsI->next ) {
   my $annotationsI = $db->get_collection('annotations')->
	   find( { "transcription_id" => $Transcription->{_id} } );
   $Transcriptions++;
   $People{$Transcription->{zooniverse_user_id}}++;
    while ( my $Annotation = $annotationsI->next ) {
	if(defined($Annotation->{data}) &&
	   exists($Annotation->{data}->{height_1})) { $Weather++; }
	foreach my $Key (keys(%{$Annotation->{data}})) {
	   if(defined($Annotation->{data}->{$Key}) &&
		      $Annotation->{data}->{$Key} =~ /\S/) {
	      $Elements{$Key}++;
	      $Chars+= length($Annotation->{data}->{$Key});
	  }
       }
    
    }
   #if($Transcriptions>1000) { last; }
}

printf "Total pages: %d (%d completed)\n",$PagesTotal,$PagesDone;
printf "Total transcriptions: %d\n",$Transcriptions;
printf "Total people: %d\n",scalar(keys(%People));
printf "Total weather observations: %d\n",$Weather;
printf "Total characters: %d\n",$Chars;
foreach my $Key (keys(%Elements)) {
   printf "Total %s: %d\n",$Key,$Elements{$Key};
}
