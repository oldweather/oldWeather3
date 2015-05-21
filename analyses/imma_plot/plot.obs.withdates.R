#!/usr/bin/Rscript --no-save

# Plot the locations of a set of IMMA observations

library(GSDF)
library(GSDF.WeatherMap)
library(IMMA)
library(gridBase)

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
dates<-chron(dates=sprintf("%04d-%02d-%02d",o$YR,o$MO,o$DY),
             times=sprintf("%02d:00:00",as.integer(o$HR)),
             format=c(dates = "y-m-d", times = "h:m:s"))
l2<-GSDF.ll.to.rg(o$LAT,o$LON,Options$pole.lat,Options$pole.lon)
obs.ll<-list()
obs.ll$Longitude<-l2$lon
obs.ll$Latitude<-l2$lat


png(file='imma.png',
             width=1080*aspect,
             height=1080/0.8,
             bg=Options$sea.colour,
             pointsize=24)

   plot.new()
   grid.newpage()
   pushViewport(viewport(x=unit(0,'npc'),y=unit(0.2,'npc'),
                         width = unit(1, "npc"), height = unit(0.8, "npc"),
                         just=c('left','bottom')))
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
   upViewport()
   pushViewport(viewport(x=unit(0,'npc'),y=unit(0.0,'npc'),
                         width = unit(1, "npc"), height = unit(0.2, "npc"),
                         just=c('left','bottom')))
      grid.rect(gp=gpar(col="white",fill="white"))
      par(fig=gridFIG(),new=TRUE,ps=24,
          mar=c(2,5,1,0)) # Fit base graphics in current grid viewport
      hist(as.POSIXct(dates),breaks='years',col='grey',freq=TRUE,main='',
           xlab='',ylab='No.of obs.')
   upViewport()
  dev.off()
warnings()
