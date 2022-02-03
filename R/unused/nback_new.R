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
dataFolder   <- file.path("logs")

# read files
file_list <- list.files(dataFolder)

# matrix for results of loop
res_nback <- matrix(nrow = 0, ncol = 0, byrow = FALSE, dimnames = NULL)

# loop over all files
for (f in 1:length(file_list)){
  print(file_list[f])
  nBack <- read.csv(file=file.path(dataFolder,file_list[f]), skip = 3, header = TRUE, sep="\t", na.strings = c("", "NA"))
  
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

# Clean up data
remove(a_response, nBack, v_response, f, file_list, i)  


# Renaming participants / special cases translators
res_nback$Subject <- gsub("ÃoMA_CE0", "CE0", res_nback$Subject)
res_nback$Subject <- gsub("MPR_AUA0310", "CU3", res_nback$Subject)
res_nback$Subject <- gsub("MBA_CEG0921", "CM0", res_nback$Subject)
res_nback$Subject <- gsub("CUO", "CU0", res_nback$Subject)
res_nback$Subject <- gsub("CQO", "CQ0", res_nback$Subject)
res_nback$Subject <- gsub("MPR_RBM10799", "MPR_RBM1079", res_nback$Subject)
res_nback$Subject <- gsub("MPR_RBM1079", "CU2", res_nback$Subject)
res_nback$Subject <- gsub("UMA_MDG1232", "CE7", res_nback$Subject)
res_nback$Subject <- gsub("MPR_KWS0749", "CU1", res_nback$Subject)
res_nback$Subject <- gsub("DPR_DBS1057", "CI6", res_nback$Subject)
res_nback$Subject <- gsub("UPR_CBA0104", "CI4", res_nback$Subject)
res_nback$Subject <- gsub("CA1_", "CA1", res_nback$Subject)
res_nback$Subject <- gsub("CN0 ", "CN0", res_nback$Subject)

# Renaming participants / special cases interpreters
res_nback$Subject <- gsub("CBM1293", "DBA_CBM1293", res_nback$Subject)
res_nback$Subject <- gsub("DZU1289", "DBA_DZU1289", res_nback$Subject)
res_nback$Subject <- gsub("RBB0517", "DBA_RBB0517", res_nback$Subject)
res_nback$Subject <- gsub("RZB1142", "DBA_RZB1142", res_nback$Subject)
res_nback$Subject <- gsub("SLO0589", "DBA_SLO0589", res_nback$Subject)
res_nback$Subject <- gsub("TDN0914", "DBA_TDN0914", res_nback$Subject)
res_nback$Subject <- gsub("DBM_SHN0451", "DMA_SHN0451", res_nback$Subject)
res_nback$Subject <- gsub("DBA_SHN0451", "DMA_SHN0451", res_nback$Subject)



###########################################################
##                         RT                            ##
###########################################################


# create new df with mean of RT (only for hit and false alarm)
res_nback_RT <- res_nback %>%
  filter(Response != "other", Response != "miss", RT > 250) %>%
  group_by(Subject, Task, Response) %>% 
  summarise(meanRT = mean(RT, na.rm = TRUE))



###########################################################
##                       indices                         ##
###########################################################


# dprime, criteria (c), error rate & accuracy with:
# TP = true positive / hits
# FN = false negative / misses
# FP = false positive / false alarms
# TN = true negative / correct rejections
# TPR = true positive rate
# FPR = flase positive rate

indices_nback <- res_nback %>% 
  group_by(Subject, Task) %>%
  summarise(
    TP = sum(Response == "hit"), 
    FN = sum(Response == "miss"),
    FP = sum(Response == "false_alarm"),
    TN = sum(Response == "other")
  ) %>% 
  mutate(
    TPR = TP/(TP + FN), 
    FPR = FP/(FP + TN),
    dprime = qnorm(TPR) - qnorm(FPR),
    c = -0.5*(qnorm(TPR)+qnorm(FPR)),
    accuracy_rate = (TP + TN)*100/60, 
    error_rate = (FP + FN)*100/60
  ) 

## 0% in error rate leads to infinite dprimes, to adjust for that, we used this approach: 

#for FPR = 0 use 1/(2*N) (N = maximum number of false alarme, N=40)
#(observe half of a false alarm)
#for TPR = 1 use 1 - 1/2*N (N = maximum number of hits, N=20)
#(observe half of a miss)
#http://www.kangleelab.com/sdt-d-prime-calculation---other-tips.html
for (i in 1:nrow(indices_nback)) {
  if (indices_nback$FPR[i] == 0){
    indices_nback$FPR[i] <- 1/(2*40)
  }
}

for (i in 1:nrow(indices_nback)) {
  if (indices_nback$TPR[i] == 1){
    indices_nback$TPR[i] <- 1-1/(2*20)
  }
}

indices_nback$dprime <- qnorm(indices_nback$TPR) - qnorm(indices_nback$FPR)
indices_nback$c <- -0.5*(qnorm(indices_nback$TPR)+qnorm(indices_nback$FPR))


###########################################################
##                accuracy & error rate                  ##
###########################################################

#mean of accuracy & error rate by task
mean_rate_nback <- indices_nback %>%
#  ungroup(indices_nback) %>% 
  select(Task, accuracy_rate, error_rate) %>% 
  group_by(Task) %>% 
  summarise(
    mean_accuracy = mean(accuracy_rate),
    mean_error = mean(error_rate)
  )

###########################################################
##                implement group variable               ##
###########################################################

indices_group<- indices_nback %>% 
  mutate(group = case_when(startsWith(Subject, "DPR") ~ "IntPro",
                           
                           startsWith(Subject, "DMA") ~ "IntMA",
                           
                           startsWith(Subject, "MPR") ~ "MulPro",
                           
                           startsWith(Subject, "MMA") ~ "MulMA",
                           
                           startsWith(Subject, "MBA") ~ "MulBA",
                           
                           startsWith(Subject, "DBA") ~ "IntBA"))

codes <- read_delim(paste("codes.csv", sep="/"), 
                    ";", escape_double = FALSE, trim_ws = TRUE, 
                    skip = 2)
codes = codes %>% 
  select(id, group) %>% 
  rename(Subject = id)

indices_group <- full_join(indices_group, codes, by = "Subject")

indices_group <- unite(indices_group, "group", c("group.x", "group.y"))

indices_group$group <- gsub("NA_", "", indices_group$group)
indices_group$group <- gsub("_NA", "", indices_group$group)

# Define variables as factors and dataframe as tibble

indices_nback <- indices_group %>% 
  select(1,13,2:12) %>% 
  rename(subject = Subject, task = Task)

indices_nback[,1:3] <- lapply(indices_nback[,1:3], factor)

indices_nback <- indices_nback %>%
  as_tibble()

remove(codes, indices_group, i)

###########################################################
##                       Plotting                        ##
###########################################################

#library(ggplot2) 
#nback_graph = full_join(indices_nback,res_nback_RT)
#nback_graphs = full_join(nback_graph,res_nback)
# RT

#pRT <- ggplot(res_nback_RT, aes(Response, meanRT, fill=Response))
#pRT + 
#  geom_bar(stat="identity")+
#  geom_text(aes(label=meanRT), vjust=1.6, color="white", size=3.5)+
#  theme_bw()

#### Verteilung dprime
#ggplot(indices_nback,aes(x = dprime)) + 
#  facet_wrap(~Task,scales = "free_x") + 
#  geom_histogram()+ labs(y="Haeufigkeit", title="dprime distribution per task")+ theme_classic()

#### Verteilung c
#ggplot(indices_nback,aes(x = c)) + 
#  facet_wrap(~Task,scales = "free_x") + 
#  geom_histogram()+ labs(y="Haeufigkeit", title="c distribution per task")+ theme_classic()

#### RT und dprime
#ggplot(nback_graphs,aes(x = RT, y=dprime)) + 
#  geom_histogram()+ labs(y="Haeufigkeit", title="c distribution per task")+ theme_classic()  



#### dprime und Stimulus
#wichtigen variablen selektieren
#nback_graphs_s = nback_graphs %>% 
#  select(Subject, Task, RT, Stimulus)

#Mittelwert ausrechnen
#nback_graphs_s_aggreg <- aggregate(nback_graphs_s[, 3], list(nback_graphs_s$Stimulus), mean, na.rm=TRUE)

#Grafik: dprime pro stimulus
#ggplot(nback_graphs_s_aggreg, aes(x = Group.1, y = RT, linetype = Group.1))+geom_point()+labs(x="Stimulus",title="dprime per Stimulus")



####HIT und FA
#wichtigen variablen selektieren
#nback_graphs_s = nback_graphs %>% 
#  select(Subject, Task, FP, TP)

#Mittelwert ausrechnen
#nback_graphs_s_sum <- aggregate(nback_graphs_s[, 3:4], list(nback_graphs_s$Task), sum, na.rm=TRUE)

#Grafik: dprime pro stimulus
#library(reshape2)
#df.long<-melt(nback_graphs_s_sum)
#ggplot(df.long,aes(Group.1,value,fill=variable))+
#  geom_bar(stat="identity",position="dodge")+
#  labs(x="Task",y="n", title="Performance")



####dprime und task
#nback_graphs_d = nback_graphs %>% 
#  select(Subject, Task, dprime)

#Mittelwert ausrechnen
#nback_graphs_s_sum <- aggregate(nback_graphs_d[, 3], list(nback_graphs_s$Task), sum, na.rm=TRUE)

#Grafik: dprime pro stimulus
#df.long3<-melt(nback_graphs_s_sum)
#ggplot(df.long,aes(Group.1,value,fill=variable))+
#  geom_bar(stat="identity",position="dodge")+ geom_errorbar(aes(x=Group.1, ymin=value-sd, ymax=value+sd), width=0.25)+
#  labs(x="Task",y="n", title="Performance")


## Save Dataframes ----
#save(res_nback, file = "res_nback.RData")
#save(res_nback_RT, file = "res_nback_RT.RData")
save(indices_nback, file = "indices_nback.RData")

