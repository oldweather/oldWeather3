#!/opt/local/bin/perl

# Count the total number of weather observations transcribed

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

my $annotationsI = $db->get_collection('annotations')->find();

my $Weather=0;
my $Chars=0;
my %Elements;
while ( my $Annotation = $annotationsI->next ) {
    unless(defined($Annotation->{data}) &&
           exists($Annotation->{data}->{height_1})) { next; }
	$Weather++;
    foreach my $Key (keys(%{$Annotation->{data}})) {
       if(defined($Annotation->{data}->{$Key}) &&
                  $Annotation->{data}->{$Key} =~ /\S/) {
          $Elements{$Key}++;
          $Chars+= length($Annotation->{data}->{$Key});
      }
   }
   #if($Weather>100) { last; }
}

printf "Total weather observations: %d\n",$Weather;
printf "Total characters: %d\n",$Chars;
foreach my $Key (keys(%Elements)) {
   printf "Total %s: %d\n",$Key,$Elements{$Key};
}
