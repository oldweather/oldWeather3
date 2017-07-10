#!/usr/bin/perl

# Process digitised logbook data from Concord into
#  IMMA records.

use strict;
use warnings;
use MarineOb::IMMA;
use MarineOb::lmrlib
  qw(rxltut ixdtnd rxnddt fxeimb fxmmmb fwbpgv fxtftc ix32dd ixdcdd fxbfms
     fwbptf fwbptc);
use Date::Calc qw(check_date check_time Delta_DHMS);
use FindBin;

my $Name='Pioneer';
my $Last_lat=37.8;
my $Last_lon=-122.4;
my $Last_pre_inches=29;
my $Last_date;
my %Positions;
my @Imma;

# Read in the dates
my %Dates;
open(DIN,"$FindBin::Bin/dates.qc") or die;
while (my $Line = <DIN>) {
    chomp $Line;
    my @fields = split /\t/,$Line;
    $Date{$fields[0]}=$fields[2];
}
close(DIN);

# Read in the positions
my %Latitudes;
my %Longitudes;
open(DIN,"$FindBin::Bin/positions.qc") or die;
while (my $Line = <DIN>) {
    chomp $Line;
    my @fields = split /\t/,$Line;
    $Latitudes{$fields[0]}=$fields[2];
    $Longitudes{$fields[0]}=$fields[3];
}
close(DIN);

# Process the obs
open(DIN,"$FindBin::Bin/obs.raw") or die;
while (my $Line = <DIN>) {
    chomp $Line;
    my @fields = split /\t/,$Line;
    my $Asset=$fields[0];
    my $Hour =$fields[1];
    
    # Is there any data for this line? A Date, position, or obs?
    if(defined($Date{$Asset})                      ||
       (defined($Latitudes{$Asset}) && $Hour==12)  ||
       (defined($Longitudes{$Asset}) && $Hour==12) ||
       defined($fields[2])                         ||  #AT
       defined($fields[5])) {                          #SLP
	
	my $Ob = new MarineOb::IMMA;
	$Ob->clear();    # Why is this necessary?
	push @{ $Ob->{attachments} }, 0;
	$Ob->{ID}=$Name;

        # Date - In ship's time at this point
        if(defined($Date{$Asset})) {
	    unless($Date{$Asset} =~ /(\d\d)\D(\d\d)\D(\d\d\d\d))/) {
		die("Bad date $Date{$Asset}");
	    }
            $Ob->{YR} = $3;
            $Ob->{MO} = $2;
            $Ob->{DY} = $1;
            $Ob->{HR} = $Hour;
	}

        # Positions
        if($Hour==12) {
            if(defined($Latitudes{$Asset})) {
		$Ob->{LAT} = $Latitudes{$Asset};
                $Last_lat = $Ob->{LAT};
	    }
            if(defined($Longitudes{$Asset})) {
		$Ob->{LON} = $Longitudes{$Asset};
                $Last_lon = $Ob->{LON};
	    }
	}

        # Air temperature
	if($Fields[2] ne 'NA') {
	   $Ob->{AT} = fxtftc($Fields[2]);
	}

        # SST
	if($Fields[3] ne 'NA') {
	   $Ob->{SST} = fxtftc($Fields[3]);
	}

        # Pressure
	if($Fields[5] ne 'NA' ) {
	    if($Fields[5]>2800) { $Fields[5]/=100; } # Omitted decimal point
            if($Fields[5] =~ /(\d\d)\D(\d+)/) {
		$Fields[5] = sprintf "%02d\.%02d",$1,$2;
                $Last_pre_inches=$1;
            }
            elsif ($Fields[5] =~ /(\d\d)/) { # Tenths and hundredths only
		$Fields[5]=sprintf "%02d\.%02d",$Last_pre_inches,$1;
	    }
            
	    # Temperature correction
	    if($Fields[4] ne 'NA') {
		$Fields[5] += fwbptf($Fields[5],$Fields[4]);
	    }
	    $Ob->{SLP}=fxeimb($Fields[5]);

	    # No gravity correction yet, don't have latitude

        }
	push @Imma,$Ob;
    } # End of ob line
} # End of obs.

# Sort into date order
@Imma= sort imma_by_date @Imma;

# Interpolate positions
fill_gaps('LAT');
fill_gaps('LON');

# Now we've got positions - convert the dates to UTC
my $elon;
for(my $i=0;$i<scalar(@Imma);$i++) {
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
}

# Now every ob has a latitude, gravity correct the pressures
for(my $i=0;$i<scalar(@Imma);$i++) {
    if(defined($Imma[$i]->{LAT}) && defined($Imma[$i]->{SLP})) {
       $Imma[$i]->{SLP} += fwbpgv( $Imma[$i]->{SLP}, $Imma[$i]->{LAT}, 2 );
    }
}

# Done - output the new obs
open(DOUT,sprintf ">%s.imma",$Name) or die;
for(my $i=0;$i<scalar(@Imma);$i++) {
    $Imma[$i]->write(\*DOUT);
}
close(DOUT);


sub imma_by_date {
    return($a->{YR} <=> $b->{YR} ||
           $a->{MO} <=> $b->{MO} ||
           $a->{DY} <=> $b->{DY} ||
	   $a->{HR} <=> $b->{HR});
}

# Check that a record has a good date & time
sub IMMA_check_date {
    my $Ob = shift;
    if(defined( $Ob->{YR}) &&
       defined( $Ob->{MO}) &&
       defined( $Ob->{DY}) &&
       defined( $Ob->{HR}) &&
       check_date($Ob->{YR},$Ob->{MO},$Ob->{DY}) &&
       check_time(int($Ob->{HR}/100),30,30)) { return(1); }
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
        if ( defined( $Imma[$j]->{$Var}) &&
             IMMA_check_date($Imma[$j])) { return($j); }
    }
    return;
}
# Find the next subsequent ob that has a valid date and
#  value of $Var;
sub find_next {
    my $Var = shift;
    my $Point = shift;
    for ( my $j = $Point + 1 ; $j < scalar(@Imma) ; $j++ ) {
        if ( defined( $Imma[$j]->{$Var}) &&
             IMMA_check_date($Imma[$j])) { return($j); }
    }
   return;
}

sub fill_gaps {
    my $Var = shift;
    for ( my $i = 0 ; $i < scalar(@Imma) ; $i++ ) {
	if ( defined( $Imma[$i]->{$Var} ) ) {
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
    if (
        IMMA_Delta_Seconds( $Previous, $Next ) > $Max_days*86400
        && (   abs( $Previous->{LON} - $Next->{LON} ) > 5
            || abs( $Previous->{LAT} - $Next->{LAT} ) > 5 )
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
