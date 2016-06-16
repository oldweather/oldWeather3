# Convert Jeannette images to black and white

library(jpeg)

split.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Jeannette.split'
bw.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Jeannette.split.bw'
if(!file.exists(bw.dir)) dir.create(bw.dir,recursive=TRUE)

raw<-list.files(path=split.dir)
for(fn in raw) {
  system(sprintf("convert %s/%s -threshold 55%% %s/%s",
                 split.dir,fn,bw.dir,fn))
}
