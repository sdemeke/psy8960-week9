#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


library(rvest)


# get_html <- read_html("https://www.reddit.com/r/rstats/")

saveRDS(get_html,"../data/scrapedRedditstats.RDS") #saved response from 03/22 5:16pm

reddit_scrpd_response <- readRDS("../data/scrapedRedditstats.RDS")

