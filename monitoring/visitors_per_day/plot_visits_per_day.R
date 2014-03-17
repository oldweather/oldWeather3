library(chron)
library(grid)

ts<-read.table('Analytics.txt',header=T)
ts$Day<-chron(dates=as.character(ts$Day),
             times="12:00:00",
             format=c(dates = "m/d/y", times = "h:m:s"))
pdf(file="visits_per_day.pdf",
    width=8,height=6,pointsize=12)

range<-c(chron(dates='7/31/12',
             times="12:00:00",
             format=c(dates = "m/d/y", times = "h:m:s")),ts$Day[length(ts$Day)])
pushViewport(viewport(width=1,height=1,x=0,y=0,
	                  just=c("left","bottom"),name="vp_main"))
pushViewport(plotViewport(margins=c(5,5,1,1)))
pushViewport(dataViewport(range,c(0,1500)))
tics<-pretty(range)
grid.xaxis(at=tics,label=attr(tics,'label'),main=T)
grid.text('Date',y=unit(-3,"lines"))
grid.yaxis(main=T)
grid.text('No. of visits',x=unit(-3.5,"lines"), rot=90)
popViewport()
pushViewport(dataViewport(range,c(0,1500),clip='on'))
gp_blue  = gpar(col=rgb(0,0,1,1),fill=rgb(0,0,1,1))
grid.lines(x=unit(ts$Day,"native"),y=unit(ts$Visits,'native'),
               gp=gp_blue)
grid.points(x=unit(ts$Day,"native"),y=unit(ts$Visits,'native'),pch=20,
			               size=unit(3,"native"),gp=gp_blue)
popViewport() 
popViewport() 
upViewport()
