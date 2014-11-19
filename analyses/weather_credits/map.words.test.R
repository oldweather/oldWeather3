#!/usr/bin/Rscript --no-save

# Tweak the weather mapper to use words instead of lines

library(GSDF.TWCR)
library(GSDF.WeatherMap)

# Get the volunteer names
znv.names<-read.table('name.lengths.out',header=F)
znv.names$V1<-as.character(znv.names$V1)

# Override the draw streamlines function to draw a word instead
new.WeatherMap.draw.streamlines<-function(s,Options) {

   for(i in seq_along(s$status)) {     
      if(any(is.na(s[['x']][i,]))) next()
      gp<-gpar(col=rgb(.2,.2,.2,1),fill=rgb(.2,.2,.2,1),lwd=Options$wind.vector.lwd)
      if(!is.null(s[['t_anom']][i])) {
          level<-max(min((na.omit(s[['t_anom']][i]) +
                           Options$temperature.range)/
                           (Options$temperature.range*2),1),0)
          tp<-min(1-min(1,abs(level-0.5)*2),0.75)
          tp<-1.0-Options$wind.palette.opacity
          #tp<-tp*abs(s[['status']])
          gp<-GSDF.WeatherMap:::WeatherMap.streamline.getGC(level,transparency=tp,
                                          status=min(abs(s[['status']][i]),1),Options)
          #colour<-rgb(0,0,0,255,maxColorValue = 255)
          #gp<-gpar(col=colour,fill=colour,lwd=Options$wind.vector.lwd)
      }
      grid.text(znv.names$V1[i],x=unit((s[['x']][i,1]+s[['x']][i,2])/2,'native'),
                          y=unit((s[['y']][i,1]+s[['y']][i,2])/2,'native'),
                          rot=atan2(s[['y']][i,2]-s[['y']][i,1],
                                    s[['x']][i,2]-s[['x']][i,1])*180/pi,
                          gp=gp)
   }
}
unlockBinding("WeatherMap.draw.streamlines", as.environment("package:GSDF.WeatherMap"))
assignInNamespace("WeatherMap.draw.streamlines", new.WeatherMap.draw.streamlines,
                    ns="GSDF.WeatherMap", envir=as.environment("package:GSDF.WeatherMap"))
assign("WeatherMap.draw.streamlines", new.WeatherMap.draw.streamlines, as.environment("package:GSDF.WeatherMap"))
lockBinding("WeatherMap.draw.streamlines", as.environment("package:GSDF.WeatherMap"))

