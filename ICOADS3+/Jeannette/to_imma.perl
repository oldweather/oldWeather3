#!/usr/bin/perl

# Process digitised logbook data from Manning into
#  IMMA records.

use strict;
use warnings;
use lib "$ENV{HOME}/Projects/IMMA/Perl";
use MarineOb::IMMA;
use MarineOb::lmrlib
  qw(rxltut ixdtnd rxnddt fxeimb fxmmmb fwbpgv fxtftc ix32dd ixdcdd fxbfms
     fwbptf fwbptc);
use Date::Calc qw(check_date check_time Delta_DHMS);
use FindBin;
use Data::Dumper;
use Clone qw(clone);

my $Name='Jeannette';
my $Last_lat=38.1;
my $Last_lon=-122.3;
my $Last_pre_inches=29;
my $Last_date;
my @Imma;

# Read in the dates
my %Dates;
my %ODates;
open(DIN,"$FindBin::Bin/dates.qc") or die;
while (my $Line = <DIN>) {
    chomp $Line;
    my @fields = split /\t/,$Line;
    if($fields[2] =~ /\d\d\D\d\d\D\d\d\d\d/) { $Dates{$fields[0]}=$fields[2];  }
    if($fields[1] =~ /\d\d\D\d\d\D\d\d\d\d/) { $ODates{$fields[0]}=$fields[1]; }
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
    $orig =~ s/^\s+//; # strip leading spaces
    my @of = split /\s+/,$orig;
    my $result='';
    if(defined($of[0]) && $of[0] =~ /([\d\+\.\-]+)/) {
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

# Read in the positions
# Read in the positions
my %Latitudes;
my %Longitudes;
open(DIN,"$FindBin::Bin/positions.out.olddates") or die;
while (my $Line = <DIN>) {
    chomp $Line;
    my @fields = split /,/,$Line;
    if($fields[1] ne 'NA') { $Latitudes{$fields[0]}=$fields[1]; }
    if($fields[2] ne 'NA') { $Longitudes{$fields[0]}=$fields[2]; }
}
close(DIN);

sub latitude_from_asset {
    my $AssetID = shift;
    unless(defined($ODates{$AssetID})) { return; }
    $ODates{$AssetID} =~ /(\d\d)\D(\d\d)\D(\d\d\d\d)/;
    my $Key = sprintf "%04d-%02d-%02d",$3,$2,$1;
    unless(defined($Latitudes{$Key})) { return; }
    return $Latitudes{$Key};
}
sub longitude_from_asset {
    my $AssetID = shift;
    unless(defined($ODates{$AssetID})) { return; }
    $ODates{$AssetID} =~ /(\d\d)\D(\d\d)\D(\d\d\d\d)/;
    my $Key = sprintf "%04d-%02d-%02d",$3,$2,$1;
    unless(defined($Longitudes{$Key})) { return; }
    return $Longitudes{$Key};
}

my %Seen;
sub position_only {
    my $Asset = shift;
    unless(defined($Dates{$Asset})) { return 0; }
    $Dates{$Asset} =~ /(\d\d)\D(\d\d)\D(\d\d\d\d)/;  
    if($Seen{sprintf "%04d%02d%02d12",$3,$2,$1}) { return 0; }
    return 1;
}
       
# Process the obs
open(DIN,"$FindBin::Bin/obs.raw") or die;
while (my $Line = <DIN>) {
    chomp $Line;
    my @fields = split /\t/,$Line;
    my $Asset=$fields[0];
    my $Hour =$fields[1];
    
    # Is there any data for this line? A position, or obs?
    my $ALat=latitude_from_asset($Asset);
    my $ALon=longitude_from_asset($Asset);
    if($fields[2] ne 'NA'                           ||  #AT
       $fields[3] ne 'NA'                           ||  #SST
       $fields[5] ne 'NA') {
	
	my $Ob = new MarineOb::IMMA;
	$Ob->clear();    # Why is this necessary?
	push @{ $Ob->{attachments} }, 0;
	$Ob->{ID}=$Name;

        # Date - In ship's time at this point
        if(defined($Dates{$Asset})) {
	    unless($Dates{$Asset} =~ /(\d\d)\D(\d\d)\D(\d\d\d\d)/) {
		die("Bad date $Dates{$Asset}");
	    }
	    unless(check_date($3,$2,$1)) {
		die "Bad date $Dates{$Asset}";
	    }
            $Ob->{YR} = $3;
            $Ob->{MO} = $2;
            $Ob->{DY} = $1;
            $Ob->{HR} = $Hour;
	    if($Hour==24) { $Ob->{HR}=23.99; }
	}

        # Positions
        if($Hour==12) {
            if(defined($ALat)) {
		$Ob->{LAT} = $ALat;
	    }
            if(defined($ALon)) {
		$Ob->{LON} = $ALon;
	    }
	}

        # Air temperature
	if($fields[2] ne 'NA') {
	   $Ob->{AT} = fxtftc($fields[2]);
	}

        # SST
	if($fields[3] ne 'NA') {
	   $Ob->{SST} = fxtftc($fields[3]);
	}

        # Pressure
	if($fields[5] ne 'NA' ) {
	    if($fields[5]>2800) { $fields[5]/=100; } # Omitted decimal point
            if($fields[5] =~ /(\d\d)\D(\d+)/) {
		$fields[5] = sprintf "%02d\.%02d",$1,$2;
                $Last_pre_inches=$1;
            }
            elsif ($fields[5] =~ /(\d\d)/) { # Tenths and hundredths only
		$fields[5]=sprintf "%02d\.%02d",$Last_pre_inches,$1;
	    }
            
	    # Temperature correction
	    if($fields[4] ne 'NA') {
		$fields[5] += fwbptf($fields[5],$fields[4]);
	    }
	    $Ob->{SLP}=fxeimb($fields[5]);

	    # No gravity correction yet, don't have latitude

        }

	# Add the asset ID for tracebility
	$Ob->{ATTC}++;
        push @{ $Ob->{attachments} }, 99;
        $Ob->{ATTE} = undef;
        $Ob->{SUPD} = $Asset;

	$Seen{sprintf "%04d%02d%02d%02d",$Ob->{YR},$Ob->{MO},$Ob->{DY},$Ob->{HR}}=1;
	push @Imma,$Ob;
    } # End of ob line
} # End of obs.
# Sort into date order
@Imma= sort imma_by_date @Imma;

# Interpolate positions
my @Imma_old=@{clone(\@Imma)};
fill_gaps('LAT');
fill_gaps('LON');

# Now we've got positions - convert the dates to UTC
my $elon;
for(my $i=0;$i<scalar(@Imma);$i++) {
    if(!defined($Imma[$i]->{YR}) ||
       !defined($Imma[$i]->{MO}) ||
       !defined($Imma[$i]->{DY}) ||
       !defined($Imma[$i]->{HR})) {
	    $Imma[$i]->{YR} = undef;
	    $Imma[$i]->{MO} = undef;
	    $Imma[$i]->{DY} = undef;
	    $Imma[$i]->{HR} = undef;
            next;
    }      	
    # They did not change day until July 19 in 1881
    if($Imma[$i]->{YR}==1881 && $Imma[$i]->{MO}==7 &&
       $Imma[$i]->{DY} && $Imma[$i]->{DY}<19) {
	$Imma[$i]->{DY}++;
    }
    if(defined($Imma[$i]->{LON})) { $Last_lon=$Imma[$i]->{LON};}
    $elon=$Last_lon;
    if ( $elon < 0 ) { $elon += 360; }
    my ( $uhr, $udy ) = rxltut(
	$Imma[$i]->{HR} * 100,
	ixdtnd( $Imma[$i]->{DY}, $Imma[$i]->{MO}, $Imma[$i]->{YR} ),
	$elon * 100
    );
    $Imma[$i]->{HR} = $uhr / 100;
    ( $Imma[$i]->{DY}, $Imma[$i]->{MO}, $Imma[$i]->{YR} ) = rxnddt($udy);
    # When they crossed the dateline they did not change date
    # But the conversion assumes they did - So we need to go forward a day.
    if($Last_lon>0) {
	($Imma[$i]->{YR},$Imma[$i]->{MO},$Imma[$i]->{DY})=
             Add_Delta_Days($Imma[$i]->{YR},$Imma[$i]->{MO},$Imma[$i]->{DY},1);
    }      
}

# Now every ob has a latitude, gravity correct the pressures
for(my $i=0;$i<scalar(@Imma);$i++) {
    if(defined($Imma[$i]->{LAT}) && defined($Imma[$i]->{SLP})) {
       $Imma[$i]->{SLP} += fwbpgv( $Imma[$i]->{SLP}, $Imma[$i]->{LAT}, 2 );
    }
}

# Done - output the new obs
open(DOUT,sprintf ">../../imma_3+/%s.imma",$Name) or die;
for(my $i=0;$i<scalar(@Imma);$i++) {
    $Imma[$i]->write(\*DOUT);
}
close(DOUT);


sub imma_by_date {
    my $aYR = defined($a->{YR}) ? $a->{YR} : 0;
    my $bYR = defined($b->{YR}) ? $b->{YR} : 0;
    my $aMO = defined($a->{MO}) ? $a->{MO} : 0;
    my $bMO = defined($b->{MO}) ? $b->{MO} : 0;
    my $aDY = defined($a->{DY}) ? $a->{DY} : 0;
    my $bDY = defined($b->{DY}) ? $b->{DY} : 0;
    my $aHR = defined($a->{HR}) ? $a->{HR} : 0;
    my $bHR = defined($b->{HR}) ? $b->{HR} : 0;
    return($aYR <=> $bYR ||
           $aMO <=> $bMO ||
           $aDY <=> $bDY ||
	   $aHR <=> $bHR);
}

# Check that a record has a good date & time
sub IMMA_check_date {
    my $Ob = shift;
    if(defined( $Ob->{YR}) &&
       defined( $Ob->{MO}) &&
       defined( $Ob->{DY}) &&
       defined( $Ob->{HR}) &&
       check_date($Ob->{YR},$Ob->{MO},$Ob->{DY})) { return(1); }
    return;
}
# Difference between 2 records in seconds
sub IMMA_Delta_Seconds {
    my $First = shift;
    my $Last  = shift;
    my ( $Dd, $Dh, $Dm, $Ds ) = Delta_DHMS(
        $First->{YR},
        $First->{MO},
        $First->{DY},
        int( $First->{HR} ),
        int( ( $First->{HR} - int( $First->{HR} ) ) * 60 ),
        0,
        $Last->{YR},
        $Last->{MO},
        $Last->{DY},
        int( $Last->{HR} ),
        int( ( $Last->{HR} - int( $Last->{HR} ) ) * 60 ),
        0
    );
    return $Dd * 86400 + $Dh * 3600 + $Dm * 60 + $Ds;
}

# Find the last previous ob that has a date
sub find_previous {
    my $Var = shift;
    my $Point = shift;
    for ( my $j = $Point - 1 ; $j >= 0 ; $j-- ) {
        if ( defined( $Imma_old[$j]->{$Var}) &&
             IMMA_check_date($Imma_old[$j])) { return($j); }
    }
    return;
}
# Find the next subsequent ob that has a valid date and
#  value of $Var;
sub find_next {
    my $Var = shift;
    my $Point = shift;
    for ( my $j = $Point + 1 ; $j < scalar(@Imma_old) ; $j++ ) {
        if ( defined( $Imma_old[$j]->{$Var}) &&
             IMMA_check_date($Imma_old[$j])) { return($j); }
    }
   return;
}

sub fill_gaps {
    my $Var = shift;
    for ( my $i = 0 ; $i < scalar(@Imma_old) ; $i++ ) {
	if ( defined( $Imma_old[$i]->{$Var} ) ) {
	    next;
	}
	my $Previous = find_previous($Var,$i);
	my $Next     = find_next($Var,$i);
	if (   defined($Previous)
	    && defined($Next) )
	{
	    $Imma[$i]->{$Var} = interpolate( $Var, $Imma[$Previous],
                                                   $Imma[$Next],
                                                   $Imma[$i],
                                             30,100);
	}
    }
}

sub interpolate {
    my $Var      = shift;
    my $Previous = shift;
    my $Next     = shift;
    my $Target   = shift;
    my $Max_days = shift;
    my $Max_var  = shift;

    # Give up if the gap is too long
    if ( !defined($Previous) || !defined($Next) ||
	 !defined($Previous->{$Var}) || !defined($Next->{$Var}) ||
         (IMMA_Delta_Seconds( $Previous, $Next ) > $Max_days*86400)
      )
    {
        return;
    }

    # Deal with any logitude wrap-arounds
    my $Next_var = $Next->{$Var};
    if( $Var eq 'LON') {
       if ( $Next_var - $Previous->{LON} > 180 ) { $Next_var -= 360; }
       if ( $Next_var - $Previous->{LON} < -180 ) { $Next_var += 360; }
    }

    # Give up if the separation is too great
    if (   abs( $Next_var - $Previous->{$Var} ) > $Max_var ) { return; }

    # Do the interpolation
    if ( IMMA_Delta_Seconds( $Target, $Next ) <= 0 ) { return; }
    if ( IMMA_Delta_Seconds( $Previous, $Next ) <= 0 ) { return; }
    my $Weight = IMMA_Delta_Seconds( $Target, $Next ) / 
                 IMMA_Delta_Seconds( $Previous, $Next );
    if ( $Weight < 0 || $Weight > 1 ) { return ( undef, undef ); }
    my $Target_var = $Next_var * ( 1 - $Weight ) + $Previous->{$Var} * $Weight;
    if( $Var eq 'LON') {
       if ( $Target_var < -180 ) { $Target_var += 360; }
       if ( $Target_var > 180 ) { $Target_var -= 360; }
    }
    return ( $Target_var );
}
