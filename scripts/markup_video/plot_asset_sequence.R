# R script to visualise transcriptions for an asset
#  reads in data from a JSON structure
#  make a sequence of plots for a video

library(rjson)
library(grid)

asset<-fromJSON(file='tst.js')

gp_black        <- gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1))
gp_grey         <- gpar(col=rgb(0.7,0.7,0.7,1),fill=rgb(0.7,0.7,0.7,1))
gp_weather      <- gpar(col=rgb(0,0.38,0.38,0.05),fill=rgb(0,0.38,0.38,0.05))
gp_weather_link <- gpar(col=rgb(0,0.38,0.38,0.15),fill=rgb(0,0.38,0.38,0.15))
gp_event        <- gpar(col=rgb(0.80,0.19,0.14,0.25),fill=rgb(0.80,0.19,0.14,0.25))
gp_event_link   <- gpar(col=rgb(0.80,0.19,0.14,0.75),fill=rgb(0.80,0.19,0.14,0.75))
gp_date         <- gpar(col=rgb(0.13,0.13,0.13,0.25),fill=rgb(0.13,0.13,0.13,0.25))
gp_location     <- gpar(col=rgb(0.33,0.24,0.11,0.15),fill=rgb(0.33,0.24,0.11,0.15))
gp_location_link<- gpar(col=rgb(0.33,0.24,0.11,0.25),fill=rgb(0.33,0.24,0.11,0.25))
gp_cW           <- gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1),fontfamily='mono',
                        fontsize=14)
gp_cWb          <- gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1),fontfamily='mono',
                        fontsize=14,fontface='bold')
gp_cWx          <- gpar(col=rgb(1,0,0,1),fill=rgb(1,0,0,1),fontfamily='mono',
                        fontsize=14,fontface='bold')
gp_cW1          <- gpar(col=rgb(0,0,0,1),fill=rgb(0,0,0,1),fontfamily='mono',
                        fontsize=14,fontface='italic')

TextLeft <- 0.5 # x position of the left-had edge of the text part of the page
image.width<-(as.numeric(asset[['width']])/as.numeric(asset[['height']]))*0.88*(720/1280)
if(image.width+0.05 > 0.5) TextLeft <- image.width+0.05

# Get the height on the page for the various
#  categories of annotation.
get.date.height<-function() {
	return(0.96)
}
get.position.height<-function() {
	return(0.93)
}
get.weather.height<-function(n.weather) {
	return(0.88-(0.75/32)*(n.weather-1))
}
get.event.height<-function(n.weather,n.event,Events) {
	base<-get.weather.height(n.weather+1.5)
	if(n.event>1) {
		for(i in seq(1,(n.event-1))) {
			base<-base-1/55-length(Events[[i]][['lines']])*(1/60)
		}
	}
	return(base)
}

# Draw a line linking the annotation box with its cannonical text.
#   Call this (and all the other drawing functions) from the full page viewport.
draw.link<-function(annotation,text.y=0) {
   y.left<-page.boundaries[4]+page.boundaries[2]*(1-as.numeric(annotation[['bounds']][['y']])-
                           as.numeric(annotation[['bounds']][['height']])/2)
   x.left<-page.boundaries[3]+page.boundaries[1]*(as.numeric(annotation[['bounds']][['x']])+
                            as.numeric(annotation[['bounds']][['width']]))
   x.right<-0
   y.right<-0
   gp<-gp_black
   if(!is.null(annotation[['data']][['air_temperature']])) {
      y.right<-text.y
      x.right<-TextLeft-0.01
      gp<-gp_weather_link
   }
   if(!is.null(annotation[['data']][['date']])) {
      y.right<-text.y
      x.right<-TextLeft-0.01
      gp<-gp_date
   }
   if(!is.null(annotation[['data']][['latitude']])) {
      y.right<-text.y
      x.right<-TextLeft-0.01
      gp<-gp_location_link
   }
   if(!is.null(annotation[['data']][['event']])) {
      y.right<-text.y
      x.right<-TextLeft-0.01
      gp<-gp_event_link
   }
   grid.lines(x=unit(c(x.left,x.right),'npc'),
              y=unit(c(y.left,y.right),'npc'),
              gp=gp)
}

