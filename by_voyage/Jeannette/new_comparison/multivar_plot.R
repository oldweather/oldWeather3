# Plot Pressure, AT, SST and ice - obs and reanalysis - along
# the voyage

library(grid)
library(chron)

o<-read.table('351.comparisons')
dates<-chron(dates=sprintf("%04d/%02d/%02d",o$V1,o$V2,o$V3),
             times=sprintf("%02d:00:00",o$V4),
             format=c(dates = "y/m/d", times = "h:m:s"))
o2<-read.table('354.comparisons')
dates2<-chron(dates=sprintf("%04d/%02d/%02d",o2$V1,o2$V2,o2$V3),
             times=sprintf("%02d:00:00",o2$V4),
             format=c(dates = "y/m/d", times = "h:m:s"))
tics=pretty(dates,n=7)
ticl=attr(tics,'labels')

pdf(file="Jeannette_comparison.pdf",
    width=10,height=10*sqrt(2),family='Helvetica',
    paper='special',pointsize=12)

# Pressure along the bottom with x axis
pushViewport(viewport(width=1.0,height=0.34,x=0.0,y=0.0,
                      just=c("left","bottom"),name="Page",clip='off'))
   pushViewport(plotViewport(margins=c(4,6,0,0)))
      pushViewport(dataViewport(dates,c(955,1055)))
            
         grid.xaxis(at=as.numeric(tics),label=ticl,main=T)
         grid.text('Date',y=unit(-3,'lines'))
         grid.yaxis(main=T)
         grid.text('Sea-level pressure (hPa)',x=unit(-4,'lines'),rot=90)
         

         # 351 Analysis spreads
         gp=gpar(col=rgb(0.8,0.8,1,1),fill=rgb(0.8,0.8,1,1))
         for(i in seq_along(o$V1)) {
            x<-c(dates[i]-0.125,dates[i]+0.125,
                 dates[i]+0.125,dates[i]-0.125)
            y<-c(o$V6[i]-(o$V7[i])*2,
                 o$V6[i]-(o$V7[i])*2,
                 o$V6[i]+(o$V7[i])*2,
                 o$V6[i]+(o$V7[i])*2)
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
         # 354 Analysis spreads
         gp=gpar(col=rgb(0.4,0.4,1,1),fill=rgb(0.4,0.4,1,1))
         for(i in seq_along(o2$V1)) {
            x<-c(dates2[i]-0.125,dates2[i]+0.125,
                 dates2[i]+0.125,dates2[i]-0.125)
            y<-c(o2$V6[i]-(o2$V7[i])*2,
                 o2$V6[i]-(o2$V7[i])*2,
                 o2$V6[i]+(o2$V7[i])*2,
                 o2$V6[i]+(o2$V7[i])*2)
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
            
        # Observation
         gp=gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1))
         grid.points(x=unit(dates,'native'),
                     y=unit(o$V5,'native'),
                     size=unit(0.2,'mm'),
                     pch=20,
                     gp=gp)
      popViewport()
   popViewport()
popViewport()
     
# AT next up
pushViewport(viewport(width=1.0,height=0.28,x=0.0,y=0.34,
                      just=c("left","bottom"),name="Page",clip='off'))
   pushViewport(plotViewport(margins=c(0,6,0,0)))
      pushViewport(dataViewport(dates,c(-55,30)))

         grid.yaxis(main=T)
         grid.text('Air temperature (C)',x=unit(-4,'lines'),rot=90)
         

         # 351 Analysis spreads
         gp=gpar(col=rgb(0.8,0.8,1,1),fill=rgb(0.8,0.8,1,1))
         for(i in seq_along(o$V1)) {
            x<-c(dates[i]-0.125,dates[i]+0.125,
                 dates[i]+0.125,dates[i]-0.125)
            y<-c(o$V9[i]-(o$V10[i])*2,
                 o$V9[i]-(o$V10[i])*2,
                 o$V9[i]+(o$V10[i])*2,
                 o$V9[i]+(o$V10[i])*2)
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
          # 354 Analysis spreads
         gp=gpar(col=rgb(0.4,0.4,1,1),fill=rgb(0.4,0.4,1,1))
         for(i in seq_along(o2$V1)) {
            x<-c(dates2[i]-0.125,dates2[i]+0.125,
                 dates2[i]+0.125,dates2[i]-0.125)
            y<-c(o2$V9[i]-(o2$V10[i])*2,
                 o2$V9[i]-(o2$V10[i])*2,
                 o2$V9[i]+(o2$V10[i])*2,
                 o2$V9[i]+(o2$V10[i])*2)
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
           
        # Observation
         gp=gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1))
         grid.points(x=unit(dates,'native'),
                     y=unit(o$V8,'native'),
                     size=unit(0.2,'mm'),
                     pch=20,
                     gp=gp)
      popViewport()
   popViewport()
