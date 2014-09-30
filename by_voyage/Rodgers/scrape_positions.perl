#!/usr/bin/perl

# Get dates and positions from edited ship history

use strict;
use warnings;
use Data::Dumper;

my %mon2num = qw(
  jan 1  feb 2  mar 3  apr 4  may 5  jun 6
  jul 7  aug 8  sep 9  oct 10 nov 11 dec 12
);

my $nhn=`curl http://www.naval-history.net/OW-US/Rodgers/USS_Rodgers-1881.htm`;
$nhn =~ s/\n/ /gm; # strip newlines
my @nhn = split /\<\/p\>/,$nhn; # split on paragraphs

my %Lat;
my %Lon;
my $Date;

for(my $i=0;$i<scalar(@nhn);$i++) {

    if($nhn[$i] =~ /(\d+)\s+(\w+)\s+(\d\d\d\d)/) {
        my $Mn = $mon2num{lc(substr($2,0,3))};
	$Date = sprintf "%04d-%02d-%02d",$3,$Mn,$1;
        #print "$Date\n";
    }
    if($nhn[$i] =~ /Lat (\-*\d+\.*\d*)/) {
        $Lat{$Date} = $1;
    }
    if($nhn[$i] =~ /Long (\-*\d+\.*\d*)/) {
        $Lon{$Date} = $1;
        unless(defined($Lat{$Date})) { $Lat{$Date} = undef; }
    }
}
foreach $Date (sort(keys(%Lat))) {
    unless(defined($Lat{$Date})) { $Lat{$Date}='NA'; }
    unless(defined($Lon{$Date})) { $Lon{$Date}='NA'; }
    printf "%s,%s,%s\n",$Date,$Lat{$Date},$Lon{$Date};
}
