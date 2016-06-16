# Convert Rodgers images to black and white

library(jpeg)

split.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Rodgers.split'
bw.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Rodgers.split.bw'
if(!file.exists(bw.dir)) dir.create(bw.dir,recursive=TRUE)

raw<-list.files(path=split.dir)
for(fn in raw) {
  system(sprintf("convert %s/%s -threshold 75%% %s/%s",
                 split.dir,fn,bw.dir,fn))
}
