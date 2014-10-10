# Make the IMMA file and diagnostic plots for Bear

../../scripts/utilities/voyage_positions.perl --ship='Bear' > positions.out
clean_positions.perl < positions.out > positions.weeded
cd positions.qc.annual
../split_by_year.perl < ../positions.weeded
# Manually edited - remove dud positions from annual files
cd ..
../../scripts/utilities/voyage_t+p.perl --ship='Bear' > obs.out
cd obs.qc.annual
../split_by_year.perl < obs.out
# Manually edited - remove dud positions from annual files
# Manually edited - fix dud dates to obs.qc.out
./to_imma.perl
R --no-save < plot_voyage.R
R --no-save < 20CR.extract.ship.R
R --no-save < O_R_plot.R
cp imma.annual/* ../../imma
