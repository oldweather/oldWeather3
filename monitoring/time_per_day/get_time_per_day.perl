#!/opt/local/bin/perl

# Estimate total time transcribing spent each day

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;
use Date::Calc 'Date_to_Time';

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the oldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

my $transcriptionsI = $db->transcriptions->find();

my %TimesA;
while ( my $Transcription = $transcriptionsI->next ) {
    my $User = $Transcription->{zooniverse_user_id};
    unless(defined($User)) { next; } # ???
    my $Date = $Transcription->{created_at};
    my $TimeT = Date_to_Time(
        $Date->{local_c}->{year},   $Date->{local_c}->{month},
        $Date->{local_c}->{day},    $Date->{local_c}->{hour},
        $Date->{local_c}->{minute}, $Date->{local_c}->{second}
    );
    my $Day=sprintf "%04d-%02d-%02d",$Date->{local_c}->{year},$Date->{local_c}->{month},$Date->{local_c}->{day};
    push @{ $TimesA{$User} }, [$TimeT,$Day];
}

# Assume the first page done takes 250 seconds (median)
# and gaps of more than one hour are breaks.
my %Days;
foreach my $User ( keys(%TimesA) ) {
    my @TimesU = sort {$a->[0] <=>$b->[0]} @{ $TimesA{$User} };
    $Days{$TimesU[0][1]}+=250;
    for ( my $i = 1 ; $i < scalar(@TimesU) ; $i++ ) {
	    my $Duration = $TimesU[$i][0] - $TimesU[ $i - 1 ][0];
	    if($Duration>3600) { $Duration=250; }
        $Days{$TimesU[$i][1]}+=$Duration;
    }
}

foreach my $Day (sort(keys(%Days))) {
        printf "%s %d\n",$Day,$Days{$Day};
}
