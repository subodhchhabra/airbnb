library(dplyr)
library(readr)

# load data into dataframes
reviews <- read_csv("reviews.csv", na='\\N')
listings <- read_csv("listings.csv", na='\\N')
calendar <- read_csv("calendar.csv", na='\\N')