export LC_ALL='C'
./dump_ice_events_to_csv.perl --ship=Corwin | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Corwin.csv
./dump_ice_events_to_csv.perl --ship=Jeannette | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Jeannette.csv
./dump_ice_events_to_csv.perl --ship=Manning | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Manning.csv
./dump_ice_events_to_csv.perl --ship=Rodgers | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Rodgers.csv
./dump_ice_events_to_csv.perl --ship='Unalga (II)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Unalga_II.csv
./dump_ice_events_to_csv.perl --ship=Yukon | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Yukon.csv
./dump_ice_events_to_csv.perl --ship=Bear | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Bear.csv
./dump_ice_events_to_csv.perl --ship=Thetis | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Thetis.csv
./dump_ice_events_to_csv.perl --ship=Rush | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Rush.csv
./dump_ice_events_to_csv.perl --ship=Concord | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Concord.csv
./dump_ice_events_to_csv.perl --ship=Pioneer | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Pioneer.csv
./dump_ice_events_to_csv.perl --ship=Perry | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Perry.csv
./dump_ice_events_to_csv.perl --ship=Vicksburg | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Vicksburg.csv
./dump_ice_events_to_csv.perl --ship=Yorktown | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Yorktown.csv
./dump_ice_events_to_csv.perl --ship=Patterson | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Patterson.csv
./dump_ice_events_to_csv.perl --ship='Unalga (I)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Unalga_I.csv
./dump_ice_events_to_csv.perl --ship='Jamestown (1844)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Jamestown_1844.csv
./dump_ice_events_to_csv.perl --ship='Jamestown (1866)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Jamestown_1866.csv
./dump_ice_events_to_csv.perl --ship='Jamestown (1879)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Jamestown_1879.csv
./dump_ice_events_to_csv.perl --ship='Jamestown (1886)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Jamestown_1886.csv
./dump_ice_events_to_csv.perl --ship='Albatross (1884)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Albatross_1884.csv
./dump_ice_events_to_csv.perl --ship='Albatross (1890)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Albatross_1890.csv
./dump_ice_events_to_csv.perl --ship='Albatross (1900)' | gsort --field-separator=',' --key=2 | egrep -i -A 10 -B 10 'ice|pack|floe' | tr '|' '\n' > Albatross_1900.csv

