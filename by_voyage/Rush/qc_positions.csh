#!/bin/csh


# Written by Chesley McColl 11/17/2015
# after dumping the database with the following format
#  01/06/1890            NA              NA            37.8          -122.4                  san francisco                   san francisco
# date,ship_lat,ship_lon,port_lat,port_lon,port,port_name
# %12s\t,%10s\t,%10s\t,%10s\t,%10s\t,%25s\t,%25s\t


# check the date format 
# check that the ship latitude and longitude are within 10 degrees of the last known position

#set list = date,slat,slon,plat,plon,name,pname 

 @ dd = 1
 @ ldd = 1
 @ mm = 1
 set lastns = 'N'
 set lastew = 'W'
 set first = 'yes'

foreach line ("`cat positions.out`")

   set split = ($line:as/	/ /)

#test to make sure format of the 2nd and 3rd column is correct
   set second_tab = `printf "%s $line\n" | cut -f 2`
   set third_tab = `printf "%s $line\n" | cut -f 3`
   set split_lat = ($second_tab:as/        / /)
   set split_lon = ($third_tab:as/        / /)
   set nlat = `printf "%s $second_tab \n" |wc -w`
   set nlon = `printf "%s $third_tab \n" |wc -w`

###echo "Input looks like $split[1],$split[2],$split[3],$split[4]"

# if the second column has only one value then it should be NA
   if ($nlat == 1 || $nlon == 1 ) then
    ###echo "2nd column only has a single value needs NA"
    set split[2] = 'NA'
    set split[3] = 'NA' 
   else
     # if the second column has more then one column,it must be a number

     ###echo "2nd column has at least 2 values $split_lat[1]" 
     echo $split_lat[1] | grep -q '[0-9]'
     if ( $status != 0 ) then
       ###echo "but it isn't a number  need to shift all the splits by nlat+nlon-2\n" 

       set split[2] = 'NA'
       set split[3] = 'NA'
       set column = 4
       @ jump = $nlat + $nlon - 2
       ###echo "$second_tab $third_tab \n"
       ###echo "jump this number of columns $jump\n"
       while ( $column <= 8 )
         @ new_col = $column + $jump
         set split[$column] = $split[$new_col]
         @ column = $column + 1
       end
     else

       ###echo "3rd column has at least 2 values $split_lon[1]" 
       echo $split_lon[1] | grep -q '[0-9]'
       if ( $status != 0 ) then
         ###echo "but it isn't a number  need to shift all the splits by nlat+nlon-2\n" 
         set split[2] = 'NA'
         set split[3] = 'NA'
         set column = 4
         @ jump = $nlat + $nlon - 2
         while ( $column <= 8 )
           @ new_col = $column + $jump
           set split[$column] = $split[$new_col]
           @ column = $column + 1
         end
       endif
     endif
   endif
###echo "NEW line looks like $split[1],$split[2],$split[3],$split[4]"

#first line of the positions file needs to have a valid yyyy plat and plon to initialize the values
  if ( $first == 'yes') then
   @ yyyy = `echo $split[1]| awk '{printf "%d\n",$0;}'`
   @ lastlat = `echo $split[4]| awk '{printf "%d\n",$0;}'`
   @ lastlon = `echo $split[5]| awk '{printf "%d\n",$0;}'`
   set split[1] = {'NA'}
   set first = 'no'
  endif 

# quitely check if the first column contains numbers
#############date##################################################
  set date = $split[1]
  echo $split[1] | grep -q '[0-9]'
  if ( $status != 0  && $split[1] != 'NA') then 
  # does not contain numbers try next column if not NA
    echo $split[2] |grep -q '[0-9]'
    if ( $status != 0 && $split[2] != 'NA') then
#       echo "even 2nd column doesn't contain numbers"
#       echo "hand edit $split[1] $split[2]\n"
    else
       set date = $split[2]
    endif 
  endif 

