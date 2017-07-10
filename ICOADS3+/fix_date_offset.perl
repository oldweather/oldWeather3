#!/usr/bin/perl

# Reprocess the IMMA records for a ship to fix the date offset
#  problem Larry found.

use strict;
use warnings;
use MarineOb::IMMA;
use Date::Calc qw(check_date check_time Delta_DHMS);
use FindBin;

GetOptions(
    "ship=s"   => \$Ship_name,
    "voyage=i" => \$VoyageN,
    "id=s"     => \$Id,
    "only=i"   => \$Only
);
unless ( defined($Ship_name) ) { die "Usage: --ship=<ship.name>"; }

# Read in the dates
my %Dates;
my %ODates;
open(DIN,sprintf "$FindBin::Bin/%s/dates.qc",$Ship_name) or die;
while (my $Line = <DIN>) {
    chomp $Line;
    my @fields = split /\t/,$Line;
    $Dates{$fields[0]}=$fields[2];
    $ODates{$fields[0]}=$fields[2];
}
close(DIN);

# For each ob, find its date (in ship time) and check if the
#  old and new dates are different at that old date.
# If so - shift it to the new date.
open(DIN,sprintf "$FindBin::Bin/../%s.imma",$Ship_name) or die;
while (my $Ob = imma_read(\*DIN)) {
    chomp $Line;
    my @fields = split /\t/,$Line;
    my $Asset=$fields[0];
    my $Hour =$fields[1];
    

        }
	push @Imma,$Ob;
    } # End of ob line
} # End of obs.

