
library(chron)
library(grid)

ts<-read.table('time_per_day.txt')
ts$V1<-chron(dates=as.character(ts$V1),
             times="12:00:00",
             format=c(dates = "y-m-d", times = "h:m:s"))
ts$V2<-ts$V2/3600 # To hours
pdf(file="time_per_day.pdf",
    width=8,height=6,pointsize=12)

pushViewport(viewport(width=1,height=1,x=0,y=0,
	                  just=c("left","bottom"),name="vp_main"))
pushViewport(plotViewport(margins=c(5,5,1,1)))
pushViewport(dataViewport(ts$V1,c(0,max(ts$V2))))
tics<-pretty(ts$V1,n=7)
grid.xaxis(at=tics,label=attr(tics,'label'),main=T)
grid.text('Date',y=unit(-3,"lines"))
grid.yaxis(main=T)
grid.text('Transcribing time (person hours)',x=unit(-3.5,"lines"), rot=90)
gp_blue  = gpar(col=rgb(0,0,1,1),fill=rgb(0,0,1,1))
grid.lines(x=unit(ts$V1,"native"),y=unit(ts$V2,'native'),
               gp=gp_blue)
grid.points(x=unit(ts$V1,"native"),y=unit(ts$V2,'native'),pch=20,
			               size=unit(3,"native"),gp=gp_blue)
popViewport() 
popViewport() 
upViewport()
