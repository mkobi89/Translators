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
readingDuration <- read.csv(file.path(dataFolderRaw,"readingDuration.csv"), header = TRUE, sep = ";")
readingFixations <- read.csv(file.path(dataFolderRaw,"readingFixations.csv"), header = TRUE, sep = ";")

readingDuration_summary <- readingDuration %>% 
  group_by(text,condition,group) %>% 
  summarise(meanRD = mean(avgReadingDuration), sdRD = sd(avgReadingDuration))

## remove outliers from reading duration dataset
trim <- 3

## calculate cutoffs for text 1
cutoffs_t1 <- readingDuration %>%
  filter(text == "Text1") %>% 
  summarise(mean = mean(avgReadingDuration, na.rm = TRUE), sd = sd(avgReadingDuration, na.rm = TRUE), median = median(avgReadingDuration, na.rm = TRUE)) %>%
  mutate(upper = mean+trim*sd, lower= mean-trim*sd)

## filter data with cutoffs
upper_trim_t1 <- readingDuration %>%
  filter(text == "Text1") %>% 
  filter(avgReadingDuration > cutoffs_t1$upper)

readingDuration_trimmed_t1 <- readingDuration %>%
  filter(text == "Text1") %>% 
  filter(avgReadingDuration < cutoffs_t1$upper)


## calculate cutoffs for text 2
cutoffs_t2 = readingDuration %>%
  filter(text == "Text2") %>% 
  summarise(mean = mean(avgReadingDuration, na.rm = TRUE), sd = sd(avgReadingDuration, na.rm = TRUE), median = median(avgReadingDuration, na.rm = TRUE)) %>%
  mutate(upper = mean+trim*sd, lower= mean-trim*sd)

## filter data with cutoffs
upper_trim_t2 = readingDuration %>%
  filter(text == "Text2") %>% 
  filter(avgReadingDuration > cutoffs_t2$upper)

readingDuration_trimmed_t2 <- readingDuration %>%
  filter(text == "Text2") %>% 
  filter(avgReadingDuration < cutoffs_t2$upper)

## fixations dataset

fixation_summary <- readingFixations %>% 
  group_by(id, text, condition) %>%
  summarise(sumFixationDuration = sum(duration)/1000)


readingDuration_all <- full_join(readingDuration,fixation_summary, by = c("id", "text", "condition"))

readingDuration_all$percFixationDuration <- readingDuration_all$sumFixationDuration/readingDuration_all$sumReadingDuration*100





## exclude



## fixation evaluation

fixation_evaluation <- readingFixations %>%
  group_by(id, text, condition, type) %>% 
  summarise(n=n()) 

fixation_total <- readingFixations %>% 
  group_by(id, text, condition) %>% 
  summarise(totalFixation = n()) 

fixation_evaluation_wide <- fixation_evaluation %>% 
  spread(type, n)

fixation_evaluation_total <- full_join(fixation_evaluation_wide, fixation_total, by = c("id","text", "condition") )

fixation_evaluation_total$percunknown <- fixation_evaluation_total$unknown / fixation_evaluation_total$totalFixation * 100
fixation_evaluation_total$totalword <- fixation_evaluation_total$word + fixation_evaluation_total$regression

fixation_evaluation_total$nsentences <- ""

for(i in 1:nrow(fixation_evaluation_total)){
  if(fixation_evaluation_total$text[i] == "Text1"){
    fixation_evaluation_total$nsentences[i] <- 37 
  }
  if(fixation_evaluation_total$text[i] == "Text2" && fixation_evaluation_total$condition[i] == "SE" ){
    fixation_evaluation_total$nsentences[i] <- 27 
  }
  if(fixation_evaluation_total$text[i] == "Text2" && fixation_evaluation_total$condition[i] == "ELF" ){
    fixation_evaluation_total$nsentences[i] <- 25 
  }
}

