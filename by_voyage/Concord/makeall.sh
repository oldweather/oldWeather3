# Make the IMMA file and diagnostic plots for Concord

../../scripts/utilities/voyage_positions.perl --ship='Concord' > positions.out
../../scripts/utilities/voyage_t+p.perl --ship='Concord' > obs.out
