# Make the IMMA file and diagnostic plots for Rodgers

./scrape_positions.perl > positions.out
../../scripts/utilities/voyage_t+p.perl --ship=Jeannette > obs.out
./to_imma.perl > imma.out
R --no-save < plot_voyage.R
R --no-save < 20CR.extract.ship.R
R --no-save < O_R_plot.R
cp imma.out ../../imma/Jeannette.imma
