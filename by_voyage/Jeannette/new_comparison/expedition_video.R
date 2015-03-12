# Show the Route of the ship along with a Reanalysis comparison

library(GSDF.WeatherMap)
library(chron)
library(GSDF)
library(GSDF.TWCR)
library(parallel)
library(IMMA)

v351<-read.table('351.comparisons')
v351$Dates<-chron(dates=sprintf("%04d/%02d/%02d",v351$V1,
                          v351$V2,v351$V3),
                    times=sprintf("%02d:00:00",v351$V4),
                       format=c(dates='y/m/d',times='h:m:s'))
v354<-read.table('354.comparisons')
v354$Dates<-chron(dates=sprintf("%04d/%02d/%02d",v354$V1,
                          v354$V2,v354$V3),
                    times=sprintf("%02d:00:00",v354$V4),
                       format=c(dates='y/m/d',times='h:m:s'))

lDates<-v351$Dates
tics=pretty(lDates,min.n=12)
ticl=attr(tics,'labels')

GSDF.cache.dir<-sprintf("%s/GSDF.cache",Sys.getenv('GSCRATCH'))
if(!file.exists(GSDF.cache.dir)) dir.create(GSDF.cache.dir,recursive=TRUE)
Imagedir<-sprintf("%s/images/Jeannette/",Sys.getenv('GSCRATCH'))
if(!file.exists(Imagedir)) dir.create(Imagedir,recursive=TRUE)

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
Range<-30
Options<-WeatherMap.set.option(Options,'lat.min',Range*-1)
Options<-WeatherMap.set.option(Options,'lat.max',Range)
Options<-WeatherMap.set.option(Options,'lon.min',Range*16/9*(1/2)*-1)
Options<-WeatherMap.set.option(Options,'lon.max',Range*16/9*(3/2))
Options<-WeatherMap.set.option(Options,'pole.lon',50)
Options<-WeatherMap.set.option(Options,'pole.lat',50)
Options<-WeatherMap.set.option(Options,'label.xp',0.49)
Options$ice.points<-50000

set.pole<-function(Date,Options) {
  start.date<-chron(dates='1879/06/25',
                    times="01:00:00",
                    format=c(dates='y/m/d',times='h:m:s'))
  date.1<-chron(dates='1879/08/25',
                    times="01:00:00",
                    format=c(dates='y/m/d',times='h:m:s'))
  date.2<-chron(dates='1879/11/025',
                    times="01:00:00",
                    format=c(dates='y/m/d',times='h:m:s'))
  if(Date<=start.date) {
    Options<-WeatherMap.set.option(Options,'pole.lon',50)
    Options<-WeatherMap.set.option(Options,'pole.lat',50)
  }
  if(Date>=date.2) {
    Options<-WeatherMap.set.option(Options,'pole.lon',150)
    Options<-WeatherMap.set.option(Options,'pole.lat',1)
  }
  if(Date>start.date & Date<date.1) {
    Options<-WeatherMap.set.option(Options,'pole.lon',
                      50-40*(Date-start.date)/(date.1-start.date))
    Options<-WeatherMap.set.option(Options,'pole.lat',
                      50-40*(Date-start.date)/(date.1-start.date))    
  }
  if(Date>date.1 & Date<date.2) {
    Options<-WeatherMap.set.option(Options,'pole.lon',
                      5+100*(Date-date.1)/(date.2-date.1))
    Options<-WeatherMap.set.option(Options,'pole.lat',
                      10-9*(Date-date.1)/(date.2-date.1))    
  }
  return(Options)
}
  


# Make the selected plot

