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
my $eW = 2;    # East
my $Last_asset;

# Get all the pages (assets) 
my $assetI = $db->get_collection('assets')->find( );

while ( my $Asset = $assetI->next ) {

    #if($Asset->{done}) { push @AssetIds, $Asset->{_id}; }
    push @AssetIds, $Asset->{_id};

}

foreach my $AssetId (@AssetIds) {

    my $Asset = asset_read( $AssetId, $db );
    
    if(hasIce($Asset)==1) {

	if( defined( $Asset->{CPosition} ) && defined( $Asset->{CPosition}->{data}->{longitude} )) {
	    printf "%7.2f ", lon2n($Asset->{CPosition}->{data}->{longitude});
	}
	elsif(defined($Last_asset) && defined( $Last_asset->{CPosition} ) && 
		    defined( $Last_asset->{CPosition}->{data}->{longitude} )) {
	    printf "%7.2f ", lon2n($Last_asset->{CPosition}->{data}->{longitude});
	}
	elsif( defined( $Asset->{CPosition} ) && defined( $Asset->{CPosition}->{data}->{portlon} )) {
	    printf "%7.2f ", $Asset->{CPosition}->{data}->{portlon};
	}
	elsif(defined($Last_asset) && defined( $Last_asset->{CPosition} ) && 
		    defined( $Last_asset->{CPosition}->{data}->{portlon} )) {
	    printf "%7.2f ", $Last_asset->{CPosition}->{data}->{portlon};
	}
	else { print "     NA "; }

	if( defined( $Asset->{CPosition} ) && defined( $Asset->{CPosition}->{data}->{latitude} )) {
	    printf "%7.2f ", lat2n($Asset->{CPosition}->{data}->{latitude});
	}
	elsif(defined($Last_asset) && defined( $Last_asset->{CPosition} ) && 
		    defined( $Last_asset->{CPosition}->{data}->{latitude} )) {
	    printf "%7.2f ", lat2n($Last_asset->{CPosition}->{data}->{latitude});
	}
	elsif( defined( $Asset->{CPosition} ) && defined( $Asset->{CPosition}->{data}->{portlat} )) {
	    printf "%7.2f ", $Asset->{CPosition}->{data}->{portlat};
	}
	elsif(defined($Last_asset) && defined( $Last_asset->{CPosition} ) && 
		    defined( $Last_asset->{CPosition}->{data}->{portlat} )) {
	    printf "%7.2f ", $Last_asset->{CPosition}->{data}->{portlat};
	}
	else { print "     NA "; }

	print "\n";

   }

   $Last_asset=$Asset;		  

}

sub lat2n {
    my $ll = shift;
    my $Result;
    if($ll =~ /(\d+)\D+(\d+)/) { $Result = $1+$2/60; }
    if($ll =~ /[sS]/) { $Result *= -1; }
    return($Result);
}
sub lon2n {
    my $ll = shift;
    my $Result;
    if($ll =~ /(\d+)\D+(\d+)/) { $Result = ($1+$2/60)*-1; }
    if($ll !~ /[wW]/) { $Result *= -1; }
    return($Result);
}


sub hasIce {
    my $Asset = shift;
    foreach my $Transcription ( @{ $Asset->{transcriptions} } ) {
        foreach my $Annotation ( @{ $Transcription->{annotations} } ) {
            if ( defined( $Annotation->{data}->{event} ) ) {
                if(lc($Annotation->{data}->{event}) =~ /\sice/) { 
                   #print($Annotation->{data}->{event});
                   return(1); 
                }
            }

        }
    }
    return(0);
}
