./get_joining_and_last_dates.perl > joining_and_last_dates.txt
./rjl.perl < joining_and_last_dates.txt > by_day.txt
R --no-save < plot_rjl.R
