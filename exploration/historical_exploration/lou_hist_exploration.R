
library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)
library(scales)

listings1501 <- read_csv("../../raw_data/2015-01-01-listings.csv", na='\\N')
# No data for Feb 2015
listings1503 <- read_csv("../../raw_data/2015-03-01-listings.csv", na='\\N')
listings1504 <- read_csv("../../raw_data/2015-04-01-listings.csv", na='\\N')
listings1505 <- read_csv("../../raw_data/2015-05-01-listings.csv", na='\\N')
listings1506 <- read_csv("../../raw_data/2015-06-01-listings.csv", na='\\N')
# No data for July 2015
listings1508 <- read_csv("../../raw_data/2015-08-01-listings.csv", na='\\N')
listings1509 <- read_csv("../../raw_data/2015-09-01-listings.csv", na='\\N')
listings1510 <- read_csv("../../raw_data/2015-10-01-listings.csv", na='\\N')
listings1511 <- read_csv("../../raw_data/2015-11-01-listings.csv", na='\\N')
listings151120 <- read_csv("../../raw_data/2015-11-20-listings.csv", na='\\N') #watch out for this one! This is still November
listings1512 <- read_csv("../../raw_data/2015-12-02-listings.csv", na='\\N')
listings1601 <- read_csv("../../raw_data/2016-01-01-listings.csv", na='\\N')
listings1602 <- read_csv("../../raw_data/2016-02-02-listings.csv", na='\\N')
# No data for March 2016 :(
listings1604 <- read_csv("../../raw_data/2016-04-03-listings.csv", na='\\N') #APRIL! This is not March. March has been skipped.
listings1605 <- read_csv("../../raw_data/2016-05-02-listings.csv", na='\\N')
listings1606 <- read_csv("../../raw_data/2016-06-02-listings.csv", na='\\N')

nrow(filter(listings1511, room_type == "Entire home/apt")) #17898 
nrow(filter(listings151120, room_type == "Entire home/apt")) #17780
nrow(filter(listings1512, room_type == "Entire home/apt")) #18786 

View(listings1606)
#function to find % of multilistings
percent_multilistings <- function(listings){
  multilistings <- listings %>% select(host_id, room_type) %>% filter(room_type == "Entire home/apt") %>% group_by(host_id) %>% mutate(host_count = n()) %>% filter(host_count > 1) 
  listings_entire_apt <- listings %>% select(host_id, room_type) %>% filter(room_type == "Entire home/apt")
  nrow(multilistings)/ nrow(listings_entire_apt) * 100
}

#### percentage of multilistings
january15 <- percent_multilistings(listings1501)
# Feb 2015 missing
march15 <- percent_multilistings(listings1503)
april15 <- percent_multilistings(listings1504)
may15 <- percent_multilistings(listings1505)
june15 <-percent_multilistings(listings1506)
# July 2015 missing
august15 <- percent_multilistings(listings1508)
september15 <- percent_multilistings(listings1509)
october15<- percent_multilistings(listings1510)
november15 <- percent_multilistings(listings1511)
november_late15 <- percent_multilistings(listings151120)
december15 <- percent_multilistings(listings1512)
january16 <- percent_multilistings(listings1601)
february16 <- percent_multilistings(listings1602)
# March missing
april16 <- percent_multilistings(listings1604)
may16 <- percent_multilistings(listings1605)
june16 <-percent_multilistings(listings1606)

dates <- as.Date(c("2015-01-01", "2015-03-01", "2015-04-01", "2015-05-01", "2015-06-01", 
                   "2015-08-01", "2015-09-01","2015-10-01","2015-11-01","2015-11-20",
                   "2015-12-02", "2016-01-01","2016-02-02","2016-04-03","2016-05-02","2016-06-02"))
percent_of_multilistings <- c(january15, march15, april15, may15, june15, august15, september15, october15, november15, november_late15, december15, january16, february16, april16, may16, june16)

df_multilistings <- data.frame(dates, percent_of_multilistings)
View(df_multilistings)

