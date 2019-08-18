rm(list=ls())
library("twitteR")
library("ROAuth")
library("ggmap")
library("csv")
library("qdapRegex")
library("maps")
library("sf")
library("rgdal")
library("tidyverse")
library("revgeo")
library("maptools")
library("purrr")
library("dplyr")
library("plyr")
library("fiftystater")


install.packages("fiftystater",dependencies = T)

#All authentication Don here - NO TOUCHING - BIG NO NO
credentials <- OAuthFactory$new(consumerKey='',
                                consumerSecret='',
                                requestURL='',
                                accessURL='',
                                authURL='')



register_google(key = "YOUR KEY HERE")
setup_twitter_oauth(credentials$consumerKey, credentials$consumerSecret, credentials$oauthKey, credentials$oauthSecret)


# Set the Path to current Directory , helps when the file is moved around
currentDirP3 <- dirname(rstudioapi::getSourceEditorContext()$path)
currentDirP3
 
# Create Files with Tweets
 for(i in c('#flu','#flushot','#fluseason','#influenza','#fightflu','#fluvaccine','#H3N2','#shot')){
   

   filename <- paste(i,"csv-1",sep=".")
   path <- paste(currentDirP3,filename,sep="/")
   #getTweets
   tweets <- searchTwitter(i, n=500,lang='en',since="2019-03-07",until="2019-03-08") 
   #Remove Retweets
   filterReTwe <- strip_retweets(tweets)
   #Put in a data Frame
   tweetsd.df = ldply(filterReTwe, function(t) t$toDataFrame())
  
   #Remove urls from text for filtering
   tweetsd.df$text <- rm_url(tweetsd.df$text)
   tweetsd.df$text <- rm_twitter_url(tweetsd.df$text)
   
  #Remove duplicates based on text field
   filterDup  <- tweetsd.df[ !duplicated(tweetsd.df$text), ]
   # Write to a csv file in same directory
   write.table(filterDup, path, sep = ",", col.names = F, append = T)
   
 
 }
 
# Extracting userScreen Names 
 newDataFrame <- data.frame()
 newDataFrame <- NA
 for(j in c('#influenza')){#,,'#influenza''#fluseason','#influenza','#fightflu','#fluvaccine','#H3N2','#shot')){
   
   filenameRead <- paste(j,"csv",sep=".")
   pathRead <- paste(currentDirP3,filenameRead,sep="/")
   pathRead
   newData <- read.csv(pathRead)
   newData 
   uName <- newData$screenName
    uName
  colnames(newData)
   newDataFrame <-(c(newDataFrame,as.character( uName)))
                      
 }
View(newDataFrame) 
#converting to dataFrame
td <- as.data.frame(newDataFrame)
View(td)
#setting the Column name to screenName
colnames(td) <- "screenName"
View(td$screenName)

#Extracting the Longitude and Latitude for the screen names
namelen <- length(td$screenName)
namelen
locationDataFrame <- data.frame()
locationDataFrame <- NA
lon <- NA
lat <- NA





for(i in 1:namelen){
  if(i%%50 == 0){
    Sys.sleep(30)
  }
 # userData <- lookupUsers(td$screenName[i])
 
  userData <- tryCatch(lookupUsers(td$screenName[i]),
                       warning = function(w) {
                        
                         print("warn"); 
                         # handle warning here
                       },
                       error = function(e) {
                        
                         print("error");
                         # handle error here
                       })
  
  if(length(userData) == 0){
    next
  }
 if(userData == "error"){
   next
 }
  if(userData == "warn"){
    print(paste("Sleeping for 900 seconds, extraction continues at index ",i))
    Sys.sleep(900)
    next
  }
  userDataFrame <- twListToDF(userData)
  userLocation <- !is.na(userDataFrame$location)
  locations <- geocode(userDataFrame$location[userLocation])
  lon <- c(lon,locations$lon)
  lat <- c(lat,locations$lat)
  print(i)
}

View(lon)

#Store Longitude and Latitude in a data frame.
locationDataFrame <- data.frame(lon,lat)
View(locationDataFrame)

#Remove NA data rows
latlonfilename <- paste("latlong-influenza","csv",sep=".")
pathForLatLon <- paste(currentDirP3,latlonfilename,sep="/")
locationDataFrame <- na.omit(locationDataFrame)
View(locationDataFrame)
write.table(locationDataFrame, pathForLatLon, sep = ",", col.names = F, append = T)
locDfLen <- nrow(locationDataFrame)
locDfLen

## read lot long data
latlongdata <- read.csv(pathForLatLon)
colnames(latlongdata) <- c("no","lon","lat")
colnames(latlongdata)
nrow(latlongdata)

locFileName <- paste("locations-influenza","csv",sep=".")
pathFortweetLoc <- paste(currentDirP3,locFileName,sep="/")

  

someFrame <- revgeo(longitude=latlongdata$lon, latitude=latlongdata$lat,  output="frame")
write.table(someFrame, pathFortweetLoc, sep = ",", col.names = T, append = T)
  
StateData <- read.csv(pathFortweetLoc)
colnames(StateData)
colnames(StateData) <- c("no","housenumber","street","city","state","zip","country")

View(StateData)
stateDataBack <- StateData

usStateNames <- data.frame(stateDataBack$state[stateDataBack$country == 'United States of America'])
View(usStateNames)

usStateNames <- data.frame(table(usStateNames))
colnames(usStateNames)<- c("state","values")


usStateNames <- data.frame(usStateNames$state[!usStateNames$values==0],usStateNames$values[!usStateNames$values==0])
usStateNames
colnames(usStateNames) <- c("state","values")
tweetMap <- paste(currentDirP3,"/Influenza Map.jpeg",sep='')
jpeg(filename = tweetMap)
#us_states <- map_data("state")
head(fifty_states)
usStateNames$id <- tolower(usStateNames$state)
us_states_flu <- left_join(fifty_states, usStateNames)
colnames(us_states_flu)
p <- ggplot(data = us_states_flu,
            aes(x = long, y = lat,
                group = group, fill = values))

p + geom_polygon(color = "black", size = 0.1) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45)+scale_fill_gradientn(colors=rev(heat.colors(10)),na.value="gray90")


dev.off()




