#!/usr/bin/perl

# Process digitised logbook data from Rodgers into
#  IMMA records.

use strict;
use warnings;
use MarineOb::IMMA;
use MarineOb::lmrlib
  qw(rxltut ixdtnd rxnddt fxeimb fxmmmb fwbpgv fxtftc ix32dd ixdcdd fxbfms
     fwbptf fwbptc);

# Get the positions
my %Positions;
open(DIN,"<positions.out") or die;
while(my $Line = <DIN>) {
    chomp($Line);
    my @Fields = split /,/,$Line;
    if($Fields[1] eq 'NA') { $Fields[1]=undef; }
    if($Fields[2] eq 'NA') { $Fields[2]=undef; }
    $Positions{$Fields[0]}=($Fields[1],$Fields[2]);
}
close(DIN);

my %Imma;
open(DIN,"<obs.out") or die;
while(my $Line = <DIN>) {
    chomp($Line);
    $Line =~ s/\"//g;
    my @Fields = split /\t/,$Line;
    if($Fields[0] eq 'NA') { next; }

    my $Ob = new MarineOb::IMMA;
    $Ob->clear();    # Why is this necessary?
    push @{ $Ob->{attachments} }, 0;
    $Ob->{YR} = substr($Fields[0],0,4);
    if($Ob->{YR}==1882) { $Ob->{YR}=1881; } # QC
    $Ob->{MO} = substr($Fields[0],5,2);
    $Ob->{DY} = substr($Fields[0],9,2);
    $Ob->{HR} = $Fields[1];
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
	$Ob->{SLP}=fxeimb{$Fields[5]}
        # Temperature correction
        if($Fields[4] ne 'NA') {
	    $Ob->{SLP} += fwbptf($Fields[5],$Fields[4])
        }
        # No gravity correction yet, don't have latitude

    push @{$Imma{sprintf("%s:%02d",$Fields[0],$Fields[1])}},$Ob;
}
close(DIN);

# Add position only obs if we have any locations without obs


foreach my $Ship (keys(%Imma)) {
    my $Fn = $Ship;
    $Fn =~ s/\s/_/g;
    open(DOUT,">../../imma/$Fn") or die "Can't open output for $Fn";
    @{$Imma{$Ship}} = sort imma_by_date @{$Imma{$Ship}}; 
    foreach my $Ob (@{$Imma{$Ship}}) {
	$Ob->write(\*DOUT);
    }
    close(DOUT);
}

sub imma_by_date {
    return($a->{YR} <=> $b->{YR} ||
           $a->{MO} <=> $b->{MO} ||
           $a->{DY} <=> $b->{DY} ||
	   $a->{HR} <=> $b->{HR});
}
