# Make the IMMA file and diagnostic plots for Concord

../get_dates.perl --ship='Concord' > dates.raw
../get_positions.perl --ship='Concord' > positions.raw
../get_t+p.perl --ship='Concord' > obs.raw

# Copy dates.raw to dates.qc and fix or delete all the bad dates.
# Copy positions.raw to positions.qc and fix or delete all the bad positions.

