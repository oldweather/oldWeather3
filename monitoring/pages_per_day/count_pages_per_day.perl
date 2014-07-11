#!/opt/local/bin/perl

# Count the number of pages transcribed each day

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

my $transcriptionsI = $db->get_collection( 'transcriptions' )->find();

my %Days;
while ( my $Transcription = $transcriptionsI->next ) {
    my $Date = $Transcription->{created_at};
	my $Key = sprintf "%04d-%02d-%02d",$Date->{local_c}->{year},$Date->{local_c}->{month},$Date->{local_c}->{day};
	$Days{$Key}++;
}

foreach my $Day (sort(keys(%Days))) {
	printf "%s %d\n",$Day,$Days{$Day};
}
