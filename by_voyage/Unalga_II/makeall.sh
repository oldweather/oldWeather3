# Make the IMMA file and diagnostic plots for Unalga II

../../scripts/utilities/voyage_positions.perl --ship='Unalga (II)' > positions.out
clean_positions.perl < positions.out > positions.weeded
# Manually edited - remove dud positions to positions.qc.out
../../scripts/utilities/voyage_t+p.perl --ship='Unalga (II)' > obs.out
# Manually edited - fix dud dates to obs.qc.out
./to_imma.perl > imma.out
R --no-save < plot_voyage.R
R --no-save < 20CR.extract.ship.R
R --no-save < O_R_plot.R
cp imma.out ../../imma/Unalga.imma
