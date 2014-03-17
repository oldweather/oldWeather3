#!/opt/local/bin/perl

# Get all the event types

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;
use FindBin;
use File::Basename;
use lib "$FindBin::Bin/../../Modules";
use Asset;
use Getopt::Long;
use Data::Dumper;

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

my %Samples;
my $annotationsI = $db->annotations->find();

while ( my $Annotation = $annotationsI->next ) {
    foreach my $Key (keys( %{ $Annotation->{data} } )) {
        if ( defined( $Samples{$Key} ) ) { next; }
        print Dumper $Annotation->{data};
        foreach (keys( %{ $Annotation->{data} } )) { $Samples{$_} = 1; }
    }
}
