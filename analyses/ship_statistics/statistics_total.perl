#!/opt/local/bin/perl

# Count the total number of weather observations transcribed

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;
use Getopt::Long;


# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

# Get all the pages (assets)
my $assetI = $db->get_collection('assets')->find();

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

my $transcriptionsI = $db->get_collection('transcriptions')->find();
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
