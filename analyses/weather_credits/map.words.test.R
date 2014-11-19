#!/usr/bin/Rscript --no-save

# Tweak the weather mapper to use words instead of lines

library(GSDF.TWCR)
library(GSDF.WeatherMap)


# Override the draw streamlines function to draw a word instead
new.WeatherMap.draw.streamlines<-function(s,Options) {

   for(i in seq_along(s$status)) {     
      if(any(is.na(s[['x']][i,]))) next()
      gp<-gpar(col=rgb(.2,.2,.2,1),fill=rgb(.2,.2,.2,1),lwd=Options$wind.vector.lwd)
      if(!is.null(s[['t_anom']][i])) {
          level<-max(min((na.omit(s[['t_anom']][i]) +
                           Options$temperature.range)/
                           (Options$temperature.range*2),1),0)
          tp<-min(1-min(1,abs(level-0.5)*2),0.75)
          tp<-1.0-Options$wind.palette.opacity
          #tp<-tp*abs(s[['status']])
          gp<-GSDF.WeatherMap:::WeatherMap.streamline.getGC(level,transparency=tp,
                                          status=min(abs(s[['status']][i]),1),Options)
          #colour<-rgb(0,0,0,255,maxColorValue = 255)
          #gp<-gpar(col=colour,fill=colour,lwd=Options$wind.vector.lwd)
      }
      grid.text('testing',x=unit((s[['x']][i,1]+s[['x']][i,2])/2,'native'),
                          y=unit((s[['y']][i,1]+s[['y']][i,2])/2,'native'),
                          rot=atan2(s[['y']][i,2]-s[['y']][i,1],
                                    s[['x']][i,2]-s[['x']][i,1])*180/pi,
                          gp=gp)
   }
}
unlockBinding("WeatherMap.draw.streamlines", as.environment("package:GSDF.WeatherMap"))
assignInNamespace("WeatherMap.draw.streamlines", new.WeatherMap.draw.streamlines,
                    ns="GSDF.WeatherMap", envir=as.environment("package:GSDF.WeatherMap"))
assign("WeatherMap.draw.streamlines", new.WeatherMap.draw.streamlines, as.environment("package:GSDF.WeatherMap"))
lockBinding("WeatherMap.draw.streamlines", as.environment("package:GSDF.WeatherMap"))

uwnd<-TWCR.get.slice.at.hour('uwnd.10m',2006,3,12,6)
vwnd<-TWCR.get.slice.at.hour('vwnd.10m',2006,3,12,6)
prate<-TWCR.get.slice.at.hour('prate',2006,3,12,6)
#prmsl<-TWCR.get.slice.at.hour('prmsl',2006,3,12,6)
t.actual<-TWCR.get.slice.at.hour('air.2m',2006,3,12,6)
t.normal<-t.actual
#t.normal$data[]<-rep(285,length(t.normal$data))
icec<-TWCR.get.slice.at.hour('icec',2006,3,12,6)

Options<-WeatherMap.set.option(Options=NULL)
Options<-WeatherMap.set.option(Options,'show.mslp',F)
Options<-WeatherMap.set.option(Options,'show.ice',T)
Options$precip.points<-25000
Options$ice.points<-25000
Options$wind.vector.density<-Options$wind.vector.density*2
Options$wind.vector.scale<-Options$wind.vector.scale*1.75
Options$wind.vector.points<-2
Options$label<-"2006-03-12:06"
png('tst1.png',width=1080*16/9,
         height=1080,
         bg=Options$sea.colour,type='cairo')
w<-WeatherMap.draw(Options=Options,uwnd=uwnd,
                   vwnd=vwnd,precip=prate,mslp=prmsl,
	           t.actual=t.actual,t.normal=t.normal,icec=icec)
dev.off()
