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

indices_nback_wide <- indices_nback %>%
  select(id, task, dprime) %>% 
  pivot_wider(names_from = task, values_from = dprime) %>% 
  rename(auditory_dprime = auditory, visual_dprime = visual)

psychometrics <- full_join(psychometrics,indices_nback_wide, by = "id" )

psychometrics <- psychometrics %>% 
  filter(VPN_Code != "CF3")


## include language survey dataset
hgf_used <- hgf %>% 
#  filter(group != "IntPro", group != "IntMA", group != "IntBA") %>% 
  select(VPN_Code, cum_trainingh_DuU, Prozent_cumth_Life.x,hpd_DuU, hpw_letztesJahr_DE, hpw_letztesJahr_E, hpd_ALLE, Prozent_ALLE_pd)

colnames(hgf_used) <- c("VPN_Code", "cumTH_U", "percCumTH_U_life", "hpd_U", "hpw_DE_lj", "hpw_E_lj", "hpd_all", "perchpd_all")

psychometrics <- full_join(psychometrics,hgf_used, by = "VPN_Code")

psychometrics <- psychometrics %>% 
  filter(id != "NA")

psychometrics$percCumTH_U_life <- as.numeric(psychometrics$percCumTH_U_life)
psychometrics$hpd_U <- as.numeric(psychometrics$hpd_U)


psychometrics <- psychometrics %>% 
  filter(id != "CK0", id != "CU2")

psychometrics$id <- droplevels(psychometrics$id)
psychometrics$gender <- droplevels(psychometrics$gender)


## adding fft

alldata <- full_join(psychometrics,fft, by = c("id"))


## adding perceived difficulty

#perceivedDifficulty$task <- tolower(perceivedDifficulty$task)

perceivedDifficulty <- perceivedDifficulty %>% 
  select(-timeTra)

alldata <- full_join(alldata,perceivedDifficulty, by = c("id","group", "task", "text", "condition"))




## adding reading duration
readingDuration <- readingDuration %>% 
  mutate(task = "Reading") %>% 
  select(1,2,8,3:7)


alldata <- full_join(alldata,readingDuration, by = c("id","group","task","text","condition", "time"))



## adding control questions
CQRes <- controlQuestions %>% 
  group_by(id, group, condition) %>% 
  summarise(percCQRes = sum(correct)/5) %>% 
  mutate(task = "Reading")

alldata <- full_join(alldata,CQRes, by = c("id","group", "condition", "task"))




## adding text output
#textOutput$task <- tolower(textOutput$task)

textOutput <- textOutput %>% 
  select(-timeTra)

alldata <- full_join(alldata,textOutput, by = c("id","group", "task", "text", "condition"))
alldata <- unite(alldata,time, time.x, time.y, na.rm = TRUE)

alldata$time <- gsub("_First", "", alldata$time)
alldata$time <- gsub("_Second", "", alldata$time)

## adding results copy task

res_copy <- res_copy %>% 
  select(-cond) %>% 
  filter(!(is.na(copy_stringdist))) %>% 
  rename(cond = cond_new)


alldata <- full_join(alldata,res_copy, by = c("id","cond"))


alldata <- alldata %>% 
  filter(id != "CK0", id != "CU2")


alldata$cond <- as.factor(alldata$cond)
alldata$task <- factor(alldata$task,  levels = c("Reading","Copying", "Translating", "Reading_post"))
alldata$text <- as.factor(alldata$text)
alldata$condition <- factor(alldata$condition,  levels = c("EdE","ELF"))
alldata$time <- as.factor(alldata$time)

remove(readingDuration, controlQuestions,CQRes, perceivedDifficulty, res_copy, textOutput, expControl, dataFolder, dataFolderRaw, hgf, hgf_used, indices_nback, indices_nback_wide)




