#!/usr/bin/Rscript --no-save

# Plot the locations of a set of IMMA observations

library(GSDF)
library(GSDF.WeatherMap)
library(IMMA)

Options<-WeatherMap.set.option(NULL)
Options<-WeatherMap.set.option(Options,'obs.size',1)
Options<-WeatherMap.set.option(Options,'obs.colour',rgb(255,215,0,255,
                                                       maxColorValue=255))
Options<-WeatherMap.set.option(Options,'ice.colour',Options$land.colour)
Options<-WeatherMap.set.option(Options,'background.resolution','high')
range<-90
aspect<-2
Options<-WeatherMap.set.option(Options,'lat.min',range*-1)
Options<-WeatherMap.set.option(Options,'lat.max',range)
Options<-WeatherMap.set.option(Options,'lon.min',range*aspect*-1)
Options<-WeatherMap.set.option(Options,'lon.max',range*aspect)
Options<-WeatherMap.set.option(Options,'pole.lon',235)
Options<-WeatherMap.set.option(Options,'pole.lat',90)

land<-WeatherMap.get.land(Options)

o<-IMMA.read('tmp.imma')
l2<-GSDF.ll.to.rg(o$LAT,o$LON,Options$pole.lat,Options$pole.lon)
obs.ll<-list()
obs.ll$Longitude<-l2$lon
obs.ll$Latitude<-l2$lat


png(file='imma.png',
             width=1080*aspect,
             height=1080,
             bg=Options$sea.colour,
             pointsize=24)

  pushViewport(dataViewport(c(Options$lon.min,Options$lon.max),
                            c(Options$lat.min,Options$lat.max),
		            extension=0))

  gp<-gpar(col=Options$obs.colour,fill=Options$obs.colour)
  grid.points(x=unit(obs.ll$Longitude,'native'),
              y=unit(obs.ll$Latitude,'native'),
              size=unit(Options$obs.size,'native'),
              pch=20,gp=gp)
    WeatherMap.draw.land(land,Options)
  upViewport()
  dev.off()
warnings()
