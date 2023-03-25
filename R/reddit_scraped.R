#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(rvest)
library(tidyverse)
library(xml2)



##Data Import and Cleaning

rstats_html <- read_html("https://old.reddit.com/r/rstats/")
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
comments <- rstats_html1 %>% 
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

#cor.test() runs significance test on correlation between upvotes and comments
scraped_cortest <- cor.test(rstats_tbl$upvotes, rstats_tbl$comments)
#0.7807844     

##Publication 
#Console Output: "The correlation between upvotes and comments was r(23) = .43, p = .03. This test was statistically significant."

#paste0 concantenates predefined strings and dynamic portions. str_remove with beginning 0 removes leading zeros
#round function rounds decimals to 2 digits after decimal point
paste0("The correlation between upvotes and comments was r", "(", scraped_cortest$parameter[[1]] ,") = ",
       str_remove(round(scraped_cortest$estimate,2), pattern="^0+"), ", p = ",  
       str_remove(round(scraped_cortest$p.value,2), pattern="^0+"),". This test was statistically significant.")
       

