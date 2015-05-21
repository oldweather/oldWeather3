#!/usr/bin/perl

# Fix and standardise dates strings in Perry's pages

use strict;
use warnings;
use Date::Calc qw(check_date Add_Delta_Days);

my @Today=(1895,5,19); # Start date
my @Tomorrow=(1895,5,20);

my %Positions;
my %New_places;
my $Lon_flag='W';
my $Lat_flag='N';

while(my $Line = <>) {
    chomp($Line);
    my @Fields = split /\t/,$Line;
    unless($Fields[0] =~ /(\d+)\D+(\d+)\D+(\d+)/) {
	die "Bad date format $Fields[0]";
    }
    my $Dstring;
    if($3==$Today[0] &&
      ($2==$Today[1] && $1==$Today[2]) ||
      ($2==$Today[2] && $1==$Today[1])) {
	  $Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
    elsif($3==$Tomorrow[0] &&
      ($2==$Tomorrow[1] && $1==$Tomorrow[2]) ||
      ($2==$Tomorrow[2] && $1==$Tomorrow[1])) {
	@Today=@Tomorrow;
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
    elsif($3==1896 && $2==15 && $1==4) {
	@Today=(1896,4,15);
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
    elsif($3==1902 && $2==6 && $1==20) {
	@Today=(1902,6,20);
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
    elsif($3==1903 && $2==7 && $1==12) {
	@Today=(1903,7,12);
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
    elsif($3==1904 && $2==12 && $1==23) {
	@Today=(1904,12,23);
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
    elsif($3==1905 && $2==6 && $1==26) {
	@Today=(1905,6,26);
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
    elsif($3==1906 && $2==7 && $1==9) {
	@Today=(1906,7,9);
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
     elsif($3==1910 && $2==1 && $1==1) {
	@Today=(1910,1,1);
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
     elsif($3==1910 && $2==7 && $1==1) {
	@Today=(1910,7,1);
        @Tomorrow=Add_Delta_Days(@Today,1);
	$Dstring=sprintf "%04d-%02d-%02d",@Today;
    }
   else {
	die "Date discontinuity, $Fields[0], @Today";
    }

    printf "%s\t%s\t%s\t%s\t%s\t%s\n",$Dstring,@Fields[1..5];
}
