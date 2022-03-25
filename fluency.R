
###########################################################
##                         Translation rating            ##
##                         collecting data              ##
###########################################################

## libraries, packages, path ----
if (!"tidyverse" %in% installed.packages()[, "Package"]) {
  install.packages("tidyverse")
}

library(tidyverse)
library(readxl)
library(irr)

## get data
dataFolder <- file.path("data/translation_rating")

load("~/Translators/data/translation_rating/Translation_rating_fluency_original.RData")

fluency_R1 <- read_excel("data/translation_rating/results/Translation_rating_fluency_R1.xlsx",
                         col_types = c("numeric", "numeric", "text", "numeric"))
fluency_R1 <- fluency_R1 %>% 
  rename(fluency_R1 = fluency)


fluency_R2 <- read_excel("data/translation_rating/results/Translation_rating_fluency_R2.xlsx",
                         col_types = c("numeric", "numeric", "text", "numeric"))
fluency_R2 <- fluency_R2 %>% 
  rename(fluency_R2 = fluency)


fluency_R3 <- read_excel("data/translation_rating/results/Translation_rating_fluency_R3.xlsx",
                         col_types = c("numeric", "numeric", "text", "numeric"))
fluency_R3 <- fluency_R3 %>% 
  rename(fluency_R3 = fluency)

tra_ra_fluency <- tra_ra_fluency %>% 
  select(-reference_translation)





# combine datasets

trans_rat_fluency <- full_join(tra_ra_fluency,fluency_R1, by = c("rand_index","index"))

trans_rat_fluency <- full_join(trans_rat_fluency,fluency_R2, by = c("rand_index","index"))

trans_rat_fluency <- full_join(trans_rat_fluency,fluency_R3, by = c("rand_index","index"))

fluency_results <- trans_rat_fluency %>% 
  select(id, group, text, condition, sentence_nr, fluency_R1, fluency_R2, fluency_R3)

remove(fluency_R1, fluency_R2, fluency_R3, tra_ra_fluency, trans_rat_fluency)

for (i in 1:nrow(fluency_results)){
  if(is.na(fluency_results$fluency_R1[i])){
    fluency_results$fluency_R2[i] = NA
    fluency_results$fluency_R3[i] = NA
  }
  if(is.na(fluency_results$fluency_R2[i])){
    fluency_results$fluency_R1[i] = NA
    fluency_results$fluency_R3[i] = NA
  }  
  if(is.na(fluency_results$fluency_R3[i])){
    fluency_results$fluency_R1[i] = NA
    fluency_results$fluency_R2[i] = NA
  }  
}

fluency_results_icc <- fluency_results %>% 
  filter(!(is.na(fluency_R1))) %>% 
  select(fluency_R1, fluency_R2, fluency_R3)

icc(
  fluency_results_icc, model = "twoway", 
  type = "consistency", unit = "average"
)

fluency_results_avg <- fluency_results %>% 
  group_by(id, text, condition) %>% 
  summarise(meanR1 = mean(fluency_R1, na.rm = TRUE), meanR2 = mean(fluency_R2, na.rm = TRUE), meanR3 = mean(fluency_R3,na.rm = TRUE),n_obs = n()) %>% 
  ungroup()

fluency_results_avg_icc <- fluency_results_avg %>% 
  select(meanR1, meanR2,meanR3)

icc(
  fluency_results_avg_icc, model = "twoway", 
  type = "consistency", unit = "average"
)

## mean all raters

fluency_results_avgR <- fluency_results_avg %>% 
  mutate(meanR = (meanR1+ meanR2 + meanR3)/3)

grande_results_fluency <- fluency_results_avgR %>% 
  group_by(text, condition) %>% 
  summarise(fluencyRating = mean(meanR), n_subjects = n(), n_obs = sum(n_obs))
