# Pack names onto a image to be used as credits

library(grid)
library(sp)
library(rgeos)
library(extrafont)
library(png)

znv.names<-read.table('names.merged',header=F)
znv.names$V1<-as.character(znv.names$V1)

points.x<-seq(96*2,1920-96*2,96*2)
points.y<-seq(27*2,1080-27*2,27*1.2)
points.x.full<-as.vector(matrix(data=rep(points.x,length(points.y)),
                                ncol=length(points.x),byrow=F))
points.y.full<-as.vector(matrix(data=rep(points.y,length(points.x)),
                                ncol=length(points.y),byrow=T))
occupied<-rep(FALSE,length(points.x)*length(points.y))
current.sp<-NULL
current.np<-NULL
              
#font.names<-fonts()[c(-1,-3,-10,-13,-14,-25,-26,-27,-28)] # iMac
font.names<-fonts()[c(-1,-2,-5,-7,-8,-10,-12,-14,-15,
                      -16,-18,-21,-27,-41,-42,-43,-46,
                      -49,-54,-55,-56)] # linux
base.gp<-gpar(fontfamily='Helvetica',font=1,col='black')

bg<-readPNG('ow_bkg.png')

# Open a new plot environment (file & viewport)
Open.plotenv<-function(i) {
  png(sprintf("images/dropon.%05d.png",i),
         width=1920,
         height=1080,
         bg='white',type='cairo',
         pointsize=48)
  pushViewport(dataViewport(c(0,1920),c(0,1080),
                             extension=0,gp=base.gp))
  oneinch <- as.numeric(convertUnit(unit(1, "inches"), "native"))
  return(oneinch)
}

# Draw the current set of points
Draw.current<-function(current.np) {
   grid.raster(bg,x=unit(0.5,'npc'),y=unit(0.5,'npc'),
                  width=unit(1,'npc'),height=unit(1,'npc'))
   for(i in seq(1,length(current.np))) {
        np<-current.np[[i]]
        grid.text(np$name,x=unit(np$x,'native'),
                          y=unit(np$y,'native'),
                          gp=np$gp)
      }
   dev.off()
 }

# Prune the oldest point
Prune.current<-function(occupied,current.np,current.sp) {
  occupied[current.np[[1]]$og]<-FALSE
  current.np[1]<-NULL
  slot(current.sp,"polygons")[1]<-NULL
  print(sprintf("Pruning: %d %d %d",length(which(occupied)),
                length(current.np),length(slot(current.sp,"polygons"))))
  return(list(sp=current.sp,np=current.np,oc=occupied))
}

# Add another name, pruning as necessary
Add.point<-function(i,occupied,current.np,current.sp) {
  
  failed<-0
  while(TRUE) {
       available<-seq(1,length(occupied))[which(!occupied)]
       ran.point<-as.integer(runif(1,1,length(available)+1))
       ran.x<-points.x.full[available[ran.point]]+runif(1,-30,30)
       ran.y<-points.y.full[available[ran.point]]+runif(1,-5,5)
       colour<-i%%2
       if(colour==1) colour<-rgb(0,0,0.5,runif(1,0.4,0.9))
       else colour<-rgb(0,0,0,runif(1,0.4,0.9))
       font.name<-font.names[i%%length(font.names)+1]
       p.gp<-gpar(fontfamily=font.name,font=i%%4+1,col=colour)
       np<-GetPolygon(znv.names$V1[i],ran.x,ran.y,p.gp,
                      oneinch,available[ran.point])
       coords<-np$sp@polygons[[1]]@Polygons[[1]]@coords
       # try again if off-screen
       if(min(coords[,1])<1 | max(coords[,1])>1920 |
          min(coords[,2])<1 | max(coords[,2])>1080) next
       # try again if overlaps existing word
      if(!is.null(current.sp) && gIntersects(np$sp,current.sp)) {
          failed<-failed+1
          if(failed>10) {
            ap<-Prune.current(occupied,current.np,current.sp)
            current.sp<-ap$sp
            current.np<-ap$np
            occupied<-ap$oc
            failed<-0
          }
          next
      }
      if(is.null(current.sp)) {
          current.sp<-np$sp
          current.np<-list(np)
          occupied[available[ran.point]]<-TRUE
      } else {
         current.sp <- SpatialPolygons(c(slot(current.sp,"polygons"),
                                         slot(np$sp,"polygons")))
         current.np[[length(current.np)+1]]<-np
         occupied[available[ran.point]]<-TRUE
      }
      return(list(sp=current.sp,np=current.np,oc=occupied))
     }
 }
    
# Get a spatial polygon associated with a given name
GetPolygon<-function(name,x,y,gp,oneinch,og) {
    tg<-textGrob(name,gp=gp)
    w.w<-as.numeric(widthDetails(tg))*oneinch*1.25
    w.h<-as.numeric(heightDetails(tg))*oneinch*1.5
    x.c<-c(x-w.w/2,x+w.w/2,x+w.w/2,x-w.w/2,x-w.w/2)
    y.c<-c(y-w.h/2,y-w.h/2,y+w.h/2,y+w.h/2,y-w.h/2)
    p<-Polygon(cbind(x.c,y.c))
    sp<-SpatialPolygons(list(Polygons(list(p),name)))
    return(list(name=name,x=x,y=y,p=p,sp=sp,gp=gp,og=og))
}
    
# Make the images - adding the names 2 at a time
for(n in seq(1,length(znv.names$V1),2)) {
  print(n)
  oneinch<-Open.plotenv(n)
  ap<-Add.point(n,occupied,current.np,current.sp)
  current.sp<-ap$sp
  current.np<-ap$np
  occupied<-ap$oc
  ap<-Add.point(n+1,occupied,current.np,current.sp)
  current.sp<-ap$sp
  current.np<-ap$np
  occupied<-ap$oc
  Draw.current(current.np)
  #if(n>1000) q('no')
}

