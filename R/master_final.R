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
figureFolder <- file.path("figures/final")
RFolder      <- file.path("R/final")
saveFolder    <- file.path("data")


##########################################################
##                      PROCESSING                      ##
##########################################################

# 01: Prepare and preprocess datasets----------------------
# load and merge the data files
source(paste(RFolder, "01_answer_files_to_LDT_final.R", sep = "/"))

# load psychometrics
source(paste(RFolder, "02_psychometrics_final.R", sep = "/"))

# calculate outliers --> remove plot script from outliers
source(paste(RFolder, "03_RT_outliers_final.R", sep = "/"))


# calculate DDM parms
#source(paste(RFolder, "04_DDM_generate_datasets_without_outliers_final.R", sep = "/"))
#source(paste(RFolder, "05_DDM_parameter_estimation_final.R", sep = "/"))

# combine LDT, psychometrics, DDM and latencie values in a lfinal data format, calculate accuracy and mean rt for each condition and each person
source(paste(RFolder, "06_final_table_final.R", sep = "/"))


#### shortcut load datasets ----
#load(paste(saveFolder, "LDT.Rdata", sep = "/"))
#load(paste(saveFolder, "LDT_clean.Rdata", sep = "/"))
#load(paste(saveFolder, "psychometrcs.Rdata", sep = "/"))
#load(paste(saveFolder, "accuracies.Rdata", sep = "/"))
#load(paste(saveFolder, "all_tasks.Rdata", sep = "/"))


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



exclude_lower <- exclude_final %>% 
  filter(RT < 0.3)

critical_trials_switch <- LDT_final %>%
  filter(condition != "GNW", condition != "ENW", condition != "NWG", condition != "NWE", condition != "NWNW")

trials_wf <- LDT_final %>% 
  filter(which_task != "Switch")

exclude_wf <- exclude_final %>% 
  filter(which_task != "Switch")


exclude_switch <- exclude_final %>% 
  filter(condition != "GNW", condition != "ENW", condition != "NWG", condition != "NWE", condition != "NWNW")

exclude_trial <- (nrow(exclude_switch)+nrow(exclude_wf))/(nrow(critical_trials_switch)+nrow(trials_wf))



# 02: Process and Plot -----------------------------------
# extract, summarise and plot the relevant variables from the data
# source(paste(RFolder, "2_process.R", sep = "/"))

source(paste(RFolder, "07_summarise_tables.R", sep = "/"))

source(paste(RFolder, "08_plots.R", sep = "/"))

# 03: Analyse ------------------------------------------
# explore and analyse the data
#source(paste(RFolder, "3_analyse.R", sep = "/"))
