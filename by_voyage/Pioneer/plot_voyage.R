#!/usr/bin/Rscript --no-save

# Voyages of the Pioneer

library(GSDF.WeatherMap)
library(GSDF)

Options<-WeatherMap.set.option(NULL)
Options<-WeatherMap.set.option(Options,'show.mslp',F)
Options<-WeatherMap.set.option(Options,'show.ice',F)
Options<-WeatherMap.set.option(Options,'show.obs',T)
Options<-WeatherMap.set.option(Options,'show.fog',F)
Options<-WeatherMap.set.option(Options,'show.wind',F)
Options<-WeatherMap.set.option(Options,'show.temperature',F)
Options<-WeatherMap.set.option(Options,'show.precipitation',F)
Options<-WeatherMap.set.option(Options,'temperature.range',12)
Options<-WeatherMap.set.option(Options,'obs.size',1)
Options<-WeatherMap.set.option(Options,'obs.colour',rgb(255,215,0,255,
                                                       maxColorValue=255))
Options<-WeatherMap.set.option(Options,'ice.colour',Options$land.colour)
Options<-WeatherMap.set.option(Options,'lat.min',-45)
Options<-WeatherMap.set.option(Options,'lat.max',45)
Options<-WeatherMap.set.option(Options,'lon.min',-60)
Options<-WeatherMap.set.option(Options,'lon.max',60)
Options<-WeatherMap.set.option(Options,'pole.lon',65)
Options<-WeatherMap.set.option(Options,'pole.lat',35)

Options$ice.points<-50000
#land<-WeatherMap.get.land(Options)


for(year in seq(1928,1928)) {


    image.name<-sprintf("Route/%04d.png",year)

    ifile.name<-sprintf("%s",image.name)

     png(ifile.name,
             width=1080*WeatherMap.aspect(Options),
             height=1080,
             bg=Options$sea.colour,
             pointsize=24,
             type='cairo')

    # Get the observations
    o<-read.fwf(file=sprintf('imma.annual/Pioneer.%d.imma',year),
                widths=c(4,2,2,4,5,6,84))
    o$Longitude<-o$V6/100
    o$Latitude<-o$V5/100

    Options$label<-sprintf("Pioneer %d",year)
       WeatherMap.draw(Options=Options,uwnd=NULL,icec=NULL,
                          vwnd=NULL,precip=NULL,mslp=NULL,
                          t.actual=NULL,t.normal=NULL,land=NULL,
                          fog=NULL,obs=o,streamlines=NULL)
dev.off()
}
