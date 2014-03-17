#!/opt/local/bin/perl

# Get the 100 most-popular N-grams for each value of N

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;
use FindBin;
use Data::Dumper;

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

my %Samples;
my $annotationsI = $db->annotations->find();

my @NGrams;
while ( my $Annotation = $annotationsI->next ) {
    if ( defined( $Annotation->{data}->{undefined} ) ) {
        my $Text = lc( $Annotation->{data}->{undefined} );
        $Text =~ s/\W+/ /g;
        my @Fields = split /\s+/, $Text;
        for ( my $Length = 0 ; $Length < scalar(@Fields) ; $Length++ ) {
            for (
                my $Offset = 0 ;
                $Offset < scalar(@Fields) - $Length ;
                $Offset++
              )
            {
                my $NG = join( " ", @Fields[ $Offset .. $Offset + $Length ] );
                $NGrams[$Length]->{$NG}++;
            }
        }
    }
}

for ( my $Length = 0 ; $Length < scalar(@NGrams) ; $Length++ ) {
    printf "\n\nLength %d:\n\n", $Length + 1;
    my $Count = 0;
    foreach my $NG ( sort { $NGrams[$Length]->{$b} <=> $NGrams[$Length]->{$a} }
        keys( %{$NGrams[$Length]} ) )
    {
        printf "%3d %s\n", $NGrams[$Length]->{$NG}, $NG;
        if ( ++$Count > 100 ) { last; }
    }
}
