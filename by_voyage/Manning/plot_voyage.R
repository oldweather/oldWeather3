#!/usr/bin/Rscript --no-save

# Voyage of the Manning

library(GSDF.WeatherMap)
library(GSDF)

# Get the observations
o<-read.fwf(file='imma.out', widths=c(4,2,2,4,5,6,84))
o$Longitude<-o$V6/100
o$Latitude<-o$V5/100

Options<-WeatherMap.set.option(NULL)
Options<-WeatherMap.set.option(Options,'show.mslp',F)
Options<-WeatherMap.set.option(Options,'show.ice',F)
Options<-WeatherMap.set.option(Options,'show.obs',T)
Options<-WeatherMap.set.option(Options,'show.fog',F)
Options<-WeatherMap.set.option(Options,'show.wind',F)
Options<-WeatherMap.set.option(Options,'show.temperature',F)
Options<-WeatherMap.set.option(Options,'show.precipitation',F)
Options<-WeatherMap.set.option(Options,'temperature.range',12)
Options<-WeatherMap.set.option(Options,'obs.size',0.5)
Options<-WeatherMap.set.option(Options,'obs.colour',rgb(255,215,0,255,
                                                       maxColorValue=255))
Options<-WeatherMap.set.option(Options,'ice.colour',Options$land.colour)
Options<-WeatherMap.set.option(Options,'lat.min',-30)
Options<-WeatherMap.set.option(Options,'lat.max',30)
Options<-WeatherMap.set.option(Options,'lon.min',-50)
Options<-WeatherMap.set.option(Options,'lon.max',50)
Options<-WeatherMap.set.option(Options,'pole.lon',30)
Options<-WeatherMap.set.option(Options,'pole.lat',35)

Options$ice.points<-50000
land<-WeatherMap.get.land(Options)


    image.name<-"Route.png"

    ifile.name<-sprintf("%s",image.name)

     png(ifile.name,
             width=500*WeatherMap.aspect(Options),
             height=500,
             bg=Options$sea.colour,
             pointsize=24,
             type='cairo')
    Options$label<-sprintf("Manning")
       WeatherMap.draw(Options=Options,uwnd=NULL,icec=NULL,
                          vwnd=NULL,precip=NULL,mslp=NULL,
                          t.actual=NULL,t.normal=NULL,land=land,
                          fog=NULL,obs=o,streamlines=NULL)
    dev.off()
