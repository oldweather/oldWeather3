# Make the IMMA file and diagnostic plots for Jamestown (1866)

../../scripts/utilities/voyage_positions.perl --ship='Jamestown (1866)' > positions.out
# Manually edited to make positions_Jamestown_1866.xlsx & positions_Jamestown_1866.csv
# Further edited to make positions_Perry.csv.qc
#./qc_positions.perl < positions_Perry.csv.qc > positions_Perry.fmt
#../../scripts/utilities/voyage_t+p.perl --ship='Jamestown (1866)' > obs.out
# Manually edited - fix dud dates to obs.qc.out
#./qc_obs_dates.perl < obs.out.qc > obs.out.date.fmt
#./to_imma.perl > imma.out
#R --no-save < plot_voyage.R
#R --no-save < 20CR.extract.ship.R
#R --no-save < O_R_plot.R
#cp imma.out ../../imma/Perry.imma
