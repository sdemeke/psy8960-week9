#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


library(httr)
library(jsonlite)
library(tidyverse)

download.file("https://www.reddit.com/r/rstats/.json","../data/rawredditjson.html")
rstats_list <- fromJSON("../data/rawredditjson.html", flatten = TRUE) 
rstats_original_tbl <- rstats_list$data$children
rstats_tbl <- rstats_original_tbl %>% 
   select(
    post=data.selftext, #do we want the body text or the titles? some posts don't have inner text
    upvotes=data.ups,
    comments=data.num_comments
  ) 
rstats_tbl %>% 
  ggplot(aes(upvotes,comments)) +
  geom_point()

cor.test(rstats_tbl$upvotes, rstats_tbl$comments)
#0.7857551 


