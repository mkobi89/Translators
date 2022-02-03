###########################################################
##                      PSYCHOMETRICS                    ##
##                    DATA PREPROCESSING                 ##
###########################################################
## Description :: loads and merges psychometrics raw data
## Input :::::::: csv data file 
## Libraries :::: dplyr, readr, eeptools, lubridate
## Output ::::::: psychometrics.Rdata
##########################################################

## libraries, packages, path ----
if (!"tidyverse" %in% installed.packages()[, "Package"]) {
  install.packages("tidyverse")
}

if (!"lubridate" %in% installed.packages()[, "Package"]) {
  install.packages("lubridate")
}

if(!"gtsummary" %in% installed.packages()[ ,"Package"]) {
  install.packages("gtsummary")
}

if(!"webshot" %in% installed.packages()[ ,"Package"]) {
  install.packages("webshot")
}

library(tidyverse)
library(lubridate)
library(gtsummary)
library(webshot)

# data path
dataFolderRaw   <- file.path("data/rawdata")
dataFolder   <- file.path("data")

# read files
psychometrics <- read.csv(file.path(dataFolderRaw,"psychometrics.csv"), header = TRUE, sep = ";")

## remove unused rows

psychometrics = psychometrics %>% 
  filter(date !="")

## calculate age of participants
psychometrics$age <- floor(time_length(interval(as.Date(psychometrics$birthdate, "%d.%m.%Y"), as.Date(psychometrics$date, "%d.%m.%Y")), "years"))

## get handedness
for(i in 1:nrow(psychometrics)){
  if(psychometrics$Anz_re_Annett[i] >= 7) 
  {psychometrics$handedness[i] = "right-handed"}
  else if(psychometrics$Anz_re_Annett[i] == 6) 
  {psychometrics$handedness[i] = "ambidextrous"}
  else if(psychometrics$Anz_re_Annett[i] <= 5) 
  {psychometrics$handedness[i] = "left-handed"}
}

psychometrics$english_score[psychometrics$english_score == 0] <- NA

## Select relevant variables

colnames(psychometrics)[1] <- "VPN_Code"

psychometrics = psychometrics %>% 
  select(VPN_Code, id, group, age, gender, english_score, HAWIE_T_Value, handedness)
  



## Tell R, which variables in datasets are factors and numeric
psychometrics$id <- as.factor(psychometrics$id)
psychometrics$group <- as.factor(psychometrics$group)
psychometrics$handedness <- as.factor(psychometrics$handedness)
psychometrics$english_score <- as.numeric(psychometrics$english_score)


## Clean up workspace

remove(i, dataFolder, dataFolderRaw)
