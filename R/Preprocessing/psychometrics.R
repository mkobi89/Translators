###########################################################
##                         Psychometrics                 ##
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

# read files
pilot_vpdata <- read.csv(file.path(dataFolderRaw,"psychometricsPilot.csv"), header = TRUE, sep = ";")
vpdata <- read.csv(file.path(dataFolderRaw,"psychometrics.csv"), header = TRUE, sep = ";")

## remove unused rows

pilot_vpdata = pilot_vpdata %>% 
  filter(date !="")

vpdata = vpdata %>% 
  filter(date !="")


## Join VP and Pilot data and select relevant variables

vpdata = vpdata %>% 
  select(id, group, gender, SpT_Score, HAWIE_T_Value, t_TMT_A_in_s, F_TMT_A, t_TMT_B_in_s, F_TMT_B, Anz_li_Annett, Anz_re_Annett)

pilot_vpdata = pilot_vpdata %>% 
  select(id, group, gender, HAWIE_T_Value, t_TMT_A_in_s, F_TMT_A, t_TMT_B_in_s, F_TMT_B, Anz_li_Annett, Anz_re_Annett)

vpdata = full_join(pilot_vpdata,vpdata, by = c("id", "group", "gender", "HAWIE_T_Value", "t_TMT_A_in_s", "F_TMT_A", "t_TMT_B_in_s", "F_TMT_B", "Anz_li_Annett", "Anz_re_Annett"))


# Tell R, which variables in datasets are factors
vpdata$id <- as.factor(vpdata$id)
vpdata$group <- as.factor(vpdata$group)


## save Rdata

save(vpdata, file = file.path(dataFolder,"vpdata.RData"))

## Clean up workspace

remove(pilot_vpdata, dataFolder, dataFolderRaw)
