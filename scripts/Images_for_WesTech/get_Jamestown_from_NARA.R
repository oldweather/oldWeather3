# Retrieve and Rename the first vol of high-resolution Jamestown images from NARA

local.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Jamestown'
base.url<-'https://catalog.archives.gov/OpaAPI/media/7284428/content/arcmedia/dc-metro/rg-024/581208-noaa/118/jamestown/vol001of067/'
for(image in seq(1,256)) {
  image.url<-sprintf("%s/24-118-jamestown-vol001of067_%03d.jpg?download=true",base.url,image)
  destination.file<-sprintf("%s/jamestown-vol001of067_%03d.jpg",local.dir,image)
  download.file(image.url,destination.file,'wget')
}

