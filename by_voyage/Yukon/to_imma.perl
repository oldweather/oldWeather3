#!/usr/bin/perl

# Process digitised logbook data from Yukon into
#  IMMA records.

use strict;
use warnings;
use MarineOb::IMMA;
use MarineOb::lmrlib
  qw(rxltut ixdtnd rxnddt fxeimb fxmmmb fwbpgv fxtftc ix32dd ixdcdd fxbfms
     fwbptf fwbptc);
use Date::Calc qw(check_date check_time Delta_DHMS);

my $Name='Unalga_II';
my $Last_lat=37.8;
my $Last_lon=-122.4;
my $Last_pre_inches=29;
my $Last_date;

# Get the positions
my %Positions;
open(DIN,"<positions.qc.out") or die;
while(my $Line = <DIN>) {
    chomp($Line);
    my @Fields = split /\t/,$Line;
    if(!defined($Fields[0]) || $Fields[0] =~ /NA/) { next; }
    unless($Fields[0] =~ /(\d+)\/(\d+)\/(\d\d\d\d)/) { die "Bad date $Fields[0]"; }
    $Fields[0] = sprintf "%04d-%02d-%02d",$3,$2,$1;
    for(my $i=0;$i<=4;$i++) {
        if($Fields[$i] eq 'NA') { $Fields[$i]=undef; }
    }
    if(defined($Fields[1]) && $Fields[1] =~ /(\d+)\D+(\d+)/) {
	$Positions{$Fields[0]}[0]=$1+$2/60;
    }
    elsif(defined($Fields[3]) && $Fields[3] =~ /\d+/) {
       $Positions{$Fields[0]}[0]=$Fields[3];
    }
    if(defined($Fields[2]) && $Fields[2] =~ /(\d+)\D+(\d+)/) {
	$Positions{$Fields[0]}[1]=($1+$2/60)*-1;
        if($Fields[2] =~ /[Ee]/) { $Positions{$Fields[0]}[1]*= -1; }
    }
    elsif(defined($Fields[4]) && $Fields[4] =~ /\d+/) {
       $Positions{$Fields[0]}[1]=$Fields[4];
    }
}
close(DIN);

my @Imma;
open(DIN,"<obs.qc.out") or die;
while(my $Line = <DIN>) {
    chomp($Line);
    $Line =~ s/\"//g;
    if($Line =~ /NA\s+NA\s+NA\s+NA/) { next; } # No obs.
    my @Fields = split /\t/,$Line;
    if(!defined($Fields[0]) || $Fields[0] =~ /NA/) { next; }

    my $Ob = new MarineOb::IMMA;
    $Ob->clear();    # Why is this necessary?
    push @{ $Ob->{attachments} }, 0;
    $Ob->{ID}=$Name;
    if($Fields[0] =~ /NA/) {
	$Fields[0]=$Last_date;
    } else {
	$Last_date=$Fields[0];
    }
    $Ob->{YR} = substr($Fields[0],0,4);
    $Ob->{MO} = substr($Fields[0],5,2);
    $Ob->{DY} = substr($Fields[0],8,2);
    $Ob->{HR} = $Fields[1];
    if(!check_date($Ob->{YR},$Ob->{MO},$Ob->{DY})) {
	warn $Line;
        die;
    }
    if($Ob->{HR}==24) { $Ob->{HR}=23.99; }
    # Still in local time - don't yet have longitude
    if(defined($Positions{$Fields[0]}) && $Ob->{HR}==12) {
      $Ob->{LAT} = $Positions{$Fields[0]}[0];
      $Ob->{LON} = $Positions{$Fields[0]}[1];
      delete($Positions{$Fields[0]});
    }
    if($Fields[2] ne 'NA') {
       $Ob->{AT} = fxtftc($Fields[2]);
    }
    if($Fields[3] ne 'NA') {
       $Ob->{SST} = fxtftc($Fields[3]);
    }
    if($Fields[5] ne 'NA' ) {
        if($Fields[5]>2800) { $Fields[5]/=100; } # Omitted decimal point
        # sometimes they only give the last two digits of the pressure
        if($Fields[5] =~ /(\d\d)\.\d\d/) { $Last_pre_inches=$1; }
        if($Fields[5] !~ /\./ && $Fields[5]<100) {
	    $Fields[5]=sprintf "%02d\.%02d",$Last_pre_inches,$Fields[5];
        }
        # Temperature correction
        if($Fields[4] ne 'NA') {
	    $Fields[5] += fwbptf($Fields[5],$Fields[4]);
        }
	$Ob->{SLP}=fxeimb($Fields[5]);
        # No gravity correction yet, don't have latitude
    }
    push @Imma,$Ob;
}
close(DIN);

# Add position only obs if we have any locations without obs
foreach my $Date (keys(%Positions)) {
    my $Ob = new MarineOb::IMMA;
    $Ob->clear();
    push @{ $Ob->{attachments} }, 0;
    $Ob->{ID}=$Name;
    $Ob->{YR} = substr($Date,0,4);
    $Ob->{MO} = substr($Date,5,2);
    $Ob->{DY} = substr($Date,8,2);
    $Ob->{HR} = 12;
    $Ob->{LAT} = $Positions{$Date}[0];
    $Ob->{LON} = $Positions{$Date}[1];
    push @Imma,$Ob;
}

@Imma= sort imma_by_date @Imma;

# Interpolate latitudes
fill_gaps('LAT');
fill_gaps('LON');
#for(my $i=0;$i<100;$i++) {
#   if($Imma[$i]->{YR}==1879 && $Imma[$i]->{MO}==6 &&
#      !defined($Imma[$i]->{LAT})) {
#       $Imma[$i]->{LAT} = 38.1;
#       $Imma[$i]->{LON} = -122.3;
#   }
#}

# Now we've got positions - convert the dates to UTC
my $elon;
for(my $i=0;$i<scalar(@Imma);$i++) {
    # They did not change day until July 19
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
}
# and gravity-correct the pressures
for(my $i=0;$i<scalar(@Imma);$i++) {
    if(defined($Imma[$i]->{LAT}) && defined($Imma[$i]->{SLP})) {
       $Imma[$i]->{SLP} += fwbpgv( $Imma[$i]->{SLP}, $Imma[$i]->{LAT}, 2 );
    }
}

# Done - output the new obs
for(my $i=0;$i<scalar(@Imma);$i++) {
    $Imma[$i]->write(\*STDOUT);
}


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
