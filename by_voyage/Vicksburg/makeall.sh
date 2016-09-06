# Make the IMMA file and diagnostic plots for Vicksburg

../../scripts/utilities/voyage_positions.perl --ship='Vicksburg' > positions.out
../../scripts/utilities/voyage_t+p.perl --ship='Vicksburg' > obs.out
