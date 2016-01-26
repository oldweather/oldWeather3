library(treemap)

ts<-read.table('pages_per_user.txt')
ts$V3<-as.character(runif(length(ts$V2),max=11)+1)
#ts$V3<-as.character(seq(1,length(ts$V2)))
pdf(file="pages_per_user.pdf",width=64,height=48,pointsize=50)
#tmPlot(ts,index='V1',vSize='V2',vColor='V1',type='linked',fontsize.labels=200,lowerbound.cex.labels=1,title='')
treemap(ts,index='V1',vSize='V2',vColor='V1',type='categorical',fontsize.labels=0,lowerbound.cex.labels=0,title='',position.legend='none')
