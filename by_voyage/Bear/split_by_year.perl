#!/usr/bin/perl

# Split a long ship positions or obs file into yearly parts
# specific to the Bear.

use strict;
use warnings;

my %By_year;

while(my $Line = <STDIN>) {
    $Line =~ s/1907\-04\-23/1884\-07\-27/; # fix dud date
    $Line =~ s/23\/4\/1907/27\/07\/1884/;
    my $Year='NA';
    if($Line =~ /(\d\d\d\d).*/) { $Year=$1; }
    if($Year ne 'NA' && $Year==1820) {
	$Year=1894;
        $Line =~ s/1820/1894/;
    }
    push @{$By_year{$Year}},$Line;
}

foreach my $Year (keys(%By_year)) {
    open(DOUT,">$Year.out") or die;
    print DOUT @{$By_year{$Year}};
    close(DOUT);
}
