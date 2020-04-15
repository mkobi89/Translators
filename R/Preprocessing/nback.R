###########################################################
##                         nBack                         ##
##                    data preprocessing                 ##
###########################################################

## libraries, packages, path ----
if (!"tidyverse" %in% installed.packages()[, "Package"]) {
  install.packages("tidyverse")
}

library(tidyverse)

# data path
dataFolderRaw   <- file.path("data/rawdata/nback_logs")
dataFolder   <- file.path("data")

# read files
file_list <- list.files(dataFolderRaw)

# matrix for results of loop
res_nback <- matrix(nrow = 0, ncol = 0, byrow = FALSE, dimnames = NULL)

# loop over all files
for (f in 1:length(file_list)){
  print(file_list[f])
  nBack <- read.csv(file=file.path(dataFolderRaw,file_list[f]), skip = 3, header = TRUE, sep="\t", na.strings = c("", "NA"))
  
  #select columns of intrest
  nBack <- nBack %>%
    select(Subject, Event.Type, Code, TTime, Stim.Type)
  
  #creat empty column to fill results of RT
  nBack$RT <- NA
  
  #loop for RT (RT in row before)
  #condition: if Event.Type = Response & Picture in row befor (i-1)
  #take TTime of row in Response and add to column RT (+ convert into ms)
  for (i in 1:nrow(nBack)){
    if (nBack$Event.Type[i] == "Response" && nBack$Event.Type[i-1] == "Picture"){
      nBack$RT[i-1] <- nBack$TTime[i]/10
    }
  }
  
  #filter rows with relevant information
  v_response <- nBack %>% 
    filter(Event.Type == "Picture")
  
  #same loop for auditory condition
  for (i in 1:nrow(nBack)){
    if (nBack$Event.Type[i] == "Response" && nBack$Event.Type[i-1] == "Sound"){
      nBack$RT[i-1] <- nBack$TTime[i]/10
    }
  }
  
  a_response <- nBack %>% 
    filter(Event.Type == "Sound")  
  
  
  # fill matrix with files
  res_nback <- rbind.data.frame(res_nback, v_response, a_response)

}

# select columns of interest, delete rows with "Start", rename column
res_nback <- res_nback %>% 
  select(Subject, Event.Type, Code, Stim.Type, RT) %>% 
  filter(str_detect(Code, "Start", negate = TRUE)) %>% 
  rename(Task = Event.Type, Stimulus = Code, Response = Stim.Type)


#rename Picture/Sound
res_nback$Task <- gsub("Picture", "visual", res_nback$Task)
res_nback$Task <- gsub("Sound", "auditory", res_nback$Task)



#Recode for Stimulus (Data Mathias Lab)
res_nback$Stimulus <- gsub("A50", "A", res_nback$Stimulus)
res_nback$Stimulus <- gsub("E51", "E", res_nback$Stimulus)
res_nback$Stimulus <- gsub("I52", "I", res_nback$Stimulus)
res_nback$Stimulus <- gsub("O53", "O", res_nback$Stimulus)
res_nback$Stimulus <- gsub("U54", "U", res_nback$Stimulus)
res_nback$Stimulus <- gsub("B55", "B", res_nback$Stimulus)
res_nback$Stimulus <- gsub("F56", "F", res_nback$Stimulus)
res_nback$Stimulus <- gsub("H57", "H", res_nback$Stimulus)
res_nback$Stimulus <- gsub("L58", "L", res_nback$Stimulus)
res_nback$Stimulus <- gsub("M59", "M", res_nback$Stimulus)

# Clear up data
remove(a_response, nBack, v_response, f, file_list, i)  


# Renaming Participants

res_nback$Subject <- gsub("?oMA_CE0", "CE0", res_nback$Subject)
res_nback$Subject <- gsub("MPR_AUA0310", "CU3", res_nback$Subject)
res_nback$Subject <- gsub("MBA_CEG0921", "CM0", res_nback$Subject)
res_nback$Subject <- gsub("CUO", "CU0", res_nback$Subject)
res_nback$Subject <- gsub("MPR_RBM10799", "MPR_RBM1079", res_nback$Subject)
res_nback$Subject <- gsub("MPR_RBM1079", "CU2", res_nback$Subject)
res_nback$Subject <- gsub("UMA_MDG1232", "CE7", res_nback$Subject)
res_nback$Subject <- gsub("UPR_CBA0104", "CI4", res_nback$Subject)


# Define variables as factors and dataframe as tibble

res_nback[,1:3] <- lapply(res_nback[,1:3], factor)

res_nback <- res_nback %>%
  as_tibble()

#res_nback




## Save Dataframes ----


save(res_nback, file = file.path(dataFolder,"res_nback.RData"))

