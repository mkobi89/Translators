###########################################################
##                      Behavioral Data                  ##
##                    data preprocessing                 ##
###########################################################


library(tidyverse)

# data path
dataFolderRaw   <- file.path("data/rawdata")
dataFolder   <- file.path("data")

## read files
controlQuestions <- read.csv(file.path(dataFolderRaw,"controlQuestions.csv"), header = TRUE, sep = ";")
expControl <- read.csv(file.path(dataFolderRaw,"expControl.csv"), header = TRUE, sep = ";")
perceivedDifficulty <- read.csv(file.path(dataFolderRaw,"perceivedDifficulty.csv"), header = TRUE, sep = ";")
readingDuration <- read.csv(file.path(dataFolderRaw,"readingDuration.csv"), header = TRUE, sep = ";")
textOutput <- read.csv(file.path(dataFolderRaw,"textOutput.csv"), header = TRUE, sep = ";")


## include data from nback-task

source(file.path("R/Preprocessing/nback.R"))


indices_nback_wide <- indices_nback %>%
  select(id, task, dprime) %>% 
  pivot_wider(names_from = task, values_from = dprime) %>% 
  rename(auditory_dprime = auditory, visual_dprime = visual)

## join datasets

psychometrics <- full_join(psychometrics,indices_nback_wide, by = "id" )


## include data from language survey

source(file.path("R/Preprocessing/language_survey.R"))

hgf_used <- hgf %>% 
  filter(group != "IntPro", group != "IntMA", group != "IntBA") %>% 
  select(VPN_Code, cum_trainingh_DuU, Prozent_cumth_Life.x,hpd_DuU, hpw_letztesJahr_DE, hpw_letztesJahr_E, hpd_ALLE, Prozent_ALLE_pd)

colnames(hgf_used) <- c("VPN_Code", "cumTH_U", "percCumTH_U_life", "hpd_U", "hpw_DE_lj", "hpw_E_lj", "hpd_all", "perchpd_all")


## Check for doubled dataframes and create new subset ----
#doubles <- hgf_used %>%
#  group_by(VPN_Code) %>%
#  filter(n()>1) %>% 
#  summarize(n=n())

#doubles_df <- hgf_used %>% 
#  filter(VPN_Code == doubles$VPN_Code[1] | VPN_Code == doubles$VPN_Code[2] | VPN_Code == doubles$VPN_Code[3] | VPN_Code == doubles$VPN_Code[4])

#hgf <- hgf %>% 
#  filter(VPN_Code != doubles$VPN_Code[1] & VPN_Code != doubles$VPN_Code[2] & VPN_Code != doubles$VPN_Code[3] & VPN_Code != doubles$VPN_Code[4])

psychometrics <- full_join(psychometrics,hgf_used, by = "VPN_Code")

psychometrics <- psychometrics %>% 
  filter(id != "NA")

psychometrics$percCumTH_U_life <- as.numeric(psychometrics$percCumTH_U_life)
psychometrics$hpd_U <- as.numeric(psychometrics$hpd_U)

## save Rdata

save(psychometrics, file = file.path(dataFolder,"psychometrics.RData"))




