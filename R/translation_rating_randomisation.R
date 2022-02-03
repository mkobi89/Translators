
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
tra_ra_t1 <- read.csv(file.path(dataFolder,"rawdata/translation_rating_t1.csv"), header = TRUE, sep = ";")
tra_ra_t2 <- read.csv(file.path(dataFolder,"rawdata/translation_rating_t2.csv"), header = TRUE, sep = ";")


## join datasets

tra_ra <- full_join(tra_ra_t1,tra_ra_t2)


## fluency shuffling

tra_ra_fluency <- tra_ra

for(i in 1:nrow(tra_ra_fluency)){
  tra_ra_fluency$index[i] = i
}

rand_numbers <- 1:1:nrow(tra_ra_fluency)
rand_numbers <- sample(rand_numbers)

tra_ra_fluency$rand_index <- rand_numbers

save(tra_ra_fluency, file = file.path(dataFolder,"Translation_rating_fluency_original.RData"))

tra_ra_fluency_shuffle <- tra_ra_fluency[order(tra_ra_fluency$rand_index), ]
save(tra_ra_fluency_shuffle, file = file.path(dataFolder,"Translation_rating_fluency_shuffle.RData"))

tra_ra_fluency_shuffle <- tra_ra_fluency_shuffle %>% 
  select(10,9,7)

tra_ra_fluency_shuffle$fluency <- ""

write.csv(tra_ra_fluency_shuffle,file.path(dataFolder,"translation_rating_fluency.csv"), row.names = FALSE)


## accuracy

tra_ra_accuracy <- tra_ra

for(i in 1:nrow(tra_ra_accuracy)){
  tra_ra_accuracy$index[i] = i
}

rand_numbers <- 1:1:nrow(tra_ra_accuracy)
rand_numbers <- sample(rand_numbers)

tra_ra_accuracy$rand_index <- rand_numbers

save(tra_ra_accuracy, file = file.path(dataFolder,"Translation_rating_accuracy_original.RData"))

tra_ra_accuracy_shuffle <- tra_ra_accuracy[order(tra_ra_accuracy$rand_index), ]
save(tra_ra_accuracy_shuffle, file = file.path(dataFolder,"Translation_rating_accuracy_shuffle.RData"))

tra_ra_accuracy_shuffle <- tra_ra_accuracy_shuffle %>% 
  select(10,9,7,8)

tra_ra_accuracy_shuffle$accuracy <- ""

write.csv(tra_ra_accuracy_shuffle,file.path(dataFolder,"translation_rating_accuracy.csv"), row.names = FALSE)



