# Make the IMMA file and diagnostic plots for Pioneer

../../scripts/utilities/voyage_positions.perl --ship='Pioneer' > positions.out
# cp positions.out positions.qc.out # Hand edit bad positions
cd positions.qc.annual
../split_by_year.perl < ../positions.qc.out
# Manually edited - remove dud positions from annual files
cd ..
../../scripts/utilities/voyage_t+p.perl --ship='Pioneer' > obs.out
cd obs.qc.annual
../split_by_year.perl < obs.out
# Manually edited - remove dud positions from annual files
# Manually edited - fix dud dates to obs.qc.out
./to_imma.perl
R --no-save < plot_voyage.R
R --no-save < 20CR.extract.ship.R
R --no-save < O_R_plot.R
cp imma.annual/* ../../imma
