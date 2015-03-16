#!/usr/bin/perl -w

# Take the Jeannette positions from the IMMA file and output them in 
#  plain text format.

use strict;
use warnings;
use MarineOb::IMMA;

while( my $Ob=imma_read(\*STDIN) ) {
    printf "%04d-%02d-%02d-%02d\t",$Ob->{YR},$Ob->{MO},$Ob->{DY},$Ob->{HR};
    if(defined($Ob->{LAT})) {
	printf "%5.1f\t",$Ob->{LAT};
    } else {
        print "   NA\t";
    }
    if(defined($Ob->{LON})) {
	printf "%6.1f\n",$Ob->{LON};
    } else {
        print "    NA\n";
    }
}
