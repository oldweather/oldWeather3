# Compare data from Jeannette and 20CR 3.5.4

library(IMMA)
library(GSDF.TWCR)
library(parallel)

version<-'3.5.4'

# Get the observations for this ship
o<-IMMA.read('../../../imma/Jeannette.imma')
o$chron<-chron(dates=sprintf("%04d/%02d/%02d",o$YR,o$MO,o$DY),
             times=sprintf("%02d:00:00",as.integer(o$HR)),
             format=c(dates = "y/m/d", times = "h:m:s"))
# 3.5.4 starts on 1879-11-01 so chop any records from before this point
v354.start<-chron(dates="1879/11/01",times="06:00:00",
             format=c(dates = "y/m/d", times = "h:m:s"))
w<-which(o$chron>v354.start)
o<-o[w,]


# Fill in gaps in the obs series - just to make the reanalysis series continuous
o.add<-o[1,]
for(i in seq(1,length(o.add))) is.na(o.add[[i]])<-T
c.date<-o[2,]$chron+1
while(c.date<o[length(o$YR)-1,]$chron-1) {
   year<-as.integer(as.character(years(c.date)))
   month<-as.integer(months(c.date))
   day<-as.integer(days(c.date))
   for(hour in c(0,6,12,18)) {
      w<-which(o$YR==year & o$MO==month & o$DY==day & abs(o$HR-hour)<3)
      if(length(w)>0) next
      insert<-o.add
      insert$YR<-year
      insert$MO<-month
      insert$DY<-day
      insert$HR<-hour
      insert$chron<-chron(dates=sprintf("%04d/%02d/%02d",year,month,day),
                          times=sprintf("%02d:00:00",hour),
                          format=c(dates = "y/m/d", times = "h:m:s"))
      before<-max(which(o$chron<insert$chron))
      after<-min(which(o$chron>insert$chron))
      weight<-(as.numeric(insert$chron)-as.numeric(o[before,]$chron))/
              (as.numeric(o[after,]$chron)-as.numeric(o[before,]$chron))
      insert$LAT<-o[after,]$LAT*weight+o[before,]$LAT*(1-weight)
      insert$LON<-o[after,]$LON*weight+o[before,]$LON*(1-weight)
      w<-which(o$chron<insert$chron)
      o<-rbind(o[w,],insert,o[-w,])
   }
   c.date<-c.date+1
}

# Will probably run this more than once, cache the field accesses.
GSDF.cache.dir<-sprintf("%s/GSDF.cache",Sys.getenv('GSCRATCH'))

# Get means and spreads for each ob.
  
get.comparisons<-function(i) {
  
  if(any(is.na(o$YR[i]),is.na(o$MO[i]),is.na(o$DY[i]),
         is.na(o$HR[i]),is.na(o$LAT[i]),is.na(o$LON[i]))) {
    return(rep(NA,7))
  }
  # Only need reanalysis every 6 hours - don't bother with hourly
  if(as.integer(o$HR[i])%%6!=0) {
    return(rep(NA,7))
  }
  year<-o$YR[i]
  month<-o$MO[i]
  day<-o$DY[i]
  hour<-as.integer(o$HR[i])
  t2m<-TWCR.get.slice.at.hour('air.2m',year,month,day,hour,
                              version=version)
  t2m.mean<-GSDF.interpolate.ll(t2m,o$LAT[i],o$LON[i])  
  t2m<-TWCR.get.slice.at.hour('air.2m',year,month,day,hour,
                              type='spread',
                              version=version)
  t2m.spread<-GSDF.interpolate.ll(t2m,o$LAT[i],o$LON[i])  
  prmsl<-TWCR.get.slice.at.hour('prmsl',year,month,day,hour,
                              version=version)
  prmsl.mean<-GSDF.interpolate.ll(prmsl,o$LAT[i],o$LON[i])
  prmsl<-TWCR.get.slice.at.hour('prmsl',year,month,day,hour,
                              type='spread',
                              version=version)
  prmsl.spread<-GSDF.interpolate.ll(prmsl,o$LAT[i],o$LON[i])
  sst<-TWCR.get.slice.at.hour('sst',year,month,day,hour,
                              version=version)
  sst.mean<-GSDF.interpolate.ll(sst,o$LAT[i],o$LON[i],greedy=TRUE)  
  sst<-TWCR.get.slice.at.hour('sst',year,month,day,hour,
                              type='spread',
                              version=version)
  sst.spread<-GSDF.interpolate.ll(sst,o$LAT[i],o$LON[i],greedy=TRUE)  
  icec<-TWCR.get.slice.at.hour('icec',year,month,day,hour,
                              version=version)
  icec.mean<-GSDF.interpolate.ll(icec,o$LAT[i],o$LON[i],greedy=TRUE)  
  return(c(t2m.mean,t2m.spread,prmsl.mean,prmsl.spread,sst.mean,sst.spread,icec.mean))
}

#r<-lapply(seq(1,10),get.comparisons)
r<-lapply(seq_along(o$YR),get.comparisons)
#r<-mclapply(seq_along(o$YR),get.comparisons,mc.cores=1)
r<-unlist(r)
t2m.mean<-r[seq(1,length(r),7)]
t2m.spread<-r[seq(2,length(r),7)]
prmsl.mean<-r[seq(3,length(r),7)]
prmsl.spread<-r[seq(4,length(r),7)]
sst.mean<-r[seq(5,length(r),7)]
sst.spread<-r[seq(6,length(r),7)]
icec.mean<-r[seq(7,length(r),7)]

# Output the result
fileConn<-file(sprintf("354.comparisons"))
writeLines(sprintf("%d %d %d %d %f %f %f %f %f %f %f %f %f %f %f %f",
                   o$YR,o$MO,o$DY,as.integer(o$HR),
                   o$SLP,prmsl.mean/100,prmsl.spread/100,
                   o$AT,t2m.mean-273.15,t2m.spread,
                   o$SST,sst.mean-273.15,sst.spread,
                   icec.mean,o$LAT,o$LON),
                   fileConn)
close(fileConn)
