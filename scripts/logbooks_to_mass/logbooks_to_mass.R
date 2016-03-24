# Transfer logbook images from Gina's disc to MO MASS system

ArchiveDir <- 'moose:/adhoc/users/philip.brohan/logbook_images/oW3_Gina/'
SourceDir <- '/media/External_119/data/Shipment to UK 2015-06-23'

process.dir<-function(dir.name) {
  #cat(dir.name,"\n")
  moose.dir<-sub(SourceDir,ArchiveDir,dir.name)
  moose.dir<-gsub("\\s+","_",moose.dir)
  moose.dir<-gsub("\\(","",moose.dir) # No brackets in mass
  moose.dir<-gsub("\\)","",moose.dir)
  moose.dir<-gsub("\\[","",moose.dir) # No brackets in mass
  moose.dir<-gsub("\\]","",moose.dir)
  cat("moo mkdir ",moose.dir,"\n")
  files<-list.files(dir.name,pattern="\\.") # only want jpgs really
  if(length(files)>0) pack.contents(dir.name,moose.dir)
  dirs<-list.dirs(dir.name,recursive=FALSE)
  for(dir in dirs) {
    process.dir(dir)
  }
}

pack.contents<-function(dir.name,moose.dir) {
  dir.base<-basename(dir.name)
  dir.base<-gsub("\\s+","_",dir.base)
  t.dir<-tempdir()
  tar.file<-sprintf("%s/%s.contents.tgz",tempdir(),dir.base)
  cat("cd \"",dir.name,"\"\n",sep="")
  command<-sprintf("tar -czf %s --no-recursion *.*",
                   tar.file)
  cat("mkdir -p ",t.dir,"\n")
  cat(command,"\n")
  cat("moo put ",tar.file,moose.dir,"\n")
  cat("rm -r ",t.dir,"\n")
}
  
process.dir(SourceDir)
