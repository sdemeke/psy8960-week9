#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(rvest)
library(tidyverse)
#library(xml2)

##Data Import and Cleaning

#download.file() saves local file of the data to scrape to reduce fetch requests while testing code and avoid rate limiting status code
download.file("https://old.reddit.com/r/rstats/","../data/rawreddithtml.html")
#read_html reads in saved html file
rstats_html <- read_html("../data/rawreddithtml.html")
#using SelectorGadget, I identified the CSS selector to select all post titles (excluded some unnecessary text underneath some post titles)
post <- rstats_html %>% 
  html_elements(css='.title.may-blank') %>% 
  html_text()
#using Developer Tools/Inspect, I found the class name for each upvote and the text extracted is the number of upvotes
#I found it easier to construct the xpath myself
#coerced to numeric
upvotes <- rstats_html %>% 
  html_elements(xpath='//div[@class = "score unvoted"]') %>% #
  html_text() %>% 
  as.numeric() %>% 
  replace_na(0)
#used SelectorGadget to identify selector for every 'X comments' on page
#before coercing to numeric, I remove all characters using str_remove_all() to leave only number of comments
comments <- rstats_html %>% 
  html_elements(css='.first') %>% 
  html_text() %>% 
  str_remove_all(pattern="[A-Za-z]*") %>% 
  as.numeric() %>% 
  replace_na(0)

#creating tibble of scraped and cleaned vectors
rstats_tbl <- tibble(
    post=post, #do we want the body text or the titles? some posts don't have inner text, taking title for now
    upvotes=upvotes,
    comments=comments
  ) 


##Visualization

#ggplot and geom_point plot scatterplot where x=number of upvotes and y=number of comments
rstats_tbl %>% 
  ggplot(aes(upvotes,comments)) +
  geom_point()


##Analysis

#cor.test() runs significance test on correlation between upvotes and comments and saves object for use in paste0()
scraped_cortest <- cor.test(rstats_tbl$upvotes, rstats_tbl$comments)
#display correlaiton and p-value to console
scraped_cortest$estimate
scraped_cortest$p.value

##Publication 
#Console Output (03/26 4:08p): "The correlation between upvotes and comments was r(23) = .34, p = .10. This test was not statistically significant."

#custom function that takes in a numeric value and specifies the publication format
#str_remove with regex pattern of starting 0 removes leading zeros
#round function rounds decimals to 2 digits and format with nsmall argument makes sure at least 2 digits are shown (e.g., in cases where 0.100 rounds to 0.1)
custom_decimal <-  function(x){
  str_remove(format(round(x, digits=2L), nsmall=2L), pattern="^0+")
}

#paste0 concantenates predefined strings and dynamic portions for publication
#ifelse interprets p < 0.05 depending on current p value
paste0("The correlation between upvotes and comments was r(",
       scraped_cortest$parameter[[1]] ,
       ") = ",
       custom_decimal(scraped_cortest$estimate),
       ", p = ",  
       custom_decimal(scraped_cortest$p.value),
       ". This test was",
       ifelse(scraped_cortest$p.value < .05, " statistically significant.", " not statistically significant.")
)
       

