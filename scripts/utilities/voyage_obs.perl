#!/opt/local/bin/perl

# Get cannonical observations (and dates) for a voyage

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
use Scalar::Util qw(looks_like_number);

my $Ship_name  = undef;
my $Id         = undef;    # If selected, only do this page
my $Only       = undef;    # If selected, only show this transcription
my $VoyageN    = 1;
my $ImageCount = 0;
my $LastFile;
GetOptions(
    "ship=s"   => \$Ship_name,
    "voyage=i" => \$VoyageN,
    "id=s"     => \$Id,
    "only=i"   => \$Only
);
unless ( defined($Ship_name) ) { die "Usage: --ship=<ship.name>"; }

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

my @AssetIds;    # Assets to process

if ( !defined($Id) ) {

    # Get the ship record
    my $ships = $db->get_collection('ships')->find( { "name" => $Ship_name } )
      or die "No such ship: $Ship_name";
    my $Ship = $ships->next;    # Assume there's only one

    my $voyageI = $db->get_collection('voyages')->find( { "ship_id" => $Ship->{_id} } );

    my $Voyage;
    my $Count = 0;
    while ( $Count++ < $VoyageN ) { $Voyage = $voyageI->next; }

    # Get all the pages (assets) for this voyage
    my $assetI = $db->get_collection('assets')->find( { "voyage_id" => $Voyage->{_id} } );

    while ( my $Asset = $assetI->next ) {

        #if($Asset->{done}) { push @AssetIds, $Asset->{_id}; }
        push @AssetIds, $Asset->{_id};

    }
}
else {    # only one id - for debugging
    push @AssetIds, MongoDB::OID->new( value => $Id );
}

my $Date;
foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );
    if ( defined( $Asset->{CDate}->{data}->{date} )
        && $Asset->{CDate}->{data}->{date} =~ /\w/ )
    {
        $Date = $Asset->{CDate}->{data}->{date};
    }

    for ( my $Hour = 1 ; $Hour <= 24 ; $Hour++ ) {
        if ( defined($Date) && $Date =~ /(\d+)\/(\d+)\/(\d+)/ ) {
            printf "%04d-%02d-%02d:%02d\t", $3, $2, $1, $Hour;
        }
        else { print "             NA\t"; }

        if (
            defined( $Asset->{CWeather}[$Hour]->{data}->{air_temperature} )
            && looks_like_number(
                $Asset->{CWeather}[$Hour]->{data}->{air_temperature}
            )
          )
        {
            printf "%6.1f\t",
              $Asset->{CWeather}[$Hour]->{data}->{air_temperature};
        }
        else { print "    NA\t"; }
        if (
            defined( $Asset->{CWeather}[$Hour]->{data}->{bulb_temperature} )
            && looks_like_number(
                $Asset->{CWeather}[$Hour]->{data}->{bulb_temperature}
            )
          )
        {
            printf "%6.1f\t",
              $Asset->{CWeather}[$Hour]->{data}->{bulb_temperature};
        }
        else { print "    NA\t"; }
        if (
            defined( $Asset->{CWeather}[$Hour]->{data}->{sea_temperature} )
            && looks_like_number(
                $Asset->{CWeather}[$Hour]->{data}->{sea_temperature}
            )
          )
        {
            printf "%6.1f\t",
              $Asset->{CWeather}[$Hour]->{data}->{sea_temperature};
        }
        else { print "    NA\t"; }
        if ( defined( $Asset->{CWeather}[$Hour]->{data}->{height_1} )
            && looks_like_number(
                $Asset->{CWeather}[$Hour]->{data}->{height_1} ) )
        {
            printf "%6.2f\t", $Asset->{CWeather}[$Hour]->{data}->{height_1};
        }
        else { print "    NA\t"; }
        if ( defined( $Asset->{CWeather}[$Hour]->{data}->{height_2} )
            && looks_like_number(
                $Asset->{CWeather}[$Hour]->{data}->{height_2} ) )
        {
            printf "%6.1f\t", $Asset->{CWeather}[$Hour]->{data}->{height_2};
        }
        else { print "    NA\t"; }
        if ( defined( $Asset->{CWeather}[$Hour]->{data}->{wind_direction} )
            && $Asset->{CWeather}[$Hour]->{data}->{wind_direction} =~ /\w/ )
        {
            $Asset->{CWeather}[$Hour]->{data}->{wind_direction} =~ s/\s//g;
            printf "%6s\t", $Asset->{CWeather}[$Hour]->{data}->{wind_direction};
        }
        else { print "    NA\t"; }
        if ( defined( $Asset->{CWeather}[$Hour]->{data}->{wind_force} )
            && $Asset->{CWeather}[$Hour]->{data}->{wind_force} =~ /\w/ )
        {
            $Asset->{CWeather}[$Hour]->{data}->{wind_force} =~ s/\s//g;
            printf "%6s\t", $Asset->{CWeather}[$Hour]->{data}->{wind_force};
        }
        else { print "    NA\t"; }
        if ( defined( $Asset->{CWeather}[$Hour]->{data}->{weather_code} )
            && $Asset->{CWeather}[$Hour]->{data}->{weather_code} =~ /\w/ )
        {
            $Asset->{CWeather}[$Hour]->{data}->{weather_code} =~ s/\s//g;
            printf "%6s\t", $Asset->{CWeather}[$Hour]->{data}->{weather_code};
        }
        else { print "    NA\t"; }
        print "\n";
    }
}

