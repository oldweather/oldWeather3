#!/usr/bin/perl

# Reformat positions - fixing dates and 
#  merging in Sophia's edits.

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
    my @Fields = split /,/,$Line;
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
   # Assign positions
    if($Fields[1]=~ /(\d+)\D+(\d+)/) {
	unless(defined($Positions{$Dstring}{'lat'}{'observed'})) {
	    $Positions{$Dstring}{'lat'}{'observed'} = $1+$2/60;
            if($Fields[1]=~ /[Ss]/) { $Lat_flag='S'; }
            if($Fields[1]=~ /[nN]/) { $Lat_flag='N'; }
	    if($Lat_flag eq 'S') {
		$Positions{$Dstring}{'lat'}{'observed'} *= -1;
            }
	}
    }
    if($Fields[2]=~ /(\d+)\D+(\d+)/) {
	unless(defined($Positions{$Dstring}{'lon'}{'observed'})) {
	    $Positions{$Dstring}{'lon'}{'observed'} = $1+$2/60;
            if($Fields[2]=~ /[wW]/) { $Lon_flag='W'; }
            if($Fields[2]=~ /[eE]/) { $Lon_flag='E'; }
	    if($Lon_flag eq 'W') {
                $Positions{$Dstring}{'lon'}{'observed'} *= -1;
            }
	}
    }
    if($Fields[7]=~ /\w+/ && $Fields[7]!~ /north pacific/) { # Sophia's corrected the position
	if($Fields[8]=~ /(\d+)\s+(\d+)/) {
	   $New_places{$Fields[7]}{'lat'} = $1+$2/60;
            if($Fields[8]=~ /[Ss]/) { $Lat_flag='S'; }
            if($Fields[8]=~ /[nN]/) { $Lat_flag='N'; }
	    if($Lat_flag eq 'S') {
	       $New_places{$Fields[7]}{'lat'} *= -1;
           }
	}
	if($Fields[8]=~ /(\d+\.\d+)/) {
	   $New_places{$Fields[7]}{'lat'} = $1;
            if($Fields[8]=~ /[Ss]/) { $Lat_flag='S'; }
            if($Fields[8]=~ /[nN]/) { $Lat_flag='N'; }
	    if($Lat_flag eq 'S') {
	       $New_places{$Fields[7]}{'lat'} *= -1;
           }
	}
	if($Fields[9]=~ /(\d+)\s+(\d+)/) {
	   $New_places{$Fields[7]}{'lon'} = $1+$2/60;
            if($Fields[9]=~ /[wW]/) { $Lon_flag='W'; }
            if($Fields[9]=~ /[eE]/) { $Lon_flag='E'; }
	    if($Lon_flag eq 'W') {
	       $New_places{$Fields[7]}{'lon'} *= -1;
           }
	}
	if($Fields[9]=~ /(\d+\.\d+)/) {
	   $New_places{$Fields[7]}{'lon'} = $1;
           if($Fields[9]=~ /[wW]/) { $Lon_flag='W'; }
           if($Fields[9]=~ /[eE]/) { $Lon_flag='E'; }
	   if($Lon_flag eq 'W') {
	       $New_places{$Fields[7]}{'lon'} *= -1;
           }
	}
        if(defined($New_places{$Fields[7]}{'lat'})) {
           $Positions{$Dstring}{'lat'}{'place'} =
	       $New_places{$Fields[7]}{'lat'};
        }
        if(defined($New_places{$Fields[7]}{'lon'})) {
           $Positions{$Dstring}{'lon'}{'place'} =
	       $New_places{$Fields[7]}{'lon'};
        }  
    }
    if($Fields[3]=~ /\d/ && $Fields[7] !~ /\w/ &&
       $Fields[6] !~ /behring/) { # Auto place location, use if uncorrected
    	unless(defined($Positions{$Dstring}{'lat'}{'place'})) {
	    $Positions{$Dstring}{'lat'}{'place'} = $Fields[3];
        }
    }
    if($Fields[4]=~ /\d/ && $Fields[7] !~ /\w/ &&
       $Fields[6] !~ /behring/) {
    	unless(defined($Positions{$Dstring}{'lon'}{'place'})) {
	    $Positions{$Dstring}{'lon'}{'place'} = $Fields[4];
        }
    }    
}

# Output the positions
foreach my $Dstring (sort(keys(%Positions))) {
    $Dstring =~ /(\d\d\d\d).(\d\d).(\d\d)/;
    printf "%04d %02d %02d ",$1,$2,$3;
    if(defined($Positions{$Dstring}{'lat'}{'observed'})) {
	printf "%6.2f ",$Positions{$Dstring}{'lat'}{'observed'};
    }
    elsif(defined($Positions{$Dstring}{'lat'}{'place'})) {
	printf "%6.2f ",$Positions{$Dstring}{'lat'}{'place'};
    }
    else {
        print "    NA ";
    }
    if(defined($Positions{$Dstring}{'lon'}{'observed'})) {
	printf "%7.2f ",$Positions{$Dstring}{'lon'}{'observed'};
    }
    elsif(defined($Positions{$Dstring}{'lon'}{'place'})) {
	printf "%7.2f ",$Positions{$Dstring}{'lon'}{'place'};
    }
    else {
        print "     NA ";
    }
    print "\n";
}
