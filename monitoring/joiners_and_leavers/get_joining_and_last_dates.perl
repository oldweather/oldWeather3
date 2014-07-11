#!/opt/local/bin/perl

# For each volunteer, get the date of registration

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

my %Registered;
my $volunteersI = $db->get_collection('zooniverse_users')->find();
while ( my $Volunteer = $volunteersI->next ) {
    unless ( defined( $Volunteer->{_id} ) ) { next; }
    my $Date = $Volunteer->{created_at};
    my $Key = sprintf "%04d-%02d-%02d", $Date->{local_c}->{year},
      $Date->{local_c}->{month}, $Date->{local_c}->{day};
    $Registered{ $Volunteer->{_id} } = $Key;
}

my $transcriptionsI = $db->get_collection('transcriptions')->find();
my %First;
my %Last;
while ( my $Transcription = $transcriptionsI->next ) {
    unless ( defined( $Transcription->{zooniverse_user_id} ) ) { next; }
    unless ( defined $Registered{ $Transcription->{zooniverse_user_id} } ) {
        die "No registration for $Transcription->{zooniverse_user_id}";
    }
    my $Date = $Transcription->{created_at};
    my $Key = sprintf "%04d-%02d-%02d", $Date->{local_c}->{year},
      $Date->{local_c}->{month}, $Date->{local_c}->{day};
    if ( !defined( $First{ $Transcription->{zooniverse_user_id} } )
        || ( $Key cmp $First{ $Transcription->{zooniverse_user_id} } ) < 0 )
    {
        $First{ $Transcription->{zooniverse_user_id} } = $Key;
    }
    if ( !defined( $Last{ $Transcription->{zooniverse_user_id} } )
        || ( $Key cmp $Last{ $Transcription->{zooniverse_user_id} } ) > 0 )
    {
        $Last{ $Transcription->{zooniverse_user_id} } = $Key;
    }
}

foreach my $User (sort( keys(%Registered) )) {
    printf "%s %10s ", $User, $Registered{$User};
    if ( defined( $First{$User} ) ) { printf "%10s ", $First{$User}; }
    else                            { print "        NA "; }
    if ( defined( $Last{$User} ) ) { printf "%10s ", $Last{$User}; }
    else                           { print "        NA "; }
    print "\n";
}
