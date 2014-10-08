# Get pressures from 20CR, for a selected ship.

ship<-'Corwin'

library(GSDF.TWCR)
library(parallel)

# Get the observations for this ship
o<-read.fwf(file='imma.out', widths=c(4,2,2,4,5,6,36,5,4,5,12,5))
o$Longitude<-o$V6/100
o$Latitude<-o$V5/100
o$Pressure<-as.numeric(o$V8)/10
o$AT<-as.numeric(o$V10)/10
o$SST<-as.numeric(o$V12)/10
#w<-seq(1,1000) # Testing
#o<-o[w,]

# Get mean and spread from 3.2.1 for each ob.
  
get.comparisons<-function(i) {
  
  year<-o$V1[i]
  month<-o$V2[i]
  day<-o$V3[i]
  hour<-as.integer(o$V4[i]/100)
  t2m<-TWCR.get.slice.at.hour('air.2m',year,month,day,hour,
                              version='3.2.1',opendap=F)
  tt<-GSDF.interpolate.ll(t2m,o$Latitude[i],o$Longitude[i])  
  t2m<-TWCR.get.slice.at.hour('air.2m',year,month,day,hour,
                              type='spread',
                              version='3.2.1',opendap=F)
  tt.spread<-GSDF.interpolate.ll(t2m,o$Latitude[i],o$Longitude[i])  
  old<-TWCR.get.slice.at.hour('prmsl',year,month,day,hour,
                              version='3.2.1',opendap=F)
  mean<-GSDF.interpolate.ll(old,o$Latitude[i],o$Longitude[i])
  old<-TWCR.get.slice.at.hour('prmsl',year,month,day,hour,
                              type='spread',
                              version='3.2.1',opendap=F)
  spread<-GSDF.interpolate.ll(old,o$Latitude[i],o$Longitude[i])
  #if(i==10) break
  return(c(i,tt,tt.spread,mean,spread))
}

#lapply(seq_along(o$V1),get.comparisons)
r<-mclapply(seq_along(o$V1),get.comparisons,mc.cores=6)
r<-unlist(r)
odr<-r[seq(1,length(r),5)]
tt<-r[seq(2,length(r),5)]
tt.spread<-r[seq(3,length(r),5)]
mean<-r[seq(4,length(r),5)]
spread<-r[seq(5,length(r),5)]

# Output the result
fileConn<-file(sprintf("obs.%s",ship))
writeLines(sprintf("%d %d %d %d %f %f %f %f %f %f",
                   o$V1[odr],o$V2[odr],o$V3[odr],o$V4[odr],
                   o$Pressure[odr],mean/100,spread/100,
                   o$AT[odr],tt-273.15,tt.spread),
                   fileConn)
close(fileConn)
