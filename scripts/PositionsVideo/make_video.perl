#!/usr/bin/perl

# Make a video

use strict;
use warnings;

# Put the selected images in a temporary directory
my $Tdir = "/var/tmp/philip/$$";
mkdir($Tdir) or die "Couldn't make $Tdir";

    my $Glob = "/Users/philip/LocalData/images/oW3.Perry/*.png";
    my $Count=0;
    foreach my $ImageFile ( glob($Glob) ) {
        unless ( -r $ImageFile ) { die "Missing image $ImageFile"; }
        my $Nfname = sprintf "%s/%04d.png", $Tdir, $Count++;
        `ln  $ImageFile $Nfname`;
    }

`ffmpeg  -r 48 -i $Tdir/%04d.png -c:v libx264 -preset slow -tune animation -profile:v high -level 4.2 -pix_fmt yuv420p -crf 22 -c:a copy oW3.Perry.mp4`;

`rm -r $Tdir`;
