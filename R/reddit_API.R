#Script Settings and Resources

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(httr)
library(jsonlite)
library(tidyverse)

#Data Import and Cleaning

#first line download.file() saves local image of the rstats/.json
download.file("https://www.reddit.com/r/rstats/.json","../data/rawredditjson.html")
#fromJSON parson raw information as nested list objects, flatten argument collapses nested data frames
rstats_list <- fromJSON("../data/rawredditjson.html", flatten = TRUE) 
#the df we want is stored in [["children"]] list element of rstats_list so we extract it
rstats_original_tbl <- rstats_list$data$children
#next we create new df with just the desired variables and rename the original JSON names which were collapsed i.e., data.selftext
rstats_tbl <- rstats_original_tbl %>% 
   select(
    post=data.selftext, #do we want the body text or the titles? some posts don't have inner text
    upvotes=data.ups,
    comments=data.num_comments
  ) 

#Visualization

#ggplot and geom_point plot scatterplot where x=number of upvotes and y=number of comments
rstats_tbl %>% 
  ggplot(aes(upvotes,comments)) +
  geom_point()

#Analysis

#cor.test() runs significance test on correlation between upvotes and comments
cor.test(rstats_tbl$upvotes, rstats_tbl$comments)
#0.7857551 

#Publication