fixation_evaluation_total$nsentences <- as.numeric(fixation_evaluation_total$nsentences)

fixation_evaluation_total$totalFixationPerSentence <- fixation_evaluation_total$totalword / fixation_evaluation_total$nsentences

fixation_evaluation_total$regressionPerSentence <- fixation_evaluation_total$regression / fixation_evaluation_total$nsentences

psychometrics_group <- psychometrics %>% 
  select(id,group)

fixation_evaluation_total <- full_join(psychometrics_group, fixation_evaluation_total, by = "id")


## fixation duration
fixation_duration_evaluation <- readingFixations %>%
  group_by(id, text, condition, type) %>% 
  summarise(sumDuration = sum(duration)/1000) 

fixation_duration_evaluation_wide <- fixation_duration_evaluation %>% 
  spread(type, sumDuration)


fixation_duration_evaluation_wide$nsentences <- ""

for(i in 1:nrow(fixation_duration_evaluation_wide)){
  if(fixation_duration_evaluation_wide$text[i] == "Text1"){
    fixation_duration_evaluation_wide$nsentences[i] <- 37 
  }
  if(fixation_duration_evaluation_wide$text[i] == "Text2" && fixation_duration_evaluation_wide$condition[i] == "SE" ){
    fixation_duration_evaluation_wide$nsentences[i] <- 27 
  }
  if(fixation_duration_evaluation_wide$text[i] == "Text2" && fixation_duration_evaluation_wide$condition[i] == "ELF" ){
    fixation_duration_evaluation_wide$nsentences[i] <- 25 
  }
}

fixation_duration_evaluation_wide$nsentences <- as.numeric(fixation_duration_evaluation_wide$nsentences)

fixation_duration_evaluation_wide$totalReadingTimePerSentence <- (fixation_duration_evaluation_wide$word + fixation_duration_evaluation_wide$regression) / fixation_duration_evaluation_wide$nsentences

fixation_duration_evaluation_wide$regressionTimePerSentence <- fixation_duration_evaluation_wide$regression / fixation_duration_evaluation_wide$nsentences


fixation_duration_evaluation_wide <- full_join(psychometrics_group, fixation_duration_evaluation_wide, by = "id")

fixation_duration_evaluation_wide_trimmed <- fixation_duration_evaluation_wide %>% 
  filter(id != "CI1", id != "CI9", id != "CJ4", id != "CU2", id != "CE6")


ggplot(fixation_duration_evaluation_wide_trimmed, aes(x = condition, y = totalReadingTimePerSentence, color = group)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Total reading time per sentence") +
  facet_wrap( ~ text)

ggplot(fixation_duration_evaluation_wide_trimmed, aes(x = condition, y = regressionTimePerSentence, color = group)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Total regression time per sentence") +
  facet_wrap( ~ text)


## all in one
fixation_summary_all <- readingFixations %>%
  filter(type != "unknown") %>% 
  group_by(id, text, condition) %>%
  summarise(sumFixationDuration = sum(duration)/1000, n= n()) %>% 
  mutate(avgFixationDuration = sumFixationDuration/n)

fixation_summary_all <- full_join(psychometrics_group, fixation_summary_all, by = "id")

fixation_summary_all_trimmed <- fixation_summary_all %>% 
  filter(id != "CI1", id != "CI9", id != "CJ4", id != "CU2", id != "CE6")

ggplot(fixation_summary_all_trimmed, aes(x = condition, y = avgFixationDuration, color = group)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Average fixation duration") +
  facet_wrap( ~ text)

## trim data
fixation_evaluation_total_trimmed <- fixation_evaluation_total %>% 
  filter(percunknown < (mean(fixation_evaluation_total$percunknown) + 3 * sd(fixation_evaluation_total$percunknown)))

fixation_evaluation_total_trimmed_2 <- fixation_evaluation_total_trimmed %>% 
  filter(id != "CI1", id != "CI9", id != "CJ4")










