
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


# Rater 1
accuracy_R1 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_R1.xlsx",
                         col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R1_2 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_2_R1.xlsx",
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R1 <- accuracy_R1 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R1_2 <- accuracy_R1_2 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R1_use <- accuracy_R1 %>% 
  filter(!(index %in% accuracy_R1_2$index))


accuracy_R1_combined <- full_join(accuracy_R1_use,accuracy_R1_2)


accuracy_R1_3 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_3_R1.xlsx",
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R1_3 <- accuracy_R1_3 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R1 <- full_join(accuracy_R1_combined,accuracy_R1_3)


accuracy_R1 <- accuracy_R1 %>% 
  rename(accuracy_R1 = accuracy)



# Rater 2

accuracy_R2 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_R2.xlsx",
                          col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R2_2 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_2_R2.xlsx",
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R2 <- accuracy_R2 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R2_2 <- accuracy_R2_2 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R2_use <- accuracy_R2 %>% 
  filter(!(index %in% accuracy_R2_2$index))


accuracy_R2_combined <- full_join(accuracy_R2_use,accuracy_R2_2)

accuracy_R2_3 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_3_R2.xlsx",
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R2_3 <- accuracy_R2_3 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R2 <- full_join(accuracy_R2_combined,accuracy_R2_3)



accuracy_R2 <- accuracy_R2 %>% 
  rename(accuracy_R2 = accuracy)



# Rater 3

accuracy_R3 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_R3.xlsx",
                          col_types = c("numeric", "numeric", "text", "text", "numeric"))


accuracy_R3_2 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_2_R3.xlsx",
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R3 <- accuracy_R3 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R3_2 <- accuracy_R3_2 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R3_use <- accuracy_R3 %>% 
  filter(!(index %in% accuracy_R2_2$index))


accuracy_R3_combined <- full_join(accuracy_R3_use,accuracy_R3_2)

accuracy_R3_3 <- read_excel("data/translation_rating/results/Translation_rating_accuracy_3_R3.xlsx",
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R3_3 <- accuracy_R3_3 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R3 <- full_join(accuracy_R3_combined,accuracy_R3_3)



accuracy_R3 <- accuracy_R3 %>% 
  rename(accuracy_R3 = accuracy)


remove(accuracy_R1_2, accuracy_R1_3, accuracy_R1_combined, accuracy_R1_use, accuracy_R2_2, accuracy_R2_3, accuracy_R2_combined, accuracy_R2_use, accuracy_R3_2, accuracy_R3_3, accuracy_R3_combined, accuracy_R3_use)

## get initial list

load("~/Translators/data/translation_rating/Translation_rating_accuracy_all.RData")



tra_ra_accuracy <- tra_ra_accuracy_all %>% 
  select(-reference_translation, -control_number)

tra_ra_accuracy$index <- as.numeric(tra_ra_accuracy$index)
tra_ra_accuracy$translation <- as.character(tra_ra_accuracy$translation)
#trans_rat_fluency$sentences_nr <- as.numeric(trans_rat_fluency$sentences_nr)



# combine datasets

tra_ra_accuracy <- full_join(tra_ra_accuracy,accuracy_R1)

tra_ra_accuracy <- full_join(tra_ra_accuracy,accuracy_R2)

tra_ra_accuracy <- full_join(tra_ra_accuracy,accuracy_R3)

accuracy_results <- tra_ra_accuracy %>% 
  select(id, group, text, condition, sentence_nr, accuracy_R1, accuracy_R2, accuracy_R3)

remove(tra_ra_accuracy, tra_ra_accuracy_all)

for (i in 1:nrow(accuracy_results)){
  if(is.na(accuracy_results$accuracy_R1[i])){
    accuracy_results$accuracy_R2[i] = NA
    accuracy_results$accuracy_R3[i] = NA
  }
  if(is.na(accuracy_results$accuracy_R2[i])){
    accuracy_results$accuracy_R1[i] = NA
    accuracy_results$accuracy_R3[i] = NA
  }  
  if(is.na(accuracy_results$accuracy_R3[i])){
    accuracy_results$accuracy_R1[i] = NA
    accuracy_results$accuracy_R2[i] = NA
  }  
}

accuracy_results_icc <- accuracy_results %>% 
  filter(!(is.na(accuracy_R1))) %>% 
  select(accuracy_R1, accuracy_R2, accuracy_R3)

icc(
  accuracy_results_icc, model = "twoway", 
  type = "consistency", unit = "average"
)

accuracy_results_avg <- accuracy_results %>% 
  group_by(id, text, condition) %>% 
  summarise(meanR1 = mean(accuracy_R1, na.rm = TRUE), meanR2 = mean(accuracy_R2, na.rm = TRUE), meanR3 = mean(accuracy_R3,na.rm = TRUE),n_obs = n()) %>% 
  ungroup()

accuracy_results_avg_icc <- accuracy_results_avg %>% 
  select(meanR1, meanR2,meanR3)

icc(
  accuracy_results_avg_icc, model = "twoway", 
  type = "consistency", unit = "average"
)

## mean all raters

accuracy_results_avgR <- accuracy_results_avg %>% 
  mutate(meanR = (meanR1+ meanR2 + meanR3)/3)

grande_results_accuracy <- accuracy_results_avgR %>% 
  group_by(text, condition) %>% 
  summarise(accuracyRating = mean(meanR), n_subjects = n(), n_obs = sum(n_obs))
