#!/usr/bin/perl

# Split a long ship positions or obs file into yearly parts

use strict;
use warnings;

my %By_year;

while(my $Line = <STDIN>) {
    my $Year='NA';
    if($Line =~ /\/(\d\d\d\d).*/) { $Year=$1; }
    elsif($Line =~ /(\d\d\d\d)\-.*/) { $Year=$1; }
    else { 
      warn("No year in $Line"); 
      next;
    }
    push @{$By_year{$Year}},$Line;
}

foreach my $Year (keys(%By_year)) {
    open(DOUT,">$Year.out") or die("$Year");
    print DOUT @{$By_year{$Year}};
    close(DOUT);
}
