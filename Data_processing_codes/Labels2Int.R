library(tidyverse)
library(lubridate)
library(readr)
library(rstudioapi)

setwd(dirname(getActiveDocumentContext()$path))
getwd()

# This script turn classes into integer representations
#@====================================================================================
patent_rank <- read_csv(
  "patent_abs_tit_cit_ranked.csv",
  col_types = cols(
    patent_id = col_character()
  )
)

patent_rank <-  patent_rank %>%
  mutate(
    label = case_when(
      top1pct_label == 1 ~ 1,
      top10pct_label == 1 ~ 2,
      btm90_lst1_label == 1 ~ 3,
      zero_cite_label == 1 ~ 4,
    )
  )


#===========================================================================================
patent_rank <- read_csv(
  "patent_abs_tit_cit_ranked.csv",
  col_types = cols(
    patent_id = col_character()
  )
)

patent_rank_upd <-  patent_rank %>%
  mutate(
    label = case_when(
      top1pct_label == 1 ~ 1,
      top10pct_label == 1 ~ 2,
      btm90_lst1_label == 1 ~ 3,
      zero_cite_label == 1 ~ 4,
    )
  ) %>%
  select(!c(top1pct_label, top10pct_label, btm90_lst1_label, zero_cite_label))

#write_csv(patent_rank_upd, "patent_rank_upd.csv")


#===========================================================================================

patent_prerank <- read_csv(
  "patent_abs_tit_cit_prerank.csv",
  col_types = cols(
    patent_id = col_character()
  )
)