# Overide the point allocation algorithm to allow for the word length
new.WeatherMap.bridson<-function(Options,
                             previous=NULL,
                             scale.x=NULL,scale.y=NULL) {

    x.range<-c(Options$lon.min,Options$lon.max)
    y.range<-c(Options$lat.min,Options$lat.max)
    view.scale<-max(diff(x.range)/360,diff(y.range)/180)
    r.min<-Options$wind.vector.density*view.scale
    max.attempt<-Options$bridson.max.attempt
     
    # Choose background grid spacing close to r/sqrt(2)
    #  and which gives an integer number of points
    n.x<-as.integer(diff(x.range)/(r.min/sqrt(2)))
    r.x<-diff(x.range)/n.x
    n.y<-as.integer(diff(y.range)/(r.min/sqrt(2)))
    r.y<-diff(y.range)/n.y

    # Positions of point at each grid location
    #  NA if nothing there
    x<-rep(NA,n.x*n.y)
    y<-rep(NA,n.x*n.y)
    # Word index at each grid.location
    grid.word<-seq(1,n.x*n.y)

    # associate a word with each grid location
    grid.word<-seq(1,n.x*n.y)
    # Scale factors at each grid location
    scalef.x<-rep(1,n.x*n.y)
    scalef.y<-rep(1,n.x*n.y)
    if(!is.null(scale.x) && !is.null(scale.y)) {
        gp.x<-(seq(1,n.x)-0.5)*r.x+x.range[1]
        gp.y<-(seq(1,n.y)-0.5)*r.y+y.range[1]
        gp.x.full<-as.vector(matrix(data=rep(gp.x,n.y),ncol=n.x,byrow=F))
        gp.y.full<-as.vector(matrix(data=rep(gp.y,n.x),ncol=n.y,byrow=T))
        scalef.x<-abs(GSDF.interpolate.ll(scale.x,gp.y.full,gp.x.full))
        scalef.y<-abs(GSDF.interpolate.ll(scale.y,gp.y.full,gp.x.full))
        scalef.t<-sqrt(scalef.x**2+scalef.y**2)
        scalef.x<-(scalef.x/scalef.t)#(znv.names$V2[grid.word]+0.1)*10
        scalef.y<-(scalef.y/scalef.t)#(znv.names$V2[grid.word]+0.1)*10
    }
    #scalef.x<-rep(0.5,n.x*n.y)
    #scalef.y<-rep(0.5,n.x*n.y)

    # set of active points
    active<-integer(0)

    # Order of addition
    order.added<-integer(0)
    
    # Generate start point at random
    #x.c<-runif(1)*diff(x.range)+min(x.range)
    #y.c<-runif(1)*diff(y.range)+min(y.range)
    # start at top left
    x.c<-min(x.range) + r.min/2
    y.c<-max(y.range) - r.min/2
    index.c<-as.integer((y.c-min(y.range))/r.y)*n.x+
             as.integer((x.c-min(x.range))/r.x)+1
    active<-index.c
    x[index.c]<-x.c
    y[index.c]<-y.c
    order.added<-c(order.added,index.c)

    # If starting from a pre-existing set of points, load them
    # in random order, culling any too close to one already loaded.
    if(!is.null(previous)) {
        w<-which(previous$lat<min(y.range) |
                 previous$lat>max(y.range) |
                 previous$lon<min(x.range) |
                 previous$lon>max(x.range))
        if(length(w)>0) {
            previous$lat<-previous$lat[-w]
            previous$lon<-previous$lon[-w]
        }
    order<-sample.int(length(previous$lon))
    for(i in seq_along(order)) {
        index.i<-as.integer((previous$lat[i]-min(y.range))/r.y)*n.x+
                 as.integer((previous$lon[i]-min(x.range))/r.x)+1
        if(!is.na(x[index.i])) next
        cp<-GSDF.WeatherMap:::bridson.close.points(index.i,n.x,n.y)
        cp<-cp[!is.na(x[cp])]
        if(length(cp)>0) {
            d.s<-(((previous$lon[i]-x[cp])/scalef.x[cp])**2+
                  ((previous$lat[i]-y[cp])/scalef.y[cp])**2)
            if(min(d.s,na.rm=TRUE)<r.min**2) next
        }
        x[index.i]<-previous$lon[i]
        y[index.i]<-previous$lat[i]
        order.added<-c(order.added,index.i)
        # Ideally we'd set all points to active, but try
        #  only a subset - faster
        if(index.i%%7==0) active<-c(active,index.i)
      }
  }
    
    # Allocate more points to fill gaps
    while(length(active)>0) {
      c<-active[sample.int(length(active),1)] # Choose random active point
      cp<-GSDF.WeatherMap:::bridson.close.points(c,n.x,n.y)
      cp<-cp[!is.na(x[cp])]
         ns<-GSDF.WeatherMap:::bridson.annular.sample(n=max.attempt,x=x[c],y=y[c],r=r.min)
         w<-which(ns$y<y.range[1] | ns$y>y.range[2] |
            ns$x<x.range[1] | ns$x>x.range[2])
         if(length(w)>0) {
           ns$x<-ns$x[-w]
           ns$y<-ns$y[-w]
         }
         index.s<-as.integer((ns$y-y.range[1])/r.y)*n.x+
                     as.integer((ns$x-x.range[1])/r.x)+1
         w<-which(is.na(ns$x[index.s]))
         if(length(w)>0) { # At least one sample not in occupied box
           index.s<-index.s[w]
           ns$x<-ns$x[w]
           ns$y<-ns$y[w]
           if(length(cp)>0) { # At least one close point, so test necessary     
              d<-GSDF.WeatherMap:::bridson.min.distance(ns$x,ns$y,x[cp],y[cp],scalef.x[cp],scalef.y[cp])
              w<-which(d>r.min)
           } else w<-1 # no test - just take first point
           if(length(w)>0) { # new point
               x[index.s[w[1]]]<-ns$x[w[1]]
               y[index.s[w[1]]]<-ns$y[w[1]]
               active<-c(active,index.s[w[1]])
               order.added<-c(order.added,index.s[w[1]])
               next
           }
         }
         # All failed - remove current point from active list
         w<-which(active==c)
         active<-active[-w]
   }

    x<-x[order.added]
    y<-y[order.added]


    return(list(lon=x,lat=y))
  }
unlockBinding("WeatherMap.bridson", as.environment("package:GSDF.WeatherMap"))
assignInNamespace("WeatherMap.bridson", new.WeatherMap.bridson,
                    ns="GSDF.WeatherMap", envir=as.environment("package:GSDF.WeatherMap"))
assign("WeatherMap.bridson", new.WeatherMap.bridson, as.environment("package:GSDF.WeatherMap"))
lockBinding("WeatherMap.bridson", as.environment("package:GSDF.WeatherMap"))


uwnd<-TWCR.get.slice.at.hour('uwnd.10m',2006,3,12,6)
vwnd<-TWCR.get.slice.at.hour('vwnd.10m',2006,3,12,6)
prate<-TWCR.get.slice.at.hour('prate',2006,3,12,6)
#prmsl<-TWCR.get.slice.at.hour('prmsl',2006,3,12,6)
t.actual<-TWCR.get.slice.at.hour('air.2m',2006,3,12,6)
t.normal<-t.actual
#t.normal$data[]<-rep(285,length(t.normal$data))
icec<-TWCR.get.slice.at.hour('icec',2006,3,12,6)

Options<-WeatherMap.set.option(Options=NULL)
Options<-WeatherMap.set.option(Options,'show.mslp',F)
Options<-WeatherMap.set.option(Options,'show.ice',T)
Options$precip.points<-25000
Options$ice.points<-25000
Options$wind.vector.density<-Options$wind.vector.density*2
Options$wind.vector.scale<-Options$wind.vector.scale*1.75
Options$wind.vector.points<-2
Options$label<-"2006-03-12:06"
png('tst1.png',width=1080*16/9,
         height=1080,
         bg=Options$sea.colour,type='cairo')
w<-WeatherMap.draw(Options=Options,uwnd=uwnd,
                   vwnd=vwnd,precip=prate,mslp=prmsl,
	           t.actual=t.actual,t.normal=t.normal,icec=icec)
dev.off()