# Overlay the box associated with an annotation on the page image
plot.box<-function(annotation,gp) {
    if(is.null(annotation[['bounds']]) || is.null(annotation[['bounds']][['x']]) ||
       is.null(annotation[['bounds']][['y']]) || is.null(annotation[['bounds']][['width']]) ||
       is.null(annotation[['bounds']][['height']])) return()
   pushViewport(viewport(width=page.boundaries[1],height=page.boundaries[2],
                        x=page.boundaries[3],y=page.boundaries[4],
                         just=c("left","bottom"),name="vp_page"))
   grid.polygon(x=unit(c(as.numeric(annotation[['bounds']][['x']]),
                          as.numeric(annotation[['bounds']][['x']])+
                          as.numeric(annotation[['bounds']][['width']]),
                          as.numeric(annotation[['bounds']][['x']])+
                          as.numeric(annotation[['bounds']][['width']]),
                          as.numeric(annotation[['bounds']][['x']])),'npc'),
                 y=unit(c(1-as.numeric(annotation[['bounds']][['y']]),
                          1-as.numeric(annotation[['bounds']][['y']]),
                          1-as.numeric(annotation[['bounds']][['y']])-
                               as.numeric(annotation[['bounds']][['height']]),
                          1-as.numeric(annotation[['bounds']][['y']])-
                               as.numeric(annotation[['bounds']][['height']])),'npc'),
                 gp=gp)
   upViewport(0)

}

# Print given event text at specified location
plot.Event.line<-function(value,base.x,base.y) {
    grid.text(value,x=unit(base.x,'npc'),
                    y=unit(base.y,'npc'),
                    just=c('left','centre'),
                    gp=gp_cW)
}
# Print given text value at specified location
#  qc controls plot font.
plot.WVariable<-function(value,qc,base.x,base.y,step.x) {
   if(!is.null(value)) {
      if(qc=='U') {
          grid.text(value,x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cWb)
      }
      if(qc=='M' || qc=='D') {
          grid.text(value,x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cW)
      }
      if(qc=='1') {
          grid.text(value,x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cW1)
       }
      if(qc=='X') {
          grid.text('XX',x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cWx)
       }
   }
#   base.x<-base.x+step.x
#   grid.text(':',x=unit(base.x,'npc'),
#                    y=unit(base.y,'npc'),
#                     just=c('left','centre'),
#                    gp=gp_cW)
   
}
plot.VLabel<-function(value,base.x,base.y) {
          grid.text(value,x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cWb)
}

# Print cannonical date
plot.CDate<-function(cD,base.x,base.y) {
   value<-cD[['data']][['date']]
   qc<-cD[['qc']][['date']]
   if(!is.null(value)) {
      if(qc=='U') {
          grid.text(value,x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cWb)
      }
      if(qc=='M' || qc == 'D') {
          grid.text(value,x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cW)
      }
      if(qc=='1') {
          grid.text(value,x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cW1)
       }
      if(qc=='X') {
          grid.text('XX',x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cWx)
       }
   }
   else {
	          grid.text(value,x=unit(base.x,'npc'),
                          y=unit(base.y,'npc'),
                          just=c('left','centre'),
                          gp=gp_cWb)
      }
}

# Plot cannonical position
plot.CPosition<-function(cD,base.x,base.y) {
   lat.source<-' '
   for(v in c('latitude','portlat')) {
	if(!is.null(cD[['data']][[v]]) && nchar(cD[['data']][[v]])>2) {
		lat.source<-v
		break
	}
   }
   lon.source<-' '
   for(v in c('longitude','portlon')) {
	if(!is.null(cD[['data']][[v]]) && nchar(cD[['data']][[v]])>2) {
		lon.source<-v
		break
	}
   }
   for(v in c(lat.source,lon.source,'port')) {
           value<-cD[['data']][[v]]
	   if(!is.null(value)) value<-iconv(value, "", "ASCII", sub="") # Strip non-ascii characters
	   qc<-cD[['qc']][[v]]
	   if(!is.null(value) && nchar(value)>2) {
	      if(qc=='U') {
	          grid.text(value,x=unit(base.x,'npc'),
	                          y=unit(base.y,'npc'),
	                          just=c('left','centre'),
	                          gp=gp_cWb)
	      }
	      if(qc=='M' || qc == 'D') {
	          grid.text(value,x=unit(base.x,'npc'),
	                          y=unit(base.y,'npc'),
	                          just=c('left','centre'),
	                          gp=gp_cW)
	      }
	      if(qc=='1') {
	          grid.text(value,x=unit(base.x,'npc'),
	                          y=unit(base.y,'npc'),
	                          just=c('left','centre'),
	                          gp=gp_cW1)
	       }
	      if(qc=='X') {
	          grid.text(value,x=unit(base.x,'npc'),
	                          y=unit(base.y,'npc'),
	                          just=c('left','centre'),
	                          gp=gp_cW1)
	       }
	       base.x<-base.x+0.07
	   }  
   }
}

