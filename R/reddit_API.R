#Script Settings and Resources

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(httr)
library(jsonlite)
library(tidyverse)

#Data Import and Cleaning

#first line download.file() saves local image of the rstats/.json
#download.file("https://www.reddit.com/r/rstats/.json","../data/raw_reddit_json.html")
#fromJSON parson raw information as nested list objects, flatten argument collapses nested data frames
rstats_list <- fromJSON("https://www.reddit.com/r/rstats/.json", flatten = TRUE) 
#the df we want is stored in [["children"]] list element of rstats_list so we extract it
rstats_original_tbl <- rstats_list$data$children
#next we create new df with just the desired variables and rename the original JSON names which were collapsed i.e., data.selftext
rstats_api_tbl <- rstats_original_tbl %>% 
   select(
    post=data.title, #do we want the body text or the titles? some posts don't have inner text, taking title for now
    upvotes=data.ups,
    comments=data.num_comments
  ) 

#Visualization

#ggplot and geom_point plot scatterplot where x=number of upvotes and y=number of comments
rstats_api_tbl %>% 
  ggplot(aes(upvotes,comments)) +
  geom_point()

#Analysis

#cor.test() runs significance test on correlation between upvotes and comments
api_cortest <- cor.test(rstats_api_tbl$upvotes, rstats_api_tbl$comments)
#0.7803738  
   

#Publication
paste0("The correlation between upvotes and comments was r", "(", api_cortest$parameter[[1]] ,") = ",
       round(api_cortest$estimate,2), ", p = ",  round(api_cortest$p.value,2))