popViewport()

# SST next up
pushViewport(viewport(width=1.0,height=0.28,x=0.0,y=0.34+0.28,
                      just=c("left","bottom"),name="Page",clip='off'))
   pushViewport(plotViewport(margins=c(0,6,0,0)))
      pushViewport(dataViewport(dates,c(-3,25)))

         grid.yaxis(main=T)
         grid.text('SST (C)',x=unit(-4,'lines'),rot=90)
         

         # 3.5.1 Analysis spreads
         gp=gpar(col=rgb(0.8,0.8,1,1),fill=rgb(0.8,0.8,1,1))
         for(i in seq_along(o$V1)) {
            x<-c(dates[i]-0.125,dates[i]+0.125,
                 dates[i]+0.125,dates[i]-0.125)
            y<-c(o$V12[i]-(o$V13[i])*2,
                 o$V12[i]-(o$V13[i])*2,
                 o$V12[i]+(o$V13[i])*2,
                 o$V12[i]+(o$V13[i])*2)
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
         # 3.5.4 Analysis spreads
         gp=gpar(col=rgb(0.4,0.4,1,1),fill=rgb(0.4,0.4,1,1))
         for(i in seq_along(o2$V1)) {
            x<-c(dates2[i]-0.125,dates2[i]+0.125,
                 dates2[i]+0.125,dates2[i]-0.125)
            y<-c(o2$V12[i]-(o2$V13[i])*2,
                 o2$V12[i]-(o2$V13[i])*2,
                 o2$V12[i]+(o2$V13[i])*2,
                 o2$V12[i]+(o2$V13[i])*2)
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
            
        # Observation
         gp=gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1))
         grid.points(x=unit(dates,'native'),
                     y=unit(o$V11,'native'),
                     size=unit(0.2,'mm'),
                     pch=20,
                     gp=gp)
      popViewport()
   popViewport()
popViewport()

# ice fraction
pushViewport(viewport(width=1.0,height=0.1,x=0.0,y=0.34+0.28+0.28,
                      just=c("left","bottom"),name="Page",clip='off'))
   pushViewport(plotViewport(margins=c(0,6,1,0)))
      pushViewport(dataViewport(dates,c(0,1)))

         grid.yaxis(main=T)
         grid.text('Ice fraction',x=unit(-4,'lines'),rot=90)
         
         # 351 Analysis value
         gp=gpar(col=rgb(0.8,0.8,1,1),fill=rgb(0.8,0.8,1,1))
         for(i in seq_along(o$V1)) {
            x<-c(dates[i]-0.225,dates[i]+0.225,
                 dates[i]+0.225,dates[i]-0.225)
            y<-c(0,0,o$V14[i],o$V14[i])
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
         # 351 Analysis value
         gp=gpar(col=rgb(0.4,0.4,1,1),fill=rgb(0.4,0.4,1,1))
         for(i in seq_along(o2$V1)) {
            x<-c(dates2[i]-0.225,dates2[i]+0.225,
                 dates2[i]+0.225,dates2[i]-0.225)
            y<-c(0,0,o2$V14[i],o2$V14[i])
            grid.polygon(x=unit(x,'native'),
                         y=unit(y,'native'),
                      gp=gp)
          }
        # Mark the period when frozen in
        iced<-chron(dates=sprintf("%04d/%02d/%02d",c(1879,1879,1881),c(9,9,6),c(14,14,12)),
                    times=sprintf("%02d:00:00",c(12,12,12)),
                    format=c(dates = "y/m/d", times = "h:m:s"))
         gp=gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1))
         grid.lines(x=unit(iced,'native'),
                    y=unit(c(0,1,1),'native'),
                     gp=gp)
            
      popViewport()
   popViewport()
popViewport()
