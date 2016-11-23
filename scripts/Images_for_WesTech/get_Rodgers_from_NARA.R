# Retrieve and Rename all the high-resolution Rodgers images from NARA

local.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Rodgers'
base.url<-'https://catalog.archives.gov/OpaAPI/media/23665858/content/dc-metro/rg-024/581208/0002/Rodgers-b001of10'
for(image in seq(1,190)) {
  image.url<-sprintf("%s/Rodgers-b001of10_%04d.JPG?download=true",base.url,image)
  destination.file<-sprintf("%s/Rodgers-b001of10_%04d.jpg",local.dir,image)
  if(file.exists(destination.file)) next
  download.file(image.url,destination.file,'wget')
}

