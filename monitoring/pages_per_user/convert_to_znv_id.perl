#!/opt/local/bin/perl

# Convert user _id to Zooniverse user_id

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

while (<>) {
    my @Fields = split;
    my $Id     = MongoDB::OID->new( value => $Fields[0] );
    my $Znv = $db->get_collection('zooniverse_users')->find( { "_id" => $Id } )->next;
#    printf "%s %d\n", $Znv->{zooniverse_user_id}, $Fields[1];
     printf "\"%s\" %d\n",$Znv->{name},$Fields[1];

}
