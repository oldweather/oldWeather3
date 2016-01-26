#!/opt/local/bin/perl

# Extract all occurences of a regular expression in non-weather data.

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

#Default hemisphere flags
my $nS = 1;    # North
my $eW = 1;    # East

my $Regexp  = 'kelp';

# Open the database connection (default port, default server)
my $conn = MongoDB::Connection->new( query_timeout => -1 )
  or die "No database connection";

# Connect to the OldWeather3 database
my $db = $conn->get_database('oldWeather3-production-live')
  or die "OW3 database not found";

my @AssetIds;    # Assets to process


# Get all the pages (assets) for this voyage
my $assetI = $db->get_collection('assets')->find();

while ( my $Asset = $assetI->next ) {

    #if($Asset->{done}) { push @AssetIds, $Asset->{_id}; }
    push @AssetIds, $Asset->{_id};

}

foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );

    my $Header;

    $Header = sprintf "\n$Asset->{_id}: ";
    $Header .= sprintf "($Asset->{location})\n";

    if ( defined( $Asset->{CDate}->{data}->{date} ) ) {
        $Header .= sprintf "\nDate: %s\n", $Asset->{CDate}->{data}->{date};
    }

    if ( defined( $Asset->{CPosition} ) ) {
        $Header .= sprintf "Position: ";
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
               $Header .= sprintf "Lat %s, ",$Asset->{CPosition}->{data}->{$LatSource}
        }
        if(defined( $Asset->{CPosition}->{data}->{$LonSource} )
                && length( $Asset->{CPosition}->{data}->{$LonSource} ) > 2 ) {
               $Header .= sprintf "Lon %s, ",$Asset->{CPosition}->{data}->{$LonSource}
        }
        if(defined( $Asset->{CPosition}->{data}->{port} )
                && length( $Asset->{CPosition}->{data}->{port} ) > 2 ) {
               $Header .= sprintf "%s ",$Asset->{CPosition}->{data}->{port}
        }
        $Header .= sprintf "\n";
    }
    my $Thispage=0;
    foreach my $Transcription ( @{ $Asset->{transcriptions} } ) {
        foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
            if ( defined( $Annotation->{data}->{undefined} ) &&
                 $Annotation->{data}->{undefined} =~ m/\Q$Regexp/i) {
		if($Thispage==0) {
		    print $Header;
		    $Thispage=1;
		}
                printf "%s\n", $Annotation->{data}->{undefined};
            }
            if ( defined( $Annotation->{data}->{mention_type} ) &&
                 ($Annotation->{data}->{mention_name} =~ m/\Q$Regexp/i ||
                  $Annotation->{data}->{mention_context} =~ m/\Q$Regexp/i) ) {
		if($Thispage==0) {
		    print $Header;
		    $Thispage=1;
		}		
                printf "%s - %s\n", $Annotation->{data}->{mention_name},
                  $Annotation->{data}->{mention_context};
            }
            if ( defined( $Annotation->{data}->{fuel_type} ) &&
                 ($Annotation->{data}->{fuel_type} =~ m/\Q$Regexp/i ||
                  $Annotation->{data}->{fuel_ammount} =~ m/\Q$Regexp/i ||
                  $Annotation->{data}->{fuel_additional_info} =~ m/\Q$Regexp/i)) {
		if($Thispage==0) {
		    print $Header;
		    $Thispage=1;
		}				
                printf "%s: %s - %s\n",
                  $Annotation->{data}->{fuel_type},
                  $Annotation->{data}->{fuel_ammount},
                  $Annotation->{data}->{fuel_additional_info};
            }
            if ( defined( $Annotation->{data}->{animal_type} ) &&
                 ($Annotation->{data}->{animal_type} =~ m/\Q$Regexp/i ||
                  $Annotation->{data}->{animal_amount} =~ m/\Q$Regexp/i)) {
		if($Thispage==0) {
		    print $Header;
		    $Thispage=1;
                }		
                printf "%s - %s\n", $Annotation->{data}->{animal_type},
                  $Annotation->{data}->{animal_amount};
            }
            if ( defined( $Annotation->{data}->{event} ) &&
                 $Annotation->{data}->{event} =~ m/\Q$Regexp/i) {
		if($Thispage==0) {
		    print $Header;
		    $Thispage=1;
                }		
                printf "%s\n", $Annotation->{data}->{event};
            }

        }
    }
    #if($Thispage!=0) { die; }
}
