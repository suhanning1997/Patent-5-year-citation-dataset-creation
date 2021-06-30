library(tidyverse)
library(lubridate)
library(readr)
library(rstudioapi)

setwd(dirname(getActiveDocumentContext()$path))
getwd()

#Import datasets
patent_abstract_title <- read_csv(
  "patent_abstract_title.csv",
  col_types = cols(
    patent_id = col_character()
  )
)

five_year_citation <- read_csv(
  "5_year_citing_cited.csv",
  col_types = cols(
    cited_id = col_character(),
    citing_id = col_character()
  )
)

five_year_forward <- five_year_citation %>%
  group_by(cited_id) %>%
  tally()

five_year_forward <- five_year_forward %>%
  rename(five_year_fcite = n)

#Some data visualization - highlyy skewed distribution
#five_year_forward %>% filter(n < 100) %>% ggplot(aes(x = n)) + geom_histogram()

patent_abs_tit_cit <- patent_abstract_title %>%
  left_join(five_year_forward, by = c("patent_id" = "cited_id")) 

#note that observations with five_year_fcite == NA has no forward citation within a five year window
# I replace NA here with zero
patent_abs_tit_cit <- patent_abs_tit_cit %>% mutate(five_year_fcite = replace_na(five_year_fcite, 0))


#write_csv(patent_abs_tit_cit, "patent_abs_tit_cit.csv")

# Eliminate observations with NULL abstraction?? #I think not necessary, if their titles are available
filter(patent_abs_tit_cit, abstract == 'NULL')

#Add CPC claasification information
cpc_group <- read_tsv(
  "cpc_current.tsv",
  col_types = cols(
    patent_id = col_character()
  )) %>%
  select(patent_id, subsection_id, sequence)
  
#cpc_group_uni <- cpc_group %>% unique()

cpc_group_1st <- filter(cpc_group_uni, sequence == 0)

#write_csv(cpc_group_1st, "cpc_group_1st.csv")

#============================================================================================
##Complete the dateset before the final labeling of citation level
#Import datasets
cpc_group_1st <- read_csv("cpc_group_1st.csv",
                          col_types = cols(
                            patent_id = col_character()
                          )) %>% select(patent_id, subsection_id) #all of observations are rank 1 subsections

patent_abs_tit_cit <- read_csv("patent_abs_tit_cit.csv",
                               col_types = cols(
                                 patent_id = col_character()
                               ))

patent_date <- read_csv("patent_date.csv",
                        col_types = cols(
                          patent_id = col_character()
                        ))

#Combine all three datasets

#The completed dataset without ranking of citation
patent_abs_tit_cit1 <- patent_abs_tit_cit %>%
  left_join(cpc_group_1st, by = c("patent_id" = "patent_id")) %>%
  left_join(patent_date, by = c("patent_id" = "patent_id"))

patent_abs_tit_cit_prerank <- filter(patent_abs_tit_cit1, !is.na(subsection_id))

write_csv(patent_abs_tit_cit_prerank, "patent_abs_tit_cit_prerank.csv")

#=============================================================================================
## Label patents with citation level
patent_abs_tit_cit_prerank <- read_csv(
  "patent_abs_tit_cit_prerank.csv",
  col_types = cols(
    patent_id = col_character()
  )
)

fcite_date_cpc <- patent_abs_tit_cit_prerank %>% select(five_year_fcite, patent_id, date, subsection_id)

## Separate dataset above into patents that have full 5 year windows and those that do not
fcite_date_cpc_notfull <- fcite_date_cpc %>%
  filter(date > max(date) - dyears(5))

fcite_date_cpc_full <- fcite_date_cpc %>%
  filter(date < max(date) - dyears(5))

# Calculate relevant percentiles for patents with full 5 year window
fcite_90_percentile <- fcite_date_cpc_full %>%
  group_by(subsection_id) %>%  
  summarise(top10pct = quantile(five_year_fcite, probs=0.90))

fcite_99_percentile <- fcite_date_cpc_full %>%
  group_by(subsection_id) %>%  
  summarise(top1pct = quantile(five_year_fcite, probs=0.99))

fcite_10_percentile <- fcite_date_cpc_full %>%
  group_by(subsection_id) %>%  
  summarise(top90pct = quantile(five_year_fcite, probs=0.10))

fcite_date_cpc_full1 <- fcite_date_cpc_full %>%
  left_join(fcite_99_percentile, by = ("subsection_id" = "subsection_id")) %>%
  left_join(fcite_90_percentile, by = ("subsection_id" = "subsection_id"))


fcite_date_cpc_full2 <- fcite_date_cpc_full1 %>% rowwise() %>% mutate(top1pct_label = as.integer(five_year_fcite >= top1pct))
fcite_date_cpc_full3 <- fcite_date_cpc_full2 %>% rowwise() %>% mutate(top10pct_label = as.integer(five_year_fcite >= top10pct & five_year_fcite < top1pct))
fcite_date_cpc_full4 <- fcite_date_cpc_full3 %>% rowwise() %>% mutate(btm90_lst1_label = as.integer(five_year_fcite != 0 & five_year_fcite < top10pct))
fcite_date_cpc_full_complete <- fcite_date_cpc_full4 %>% rowwise() %>% mutate(zero_cite_label = as.integer(five_year_fcite == 0))

sum(fcite_date_cpc_full_complete$zero_cite_label) +
sum(fcite_date_cpc_full_complete$btm90_lst1_label) +
sum(fcite_date_cpc_full_complete$top10pct_label) +
sum(fcite_date_cpc_full_complete$top1pct_label) #=5159188 labeling is not overlapping, as desired

fcite_date_cpc_full_complete <- fcite_date_cpc_full_complete %>% select(patent_id, top1pct_label, top10pct_label, btm90_lst1_label, zero_cite_label)

patent_abs_tit_cit_complete <- patent_abs_tit_cit_prerank %>%
  left_join(fcite_date_cpc_full_complete, by = ("patent_id" = "patent_id"))

patent_abs_tit_cit_completed <- filter(patent_abs_tit_cit_complete, !is.na(top1pct_label))

write_csv(patent_abs_tit_cit_completed, "patent_abs_tit_cit_ranked.csv")

#====================================================================================
finished_dataset <- read_csv("patent_abs_tit_cit_ranked.csv")
test <- finished_dataset %>% mutate(value = 1)  %>% spread(subsection_id, value,  fill = 0 ) 
