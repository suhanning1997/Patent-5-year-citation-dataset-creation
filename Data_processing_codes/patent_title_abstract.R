library(tidyverse)
library(lubridate)
library(readr)
library(rstudioapi)

setwd(dirname(getActiveDocumentContext()$path))
getwd()

patent_abstract <- read_csv(
  "patent_precitation_prepared.csv",
  col_types = cols(
    patent_id = col_character()
  )
)

patent_abstract_nodate <- patent_abstract %>% select(patent_id, abstract, title)

#test <- unique(patent_abstract_nodate) #uniqueness test passed

write_csv(patent_abstract_nodate, "patent_abstract_title.csv")

#citing_cited <- read_csv("citing_cited.csv")