# use awk to make sure values are integers
  if ( $date != 'NA') then
 @ dd = `echo $date| awk -F/ '{printf "%d\n",$1;}'`
 @ mm = `echo $date| awk -F/ '{printf "%d\n",$2;}'`
 @ yyyy = `echo $date| awk -F/ '{printf "%d\n",$3;}'`

     # setup a check to compare previous year to new year 
  	if ( $yyyy < 1000 ) then
    		echo "$date changing year from $yyyy to $lyyyy"
    		@ yyyy = $lyyyy
  	endif
      # day and month part should be 2 digits
        set newdate = `printf "%02i/%02i/%04i" $dd $mm $yyyy`
  else
	set newdate = `printf "%12s" "NA"`
  endif
###echo $newdate
#printf "%02i/%02i/%04i\n" $dd $mm $yyyy

#############date##################################################
###echo "ready for logic"
################################################################
# now deal with ship lat and lon 
  set nsdir = ''
  set ewdir = ''
# I have gotten all the values now the logic
# using last known good position determine if value should be set to NA or kept
# if slat ne NA then use the ships latitude/longitude
#  05/06/1890       39 44 N        124 15 W              NA              NA                             NA                              NA
   if ( $split[2] == 'NA') then
       set slat_degree = $split[2]
       set slat_min = ""
       set ewdir = ""
       set slon_degree = "NA"
       set slon_min = ""
       set nwdir = ""
       set plat = $split[4]
       ###echo "plat $plat"
       set plon = $split[5]
       ###echo "plon $plon"
    else
     # need to break this up into degrees and minutes
       set slat_degree = $split[2]
       ###echo $slat_degree
       set slat_min = $split[3]
       ###echo $slat_min
     # make sure the North South is the next value
  	   echo $split[4] | grep -q '[0-9]'
     # does not contain numbers try next column to find longitude 
           if ( $status != 0 ) then 
              set nsdir = $split[4]
              set slon_degree = $split[5]
              ###echo $slon_degree
              set slon_min = $split[6]
              ###echo $slon_min
     	   # read in the port latitude and longitude also
           # make sure the East West is the next value
     	      echo $split[7] | grep -q '[0-9]'
              if ( $status != 0 ) then 
                set ewdir = $split[7]
              # does not contain numbers try next column to find longitude
                set plat = $split[8]
                ###echo "plat $plat"
                set plon = $split[9]
                ###echo "plon $plon"
              else
                set ewdir = $lastew 
                set plat = $split[7]
                ###echo "plat $plat"
                set plon = $split[8]
                ###echo "plon $plon"
              endif
          else
              set nsdir = $lastns 
              set slon_degree = $split[4]
              ###echo $slon_degree
              set slon_min = $split[5]
              ###echo "no north south dir is eastwest set? " $slon_min $slon_degree $split[6]
           # read in the port latitude and longitude also
           # make sure the East West is the next value
              echo $split[6] | grep -q '[0-9]'
              if ( $status != 0  && $split[6] != 'NA') then

                set ewdir = $split[6]
              # does not contain numbers try next column to find longitude
                set plat = $split[7]
                ###echo "plat $plat"
                set plon = $split[8]
                ###echo "plon $plon"
              else
                set ewdir = $lastew 
                set plat = $split[6]
                ###echo "plat $plat"
                set plon = $split[7]
                ###echo "plon $plon"
              endif
          endif
    endif
###echo "finished getting lat/lon values " $slat_degree $slat_min $nsdir $slon_degree $slon_min $ewdir $plat $plon
###echo "today's date $dd previous date $ldd"
# I have gotten all the values now the logic
# using last known good position determine if value should be set to NA or kept
# have slat,slon,plat,plon,lastlat,lastlon
  echo $slat_degree | grep -q '[0-9]'
  if ( $status == 0 ) then 
     # check slat is within +-5 degrees of last lat
     @ slat = `echo $slat_degree| awk '{printf "%d\n",$0;}'`
# setup values of lat - 5 degrees and lat + 5 degrees
     @ tday = $dd - $ldd + 1
#at change of month will go negative
     if ( $tday < 0 ) set tday = 1
     @ llp5 = $lastlat + 5 * $tday
     
