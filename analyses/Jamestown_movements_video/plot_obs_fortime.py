#!/usr/bin/env python

# Plot ICOADS records for a given time, emphasising those from 
#  the USS Jamestown.

import IRData.twcr as twcr
import datetime
import numpy
import pandas

import IMMA

import Meteorographica as mg
import iris
import os

import matplotlib
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
import cartopy
import cartopy.crs as ccrs

# Get the datetime to plot from commandline arguments
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--year", help="Year",
                    type=int,required=True)
parser.add_argument("--month", help="Integer month",
                    type=int,required=True)
parser.add_argument("--day", help="Day of month",
                    type=int,required=True)
parser.add_argument("--hour", help="Hour of day (0 to 23)",
                    type=int,required=True)
#parser.add_argument("--minute", help="Minute of hour (0 to 59)",
#                    type=int,required=True)
parser.add_argument("--radius", help="Marker size (degrees)",
                    type=float,default=0.75)
parser.add_argument("--opdir", help="Directory for output files",
                    default="%s/images/Jamestown" % \
                                           os.getenv('SCRATCH'),
                    type=str,required=False)
args = parser.parse_args()
if not os.path.isdir(args.opdir):
    os.makedirs(args.opdir)

dte=datetime.datetime(args.year,args.month,args.day,
                      args.hour)

# Get the Jamestown obs close to the specified time
J_obs=[]
if args.year>=1843 and args.year<=1867:
    J_obs=IMMA.read(os.path.join(os.path.dirname(__file__),
                               '../../Larry/Jamestown_1844_Prelim.imma'))
if args.year>=1865 and args.year<=1880:
    J_obs=J_obs+IMMA.read(os.path.join(os.path.dirname(__file__),
                               '../../Larry/Jamestown_1866.imma'))
if args.year>=1878 and args.year<=1887:
    J_obs=J_obs+IMMA.read(os.path.join(os.path.dirname(__file__),
                               '../../Larry/Jamestown_1879.imma'))
if args.year>=1885 and args.year<=1892:
    J_obs=J_obs+IMMA.read(os.path.join(os.path.dirname(__file__),
                               '../../Larry/Jamestown_1886.imma'))

# Get the ICOADS obs close to the specified time
i_year=args.year
i_month=args.month-1
if i_month == 0:
    i_month = 12
    i_year -= 1
I_obs=IMMA.read('/project/earthobs/ICOADS/ICOADS.3.0.0/IMMA1_R3.0.0_%04d-%02d.gz' % 
                (i_year,i_month))
i_month += 1
if i_month > 12:
    i_month = 1
    i_year += 1
I_obs=I_obs+IMMA.read('/project/earthobs/ICOADS/ICOADS.3.0.0/IMMA1_R3.0.0_%04d-%02d.gz' % 
                (i_year,i_month))
i_month += 1
if i_month > 12:
    i_month = 1
    i_year += 1
I_obs=I_obs+IMMA.read('/project/earthobs/ICOADS/ICOADS.3.0.0/IMMA1_R3.0.0_%04d-%02d.gz' % 
                (i_year,i_month))

# Define the figure (page size, background color, resolution, ...
aspect=16/9.0
fig=Figure(figsize=(10.8*aspect,10.8),  # Width, Height (inches)
           dpi=100,
           facecolor=(0.88,0.88,0.88,1),
           edgecolor=None,
           linewidth=0.0,
           frameon=False,                # Don't draw a frame
           subplotpars=None,
           tight_layout=None)
# Attach a canvas
canvas=FigureCanvas(fig)

# All mg plots use Rotated Pole, in this case just use the standard
#  pole location.
projection=ccrs.RotatedPole(pole_longitude=90.0, pole_latitude=90.0)

# Define an axes to contain the plot. In this case our axes covers
#  the whole figure
ax = fig.add_axes([0,0,1,1],projection=projection)
ax.set_axis_off() # Don't want surrounding x and y axis
# Set the axes background colour
ax.background_patch.set_facecolor((0.67,0.75,0.91,1))

# Lat and lon range (in rotated-pole coordinates) for plot
extent=[-180.0,180.0,-90.0,90.0]
ax.set_extent(extent, crs=projection)
# Lat:Lon aspect does not match the plot aspect, ignore this and
#  fill the figure with the plot.
matplotlib.rc('image',aspect='auto')


# Add the land
land_img=ax.background_img(name='GreyT', resolution='low')

# Plot the obs
for ob in J_obs:
    if ob['LAT'] is None: continue
    if ob['LON'] is None: continue
    if ob['YR'] is None: continue
    if ob['MO'] is None: continue
    if ob['DY'] is None: continue
    if ob['HR'] is None: continue
    ob_dte=datetime.datetime(ob['YR'],ob['MO'],ob['DY'],int(ob['HR']))
    dts=(dte-ob_dte).total_seconds()
    if dts>0 and dts<(3600*72):
           rp=ax.projection.transform_points(ccrs.PlateCarree(),
                                              numpy.array(ob['LON']),
                                              numpy.array(ob['LAT']))
           ax.add_patch(matplotlib.patches.Circle((rp[:,0],rp[:,1]),
                                                radius=0.5,
                                                facecolor='red',
                                                edgecolor='red',
                                                alpha=(3600*72-dts)/(3600*72),
                                                zorder=500))

for ob in I_obs:
    if ob['LAT'] is None: continue
    if ob['LON'] is None: continue
    if ob['YR'] is None: continue
    if ob['MO'] is None: continue
    if ob['DY'] is None: continue
    if ob['HR'] is None: ob['HR']=12
    try:
        ob_dte=datetime.datetime(ob['YR'],ob['MO'],ob['DY'],int(ob['HR']))
        dts=(dte-ob_dte).total_seconds()
        if dts>0 and dts<(3600*72):
               rp=ax.projection.transform_points(ccrs.PlateCarree(),
                                                  numpy.array(ob['LON']),
                                                  numpy.array(ob['LAT']))
               ax.add_patch(matplotlib.patches.Circle((rp[:,0],rp[:,1]),
                                                    radius=0.3,
                                                    facecolor='yellow',
                                                    edgecolor='yellow',
                                                    alpha=(3600*72-dts)/(3600*72),
                                                    zorder=100))
    except:
        continue

# Add a label showing the date
mg.utils.plot_label(ax,
              ('%04d-%02d-%02d' % 
               (args.year,args.month,args.day)),
              facecolor=fig.get_facecolor(),
              x_fraction=0.99,
              y_fraction=0.98,
              horizontalalignment='right',
              verticalalignment='top',
              fontsize=14)

# Render the figure as a png
fig.savefig('%s/obs_%04d%02d%02d%02d.png' % 
               (args.opdir,args.year,args.month,args.day,
                           args.hour))
