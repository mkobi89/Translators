###########################################################
##                         nBack                         ##
##                    data processing                    ##
###########################################################

## libraries, packages, workspace ----
if (!"tidyverse" %in% installed.packages()[, "Package"]) {
  install.packages("tidyverse")
}

library(tidyverse)

source(file.path("R/Preprocessing/nback.R"))

dataFolder   <- file.path("data")
load(file.path(dataFolder,"res_nback.RData"))
res_nback$Subject <- gsub("ÃœMA_CE0", "CE0", res_nback$Subject)

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
  ungroup(indices_nback) %>% 
  select(Task, accuracy_rate, error_rate) %>% 
  group_by(Task) %>% 
  summarise(
    mean_accuracy = mean(accuracy_rate),
    mean_error = mean(error_rate)
  )



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


#save(res_nback_RT, file = file.path(dataFolder,"res_nback_RT.RData"))
#save(indices_nback, file = file.path(dataFolder,"indices_nback.RData"))