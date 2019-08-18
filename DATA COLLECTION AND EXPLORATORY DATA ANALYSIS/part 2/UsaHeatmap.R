
library(ggplot2)
library(tidyverse)
library(mapdata)
library(maps)
library(stringr)
library(viridis)
library("ggmap")
library(dplyr)
library(fiftystater)

heatmapdir <- dirname(rstudioapi::getSourceEditorContext()$path)
heatmapdir

filePathhm <- paste(heatmapdir,"/usaheatmapwwek8.csv",sep="")
filePathhm
allMapData <- read.csv(filePathhm)
nrow(allMapData)
register_google(key = "YOUR KEY HERE") 
locations <- (allMapData$STATENAME)
activity <- (allMapData$ACTIVITY.LEVEL)
heatMapFrame <- data.frame(state=locations,values=activity)



#heatMapFrame
heatMapFrame$id <- tolower(heatMapFrame$state)
us_states_flu <- left_join(fifty_states, heatMapFrame)
colnames(us_states_flu)

#us_states_flu
imgName <- paste(heatmapdir,"/CDC Map.jpeg",sep='')
imgName
#jpeg(filename = imgName )
#party_colors <- c("#2E74C0", "#CB454A","#2E74C0", "#CB454A") 
p <- ggplot(data = us_states_flu,
            aes(x = long, y = lat,
                group = group, fill = values))

p + geom_polygon(color = "gray90", size = 0.1) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45)+scale_fill_manual(values = c(heat.colors(10)),aesthetics = "fill")
#dev.off()