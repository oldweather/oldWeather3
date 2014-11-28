# Pack names onto a image to be used as credits

library(grid)
library(sp)
library(rgeos)
library(extrafont)
library(png)

znv.names<-read.table('name.lengths.24.out',header=F)
znv.names$V1<-as.character(znv.names$V1)

points.x<-seq(96*2,1920-96*2,96*2)
points.y<-seq(27*2,1080-27*2,27*1.2)
points.x.full<-as.vector(matrix(data=rep(points.x,length(points.y)),
                                ncol=length(points.x),byrow=F))
points.y.full<-as.vector(matrix(data=rep(points.y,length(points.x)),
                                ncol=length(points.y),byrow=T))
occupied<-rep(FALSE,length(points.x)*length(points.y))
              
bg<-readPNG('ow_bkg.png')

png('dropon.png',width=1920,
         height=1080,
         bg='white',type='cairo',
         pointsize=48)

# Get a spatial polygon associated with a given name
GetPolygon<-function(name,x,y,gp,oneinch) {
    tg<-textGrob(name,gp=gp)
    w.w<-as.numeric(widthDetails(tg))*oneinch*1.25
    w.h<-as.numeric(heightDetails(tg))*oneinch*1.5
    x.c<-c(x-w.w/2,x+w.w/2,x+w.w/2,x-w.w/2,x-w.w/2)
    y.c<-c(y-w.h/2,y-w.h/2,y+w.h/2,y+w.h/2,y-w.h/2)
    p<-Polygon(cbind(x.c,y.c))
    sp<-SpatialPolygons(list(Polygons(list(p),name)))
    return(list(name=name,x=x,y=y,p=p,sp=sp,gp=gp))
}
    

#font.names<-fonts()[c(-1,-3,-10,-13,-14,-25,-26,-27,-28)] # iMac
font.names<-fonts()[c(-1,-2,-5,-7,-8,-10,-12,-14,-15,
                      -16,-18,-21,-27,-41,-42,-43,-46,
                      -49,-54,-55,-56)] # linux
base.gp<-gpar(fontfamily='Helvetica',font=1,col='black')
poly.gp<-gpar(family='Helvetica',font=1,col='grey',fill='lightgrey')
pushViewport(dataViewport(c(0,1920),c(0,1080),
                            extension=0,gp=base.gp))
grid.raster(bg,x=unit(0.5,'npc'),y=unit(0.5,'npc'),
               width=unit(1,'npc'),height=unit(1,'npc'))

   oneinch <- as.numeric(convertUnit(unit(1, "inches"), "native"))

   failed<-0
   name.i<-1
   current.sp<-NULL
   while(failed<100 && name.i<=length(znv.names$V1)) {
       available<-seq(1,length(occupied))[which(!occupied)]
       ran.point<-as.integer(runif(1,1,length(available)+1))
       ran.x<-points.x.full[available[ran.point]]+runif(1,-30,30)
       ran.y<-points.y.full[available[ran.point]]+runif(1,-5,5)
       colour<-name.i%%2
       if(colour==1) colour<-rgb(0,0,0.5,runif(1,0.4,0.9))
       else colour<-rgb(0,0,0,runif(1,0.4,0.9))
       font.name<-font.names[name.i%%length(font.names)+1]
       p.gp<-gpar(fontfamily=font.name,font=failed%%4+1,col=colour)
       np<-GetPolygon(znv.names$V1[name.i],ran.x,ran.y,p.gp,oneinch)
       #np<-GetPolygon(sprintf("%s %d",font.name,name.i),
       #               ran.x,ran.y,p.gp,oneinch)
       coords<-np$sp@polygons[[1]]@Polygons[[1]]@coords
       # try again if off-screen
       if(min(coords[,1])<1 | max(coords[,1])>1920 |
          min(coords[,2])<1 | max(coords[,2])>1080) next
      if(!is.null(current.sp) && gIntersects(np$sp,current.sp)) {
          failed<-failed+1
          next
      }
      if(is.null(current.sp)) {
          current.sp<-np$sp
      } else {
         current.sp <- SpatialPolygons(c(slot(current.sp,"polygons"),
                                         slot(np$sp,"polygons")))
      }
           grid.text(np$name,x=unit(np$x,'native'),
                             y=unit(np$y,'native'),
                             gp=np$gp)
           name.i<-name.i+1
           occupied[available[ran.point]]<-TRUE               
           failed<-0
           next
    }
dev.off()
warnings()
