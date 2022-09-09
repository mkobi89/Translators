
###########################################################
##                        Translation rating             ##
##                         collecting data               ##
###########################################################
## Description :: gathers all fluency ratings
## Input :::::::: Translation_rating_fluency*.txt
## Libraries :::: tidyverse, readxl
## Output ::::::: fluency_results
###########################################################

## libraries
library(tidyverse)
library(readxl)

## get data
dataFolder <- file.path("data/rawdata/translation_rating_results")


## Rater 1
# read data (two different files because of missing data)
fluency_R1 <- read_excel(paste(dataFolder, "Translation_rating_fluency_R1.xlsx", sep = "/"),
                         col_types = c("numeric", "numeric", "text", "numeric"))

fluency_R1_2 <- read_excel(paste(dataFolder, "Translation_rating_fluency_3_R1.xlsx", sep = "/"),
                         col_types = c("numeric", "numeric", "text", "numeric"))

fluency_R1 <- full_join(fluency_R1,fluency_R1_2)

fluency_R1 <- fluency_R1 %>% 
  rename(fluency_R1 = fluency)

fluency_R1 <- fluency_R1 %>% 
  select(-rand_index, -translation)


## Rater 2
# read data
fluency_R2 <- read_excel(paste(dataFolder, "Translation_rating_fluency_R2.xlsx", sep = "/"),
                         col_types = c("numeric", "numeric", "text", "numeric"))

fluency_R2_2 <- read_excel(paste(dataFolder, "Translation_rating_fluency_3_R2.xlsx", sep = "/"),
                           col_types = c("numeric", "numeric", "text", "numeric"))

fluency_R2 <- full_join(fluency_R2,fluency_R2_2)

fluency_R2 <- fluency_R2 %>% 
  rename(fluency_R2 = fluency)

fluency_R2 <- fluency_R2 %>% 
  select(-rand_index, -translation)

## Rater 3
# read data
fluency_R3 <- read_excel(paste(dataFolder, "Translation_rating_fluency_R3.xlsx", sep = "/"),
                         col_types = c("numeric", "numeric", "text", "numeric"))


fluency_R3_2 <- read_excel(paste(dataFolder, "Translation_rating_fluency_3_R3.xlsx", sep = "/"),
                           col_types = c("numeric", "numeric", "text", "numeric"))

fluency_R3 <- full_join(fluency_R3,fluency_R3_2)

fluency_R3 <- fluency_R3 %>% 
  rename(fluency_R3 = fluency)

fluency_R3 <- fluency_R3 %>% 
  select(-rand_index, -translation)

## get initial list to assign rating results to participants
load(paste(dataFolder,"Translation_rating_fluency_original.RData", sep = "/"))

tra_ra_fluency <- tra_ra_fluency %>% 
  select(-reference_translation, -control_number, -rand_index)

# add missing participants
load(paste(dataFolder,"Translation_rating_fluency_select2_original.RData", sep = "/"))

tra_ra_fluency_2 <- tra_ra_fluency_2_select %>% 
  select(-reference_translation, -control_number, -rand_index)

# join datasets
trans_rat_fluency <- full_join(tra_ra_fluency,tra_ra_fluency_2)

# redefine variables
trans_rat_fluency$index <- as.numeric(trans_rat_fluency$index)
trans_rat_fluency$translation <- as.character(trans_rat_fluency$translation)

# remove unwanted variables
remove(fluency_R1_2, fluency_R2_2, fluency_R3_2, tra_ra_fluency, tra_ra_fluency_2, tra_ra_fluency_2_select)

# combine datasets
trans_rat_fluency <- full_join(trans_rat_fluency,fluency_R1)
trans_rat_fluency <- full_join(trans_rat_fluency,fluency_R2)
trans_rat_fluency <- full_join(trans_rat_fluency,fluency_R3)

fluency_results <- trans_rat_fluency %>% 
  select(id, group, text, condition, sentence_nr, fluency_R1, fluency_R2, fluency_R3)

remove(trans_rat_fluency)

fluency_results$condition <- as.character(fluency_results$condition)

# set all raters to NA if one rater was NA, add condition as variable
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
  if(fluency_results$condition[i]== "SE"){
    fluency_results$condition[i] = "EdE"
  }
}

fluency_results$condition <- as.factor(fluency_results$condition)

# remove unwanted variables
remove(fluency_R1, fluency_R2, fluency_R3)
