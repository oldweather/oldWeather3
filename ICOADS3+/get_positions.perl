#!/opt/local/bin/perl

# Get cannonical positions for a voyage

use strict;
use warnings;
use MongoDB;
use MongoDB::OID;
use boolean;
use FindBin;
use File::Basename;
use lib "$FindBin::Bin/../Modules";
use Asset;
use Getopt::Long;
use Data::Dumper;

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

# Load Sophia's positions
my %Sophia;
open(DIN,"$FindBin::Bin/../Sophia/S.positions.tsv") or die;
while (my $Line = <DIN>) {
	chomp $Line;
        my @fields = split /\t/,$Line;
        $Sophia{$fields[0]}{latitude}=$fields[2];
        $Sophia{$fields[0]}{longitude}=$fields[4];
}
close(DIN);

# Convert DD MM SS positions to decimal
sub ddmmss_to_dec {
    my $orig = shift;
    $orig=lc($orig);
    my $Hemisphere=1;
    if($orig =~/w/ || $orig =~ /s/) {
	$Hemisphere=-1;
    }
    my @of = split /\s+/,$orig;
    my $result='';
    if(defined($of[0]) && $of[0] =~ /([\d\+\.]+)/) {
	$result=$1;
	if(defined($of[1]) && $of[1] =~ /([\d\+\.]+)/) {
	    $result += $1/60;
	}
	if(defined($of[2]) && $of[2] =~ /([\d\+\.]+)/) {
	    $result += $1/(60*60);
	}
	$result *= $Hemisphere;
    }
    return($result);
}

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

for(my $i=0;$i<scalar(@AssetIds);$i++) {
    my $AssetId = $AssetIds[$i];

    my $Asset = asset_read( $AssetId, $db );

    my $ObQ=undef;  # Where is the position from?
    my $Clat=undef;
    my $Clon=undef;

    # First choice - numeric lat and lon
    if(defined($Asset->{CPosition}->{data}->{latitude})) {
	if($Asset->{CPosition}->{data}->{latitude} !~ /\./) {
           $Asset->{CPosition}->{data}->{latitude}=
	       ddmmss_to_dec($Asset->{CPosition}->{data}->{latitude});
	}
	$Clat=$Asset->{CPosition}->{data}->{latitude};
	$ObQ=1;
    }
    if(defined($Asset->{CPosition}->{data}->{longitude})) {
	if($Asset->{CPosition}->{data}->{longitude} !~ /\./) {
           $Asset->{CPosition}->{data}->{longitude}=
	       ddmmss_to_dec($Asset->{CPosition}->{data}->{longitude});
	}
	$Clon=$Asset->{CPosition}->{data}->{longitude};
	$ObQ=1;
    }
    # Second choice - sophia's positions
    if(!defined($Clat) && defined($Sophia{$Asset->{CPosition}->{data}->{port}})) {
	$Clat=$Sophia{$Asset->{CPosition}->{data}->{port}}{latitude};
	$ObQ=2;
    }
    if(!defined($Clon) && defined($Sophia{$Asset->{CPosition}->{data}->{port}})) {
	$Clon=$Sophia{$Asset->{CPosition}->{data}->{port}}{longitude};
	$ObQ=2;
    }
    # Third choice - auto positions from port
    #if(!defined($Clat) && defined($Asset->{CPosition}->{data}->{portlat})) {
    #	$Clat=$Asset->{CPosition}->{data}->{portlat};
    #	$ObQ=3;
    #}
    #if(!defined($Clon) && defined($Asset->{CPosition}->{data}->{portlon})) {
    #	$Clon=$Asset->{CPosition}->{data}->{portlon};
    #	$ObQ=3;
    #}

    if(defined($ObQ)) {
        printf "%s\t",$AssetId;
	printf "%d\t",$ObQ;
	if(defined($Clat)) {
	    printf "%7.2f\t",$Clat;
	} else { print "       \t"; }
	if(defined($Clon)) {
	    printf "%7.2f\n",$Clon;
	} else { print "       \n"; }
    }

}

