###########################################################
##                      Behavioral Data                  ##
##                    data preprocessing                 ##
###########################################################

## libraries, packages, path ----
if (!"tidyverse" %in% installed.packages()[, "Package"]) {
  install.packages("tidyverse")
}

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


## save RData

save(controlQuestions, file = file.path(dataFolder,"controlQuestions.RData"))
save(expControl, file = file.path(dataFolder,"expControl.RData"))
save(perceivedDifficulty, file = file.path(dataFolder,"perceivedDifficulty.RData"))
save(readingDuration, file = file.path(dataFolder,"readingDuration.RData"))
save(textOutput, file = file.path(dataFolder,"textOutput.RData"))

remove(dataFolder, dataFolderRaw)
