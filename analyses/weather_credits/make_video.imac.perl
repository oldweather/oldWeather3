#!/opt/local/bin/perl

# Make a video from a set of diagnostic images
# Needed because of irregular filename numbering

use strict;
use warnings;

my $Count = 0;

# Put the selected images in a temporary directory
my $Tdir = "/var/tmp/$$";
mkdir($Tdir) or die "Couldn't make $Tdir";

my @Images = glob("images/*.png");
foreach my $Image (@Images) {

    my $Nfname = sprintf "%s/%05d.png", $Tdir, $Count++;
    `ln  $Image $Nfname`;
}

`ffmpeg -r 24 -i $Tdir/%05d.png -c:v libx264 -preset slow -tune animation -profile:v high -level 4.1 -pix_fmt yuv420p -crf 22 -c:a copy credits.mp4`;
`rm -r $Tdir`;