###### Murray Cox graph replicated!!
ggplot(aes(dates, percent_of_multilistings), data=df_multilistings) + 
  geom_point(color="blue") + geom_line(color="blue") + 
  scale_x_date(breaks=date_breaks("months"), labels=date_format("%b")) +
  scale_y_continuous(limits=c(0,20)) + 
  xlab("Month") + 
  ylab("% of Multi-listings") +
  ggtitle("Entire Home/Apartment Multilistings Over Time")

View(listings1511)
# looking at pre and post purge
prepurge_bare <- listings1511 %>% select(id, host_id, room_type) %>% filter(room_type == "Entire home/apt") %>% group_by(host_id) %>% mutate(host_count = n()) %>% filter(host_count > 1) %>% arrange(host_id)
View(prepurge_bare)
nrow(prepurge_bare) #3331

postpurge_bare <- listings151120 %>% select(id, host_id, room_type) %>% filter(room_type == "Entire home/apt") %>% group_by(host_id) %>% mutate(host_count = n()) %>% filter(host_count > 1) %>% arrange(host_id)
View(postpurge_bare)
nrow(postpurge_bare) #1829

purged_listings <- anti_join(prepurge_bare, postpurge_bare, by = 'id')
View(purged_listings)

purged_tf <- c()
for(i in 1:nrow(prepurge_bare)){
  if(prepurge_bare[i,]$id %in% purged_listings$id){
    purged_tf <- c(purged_tf, TRUE)
  } else {
    purged_tf <- c(purged_tf, FALSE)
  }
}

prepurge_bare$purged <- purged_tf
View(prepurge_bare)

nrow(prepurge_bare)
prepurge_bare <- data.frame(prepurge_bare)
typeof(prepurge_bare)

df <- prepurge_bare %>% filter(purged == TRUE)

View(df)

################################################### [graphing word frequency]
listing_history <- read_csv("../../raw_data/listing_history.csv")

word_features <- read_csv("../../raw_data/word_features.csv")
View(word_features)

# function to graph word frequency
graph_word_frequency <- function(df, range, title="Frequency of Words"){
  word_count <- colSums(df[range]) #gather sums of each word
  
  # make dataframe, and substring "word_great" to "great"
  word_summary_df <- data.frame(word=substring(colnames(df)[range], 6), frequency=word_count) %>% arrange((word_count))

  # create factors
  word_summary_df$word <- factor(word_summary_df$word, levels = word_summary_df$word[order(word_summary_df$frequency)]) 
  
  # plot
  ggplot(aes(word, frequency), data=word_summary_df) + 
    geom_point() + ggtitle(title) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) # angle x axis
  
  return(word_summary_df)
}

View(graph_word_frequency(word_features, 3:102))

################################################### [splitting word frequency]
summary(listing_history$exist_in_2016)

# filter for existence in 2016
listings_in_2016 <- listing_history %>% filter(exist_in_2016 == TRUE) 
listings_not_in_2016 <- listing_history %>% filter(exist_in_2016 == FALSE)

nrow(listing_history) == nrow(listings_in_2016) + nrow(listings_not_in_2016) # TRUE. Checking to see accurate split

graph_word_frequency(listings_in_2016, 106:205, "Listings In 2016") # graph for exists in 2016

graph_word_frequency(listings_not_in_2016, 106:205, "Listings NOT In 2016") # graph for NOT exist in 2016

# todo: get proper stat numbers!

View(graph_word_frequency(listings_in_2016, 106:205))
View(graph_word_frequency(listings_not_in_2016, 106:205))

View(graph_word_frequency(filter(listings_history, purged == TRUE), 106:205))

################################################### [ skimmed listings ]

#selects one listing per host at random
skimmed_listings_history <- listings_history %>% group_by(host_id.x) %>% filter(row_number() == sample(1:row_number(), 1))

################################################### [ correlation of rating & num verification ]
cor(listings_history$last_rating, listing_history$verifications_count, na.rm = TRUE)
?cor

