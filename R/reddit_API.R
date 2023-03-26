#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(jsonlite)
library(tidyverse)


##Data Import and Cleaning

#download.file() saves local txt file of API fetch for viewing inside R
download.file("https://www.reddit.com/r/rstats/.json","../data/rawredditjson.txt")
#fromJSON parson raw information as nested list objects, flatten argument collapses nested data frames
rstats_list <- fromJSON("../data/rawredditjson.txt", flatten = TRUE) 
#the df we want is stored in [["children"]] list element of rstats_list so we extract it
rstats_original_tbl <- rstats_list$data$children
#following create new df with desired variables and renames the original variable names which were collapsed in nested lists i.e., data.selftext
rstats_tbl <- rstats_original_tbl %>% 
   select(
    post=data.title, 
    upvotes=data.ups,
    comments=data.num_comments
  ) 

##Visualization

#ggplot and geom_point plot scatterplot where x=number of upvotes and y=number of comments
rstats_tbl %>% 
  ggplot(aes(upvotes,comments)) +
  geom_point()

##Analysis

#cor.test() runs significance test on correlation between upvotes and comments and saves object for use in paste0()
api_cortest <- cor.test(rstats_tbl$upvotes, rstats_tbl$comments)
#display correlaiton and p-value to console
api_cortest$estimate
api_cortest$p.value


##Publication 
#Console Output (03/26 4:08p): "The correlation between upvotes and comments was r(23) = .36, p = .08. This test was not statistically significant."

#custom function that takes in a numeric value and specifies the publication format
#str_remove with regex pattern of starting 0 removes leading zeros
#round function rounds decimals to 2 digits and format with nsmall argument makes sure at least 2 digits are shown (e.g., in cases where 0.100 rounds to 0.1)
custom_decimal <-  function(x){
  str_remove(format(round(x, digits=2L), nsmall=2L), pattern="^0+")
}

#paste0 concantenates predefined strings and dynamic portions for publication
#ifelse interprets p < 0.05 depending on current p value
paste0("The correlation between upvotes and comments was r(",
       api_cortest$parameter[[1]] ,
       ") = ",
       custom_decimal(api_cortest$estimate),
       ", p = ",  
       custom_decimal(api_cortest$p.value),
       ". This test was",
       ifelse(api_cortest$p.value < .05, " statistically significant.", " not statistically significant.")
)
