library(lattice)

ts<-read.table('time_per_page.txt')
is.na(ts$V1[ts$V1>3600])<-T
pdf(file='time_per_page.pdf',width=8,height=6,pointsize=12)
histogram(ts$V1,nint=100,xlab='Time between classifications (S)')
#tics<-c(1,2,5,10,20,50,100,200,500,1000,2000,5000)
#ticl<-as.character(tics)
#histogram(log(ts$V1),nint=100,xlab='Time between classifications (S)',
#		  scales=list(x=list(at=log(tics),labels=ticl)))
mean(ts$V1,na.rm=T)
median(ts$V1,na.rm=T)
