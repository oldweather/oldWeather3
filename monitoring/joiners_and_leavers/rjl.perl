#!/opt/local/bin/perl

# Count numbers registered, joined, and last seen on each day.

use strict;
use warnings;
use Date::Calc ( 'Delta_Days', 'Add_Delta_Days' );

my %Registered;
my %Joined;
my %Last;

while (<>) {
    my @Field = split;
    $Registered{ $Field[1] }++;
    $Last{ $Field[3] }++;
    $Joined{ $Field[2] }++;
}

my $Year      = 2012;
my $Month     = 7;
my $Day       = 23;
my @Last_time = ( 2014, 7, 9 );    # set to date of db dump

while ( Delta_Days( $Year, $Month, $Day, @Last_time ) ) {
    my $DayT = sprintf "%04d-%02d-%02d", $Year, $Month, $Day;
    unless ( defined( $Registered{$DayT} ) ) { $Registered{$DayT} = 0; }
    unless ( defined( $Joined{$DayT} ) )     { $Joined{$DayT}     = 0; }
    unless ( defined( $Last{$DayT} ) )       { $Last{$DayT}       = 0; }
    printf "%s %d %d %d\n", $DayT, $Registered{$DayT}, $Joined{$DayT},
      $Last{$DayT};
    ( $Year, $Month, $Day ) = Add_Delta_Days( $Year, $Month, $Day, 1 );
}
