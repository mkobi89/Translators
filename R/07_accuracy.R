
###########################################################
##                        Translation rating             ##
##                         collecting data               ##
###########################################################
## Description :: gathers all accuracy ratings
## Input :::::::: Translation_rating_accuracy*.txt
## Libraries :::: tidyverse, readxl
## Output ::::::: fluency_results
###########################################################

## libraries
library(tidyverse)
library(readxl)
library(irr)

## get data
dataFolder <- file.path("data/rawdata/translation_rating_results")


## Rater 1
# read data (two different files because of missing data)
accuracy_R1 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_R1.xlsx", sep = "/"),
                         col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R1_2 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_2_R1.xlsx", sep = "/"),
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R1 <- accuracy_R1 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R1_2 <- accuracy_R1_2 %>% 
  select(-rand_index, -translation, -reference_translation)

# remove doubled values
accuracy_R1_use <- accuracy_R1 %>% 
  filter(!(index %in% accuracy_R1_2$index))

# join data
accuracy_R1_combined <- full_join(accuracy_R1_use,accuracy_R1_2)


accuracy_R1_3 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_3_R1.xlsx", sep = "/"),
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R1_3 <- accuracy_R1_3 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R1 <- full_join(accuracy_R1_combined,accuracy_R1_3)


accuracy_R1 <- accuracy_R1 %>% 
  rename(accuracy_R1 = accuracy)

## Rater 2
# read data
accuracy_R2 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_R2.xlsx", sep = "/"),
                          col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R2_2 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_2_R2.xlsx", sep = "/"),
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R2 <- accuracy_R2 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R2_2 <- accuracy_R2_2 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R2_use <- accuracy_R2 %>% 
  filter(!(index %in% accuracy_R2_2$index))

accuracy_R2_combined <- full_join(accuracy_R2_use,accuracy_R2_2)

accuracy_R2_3 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_3_R2.xlsx", sep = "/"),
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R2_3 <- accuracy_R2_3 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R2 <- full_join(accuracy_R2_combined,accuracy_R2_3)

accuracy_R2 <- accuracy_R2 %>% 
  rename(accuracy_R2 = accuracy)



# Rater 3
# read data
accuracy_R3 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_R3.xlsx", sep = "/"),
                          col_types = c("numeric", "numeric", "text", "text", "numeric"))


accuracy_R3_2 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_2_R3.xlsx", sep = "/"),
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R3 <- accuracy_R3 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R3_2 <- accuracy_R3_2 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R3_use <- accuracy_R3 %>% 
  filter(!(index %in% accuracy_R2_2$index))


accuracy_R3_combined <- full_join(accuracy_R3_use,accuracy_R3_2)

accuracy_R3_3 <- read_excel(paste(dataFolder, "Translation_rating_accuracy_3_R3.xlsx", sep = "/"),
                            col_types = c("numeric", "numeric", "text", "text", "numeric"))

accuracy_R3_3 <- accuracy_R3_3 %>% 
  select(-rand_index, -translation, -reference_translation)

accuracy_R3 <- full_join(accuracy_R3_combined,accuracy_R3_3)

accuracy_R3 <- accuracy_R3 %>% 
  rename(accuracy_R3 = accuracy)

# remove unwanted variables
remove(accuracy_R1_2, accuracy_R1_3, accuracy_R1_combined, accuracy_R1_use, accuracy_R2_2, accuracy_R2_3, accuracy_R2_combined, accuracy_R2_use, accuracy_R3_2, accuracy_R3_3, accuracy_R3_combined, accuracy_R3_use)

## get initial list to assign rating results to participants
load(paste(dataFolder, "Translation_rating_accuracy_all.RData", sep = "/"))

tra_ra_accuracy <- tra_ra_accuracy_all %>% 
  select(-reference_translation, -control_number)

tra_ra_accuracy$index <- as.numeric(tra_ra_accuracy$index)
tra_ra_accuracy$translation <- as.character(tra_ra_accuracy$translation)


# combine datasets

tra_ra_accuracy <- full_join(tra_ra_accuracy,accuracy_R1)

tra_ra_accuracy <- full_join(tra_ra_accuracy,accuracy_R2)

tra_ra_accuracy <- full_join(tra_ra_accuracy,accuracy_R3)

accuracy_results <- tra_ra_accuracy %>% 
  select(id, group, text, condition, sentence_nr, accuracy_R1, accuracy_R2, accuracy_R3)

remove(tra_ra_accuracy, tra_ra_accuracy_all)

accuracy_results$condition <- as.character(accuracy_results$condition)

# set all raters to NA if one rater was NA, add condition as variable
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
  if(accuracy_results$condition[i]== "SE"){
    accuracy_results$condition[i] = "EdE"
  }
}

accuracy_results$condition <- as.factor(accuracy_results$condition)

# remove unwanted variables
remove(accuracy_R1, accuracy_R2, accuracy_R3)