###echo "delta " $dd $ldd $tday 
     @ llm5 = $lastlat - 5 * $tday
     if ( $slat > $llp5 || $slat < $llm5) then
	set slat_degree = "NA"
        set slat_min = ""
        set nsdir = ""
	set slon_degree = "NA"
        set slon_min = ""
        set nsdir = ""
     endif
  endif

###echo "checked slat_degree"

  echo $slon_degree | grep -q '[0-9]'
  if ( $status == 0 ) then 
     # check slon is within +-5 degrees of last lat
     @ slon = `echo $slon_degree| awk '{printf "%d\n",$0;}'`
     @ slon = $slon - 2 * $slon
###echo "this should be negative " $slon
# setup values of lon - 5 degrees and lon + 5 degrees
     @ tday = $dd - $ldd + 1
#at change of month will go negative
	if ( $tday < 0 ) set tday = 1
     @ llp5 = $lastlon + 5 * $tday
     @ llm5 = $lastlon - 5 * $tday
###echo "delta " $dd $ldd $tday 
     if ( $slon > $llp5 || $slon < $llm5 ) then
	set slat_degree = "NA"
        set slat_min = ""
        set nsdir = ""
	set slon_degree = "NA"
        set slon_min = ""
        set nsdir = ""
     else
        set ldd = $dd
 	set lastlat = $slat
        set lastlon = $slon
     endif
  endif
        

###echo "obs after +/-5 check " $slat_degree $slat_min $nsdir $lastlat $lastlon
###echo "checked slon_degree"

  echo $plat | grep -q '[0-9]'
  if ( $status == 0 ) then 
     # check plat is within +-5 degrees of last lat
     @ lat = `echo $plat| awk '{printf "%d\n",$0;}'`
# setup values of lat - 5 degrees and lat + 5 degrees
     @ tday = $dd - $ldd + 1
#at change of month will go negative
	if ( $tday < 0 ) set tday = 1
     @ llp5 = $lastlat + 5 * $tday
     @ llm5 = $lastlat - 5 * $tday
###echo "delta " $dd $ldd $tday 

     if ( $lat > $llp5 || $lat < $llm5 ) then
     # outside valid range
	set plat = "NA"
	set plon = "NA"
     endif
  endif
###echo "checked plat"

  echo $plon | grep -q '[0-9]'
  if ( $status == 0 ) then 
     # check plon is within +-5 degrees of last lat
     @ lon = `echo $plon| awk '{printf "%d\n",$0;}'`
# setup values of lon - 10 degrees and lon + 10 degrees
     @ tday = $dd - $ldd + 1
#at change of month will go negative
	if ( $tday < 0 ) set tday = 1
     @ llp5 = $lastlon + 5 * $tday 
     @ llm5 = $lastlon - 5 * $tday

###echo "delta " $dd $ldd $tday 
     if ( $lon > $llp5 || $lon < $llm5) then
	set plat = "NA"
	set plon = "NA"
     else
        echo $slon_degree | grep -q '[0-9]'
        if ( $status != 0 ) then 
        # keep plat and plon but if slat/slon is NA then use plat and plon 
###echo "valid plat $plat being set to lastlat because slat slon is $slon_degree"
 	  set lastlat = $lat
          set lastlon = $lon
        endif
     endif
  endif
###echo "guess after +/-5 check " $slat_degree $slat_min $nsdir $lastlat $lastlon
###echo "checked plot"
printf "$newdate\t $slat_degree $slat_min $nsdir\t $slon_degree $slon_min $ewdir\t $plat\t $plon\n"

if ( $slat_degree != "NA" || $plat != "NA") then
  @ ldd = $dd
  @ lmm = $mm
  @ lyyyy = $yyyy
endif
if ( $slat_degree != "NA") then
  set lastns = $nsdir
  set lastew = $ewdir
endif

#reset defaults to empty before next line
set slat_min = ""
set ewdir = ""
set slon_min = ""
set nsdir = ""

end
