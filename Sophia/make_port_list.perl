#!/usr/bin/env perl

# Take the position series Sophia made and make a list of
#  port name - corrected position pairs for each ship.

use FindBin;
use strict;
use warnings;

my @SFiles=glob("$FindBin::Bin/csv/*.csv");

# Convert '12 34 56 N' latitudes to the decimal equivalent
sub ll_to_dec {
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

# Get the corrected positions for each ship.
my (@port,@lat,@lon,@rawlat,@rawlon);
foreach my $Cfile (@SFiles) {
    open DIN, $Cfile or die "Can't open $Cfile";
    while (my $Line = <DIN>) {
	chomp $Line;
        my @fields = split /,/,$Line;
        if(defined($fields[5]) && $fields[5]=~ /\w/ &&
           defined($fields[8]) && $fields[8]=~ /\w/ &&
           defined($fields[9]) && $fields[9]=~ /\w/) {
           # Sophia has added a correction, store it
	    push @port,$fields[5];
	    push @rawlat,$fields[8];
	    push @rawlon,$fields[9];
            push @lat,ll_to_dec($fields[8]);
            push @lon,ll_to_dec($fields[9]);
	}
    }
}

# Output the positions
open(DOUT,">S.positions.tsv") or die;
for(my $i=1;$i<scalar(@port);$i++) {
    printf DOUT "%s\t%s\t%s\t%s\t%s\n",$port[$i],$rawlat[$i],
                               $lat[$i],$rawlon[$i],$lon[$i];
}

            
