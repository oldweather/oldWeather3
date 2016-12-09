
library(lubridate)
library(grid)

ts<-read.table('ppdpp.out')
ts$V1<-ymd(ts$V1)

total.pp<-rep(NA,length(names(ts))-1)
for(i in seq_along(names(ts))) {
   if(i==1) next # Dates
   total.pp[i]<-sum(ts[,i],na.rm=TRUE)
}
o<-order(total.pp,decreasing=TRUE)
last.time<-rep(5,length(total.pp))
start.time<-rep(1,length(total.pp))
end.time<-rep(length(ts[,1]),length(total.pp))

# Smooth the contributions - running mean over a week
f.week<-rep(1/7,7)
for(i in seq_along(names(ts))) {
   if(i==1) next # Dates
   w<-which(is.na(ts[,i]))
   start.time[i]<-
   ts[w,i]<-0
   ts[,i]<-filter(ts[,i],f.week,sides=2)
   w<-which(ts[,i]==0)
   is.na(ts[w,i])<-TRUE
   w<-which(!is.na(ts[,i]))
   start.time[i]<-min(w,na.rm=TRUE)
   end.time[i]<-max(w,na.rm=TRUE)
}

n.show<-length(total.pp)  # Show this many volunteers, largest to smallest
o[1:n.show]<-sample(o[1:n.show],size=n.show,replace=FALSE)
v.sep<-3  # Minimium separation between ribbons in pages
max.delta<-1 # Don't move any ribbon by more than this many pages/timestep
h.max<-length(ts[,1]) # Number of days

# Work out the page location for each ribbon
x.start<-array(dim=c(h.max,n.show))
x.end<-array(dim=c(h.max,n.show))
x.width<-array(dim=c(h.max,n.show))
for(v in 1:n.show) {
   for(day in seq(1:h.max)) {
      if(v==1) x.start[day,v]<-1
      else x.start[day,v]<-x.end[day,v-1]
      n.done<-ts[day,o[v]]
      if(is.na(n.done)) {
        n.done<-last.time[v]
        last.time[v]<-max(1,last.time[v]*0.9)
      }
      else last.time[v]<-n.done
      x.width[day,v]<-n.done
      x.end[day,v]<-x.start[day,v]+n.done+v.sep
      if(day<start.time[o[v]] || day>end.time[o[v]]) x.end[day,v]<-x.start[day,v]
      if(day>1 && (x.end[day-1,v]-x.end[day,v])>max.delta){
        x.end[day,v]<-x.end[day-1,v]-max.delta
      }
    }
    for(day in h.max:1) {
      if(day<h.max && (x.end[day+1,v]-x.end[day,v])>max.delta){
        x.end[day,v]<-x.end[day+1,v]-max.delta
      }
    }
 }

w.max<-max(x.end,na.rm=TRUE) # Scale factor - full width

# shift to be centred
max.shift<-0.5
w.shift<-(w.max-x.end[,n.show])/2
w.fill<-which(w.shift==0)
for(day in w.fill+1:h.max) {
  if(is.na(w.shift[day])) next
  if((w.shift[day]-w.shift[day-1])>max.shift) {
    w.shift[day]<-w.shift[day-1]+max.shift
  }
  if((w.shift[day-1]-w.shift[day])>max.shift) {
    w.shift[day]<-w.shift[day-1]-max.shift
  }
}
for(day in w.fill-1:1) {
  if(is.na(w.shift[day])) next
  if((w.shift[day]-w.shift[day+1])>max.shift) {
    w.shift[day]<-w.shift[day+1]+max.shift
  }
  if((w.shift[day+1]-w.shift[day])>max.shift) {
    w.shift[day]<-w.shift[day+1]-max.shift
  }
}


pdf(file="ppdpp.pdf",
    width=23.4,height=33.1,pointsize=12)
    for(day in seq(1:h.max)) {
      for(v in seq(1:n.show)) {
          n.done<-ts[day,o[v]]
          gp<-gpar(col=rgb(1,0,0,1),fill=rgb(1,0,0,1))
	  if(is.na(n.done)) {
	     gp<-gpar(col=rgb(.9,.9,.9,1),fill=rgb(.9,.9,.9,1))
	  }
	  if(day<start.time[o[v]] || day>end.time[o[v]]) next
          st<-w.shift[day]+x.start[day,v]+(x.end[day,v]-x.start[day,v]-x.width[day,v])/2
	  x<-c(st,st+x.width[day,v])/w.max
	  y<-c(h.max-day-0.5,h.max-day+0.5)/h.max
	  grid.polygon(x=unit(c(x[1],x[2],x[2],x[1]),'npc'),
	               y=unit(c(y[1],y[1],y[2],y[2]),'npc'),
		       gp=gp)
        }
    }
dev.off()


