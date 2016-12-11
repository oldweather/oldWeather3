
library(grid)
library(RColorBrewer)

ts<-list()
uids<-character(0)
dates<-character(0)
i<-1
for(file in list.files('by_ship')) {
    ts[[i]]<-read.table(sprintf("by_ship/%s",file),header=TRUE,stringsAsFactors=FALSE)
    ts[[i]]<-ts[[i]][order(ts[[i]]$Date),] # sort into date order
   uids<-unique(c(uids,names(ts[[i]])))
   dates<-unique(c(dates,ts[[i]]$Date))
   i<-i+1
}
dates<-sort(dates)
uids<-uids[2:length(uids)]

# Pad each frame so it has a row for each day - even if no transcription was done
# Otherwise the smoothing does not work as planned
pad.daily<-function(df) {
    nf<-data.frame(Date=dates)
    for(uid in names(df[2:length(names(df))])) {
        #if(is.null(df[[uid]])) next
        us<-rep(NA,length(dates))
        w<-which(!is.na(df[[uid]]))
        d.m<-match(df$Date[w],dates)
        us[d.m]<-df[[uid]][w]
        nf<-cbind(nf,us)
    }
    names(nf)<-names(df)
    return(nf)
}
for(i in seq_along(ts)) {
  ts[[i]]<-pad.daily(ts[[i]])
}

# Smooth the contributions - running mean over a week
smooth.weekly<-function(df) {
    f.week<-rep(1/7,7)
    for(i in seq_along(names(df))) {
       if(i==1) next # Dates
       w<-which(is.na(df[,i]))
       df[w,i]<-0
       df[,i]<-filter(df[,i],f.week,sides=2)
       w<-which(df[,i]==0)
       is.na(df[w,i])<-TRUE
    }
   return(df)
}
for(i in seq_along(ts)) {
  ts[[i]]<-smooth.weekly(ts[[i]])
}

total<-data.frame(Date=dates)
   for(uid in uids) {
      tot<-rep(0,length(dates))
      for(i in seq_along(ts)) {
        if(is.null(ts[[i]][[uid]])) next
	w<-which(!is.na(ts[[i]][[uid]]))
	if(length(w)==0) next
	d.m<-match(ts[[i]]$Date[w],dates)
	tot[d.m]<-tot[d.m]+ts[[i]][[uid]][w]
      }
      is.na(tot[tot==0])<-TRUE
      total<-cbind(total,tot)
   }
names(total)<-c('Dates',uids)

cols<-colorRampPalette(brewer.pal(8,"Dark2"))(length(ts))

start.time<-rep(1,length(uids))
end.time<-rep(length(dates),length(uids))
for(i in seq_along(uids)) {
    w<-which(!is.na(total[[uids[i]]]))
    start.time[i]<-min(w,na.rm=TRUE)
    end.time[i]<-max(w,na.rm=TRUE)
}

total.pp<-rep(NA,length(uids))
for(i in seq_along(uids)) {
   total.pp[i]<-sum(total[[uids[i]]],na.rm=TRUE)
}
o<-order(total.pp,decreasing=TRUE)
last.time<-rep(5,length(total.pp))


n.show<-4729 #length(total.pp)  # Show this many volunteers, largest to smallest
o[1:n.show]<-sample(o[1:n.show],size=n.show,replace=FALSE)
v.sep<-3  # Minimium separation between ribbons in pages
max.delta<-1 # Don't move any ribbon by more than this many pages/timestep
h.max<-length(dates) # Number of days

# Daily totals
d.max<-rep(NA,h.max)
d.count<-rep(NA,h.max)
for(day in seq(1:h.max)) {
   d.max[day]<-sum(total[day,o[1:n.show]],na.rm=TRUE)
   w<-which(start.time<=day & end.time>=day)
   d.count[day]<-length(w)
}
max.day.max<-max(d.max,na.rm=TRUE)

# Work out the page location for each ribbon
x.start<-array(dim=c(h.max,n.show))
x.end<-array(dim=c(h.max,n.show))
x.width<-array(dim=c(h.max,n.show))
for(v in 1:n.show) {
   for(day in seq(1:h.max)) {
      d.v.sep<-v.sep+(max.day.max-d.max[day])/d.count[day]
      if(v==1) x.start[day,v]<-1
      else x.start[day,v]<-x.end[day,v-1]
      n.done<-total[day,o[v]+1]
      if(is.na(n.done)) {
        n.done<-last.time[v]
        last.time[v]<-max(1,last.time[v]*0.9)
      }
      else last.time[v]<-n.done
      x.width[day,v]<-n.done
      x.end[day,v]<-x.start[day,v]+n.done+d.v.sep
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


pdf(file="ppdppps.pdf",
    width=23.4,height=33.1,pointsize=12)
    pushViewport(viewport(width=unit(0.98,'npc'),height=unit(0.995,'npc'))) # Padding
    for(day in seq(1:h.max)) {
      for(v in seq(1:n.show)) {
	  if(day<start.time[o[v]] || day>end.time[o[v]]) next
          n.done<-total[day,o[v]+1]
	  if(is.na(n.done)) {
	     gp<-gpar(col=rgb(.9,.9,.9,1),fill=rgb(.9,.9,.9,1))
	      st<-w.shift[day]+x.start[day,v]+(x.end[day,v]-x.start[day,v]-x.width[day,v])/2
	      x<-c(st,st+x.width[day,v])/w.max
	      y<-c(h.max-day-0.5,h.max-day+0.5)/h.max
	      grid.polygon(x=unit(c(x[1],x[2],x[2],x[1]),'npc'),
			   y=unit(c(y[1],y[1],y[2],y[2]),'npc'),
			   gp=gp)
         } else {
	      st<-w.shift[day]+x.start[day,v]+(x.end[day,v]-x.start[day,v]-x.width[day,v])/2
	      x<-c(st,st+x.width[day,v])/w.max
	      y<-c(h.max-day-0.5,h.max-day+0.5)/h.max
              uid<-uids[o[v]]
              for(i in seq_along(ts)) {
                 if(is.null(ts[[i]][[uid]])) next
                 w<-which(ts[[i]]$Date==dates[day])
                 if(length(w)==0) next
                 if(is.na(ts[[i]][[uid]][w])) next
                 gp<-gpar(col=cols[i],fill=cols[i])
                 x<-c(st,st+ts[[i]][[uid]][w])/w.max
                 st<-st+ts[[i]][[uid]][w]
                 grid.polygon(x=unit(c(x[1],x[2],x[2],x[1]),'npc'),
			   y=unit(c(y[1],y[1],y[2],y[2]),'npc'),
                              gp=gp)
             }
          }
 
        }
  }
dev.off()


