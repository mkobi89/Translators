###########################################################
##                      Copying Task                     ##
##                    data preprocessing                 ##
###########################################################
## Description :: loads results of copying task and 
##                original stimuli to calculate string
##                distance from result to stimuli
## Input :::::::: csv data files
## Libraries :::: dplyr, stringdist
## Output ::::::: psychometrics.Rdata
###########################################################


## libraries
library(stringdist)
library(tidyverse)

# data path
dataFolderRaw   <- file.path("data/rawdata/task")
dataFolder   <- file.path("data")


# get file list of results from all participants
file_list <- list.files(file.path(dataFolderRaw,"/copying"))

# get original stimuli of all 4 texts
stimulus <- read.csv(file.path(dataFolderRaw,"stimulus.csv"),header = TRUE, sep = ";")

# remove empty rows
stimulus <- stimulus %>% 
  filter(T1_SE_copy_stimulus != "")

# define varaible as char vectors
as_char <- c(1:4)
stimulus[, as_char] <- lapply(stimulus[, as_char], as.character)


# preallocate matrix for results
res_copy <- matrix(nrow = length(file_list), ncol = 5, byrow = FALSE, dimnames = NULL)

# loop through file list to calculate results
for (f in 1:length(file_list)){

  #  print(file_list[f])
  copy <- read.csv(file=file.path(dataFolderRaw,"/copying",file_list[f]), header = TRUE, sep=";",na.strings = c("", "NA"))
  
  # start with second row as first row (title) was not shown in the experiment
  copy = copy[2:nrow(copy),]
  copy[, as_char] <- lapply(copy[, as_char], as.character)

  max_row <- matrix(nrow = 1, ncol = 4, byrow = FALSE, dimnames = NULL)
  res_copy_sub <- matrix(nrow = 38, ncol = 4, byrow = FALSE, dimnames = NULL)  
    
  # Get last row in each column of copy
  for (t in 1:ncol(copy)){
    for (s in nrow(copy):1){
      if (is.na(copy[s,t])){
        max_row[t] <- s-1
      } else {
        max_row[t] <- s
        break
      }
      
    }
  }  
 # calculate results using stringdist
  for (t in 1:ncol(copy)){
    for (s in 1:nrow(copy)){
      if (!is.na(copy[s,t])){
        if (s != max_row[t]){
          res_copy_sub[s,t] <- stringdist(copy[s,t],stimulus[s,t],method = "osa")
        } else {
          res_copy_sub[s,t] <- stringdist(copy[s,t],substr(stimulus[s,t], 1, nchar(copy[s,t])),method = "osa")
        }

      }
    }
  }

  # fill matrix with results
  for (t in 2:5){
    if (max_row[t-1] != 0){
      res_copy[f,t] <- colSums(res_copy_sub, na.rm = TRUE)[t-1]
    } else {
      res_copy[f,t] <- NA
    }
  }
}

# add participant names
res_copy[,1] <- substr(file_list,1,3)

# change column names
colnames(res_copy) <- c("id", "T1_SE_copy", "T1_ELF_copy", "T2_SE_copy", "T2_ELF_copy")

# define data frame as tibble and factors
res_copy <- res_copy %>% 
  as_tibble()

as_numeric<- c(2,3,4,5)
res_copy[, as_numeric] <- lapply(res_copy[, as_numeric], as.numeric)
res_copy[, 1] <- lapply(res_copy[, 1], factor)

##convert to long format

res_copy_long <- pivot_longer(
  res_copy,
  2:5,
  names_to = "cond",
  values_to = "copy_stringdist"
)

for(i in 1:nrow(res_copy_long)){
  if(res_copy_long$cond[i] == "T1_SE_copy"){
    res_copy_long$cond_new[i] = "31_35"
  }
  if(res_copy_long$cond[i] == "T1_ELF_copy"){
    res_copy_long$cond_new[i] = "32_36"
  }
  if(res_copy_long$cond[i] == "T2_SE_copy"){
    res_copy_long$cond_new[i] = "33_37"
  }
  if(res_copy_long$cond[i] == "T2_ELF_copy"){
    res_copy_long$cond_new[i] = "34_38"
  } 
}

res_copy <- res_copy_long

## Clear workspace----
remove(copy, max_row, res_copy_sub, stimulus, as_char, as_numeric, dataFolder, dataFolderRaw, f, file_list, s, t,i, res_copy_long)
