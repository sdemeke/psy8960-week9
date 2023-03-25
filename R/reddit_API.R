#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(jsonlite)
library(tidyverse)


##Data Import and Cleaning

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

##Visualization

#ggplot and geom_point plot scatterplot where x=number of upvotes and y=number of comments
rstats_api_tbl %>% 
  ggplot(aes(upvotes,comments)) +
  geom_point()

##Analysis

#cor.test() runs significance test on correlation between upvotes and comments and saves object for use in paste0()
api_cortest <- cor.test(rstats_api_tbl$upvotes, rstats_api_tbl$comments)



##Publication 
#Console Output: "The correlation between upvotes and comments was r(23) = .43, p = .03. This test was statistically significant."

#paste0 concantenates predefined strings and dynamic portions. str_remove with beginning 0 removes leading zeros
#round function rounds decimals to 2 digits after decimal point
#ifelse interprets p <0.05 depending on current p value
paste0("The correlation between upvotes and comments was r(",
       api_cortest$parameter[[1]] ,
       ") = ",
       str_remove(round(api_cortest$estimate,2), pattern="^0+"),
       ", p = ",  
       str_remove(round(api_cortest$p.value,2), pattern="^0+"),
       ". This test was",
       ifelse(api_cortest$p.value < .05, " statistically significant.", " not statistically significant.")
)
