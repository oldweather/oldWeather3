#!/opt/local/bin/perl

# Count the number of pages transcribed each day by each participant

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
my %Uids;
while ( my $Transcription = $transcriptionsI->next ) {
    unless(defined($Transcription->{zooniverse_user_id})) { next; }
    my $Uid=$Transcription->{zooniverse_user_id};
    $Uids{$Uid}++;
    my $Date = $Transcription->{created_at};
	my $Key = sprintf "%04d-%02d-%02d",$Date->{local_c}->{year},
                          $Date->{local_c}->{month},$Date->{local_c}->{day};
    $Days{$Key}{$Uid}++;
    #if(scalar(keys(%Days))>20) { last; }
}

foreach my $Day (sort(keys(%Days))) {
    printf "%s",$Day;
    foreach my $Uid (keys(%Uids)) {
	if(defined($Days{$Day}{$Uid})) { printf " %4d",$Days{$Day}{$Uid}; }
	else { print "   NA"; }
    }
    print "\n";
}