# Print the cannonical weather record for one hour
plot.CWeather<-function(cW,hour,base.x,base.y,header=F) {
  grid.text(sprintf("%02d: ",hour),x=unit(base.x,'npc'),
                    y=unit(base.y,'npc'),
                     just=c('left','centre'),
                    gp=gp_cW)
   base.x<-base.x+0.03
   if(header)  plot.VLabel('Air',base.x,base.y+0.75/32)
   plot.WVariable(cW[['data']][['air_temperature']],cW[['qc']][['air_temperature']],
                  base.x,base.y,0.05)
    base.x<-base.x+0.05
   if(header)  plot.VLabel('Bulb',base.x,base.y+0.75/32)
   plot.WVariable(cW[['data']][['bulb_temperature']],cW[['qc']][['bulb_temperature']],
                  base.x,base.y,0.05)
    base.x<-base.x+0.05
   if(header)  plot.VLabel('Sea',base.x,base.y+0.75/32)
   plot.WVariable(cW[['data']][['sea_temperature']],cW[['qc']][['sea_temperature']],
                  base.x,base.y,0.05)
    base.x<-base.x+0.05
   if(header)  plot.VLabel('Bar',base.x,base.y+0.75/32)
   plot.WVariable(cW[['data']][['height_1']],cW[['qc']][['height_1']],
                  base.x,base.y,0.05)
    base.x<-base.x+0.05
   if(header)  plot.VLabel('Attch',base.x,base.y+0.75/32)
   plot.WVariable(cW[['data']][['height_2']],cW[['qc']][['height_2']],
                  base.x,base.y,0.05)
    base.x<-base.x+0.05
   if(header)  plot.VLabel('Wind',base.x,base.y+0.75/32)
   plot.WVariable(cW[['data']][['wind_direction']],cW[['qc']][['wind_direction']],
                  base.x,base.y,0.05)
    base.x<-base.x+0.07
   if(header)  plot.VLabel('Force',base.x,base.y+0.75/32)
   plot.WVariable(cW[['data']][['wind_force']],cW[['qc']][['wind_force']],
                  base.x,base.y,0.05)
    base.x<-base.x+0.05
   if(header)  plot.VLabel('Code',base.x,base.y+0.75/32)
   plot.WVariable(cW[['data']][['weather_code']],cW[['qc']][['weather_code']],
                  base.x,base.y,0.05)
    base.x<-base.x+0.05
}

# Sort the events and split into lines - truncating where necessary
# Everything other than date, position and weather is an event
gather.events<-function(asset,max.lines=30,max.characters=75) {
   events<-list()
   s<-rep(NA,1000)
   count<-0
   for(transcription in asset[['transcriptions']]) {
      for(annotation in transcription[['annotations']]) {
         if(!is.null(annotation[['data']][['undefined']])) {
		     annotation[['data']][['event']]<-annotation[['data']][['undefined']]
		 }
         if(!is.null(annotation[['data']][['mention_type']])) {
		     annotation[['data']][['event']]<- sprintf("%s - %s",
			   annotation[['data']][['mention_name']],
			   annotation[['data']][['mention_context']])
		 }
         if(!is.null(annotation[['data']][['fuel_type']])) {
		     annotation[['data']][['event']]<- sprintf("%s: %s - %s",
			   annotation[['data']][['fuel_type']],
			   annotation[['data']][['fuel_ammount']],
			   annotation[['data']][['fuel_additional_info']])
		 }
         if(!is.null(annotation[['data']][['animal_type']])) {
		     annotation[['data']][['event']]<- sprintf("%s: %s",
			   annotation[['data']][['animal_type']],
			   annotation[['data']][['animal_amount']])
		 }
         if(!is.null(annotation[['data']][['event']])) {
		     count<-count+1
		     events[[count]]<-annotation
		     s[count]<-as.numeric(annotation[['bounds']][['y']])+
		               as.numeric(annotation[['bounds']][['height']])/2
		}
	  }
   }
   s<-s[1:count]
   events<-events[order(s,decreasing=F)]
   lines<-list()
   lengths<-rep(0,count)
   for(i in seq_along(events)) {
	lines[[i]]<-strwrap(events[[i]][['data']][['event']],width=max.characters)
	lengths[i]<-length(lines[[i]])	
   }
   if(sum(lengths)>max.lines) { # Won't fit - truncate the longer events
	   l.max<-max(lengths)
	   while(sum(pmin(lengths,l.max))>max.lines) l.max<-l.max-1
	   if(l.max<1) l.max=1 # Won't fit, best we can do
	   for(i in seq_along(lines)) {
		if(lengths[i]>l.max) {
			lines[[i]]<-lines[[i]][1:l.max]
			lines[[i]][[l.max]]<-paste(lines[[i]][[l.max]],' ...')
		} 
	   }
	}
   for(i in seq_along(events)) events[[i]][['lines']]<-lines[[i]]
   return(events)
}

