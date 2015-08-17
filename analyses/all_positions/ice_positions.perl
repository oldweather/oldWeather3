#!/opt/local/bin/perl

# Mark all positions with ice information

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

my @AssetIds;    # Assets to process

#Default hemisphere flags
my $nS = 1;    # North
my $eW = 1;    # East

# Get all the pages (assets) 
my $assetI = $db->get_collection('assets')->find( );

while ( my $Asset = $assetI->next ) {

    #if($Asset->{done}) { push @AssetIds, $Asset->{_id}; }
    push @AssetIds, $Asset->{_id};

}

foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );
    unless(hasIce($Asset)==1) { next; }

    print "\n$Asset->{_id}: ";
    print "($Asset->{location})\n";

    if ( defined( $Asset->{CDate}->{data}->{date} ) ) {
        printf "\nDate: %s\n", $Asset->{CDate}->{data}->{date};
    }

    if ( defined( $Asset->{CPosition} ) ) {
        print "Position: ";
        my $LonSource = "";
        foreach my $v ( 'longitude', 'portlon' ) {
            if ( defined( $Asset->{CPosition}->{data}->{$v} )
                && length( $Asset->{CPosition}->{data}->{$v} ) > 2 )
            {
                $LonSource = $v;
                last;
            }
        }
        my $LatSource = "";
        foreach my $v ( 'latitude', 'portlat' ) {
            if ( defined( $Asset->{CPosition}->{data}->{$v} )
                && length( $Asset->{CPosition}->{data}->{$v} ) > 2 )
            {
                $LatSource = $v;
                last;
            }
        }
        if ( defined( $Asset->{CPosition}->{data}->{portlat} )
            && $Asset->{CPosition}->{data}->{portlat} < 0 )
        {
            $nS = -1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{latitude} )
            && lc( $Asset->{CPosition}->{data}->{latitude} ) =~ /s/ )
        {
            $nS = -1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{latitude} )
            && lc( $Asset->{CPosition}->{data}->{latitude} ) =~ /n/ )
        {
            $nS = 1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{latitude} )
            && $Asset->{CPosition}->{data}->{latitude} =~
            /\D*(\d+)\D*(\d+)\D*(\d*)/ )
        {
            #print "L1: $Asset->{CPosition}->{data}->{latitude}  ";
            $Asset->{CPosition}->{data}->{latitude} = $1 + $2 / 60;
            if ( defined($3) && length($3) > 0 ) {
                $Asset->{CPosition}->{data}->{latitude} += $3 / 360;
            }
            $Asset->{CPosition}->{data}->{latitude} *= $nS;
            $Asset->{CPosition}->{data}->{latitude} = sprintf "%6.2f",
              $Asset->{CPosition}->{data}->{latitude};
            #print "$Asset->{CPosition}->{data}->{latitude}\n";
        }
        if ( defined( $Asset->{CPosition}->{data}->{portlon} )
            && $Asset->{CPosition}->{data}->{portlon} < 0 )
        {
            $eW = -1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{longitude} )
            && lc( $Asset->{CPosition}->{data}->{longitude} ) =~ /w/ )
        {
            $eW = -1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{longitude} )
            && lc( $Asset->{CPosition}->{data}->{longitude} ) =~ /e/ )
        {
            $eW = 1;
        }
        if ( defined( $Asset->{CPosition}->{data}->{longitude} )
            && $Asset->{CPosition}->{data}->{longitude} =~
            /\D*(\d+)\D*(\d+)\D*(\d*)/ )
        {
            #print "L2: $Asset->{CPosition}->{data}->{longitude}  ";
            $Asset->{CPosition}->{data}->{longitude} = $1 + $2 / 60;
            if ( defined($3) && length($3) > 0 ) {
                $Asset->{CPosition}->{data}->{longitude} += $3 / 360;
            }
            $Asset->{CPosition}->{data}->{longitude} *= $eW;
            $Asset->{CPosition}->{data}->{longitude} = sprintf "%7.2f",
              $Asset->{CPosition}->{data}->{longitude};
            #print "$Asset->{CPosition}->{data}->{longitude}\n";
        }
        if(defined( $Asset->{CPosition}->{data}->{$LatSource} )
                && length( $Asset->{CPosition}->{data}->{$LatSource} ) > 2 ) {
               printf "Lat %s, ",$Asset->{CPosition}->{data}->{$LatSource}
        }
        if(defined( $Asset->{CPosition}->{data}->{$LonSource} )
                && length( $Asset->{CPosition}->{data}->{$LonSource} ) > 2 ) {
               printf "Lon %s, ",$Asset->{CPosition}->{data}->{$LonSource}
        }
        if(defined( $Asset->{CPosition}->{data}->{port} )
                && length( $Asset->{CPosition}->{data}->{port} ) > 2 ) {
               printf "%s ",$Asset->{CPosition}->{data}->{port}
        }
        print "\n";
    }
    die;
}

sub hasIce {
    my $Asset = shift;
    foreach my $Transcription ( @{ $Asset->{transcriptions} } ) {
        foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
            if ( defined( $Annotation->{data}->{event} ) ) {
                if(lc($Annotation->{data}->{event}) =~ /\sice/) { return(1); }
            }

        }
    }
    return(0);
}
