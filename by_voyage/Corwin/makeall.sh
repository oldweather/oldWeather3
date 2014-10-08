# Make the IMMA file and diagnostic plots for Corwin

../../scripts/utilities/voyage_positions.perl --ship=Corwin > positions.out
# Manually edited - remove dud positions to positions.qc.out
../../scripts/utilities/voyage_t+p.perl --ship=Corwin > obs.out
# Manually edited - fix dud dates to obs.qc.out
./to_imma.perl > imma.out
R --no-save < plot_voyage.R
R --no-save < 20CR.extract.ship.R
R --no-save < O_R_plot.R
cp imma.out ../../imma/Corwin.imma
