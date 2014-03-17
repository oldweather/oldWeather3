#!/opt/local/bin/perl

#  Merge the pages per user from the two versions.

use strict;
use warnings;

my %Users;
while(<>) {
	my @Fields = split;
	$Users{$Fields[0]}+=$Fields[1];
}

foreach my $User (sort {$Users{$b} <=> $Users{$a}}(keys(%Users))) {
        printf "%s %d\n",$User,$Users{$User};
}
