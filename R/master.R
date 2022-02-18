##########################################################
##                       LIBRARIES                      ##
##########################################################
# install tidyverse if not installed already
if(!"tidyverse" %in% installed.packages()[ ,"Package"]) {
  install.packages("tidyverse")
}

if(!"gtsummary" %in% installed.packages()[ ,"Package"]) {
  install.packages("gtsummary")
}

# load tidyverse
library(tidyverse)


##########################################################
##                       SETTINGS                       ##
##########################################################

# set seed for reproducible results
set.seed(1234321)

#dataFolderRaw   <- file.path("data/rawdata")
figureFolder <- file.path("figures")
RFolder      <- file.path("R")
saveFolder    <- file.path("data")


##########################################################
##                      PROCESSING                      ##
##########################################################

# 01: Prepare and preprocess datasets----------------------
# load psychometrics
source(paste(RFolder, "01_psychometrics.R", sep = "/"))

# load nback
source(paste(RFolder, "02_nback.R", sep = "/"))

# load language survey
source(paste(RFolder, "03_language_survey.R", sep = "/"))


# load copying task
source(paste(RFolder, "04_copyingtask.R", sep = "/"))


# combine LDT, psychometrics, DDM and latencie values in a lfinal data format, calculate accuracy and mean rt for each condition and each person
source(paste(RFolder, "06_fft.R", sep = "/"))

source(paste(RFolder, "07_merging_data.R", sep = "/"))


## remove unwanted  participants
psychometrics_final <- psychometrics_final %>% 
  filter(id != "C50", id != "C55", id != "CE5",id != "CI0",id != "CI2",id != "CJ0", id != "CM7",id != "CN1", id != "CU2", id != "C69", id != "CE8", id != "CM8")
psychometrics_final$id <- droplevels(psychometrics_final$id)

all_tasks_final <- all_tasks_final %>% 
  filter(subjectID != "C50", subjectID != "C55", subjectID != "CE5",subjectID != "CI0",subjectID != "CI2", subjectID != "CJ0",subjectID != "CM7",subjectID != "CN1", subjectID != "CU2", subjectID != "C69", subjectID != "CE8", subjectID != "CM8")
all_tasks_final$subjectID <- droplevels(all_tasks_final$subjectID)

LDT_clean_final <- LDT_clean_final %>% 
  filter(subjectID != "C50", subjectID != "C55", subjectID != "CE5",subjectID != "CI0",subjectID != "CI2", subjectID != "CJ0", subjectID != "CM7",subjectID != "CN1", subjectID != "CU2", subjectID != "C69", subjectID != "CE8", subjectID != "CM8")
LDT_clean_final$subjectID <- droplevels(LDT_clean_final$subjectID)

LDT_final <- LDT_final %>% 
  filter(subjectID != "C50", subjectID != "C55", subjectID != "CE5",subjectID != "CI0",subjectID != "CI2", subjectID != "CJ0", subjectID != "CM7",subjectID != "CN1", subjectID != "CU2", subjectID != "C69", subjectID != "CE8", subjectID != "CM8")
LDT_final$subjectID <- droplevels(LDT_final$subjectID)

exclude_final <- exclude_final %>% 
  filter(subjectID != "C50", subjectID != "C55", subjectID != "CE5",subjectID != "CI0",subjectID != "CI2", subjectID != "CJ0", subjectID != "CM7",subjectID != "CN1", subjectID != "CU2", subjectID != "C69", subjectID != "CE8", subjectID != "CM8")
exclude_final$subjectID <- droplevels(exclude_final$subjectID)




# 02: Process and Plot -----------------------------------
# extract, summarise and plot the relevant variables from the data
# source(paste(RFolder, "2_process.R", sep = "/"))

source(paste(RFolder, "07_summarise_tables.R", sep = "/"))

source(paste(RFolder, "08_plots.R", sep = "/"))

# 03: Analyse ------------------------------------------
# explore and analyse the data
#source(paste(RFolder, "3_analyse.R", sep = "/"))
