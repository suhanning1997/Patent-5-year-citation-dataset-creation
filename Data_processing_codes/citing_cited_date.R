library(tidyverse)
library(lubridate)
library(readr)
library(rstudioapi)

setwd(dirname(getActiveDocumentContext()$path))
getwd()

patent_citations1 <- read_tsv("uspatentcitation.tsv")
#citation_id identifying number of patent to which select patent cites
#citation_id  = id of cited patent
#patent_id  = id of citing patent

#Need to know the grant date of citing patnet as well
patent <- read_tsv(
  "patent.tsv",
  col_types = cols(
    patent_id = col_character()
  )
)

#Extract relevant columns:
patent <- patent %>%
  select(number, date, abstract, title) %>%
  rename(patent_id = number) %>%
  filter(!is.na(abstract))

write_csv(patent, "patent_precitation_prepared.csv")

#Extract date data from preapred patent dataset

patent_date <- select(patent, date, patent_id)
write_csv(patent_date, "patent_date.csv")

#patent_date_miss <- filter(patent_date, is.na(date)) #0 observations

citing_cited_id <- patent_citations1 %>%
  select(citation_id, patent_id) %>%
  rename(citing_id = patent_id, cited_id = citation_id)

write_csv(citing_cited_id, "citing_cited.csv")

#citing_cited_id_chunk1 <- slice(citing_cited_id, 1:floor(113129077/4))
#Joining patent date with citing_cited dataset
#citing_cited_date1 <- citing_cited_id_chunk1 %>%
  #inner_join(patent_date, by = c("citing_id" = "patent_id"))
  
#merge(citing_cited_id, patent_date, by = intersect(citing_id, patent_id))

#Remove observations with no description or title
#patent_miss <- filter(patent, is.na(abstract))
#abs_miss_id <- select(patent_miss, patent_id)

#citing_cited_missing_id <- citing_cited_id %>%
  #rowwise() %>%
  #filter(citing_id %in% abs_miss_id)


