#!/usr/bin/Rscript --no-save

# Pacific Centre for the 1890s, WD obs only

library(GSDF)
library(GSDF.WeatherMap)
library(GSDF.MERRA)
library(parallel)
library(chron)

year<-1894
month<-12
day<-11
hour<-0
start.hour<-hour
n.total<-24*4 # Total number of hours to be rendered
fog.threshold<-exp(1)

GSDF.cache.dir<-sprintf("%s/GSDF.cache",Sys.getenv('GSCRATCH'))
if(!file.exists(GSDF.cache.dir)) dir.create(GSDF.cache.dir,recursive=TRUE)
Imagedir<-sprintf("%s/images/oW3",Sys.getenv('GSCRATCH'))
if(!file.exists(Imagedir)) dir.create(Imagedir,recursive=TRUE)

use.cores<-2

c.date<-chron(dates=sprintf("%04d/%02d/%02d",year,month,day),
          times=sprintf("%02d:00:00",hour),
          format=c(dates='y/m/d',times='h:m:s'))

Options<-WeatherMap.set.option(NULL)
Options<-WeatherMap.set.option(Options,'show.mslp',F)
Options<-WeatherMap.set.option(Options,'show.ice',T)
Options<-WeatherMap.set.option(Options,'show.obs',T)
Options<-WeatherMap.set.option(Options,'show.fog',F)
Options<-WeatherMap.set.option(Options,'show.wind',F)
Options<-WeatherMap.set.option(Options,'show.temperature',F)
Options<-WeatherMap.set.option(Options,'show.precipitation',F)
Options<-WeatherMap.set.option(Options,'temperature.range',12)
Options<-WeatherMap.set.option(Options,'obs.size',1)
Options<-WeatherMap.set.option(Options,'obs.colour',rgb(255,215,0,255,
                                                       maxColorValue=255))
#Options<-WeatherMap.set.option(Options,'ice.colour',Options$land.colour)
Options<-WeatherMap.set.option(Options,'lat.min',-45)
Options<-WeatherMap.set.option(Options,'lat.max',45)
Options<-WeatherMap.set.option(Options,'lon.min',-60)
Options<-WeatherMap.set.option(Options,'lon.max',60)
Options<-WeatherMap.set.option(Options,'pole.lon',45)
Options<-WeatherMap.set.option(Options,'pole.lat',25)

Options$ice.points<-50000
land<-WeatherMap.get.land(Options)

imma.files<-list.files(path="../../imma")
obs<-data.frame()
for(file in imma.files) {
   obs<-rbind(obs,read.fwf(file=sprintf("../../imma/%s",file), widths=c(4,2,2,4,5,6,84)))
}
obs$Longitude<-obs$V6/100
obs$Latitude<-obs$V5/100
obs$ch<-chron(dates=sprintf("%04d/%02d/%02d",1980,obs$V2,obs$V3),
                times=sprintf("%02d:00:00",as.integer(obs$V4/100)),
                format=c(dates='y/m/d',times='h:m:s'))

obs.get.recent<-function(month,day,hour) {
   o.date<-chron(dates=sprintf("%04d/%02d/%02d",1980,month,day),
                times=sprintf("%02d:00:00",hour),
                format=c(dates='y/m/d',times='h:m:s'))
    w<-which(obs$ch>=o.date-2 & obs$ch<=o.date)
    if(length(w)==0) return(NULL)
    s.o<-obs[w,]
    return(s.o)
}   
obs.get.current<-function(month,day,hour) {
   o.date<-chron(dates=sprintf("%04d/%02d/%02d",1980,month,day),
                times=sprintf("%02d:00:00",hour),
                format=c(dates='y/m/d',times='h:m:s'))
    w<-which(obs$ch>=o.date-1 & obs$ch<=o.date)
    if(length(w)==0) return(NULL)
    current<-data.frame()
    s.o<-obs[w,]
    bs<-split(s.o,substr(s.o$V7,12,20)) # Split by ship
    for(i in seq(1,length(bs))) {
        by<-split(bs[[i]],bs[[i]]$V1) # Split by year
        for(y in seq(1,length(by))) {
            current<-rbind(current,by[[y]][length(by[[y]]$V1),])
        }
    }            
    return(current)
}   

plot.hour<-function(l.count) {    

    n.date<-c.date+l.count/24
    year<-as.numeric(as.character(years(n.date)))
    month<-months(n.date)
    day<-days(n.date)
    #hour<-hours(n.date)
    hour<-(l.count+start.hour)%%24

    image.name<-sprintf("%04d-%02d-%02d:%02d.png",year,month,day,hour)

    ifile.name<-sprintf("%s/%s",Imagedir,image.name)
    #if(file.exists(ifile.name) && file.info(ifile.name)$size>0) return()
    print(sprintf("%d %04d-%02d-%02d:%02d - %s",l.count,year,month,day,hour,
                   Sys.time()))

        icec<-MERRA.get.slice.at.hour('FRSEAICE',1980,month,day,hour)
   

     png(ifile.name,
             width=1080*WeatherMap.aspect(Options),
             height=1080,
             bg=Options$sea.colour,
             pointsize=24,
             type='cairo')
    Options$label<-sprintf("%02d-%02d",month,day)
          base.gp<-gpar(family='Helvetica',font=1,col='black',fontsize=24)
          pushViewport(dataViewport(c(Options$lon.min,Options$lon.max),
                                    c(Options$lat.min,Options$lat.max),
                                    extension=0,gp=base.gp))
          ip<-WeatherMap.rectpoints(Options$ice.points,Options)
          if(Options$show.ice) {
             if(is.null(icec)) stop("No icec provided")
             WeatherMap.draw.ice(ip$lat,ip$lon,icec,Options)
          }
          WeatherMap.draw.land(land,Options)
          o.r<-obs.get.recent(month,day,hour)
          if(!is.null(o.r)) {
              Options<-WeatherMap.set.option(Options,'obs.colour',
                                           rgb(255,215,0,50,maxColorValue=255))
               WeatherMap.draw.obs(o.r,Options)
          }
          o.c<-obs.get.current(month,day,hour)
          if(!is.null(o.c)) {
              Options<-WeatherMap.set.option(Options,'obs.colour',
                                           rgb(255,0,0,255,maxColorValue=255))
               WeatherMap.draw.obs(o.c,Options)
          }
            WeatherMap.draw.label(Options)
          upViewport()
        dev.off()
}

r<-mclapply(seq(0,n.total,2),plot.hour,mc.cores=use.cores,mc.preschedule=FALSE)