subsection_id <-  patent_prerank %>% select(subsection_id)
subsection_id_count <- subsection_id %>% group_by(subsection_id) %>% count()
unique_subsection_id <- unique(subsection_id)
patent_prerank_upd <-  patent_prerank %>%
  mutate(
    label = case_when(
      subsection_id == "A01" ~ 1,
      subsection_id == "A21" ~ 2,
      subsection_id == "A22" ~ 3,
      subsection_id == "A23" ~ 4,
      subsection_id == "A24" ~ 5,
      subsection_id == "A41" ~ 6,
      subsection_id == "A42" ~ 7,
      subsection_id == "A43" ~ 8,
      subsection_id == "A44" ~ 9,
      subsection_id == "A45" ~ 10,
      subsection_id == "A46" ~ 11,
      subsection_id == "A47" ~ 12, 
      
      subsection_id == "A61" ~ 13,
      subsection_id == "A62" ~ 14,
      subsection_id == "A63" ~ 15,
      
      subsection_id == "B01" ~ 16,
      subsection_id == "B02" ~ 17,
      subsection_id == "B03" ~ 18,
      subsection_id == "B04" ~ 19,
      subsection_id == "B05" ~ 20,
      subsection_id == "B06" ~ 21,
      subsection_id == "B07" ~ 22,
      subsection_id == "B08" ~ 23,
      subsection_id == "B09" ~ 24,
      subsection_id == "B21" ~ 25,
      subsection_id == "B22" ~ 26,
      subsection_id == "B23" ~ 27,
      subsection_id == "B24" ~ 28,
      subsection_id == "B25" ~ 29,
      subsection_id == "B26" ~ 30,
      subsection_id == "B27" ~ 31,
      subsection_id == "B28" ~ 32,
      subsection_id == "B29" ~ 33,
      subsection_id == "B30" ~ 34,
      subsection_id == "B31" ~ 35,
      subsection_id == "B32" ~ 36,
      subsection_id == "B33" ~ 37,
      subsection_id == "B41" ~ 38,
      subsection_id == "B42" ~ 39,
      subsection_id == "B43" ~ 40,
      subsection_id == "B44" ~ 41,
      subsection_id == "B60" ~ 42,
      subsection_id == "B61" ~ 43,
      subsection_id == "B62" ~ 44,
      subsection_id == "B63" ~ 45,
      subsection_id == "B64" ~ 46, 
      subsection_id == "B65" ~ 47,
      subsection_id == "B66" ~ 48,
      subsection_id == "B67" ~ 49,
      subsection_id == "B68" ~ 50,
      subsection_id == "B81" ~ 51,
      subsection_id == "B82" ~ 52, 
      
      subsection_id == "C01" ~ 53,
      subsection_id == "C02" ~ 54,
      subsection_id == "C03" ~ 55,
      subsection_id == "C04" ~ 56,
      subsection_id == "C05" ~ 57,
      subsection_id == "C06" ~ 58,
      subsection_id == "C07" ~ 59,
      subsection_id == "C08" ~ 60,
      subsection_id == "C09" ~ 61,
      subsection_id == "C10" ~ 62,
      subsection_id == "C11" ~ 63,
      subsection_id == "C12" ~ 64,
      subsection_id == "C13" ~ 65,
      subsection_id == "C14" ~ 66,
      
      subsection_id == "C21" ~ 67,
      subsection_id == "C22" ~ 68,
      subsection_id == "C23" ~ 69,
      
      subsection_id == "C25" ~ 70,
      subsection_id == "C30" ~ 71,
      subsection_id == "C40" ~ 72,
      
      subsection_id == "D01" ~ 73,
      subsection_id == "D02" ~ 74,
      subsection_id == "D03" ~ 75,
      subsection_id == "D04" ~ 76,
      subsection_id == "D05" ~ 77,
      subsection_id == "D06" ~ 78,
      subsection_id == "D07" ~ 79,
      subsection_id == "D21" ~ 80,
      
      subsection_id == "E01" ~ 81,
      subsection_id == "E02" ~ 82,
      subsection_id == "E03" ~ 83,
      subsection_id == "E04" ~ 84,
      subsection_id == "E05" ~ 85,
      subsection_id == "E06" ~ 86,
      subsection_id == "E21" ~ 87,
      
      subsection_id == "F01" ~ 88,
      subsection_id == "F02" ~ 89,
      subsection_id == "F03" ~ 90,
      subsection_id == "F04" ~ 91,
    
      subsection_id == "F15" ~ 92,
      subsection_id == "F16" ~ 93,
      subsection_id == "F17" ~ 94,
      subsection_id == "F21" ~ 95,
      subsection_id == "F22" ~ 96,
      subsection_id == "F23" ~ 97,
      subsection_id == "F24" ~ 98,
      subsection_id == "F25" ~ 99,
      subsection_id == "F26" ~ 100,
      subsection_id == "F27" ~ 101,
      subsection_id == "F28" ~ 102,
      
      subsection_id == "F41" ~ 103,
      subsection_id == "F42" ~ 104,
      
      subsection_id == "G01" ~ 105,
      subsection_id == "G02" ~ 106,
      subsection_id == "G03" ~ 107,
      subsection_id == "G04" ~ 108,
      subsection_id == "G05" ~ 109,
      subsection_id == "G06" ~ 110,
      subsection_id == "G07" ~ 111,
      subsection_id == "G08" ~ 112,
      subsection_id == "G09" ~ 113,
      subsection_id == "G10" ~ 114,
      subsection_id == "G11" ~ 115,
      subsection_id == "G12" ~ 116,
      subsection_id == "G16" ~ 117,
      subsection_id == "G21" ~ 118,
      
      subsection_id == "H01" ~ 119,
      subsection_id == "H02" ~ 120,
      subsection_id == "H03" ~ 121,
      subsection_id == "H04" ~ 122,
      subsection_id == "H05" ~ 123,
      
      subsection_id == "Y02" ~ 124,
      subsection_id == "Y10" ~ 125
      
      
    )
  ) %>%
  select(!c(top1pct_label, top10pct_label, btm90_lst1_label, zero_cite_label))

write_csv(patent_prerank_upd, "patent_prerank_upd.csv")
