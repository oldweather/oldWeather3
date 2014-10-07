# Plot a selected WD ship's pressure observations along with the
#  reanalysis mean and spread along her route.

ship<-'Jeannette'

library(grid)
library(chron)

o<-read.table(sprintf("obs.%s",ship))
o$Date<-chron(dates=sprintf("%04d/%02d/%02d",as.integer(o$V1),
                                             as.integer(o$V2),
                                             as.integer(o$V3)),
             times=sprintf("%02d:30:30",as.integer(o$V4/100)),
             format=c(dates = "y/m/d", times = "h:m:s"))
tics<-pretty(o$Date)

pdf(file=sprintf("%s_comparison.pdf",ship),
    width=10,height=6,family='Helvetica',
    paper='special',pointsize=12)

pushViewport(viewport(width=0.98,height=0.5,x=0.01,y=0.01,
                      just=c("left","bottom"),name="Page",clip='off'))
   pushViewport(plotViewport(margins=c(4,4.5,1,0)))
      pushViewport(dataViewport(o$Date,c(950,1050)))
      
      
         grid.xaxis(at=as.numeric(tics),label=attr(tics,'label'),main=T)
         grid.text('Date',y=unit(-3,'lines'))
         grid.yaxis(main=T)
         grid.text('Sea-level pressure (hPa)',x=unit(-4,'lines'),rot=90)
         

         # Analysis spreads
         gp=gpar(col=rgb(0.8,0.8,1,1),fill=rgb(0.8,0.8,1,1))
         for(i in seq_along(o$V1)) {
            x<-c(o$Date[i]-1/48,o$Date[i]+1/48,
                 o$Date[i]+1/48,o$Date[i]-1/48)
            y<-c(o$V6[i]-(o$V7[i])*2,
                 o$V6[i]-(o$V7[i])*2,
                 o$V6[i]+(o$V7[i])*2,
                 o$V6[i]+(o$V7[i])*2)
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
            
        # Observation
         gp=gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1))
         grid.points(x=unit(o$Date,'native'),
                     y=unit(o$V5,'native'),
                     size=unit(0.005,'npc'),
                     pch=20,
                     gp=gp)
      popViewport()
   popViewport()
upViewport()
     
pushViewport(viewport(width=0.98,height=0.5,x=0.01,y=0.51,
                      just=c("left","bottom"),name="Page",clip='off'))
   pushViewport(plotViewport(margins=c(0,4.5,1,0)))
      pushViewport(dataViewport(o$Date,c(-50,30)))
      
      
         grid.yaxis(main=T)
         grid.text('Air Temperature (C)',x=unit(-4,'lines'),rot=90)
         
         # Analysis
         gp=gpar(col=rgb(0.8,0.8,1,1),fill=rgb(0.8,0.8,1,1))
         for(i in seq_along(o$V1)) {
            x<-c(o$Date[i]-1/48,o$Date[i]+1/48,
                 o$Date[i]+1/48,o$Date[i]-1/48)
            y<-c(o$V9[i]-(o$V10[i])*2,
                 o$V9[i]-(o$V10[i])*2,
                 o$V9[i]+(o$V10[i])*2,
                 o$V9[i]+(o$V10[i])*2)
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
            
        # Observation
         gp=gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1))
         grid.points(x=unit(o$Date,'native'),
                     y=unit(o$V8,'native'),
                     size=unit(0.005,'npc'),
                     pch=20,
                     gp=gp)
      popViewport()
   popViewport()
popViewport()
