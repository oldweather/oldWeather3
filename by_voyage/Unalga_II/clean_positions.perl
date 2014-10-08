#!/usr/bin/perl

# Process digitised logbook data from Corwin into
#  IMMA records.

use strict;
use warnings;

#open(DIN,"<positions.out") or die;
my @Lines = <STDIN>;
#close(DIN);

# Find all the dates for which there is a lat:lon position
my %Ll;
for(my $i=0;$i<scalar(@Lines);$i++) {
    my $Line = $Lines[$i];
    chomp($Line);
    my @Fields = split /\t/,$Line;
    if(!defined($Fields[0]) || $Fields[0] =~ /NA/) { next; }
    if((defined($Fields[1]) && $Fields[1] =~ /(\d+)\D+(\d+)/) ||
       (defined($Fields[2]) && $Fields[2] =~ /(\d+)\D+(\d+)/) ) {
	$Ll{$Fields[0]}=1;
    }
}

# Weed out duplicate dates for which there is a good Ll position, and
#  infereed port pstitions which are not credible
#open(DOUT,">positions.qc.out") or die;
for(my $i=0;$i<scalar(@Lines);$i++) {
    my $Line = $Lines[$i];
    chomp($Line);
    my @Fields = split /\t/,$Line;
    if(defined($Ll{$Fields[0]})) {
       if((defined($Fields[1]) && $Fields[1] =~ /(\d+)\D+(\d+)/) ||
          (defined($Fields[2]) && $Fields[2] =~ /(\d+)\D+(\d+)/) ) {
	   printf "%s\t%s\t%s\t      NA\t      NA\t      NA\n",
               $Fields[0],$Fields[1],$Fields[2];
       }
       next;
    }
    else {
     if($Fields[6] eq '                      tic' ||
        $Fields[6] eq '                    horta' ||
        $Fields[6] eq '                  behring' ||
        $Fields[6] eq '                      goa' ||
        $Fields[6] eq '                    horta' ||
        $Fields[6] eq '                     nice' ||
        $Fields[6] eq '                      gib' ||
        $Fields[6] eq '                port said' ||
        $Fields[6] eq '                   port t') { next; }
     print "$Line\n";
    }
}  
#close(DOUT);
 
