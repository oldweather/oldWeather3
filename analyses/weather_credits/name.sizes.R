# Get size of names when printed

library(grid)

# Set up a plot environment 
png('lengths.png',width=1080*16/9,
         height=1080,
         bg='white',type='cairo',
         pointsize=24)
base.gp<-gpar(family='Helvetica',font=1,col='black')
lon.min<--180
lon.max<- 180
lat.min<- -90
lat.max<-  90
pushViewport(dataViewport(c(lon.min,lon.max),c(lat.min,lat.max),
		            extension=0,gp=base.gp))

oneinch <- as.numeric(convertUnit(unit(1, "inches"), "native"))
n<-read.table('names.txt',header=F)
n$V1<-as.character(n$V1)
for(i in seq_along(n$V1)) {
  tg<-textGrob(as.character(n$V1[i]))
  cat(sprintf("\'%s' %f %f\n",n$V1[i],
               as.numeric(widthDetails(tg))*oneinch,
               as.numeric(heightDetails(tg))*oneinch))
}
