# Make the IMMA file and diagnostic plots for Albatross (1884)

../../scripts/utilities/voyage_positions.perl --ship='Albatross (1884)' > positions.out
# Manually edited to make positions_Albatross_1884.xlsx & positions_Albatross_1884.csv
# Further edited to make positions_Albatross_1884.csv.qc
#./qc_positions.perl < positions_Albatross_1884.csv.qc > positions_Albatross_1884.fmt
#../../scripts/utilities/voyage_t+p.perl --ship='Albatross (1884)' > obs.out
# Manually edited - fix dud dates to obs.qc.out
#./qc_obs_dates.perl < obs.out.qc > obs.out.date.fmt
#./to_imma.perl > imma.out
#R --no-save < plot_voyage.R
#R --no-save < 20CR.extract.ship.R
#R --no-save < O_R_plot.R
#cp imma.out ../../imma/Albatross_18884.imma
