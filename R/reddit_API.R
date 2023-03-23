#Script Settings and Resources
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


library(httr)
library(jsonlite)


# get_json <- GET(url = "https://www.reddit.com/r/rstats/.json",
#                user_agent("UMN Researcher demek004@umn.edu"))

saveRDS(get_json, "../data/APIRedditstats.RDS") #saved response from 03/22 5:16pm

reddit_api_response <- readRDS("../data/APIRedditstats.RDS")

rstats_list <- reddit_api_response

rstats_original_tbl <- content(rstats_list)$data
