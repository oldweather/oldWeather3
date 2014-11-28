#!/usr/bin/perl

# Make a video from a set of diagnostic images
# Needed because of MO old version of ffmpeg

use strict;
use warnings;

my $Count = 0;

# Put the selected images in a temporary directory
my $Tdir = "/var/tmp/hadpb/$$";
mkdir($Tdir) or die "Couldn't make $Tdir";

my @Images = glob("images/*.png");
foreach my $Image (@Images) {

    my $Nfname = sprintf "%s/%04d.png", $Tdir, $Count++;
    `cp  $Image $Nfname`;
}

`ffmpeg -qscale 5 -r 24 -i $Tdir/%04d.png credits.mp4`;
`rm -r $Tdir`;