# Left hand side is image of page, overlain with boxes
image.width<-(as.numeric(asset[['width']])/as.numeric(asset[['height']]))*0.88*(720/1280)
page.boundaries<-c(image.width,0.88,0.036,0.06)

# Count the hours of weather, so we can estimate how much space
#  will be left for events
n.weather<-0
for(hour in 1:24) {
   if(length(asset[['CWeather']]) > hour &&
      !is.null(asset[['CWeather']][[hour+1]])) n.weather<-n.weather+1
}
Events<-gather.events(asset,max.lines<-30-n.weather) 

# Main loop - every time through the loop makes one more frame,
#   break later each time through, so each frame has a little more markup

for (pCount in 1:1000) {
	
   iCount<-1
   if(pCount>1) dev.off()
   png(filename=sprintf("images/asset_%04d.png",pCount),width=1280,height=720,bg='transparent')

   # First image has only page and ID and URL
   grid.text(asset[['_id']],x=unit(0.036,'npc'),
                            y=unit(0.03,'npc'),
                            just=c('left','centre'),
                            gp=gp_black)
   grid.text(asset[['location']],x=unit(0.016,'npc'),
                            y=unit(0.97,'npc'),
                            just=c('left','centre'),
                            gp=gp_black)
   if(iCount>=pCount) next

   # Second image also has date
   if(!is.null(asset[['CDate']])) {
      plot.CDate(asset[['CDate']],TextLeft,get.date.height())
      for(transcription in asset[['transcriptions']]) {
         for(annotation in transcription[['annotations']]) {
            if(!is.null(annotation[['data']][['date']])) {
               plot.box(annotation,gp_date)
               draw.link(annotation,get.date.height())
            }
         }
      }
      iCount<-iCount+1
   }
   if(iCount>=pCount) next 

   # 3rd image has date and position
   if(!is.null(asset[['CPosition']])) {
      plot.CPosition(asset[['CPosition']],TextLeft,get.position.height())
      for(transcription in asset[['transcriptions']]) {
         for(annotation in transcription[['annotations']]) {
            if(!is.null(annotation[['data']][['latitude']])) {
               plot.box(annotation,gp_location)
               draw.link(annotation,get.position.height())
            }
         }
      }
      iCount<-iCount+1
   }
   if(iCount>=pCount) next 

   # One new image for each hour's weather observations
   hour.count<-0
   for(hour in 1:24) {
      if(length(asset[['CWeather']]) > hour &&
         !is.null(asset[['CWeather']][[hour+1]])) {
		 hour.count<-hour.count+1
		 header<-F
		 if(hour.count==1) header=T
         plot.CWeather(asset[['CWeather']][[hour+1]],hour,TextLeft,
                       get.weather.height(hour.count),header)
         for(transcription in asset[['transcriptions']]) {
            for(annotation in transcription[['annotations']]) {
               if(!is.null(annotation[['data']][['Chour']]) &&
                  annotation[['data']][['Chour']]==hour) {
                  plot.box(annotation,gp_weather)
                  draw.link(annotation,get.weather.height(hour.count))
               }
            }
         }
         iCount<-iCount+1
      }
      if(iCount>=pCount) break   
   }
   if(iCount>=pCount) next 

   # If there is room - add the events
   event.count <- 0
   for(event in Events) {
	   if(length(event[['bounds']][['x']]) < 1) next
	      event.count <- event.count+1
          plot.box(event,gp_event)
          base.y<-get.event.height(hour.count,event.count,Events)
          draw.link(event,base.y)
          for(line in event[['lines']]) {          
	           plot.Event.line(line,TextLeft,base.y)
	           base.y<-base.y-1/60
	           iCount<-iCount+1
               if(iCount>=pCount) break 
          }
       if(iCount>=pCount) break   
   }
   if(iCount>=pCount) next 

   iCount<-iCount+1

break # out of main loop
}

