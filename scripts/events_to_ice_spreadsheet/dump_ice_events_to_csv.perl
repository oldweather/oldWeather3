#!/opt/local/bin/perl

# Dump page data and ice events in a simple spreadsheet format

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

# Make the output directories
my $Ship_dir = $Ship_name;
$Ship_dir =~ s/\s+/_/g;
$Ship_dir =~ s/[\(\)]//g;
my $Dir = sprintf( "%s/../../asset_files/%s/voyage_%03d",
    $FindBin::Bin, $Ship_dir, $VoyageN );
unless ( -d $Dir ) {
    system("mkdir -p $Dir");
}

# Keep " for csv format - replace them in strings with '
# Also get rid of any internal newlines
sub unquote {
    my $qstr=shift;
    $qstr =~ s/\"/\'/g;
    $qstr =~ s/\n/ /g;
    return($qstr)
}

#Default hemisphere flags
my $nS = 1;    # North
my $eW = 1;    # East

if ( !defined($Id) ) {

    # Get the ship record
    my $ships = $db->get_collection('ships')->find( { "name" => $Ship_name } )
      or die "No such ship: $Ship_name";
    my $Ship = $ships->next;    # Assume there's only one

    my $voyageI =
      $db->get_collection('voyages')->find( { "ship_id" => $Ship->{_id} } );

    my $Voyage;
    my $Count = 0;
    while ( $Count++ < $VoyageN ) { $Voyage = $voyageI->next; }

    # Get all the pages (assets) for this voyage
    my $assetI =
      $db->get_collection('assets')->find( { "voyage_id" => $Voyage->{_id} } );

    while ( my $Asset = $assetI->next ) {

        #if($Asset->{done}) { push @AssetIds, $Asset->{_id}; }
        push @AssetIds, $Asset->{_id};

    }
}
else {    # only one id - for debugging
    push @AssetIds, MongoDB::OID->new( value => $Id );
}

foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );

    print "$Asset->{_id},";
    print "\"$Asset->{location}\",";

    if ( defined( $Asset->{CDate}->{data}->{date} ) ) {
        printf "\"%s\",",unquote($Asset->{CDate}->{data}->{date});
    } else {
	print ",";
    }

    if ( defined( $Asset->{CPosition} ) ) {
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
        if ( defined( $Asset->{CPosition}->{data}->{$LatSource} )
            && length( $Asset->{CPosition}->{data}->{$LatSource} ) > 2 )
        {
            printf "Lat %s ", $Asset->{CPosition}->{data}->{$LatSource};
        }
        if ( defined( $Asset->{CPosition}->{data}->{$LonSource} )
            && length( $Asset->{CPosition}->{data}->{$LonSource} ) > 2 )
        {
            printf "Lon %s ", $Asset->{CPosition}->{data}->{$LonSource};
        }
        if ( defined( $Asset->{CPosition}->{data}->{port} )
            && length( $Asset->{CPosition}->{data}->{port} ) > 2 )
        {
            printf "%s ", unquote($Asset->{CPosition}->{data}->{port});
        }
    }
    print ",";
    print "\"";
    foreach my $Transcription ( @{ $Asset->{transcriptions} } ) {
         foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
            if ( defined( $Annotation->{data}->{undefined} ) ) {
                printf "%s | ",
                  unquote($Annotation->{data}->{undefined});
            }
            if ( defined( $Annotation->{data}->{mention_type} ) ) {
                printf "%s - %s | ",
                  unquote($Annotation->{data}->{mention_name}),
                  unquote($Annotation->{data}->{mention_context});
            }
            if ( defined( $Annotation->{data}->{fuel_type} ) ) {
                printf "%s: %s - %s | ",
                  unquote($Annotation->{data}->{fuel_type}),
                  unquote($Annotation->{data}->{fuel_ammount}),
                  unquote($Annotation->{data}->{fuel_additional_info});
            }
            if ( defined( $Annotation->{data}->{animal_type} ) ) {
                printf "%s - %s | ",
                  unquote($Annotation->{data}->{animal_type}),
                  unquote($Annotation->{data}->{animal_amount});
            }
            if ( defined( $Annotation->{data}->{event} ) ) {
                printf "%s | ",
                  unquote($Annotation->{data}->{event});
            }

        }
    }
    print "\",\n"
}
