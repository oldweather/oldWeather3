./count_pages_per_user.perl > pages_per_user.txt
./convert_to_znv_id.perl < pages_per_user.txt > pages_per_user.znv.txt
R --no-save < plot_pages_per_user.R