plot.time<-function(c.date) {

   year=as.numeric(as.character(years(c.date)))
   month=months(c.date)
   day=days(c.date)
   hour=hours(c.date)
   
    image.name<-sprintf("%04d-%02d-%02d:%02d.png",year,month,day,hour)
    ifile.name<-sprintf("%s/%s",Imagedir,image.name)
    if(file.exists(ifile.name) && file.info(ifile.name)$size>1000) return()
    print(sprintf("%04d-%02d-%02d:%02d",year,month,day,hour))

    Options.local<-set.pole(c.date,Options)
    icec<-TWCR.get.slice.at.hour('icec',year,month,day,hour,
                                 version='3.5.1')
    
    png(ifile.name,
                 width=1080*16/9,
                 height=1080,
                 bg=Options.local$sea.colour,
                 pointsize=24,
                 type='cairo')
      Options.local$label<-sprintf("%04d-%02d-%02d",year,month,day)

      base.gp<-gpar(family='Helvetica',font=1,col='black')
      pushViewport(dataViewport(c(Options$lon.min,Options$lon.max),
                                c(Options$lat.min,Options$lat.max),
                                extension=0,gp=base.gp))

      ip<-WeatherMap.rectpoints(Options.local$ice.points,Options.local)
      WeatherMap.draw.ice(ip$lat,ip$lon,icec,Options.local)
      WeatherMap.draw.land(NULL,Options.local)

      w<-which(v351$Dates<c.date)  
      if(length(w)>0) {
          Options.local<-WeatherMap.set.option(Options.local,'obs.colour',
                                   rgb(150,150,150,55,maxColorValue=255))
          ot<-list(Longitude=v351$V16[w],
                   Latitude=v351$V15[w])
          WeatherMap.draw.obs(ot,Options.local)
     }
      w<-which(abs(v351$Dates-c.date)<1)
      if(length(w)>0) {
          w<-max(w)
          Options.local<-WeatherMap.set.option(Options.local,'obs.colour',
                                   rgb(255,0,0,255,maxColorValue=255))
          ot<-list(Longitude=v351$V16[w],
                   Latitude=v351$V15[w])
          WeatherMap.draw.obs(ot,Options.local)
     }
      if(Options.local$label != '') {
            WeatherMap.draw.label(Options.local)
      }

   # Add the data plots
    pushViewport(viewport(width=0.5,height=1.0,x=0.5,y=0.0,
                          just=c("left","bottom"),name="Page",clip='off'))

    # Plain background
    grid.polygon(x=unit(c(0,1,1,0),'npc'),y=unit(c(0,0,1,1),'npc'),
                 gp=gpar(col='white',fill='white'))

    drange<-c(max(c.date-150,v351$Dates[1]),
              min(c.date+150,v351$Dates[length(v351$Dates)]))
    w<-which(v351$Dates>=drange[1] & v351$Dates<=c.date )  
   # Pressure
    pushViewport(viewport(width=1.0,height=0.55,x=0.0,y=0.0,
                          just=c("left","bottom"),name="Page",clip='off'))
       pushViewport(plotViewport(margins=c(4,6,0,0)))
          pushViewport(dataViewport(drange,c(955,1055)))
         wt<-which(tics>drange[1] & tics<drange[2])
         grid.xaxis(at=as.numeric(tics[wt]),label=ticl[wt],main=T)
         grid.text('Date',y=unit(-3,'lines'))
         grid.yaxis(main=T)
         grid.text('Pressure (hPa)',x=unit(-4,'lines'),rot=90)
         gp=gpar(col=rgb(0.7,0.7,0.7,1),fill=rgb(0.7,0.7,0.7,1))
         if(length(w)>0) {
	     for(i in w) {
		x<-c(v351$Dates[i]-0.125,v351$Dates[i]+0.125,
		     v351$Dates[i]+0.125,v351$Dates[i]-0.125)
		y<-c(v351$V6[i]-(v351$V7[i])*2,
		     v351$V6[i]-(v351$V7[i])*2,
		     v351$V6[i]+(v351$V7[i])*2,
		     v351$V6[i]+(v351$V7[i])*2)
		grid.polygon(x=unit(x,'native'),
			     y=unit(y,'native'),
			  gp=gp)
	      }
         }
         w2<-which(v354$Dates<=c.date & v354$Dates>=drange[1])  
         gp=gpar(col=rgb(0.3,0.3,0.3,1),fill=rgb(0.3,0.3,0.3,1))
         if(length(w2)>0) {
	     for(i in w2) {
		x<-c(v354$Dates[i]-0.125,v354$Dates[i]+0.125,
		     v354$Dates[i]+0.125,v354$Dates[i]-0.125)
		y<-c(v354$V6[i]-(v354$V7[i])*2,
		     v354$V6[i]-(v354$V7[i])*2,
		     v354$V6[i]+(v354$V7[i])*2,
		     v354$V6[i]+(v354$V7[i])*2)
		grid.polygon(x=unit(x,'native'),
			     y=unit(y,'native'),
			  gp=gp)
	      }
         }
         if(length(w)>0) {
	     gp=gpar(col=rgb(1,0,0,1),fill=rgb(1,0,0,1))
	     grid.points(x=unit(v351$Dates[w],'native'),
			 y=unit(v351$V5[w],'native'),
			 size=unit(2,'mm'),
			 pch=20,
			 gp=gp)
         }
          popViewport()
       popViewport()
    popViewport()
   # Air temperature
    pushViewport(viewport(width=1.0,height=0.45,x=0.0,y=0.55,
                          just=c("left","bottom"),name="Page",clip='off'))
       pushViewport(plotViewport(margins=c(1,6,1,0)))
          pushViewport(dataViewport(drange,c(-55,30)))
         grid.yaxis(main=T)
         grid.text('Air temperature (C)',x=unit(-4,'lines'),rot=90)
         gp=gpar(col=rgb(0.7,0.7,0.7,1),fill=rgb(0.7,0.7,0.7,1))
         if(length(w)>0) {
	     for(i in w) {
		x<-c(v351$Dates[i]-0.125,v351$Dates[i]+0.125,
		     v351$Dates[i]+0.125,v351$Dates[i]-0.125)
		y<-c(v351$V9[i]-(v351$V10[i])*2,
		     v351$V9[i]-(v351$V10[i])*2,
		     v351$V9[i]+(v351$V10[i])*2,
		     v351$V9[i]+(v351$V10[i])*2)
		grid.polygon(x=unit(x,'native'),
			     y=unit(y,'native'),
			  gp=gp)
	      }
         }
         if(length(w2)>0) {
         gp=gpar(col=rgb(0.3,0.3,0.3,1),fill=rgb(0.3,0.3,0.3,1))
	     for(i in w2) {
		x<-c(v354$Dates[i]-0.125,v354$Dates[i]+0.125,
		     v354$Dates[i]+0.125,v354$Dates[i]-0.125)
		y<-c(v354$V9[i]-(v354$V10[i])*2,
		     v354$V9[i]-(v354$V10[i])*2,
		     v354$V9[i]+(v354$V10[i])*2,
		     v354$V9[i]+(v354$V10[i])*2)
		grid.polygon(x=unit(x,'native'),
			     y=unit(y,'native'),
			  gp=gp)
	      }
         }
         if(length(w)>0) {
	     gp=gpar(col=rgb(1,0,0,1),fill=rgb(1,0,0,1))
	     grid.points(x=unit(v351$Dates[w],'native'),
			 y=unit(v351$V8[w],'native'),
			 size=unit(2,'mm'),
			 pch=20,
			 gp=gp)
         }

          popViewport()
       popViewport()
    popViewport()

popViewport()
    
    dev.off()
    #gc(verbose=F)
}

Dates = list()
count=1
c.date<-chron(dates="1879/06/25",times="00:00:00",
          format=c(dates='y/m/d',times='h:m:s'))
e.date<-chron(dates="1881/06/11",times="23:59:59",
          format=c(dates='y/m/d',times='h:m:s'))

Dates = list()
count=1
while(c.date<e.date) {
  for(hour in c(0,6,12,18)) {
     Dates[[count]]<-c.date+hour/24
     count<-count+1
   }
  c.date<-c.date+1
}

#plot.time(Dates[[100]])

mclapply(Dates,plot.time,mc.cores=8,mc.preschedule=FALSE)
