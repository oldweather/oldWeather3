#!/usr/bin/Rscript --no-save

# Polar regions - oldWeather locations

library(GSDF)
library(GSDF.WeatherMap)

Options<-WeatherMap.set.option(NULL)
Options<-WeatherMap.set.option(Options,'obs.size',1)
Options<-WeatherMap.set.option(Options,'obs.colour',rgb(255,215,0,255,
                                                       maxColorValue=255))

range<-30
aspect<-2
Options<-WeatherMap.set.option(Options,'lat.min',range*-1)
Options<-WeatherMap.set.option(Options,'lat.max',range)
Options<-WeatherMap.set.option(Options,'lon.min',range*aspect*-1)
Options<-WeatherMap.set.option(Options,'lon.max',range*aspect)
Options<-WeatherMap.set.option(Options,'pole.lon',10)
Options<-WeatherMap.set.option(Options,'pole.lat',25)

land<-WeatherMap.get.land(Options)

   obs.ll<-read.table('ll.out')
   l2<-GSDF.ll.to.rg(obs.ll$V2,obs.ll$V1,Options$pole.lat,Options$pole.lon)
   obs.ll<-list()
   obs.ll$Longitude<-l2$lon
   obs.ll$Latitude<-l2$lat

   obs.ice<-read.table('ice.out')
   l2<-GSDF.ll.to.rg(obs.ice$V2,obs.ice$V1,Options$pole.lat,Options$pole.lon)
   obs.ice<-list()
   obs.ice$Longitude<-l2$lon
   obs.ice$Latitude<-l2$lat

   obs.places<-read.table('Places.ll',sep="\t",strip.white=TRUE,quote="")
   l2<-GSDF.ll.to.rg(obs.places$V3,obs.places$V2,Options$pole.lat,Options$pole.lon)
   obs.places<-list()
   obs.places$Longitude<-l2$lon
   obs.places$Latitude<-l2$lat

     png('oW3.obs+ice.inset.png',
             width=1080*aspect,
             height=1080,
             bg=Options$sea.colour,
             pointsize=24,
             type='cairo')

  pushViewport(dataViewport(c(Options$lon.min,Options$lon.max),
                            c(Options$lat.min,Options$lat.max),
		            extension=0))

  gp<-gpar(col=Options$obs.colour,fill=Options$obs.colour)
  grid.points(x=unit(obs.ll$Longitude,'native'),
              y=unit(obs.ll$Latitude,'native'),
              size=unit(Options$obs.size,'native'),
              pch=20,gp=gp)
  gp<-gpar(col=Options$obs.colour,fill=Options$obs.colour)
  grid.points(x=unit(obs.places$Longitude,'native'),
              y=unit(obs.places$Latitude,'native'),
              size=unit(Options$obs.size,'native'),
              pch=20,gp=gp)
  gp<-gpar(col='white',fill='white')
  grid.points(x=unit(obs.ice$Longitude,'native'),
              y=unit(obs.ice$Latitude,'native'),
              size=unit(Options$obs.size,'native'),
              pch=20,gp=gp)
    WeatherMap.draw.land(land,Options)
  upViewport()
  dev.off()
