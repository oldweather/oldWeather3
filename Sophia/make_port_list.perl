#!/usr/bin/env perl

# Take the position series Sophia made and make a list of
#  port name - corrected position pairs for each ship.

use FindBin;

my @SFiles=glob("$FindBin::Bin/csv/*.csv");

# Convert '12 34 56 N' latitudes to the decimal equivalent
sub ll_to_dec {
    my $orig = shift;
    if($orig =~ /(\d\d)\s+(\d\d)+\s+(\d\d+)(\w)/) {
        my $result=$1;
	if(defined($2)) { $result += $2/60; }
        if(defined($3)) { $result += $3/(60*60);}
        if(defined($4) && (lc($4)=='s' || lc($4)=='w')) {
	    $result *= -1;
	}
        return($result);
    }
    return(orig);
}

# Get the corrected positions for each ship.
my (@port,@lat,@lon);
foreach my $Cfile (@SFiles) {
    open DIN, $Cfile or die "Can't open $Cfile";
    while (my $Line = <DIN>) {
        my @Fields = split /,/,$Line;
        if(defined($fields[5]) && $fields[5]=~ /\w/ &&
           defined($fields[8]) && $fields[8]=~ /\w/ &&
           defined($fields[9]) && $fields[9]=~ /\w/) {
           # Sophia has added a correction, store it
	    push @port,$fields[5];
            push @lat,ll_to_dec($fields[8]);
            push @lon,ll_to_dec($fields[9]);
	}
    }
}

# Output the positions
open(DOUT,">S.positions") or die;
for(my $i=1;$i<scalar(@port);$i++) {
    printf DOUT "%s\t%s\t%s\n",port[i],lat[i],lon[i];
}

            
