#!/opt/local/bin/perl

# Get time since last transcription for each transcription for each user
#  This is an approximation of the time the transcription took (with obvious caveats)

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

my $transcriptionsI = $db->get_collection('transcriptions')->find();

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
    push @{ $TimesA{$User} }, $TimeT;
}

foreach my $User ( keys(%TimesA) ) {
    my @TimesU = sort @{ $TimesA{$User} };
    for ( my $i = 1 ; $i < scalar(@TimesU) ; $i++ ) {
        print $TimesU[$i] - $TimesU[ $i - 1 ];
        print "\n";
    }
}
