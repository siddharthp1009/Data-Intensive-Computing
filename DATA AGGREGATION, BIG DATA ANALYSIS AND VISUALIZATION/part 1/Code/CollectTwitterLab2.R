
library("twitteR")
library("ROAuth")
library("ggmap")
library("csv")
library("plyr") 
library("qdapRegex")
#install.packages("rstudioapi")
library("rstudioapi")

#All authentication Done here - NO TOUCHING - BIG NO NO
credentials <- OAuthFactory$new(consumerKey='',
                                consumerSecret='',
                                requestURL='',
                                accessURL='',
                                authURL='')




setup_twitter_oauth(credentials$consumerKey, credentials$consumerSecret, credentials$oauthKey, credentials$oauthSecret)


# Set the Path to current Directory , helps when the file is moved around
currentDirP3 <- dirname(rstudioapi::getSourceEditorContext()$path)
currentDirP3

# Create Files with Tweets
count <- 0;
for (j in c(0:2)){
  


for(i in c('#cybersecurity','#hack','#cybercrime','#cyber')){
  
  
  filename <- paste(i,"csv",sep=".")
  storeDir = paste(currentDirP3,"/ORIGINAL DATA",sep="")
  path <- paste(storeDir,filename,sep="/")
  #getTweets
  tweets <- searchTwitter(i, since='2019-04-17', until='2019-04-18', n=500,lang='en') 
  #Remove Retweets
  filterReTwe <- strip_retweets(tweets)
  #Put in a data Frame
  tweetsd.df = ldply(filterReTwe, function(t) t$toDataFrame())
  
  #Remove urls from text for filtering
  tweetsd.df$text <- rm_url(tweetsd.df$text)
  tweetsd.df$text <- rm_twitter_url(tweetsd.df$text)
  
  #Remove duplicates based on text field
  filterDup  <- tweetsd.df[ !duplicated(tweetsd.df$text), ]
  print(filterDup[0])
  # Write to a csv file in same directory
  write.table(filterDup, path, sep = ",", col.names = F, append = T)
  count=count+1;
  if(count>0){
    a <-Sys.time()
    print(paste("sleeping after :",i))
    Sys.sleep(8)
    print(Sys.time()-a)
  }
  
  
}
  
  print(paste(j," loop ended")) 
  if(count==8){
    b<- Sys.time()
    print("here comes the long sleep")
    Sys.sleep(1200)
    print(Sys.time()-b)
    count<-0
    
  }
  
  print(paste("Value of count for new loop: ",count))

}
