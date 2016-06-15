# Retrieve and Rename all vol3 high-resolution Jeannette images from NARA

local.dir<-'/scratch/hadpb/oW3_logbooks/NARA/Jeannette'
base.url<-'https://catalog.archives.gov/OpaAPI/media/6919193/content/arcmedia/dc-metro/rg-024/581208-noaa/jeannette/vol003of004/'
for(image in seq(2,209)) {
  image.url<-sprintf("%s/24-118-jeannette-vol003_%03d.jpg?download=true",base.url,image)
  destination.file<-sprintf("%s/24-118-jeannette-vol003_%03d.jpg",local.dir,image)
  download.file(image.url,destination.file,'wget')
}

