
###########################################################
##                         Translation rating            ##
##                         preprocessing                 ##
###########################################################

## libraries, packages, path ----
if (!"tidyverse" %in% installed.packages()[, "Package"]) {
  install.packages("tidyverse")
}

library(tidyverse)

## get data
dataFolder <- file.path("data")

## file names 
tra_ra_t1_2 <- read.csv(file.path(dataFolder,"rawdata/translation_rating_t1_new_2.csv"), header = TRUE, sep = ";")
tra_ra_t2_2 <- read.csv(file.path(dataFolder,"rawdata/translation_rating_t2_new_2.csv"), header = TRUE, sep = ";")


## join datasets

tra_ra_2 <- full_join(tra_ra_t1_2,tra_ra_t2_2)

cf7 <- tra_ra_2 %>% 
  filter(id=="CF7")

ck0 <- tra_ra_2 %>% 
  filter(id=="CK0")

tra_ra_2_w_o_cf7 <- tra_ra_2 %>% 
  filter(id != "CF7", id != "CK0")

tra_ra_2_cf7_end <- rbind(tra_ra_2_w_o_cf7, cf7)
tra_ra_2_ck0_end <- rbind(tra_ra_2_cf7_end, ck0)

## fluency shuffling

tra_ra_fluency_2 <- tra_ra_2_ck0_end

for(i in 1:nrow(tra_ra_fluency_2)){
  tra_ra_fluency_2$index[i] = i
}

tra_ra_fluency_2_select <- tra_ra_fluency_2 %>% 
  filter(id == "CF7" | id == "CK0")

rand_numbers <- 1:1:nrow(tra_ra_fluency_2_select)
rand_numbers <- sample(rand_numbers)

tra_ra_fluency_2_select$rand_index <- rand_numbers

save(tra_ra_fluency_2_select, file = file.path(dataFolder,"Translation_rating_fluency_select2_original.RData"))

tra_ra_fluency_select_shuffle <- tra_ra_fluency_2_select[order(tra_ra_fluency_2_select$rand_index), ]
save(tra_ra_fluency_select_shuffle, file = file.path(dataFolder,"Translation_rating_fluency_select2_shuffle.RData"))

tra_ra_fluency_select_shuffle <- tra_ra_fluency_select_shuffle %>% 
  select(10,9,7)

tra_ra_fluency_select_shuffle$fluency <- ""

write.csv(tra_ra_fluency_select_shuffle,file.path(dataFolder,"translation_rating_fluency_3.csv"), row.names = FALSE)


## accuracy

tra_ra_accuracy_2 <- tra_ra_2_ck0_end

for(i in 1:nrow(tra_ra_accuracy_2)){
  tra_ra_accuracy_2$index[i] = i
}

tra_ra_accuracy_2_select <- tra_ra_accuracy_2 %>% 
  filter(id == "CK0" )
#  filter(index > 150, index != 192, index != 257, index != 286, index != 364, index != 376, index != 437, index != 468, index != 510)

rand_numbers <- 1:1:nrow(tra_ra_accuracy_2_select)
rand_numbers <- sample(rand_numbers)

tra_ra_accuracy_2_select$rand_index <- rand_numbers

save(tra_ra_accuracy_2_select, file = file.path(dataFolder,"Translation_rating_accuracy_select2_original.RData"))

tra_ra_accuracy_select_shuffle <- tra_ra_accuracy_2_select[order(tra_ra_accuracy_2_select$rand_index), ]
save(tra_ra_accuracy_select_shuffle, file = file.path(dataFolder,"Translation_rating_accuracy_select2_shuffle.RData"))

tra_ra_accuracy_select_shuffle <- tra_ra_accuracy_select_shuffle %>% 
  select(10,9,7,8)

tra_ra_accuracy_select_shuffle$accuracy <- ""

write.csv(tra_ra_accuracy_select_shuffle,file.path(dataFolder,"translation_rating_accuracy_3.csv"), row.names = FALSE)


## redo stuff
tra_ra_accuracy_all <- tra_ra_accuracy_2
save(tra_ra_accuracy_all, file = file.path(dataFolder,"Translation_rating_accuracy_all.RData"))

