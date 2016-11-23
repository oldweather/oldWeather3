# Cut the Jeannette images into individual pages in the same way as
#  done on oldWeather.

library(jpeg)

original.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Jeannette'
split.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Jeannette.split'
if(!file.exists(split.dir)) dir.create(split.dir,recursive=TRUE)

raw<-list.files(path=original.dir)
for(fn in raw) {
  j<-readJPEG(sprintf("%s/%s",original.dir,fn))
  sp<-dim(j)[2]/2
  j1<-j[,1:(dim(j)[2]/2),]
  j2<-j[,(dim(j)[2]/2+1):dim(j)[2],]
  fn1<-sprintf("%s/%s_0.jpg",split.dir,substr(fn,18,27))
  writeJPEG(j1,fn1)
  fn2<-sprintf("%s/%s_1.jpg",split.dir,substr(fn,18,27))
  writeJPEG(j2,fn2)
  # Set the metadata to report 300dpi
  system(sprintf("mogrify -density 300 %s",fn1))
  system(sprintf("mogrify -density 300 %s",fn2))
}
