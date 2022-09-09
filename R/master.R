###########################################################
##                      Master                           ##
###########################################################
## Description :: loads all packages, control R Scripts 01-08
##                removes unwanted participants, 
##                creates plots and tables, 
##                calculates statistics
## Input :::::::: R Scripts 01-08
## Output ::::::: Plots, tables to figure folder
###########################################################
## list of packages, install if needed
list.of.packages <- c("tidyverse", "gtsummary", "webshot", "lubridate", "readxl", "lme4", "graphics", "GGally", "ggpubr", "png", "irr", "gghalves", "lsr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# load packages
library(tidyverse)
library(gtsummary)
library(webshot)
library(lubridate)
library(readxl)
library(lme4)
library(graphics)
library(GGally)
library(ggpubr)
library(png)
library(irr)
library("gghalves")
library(lsr)
source("https://raw.githubusercontent.com/datavizpyr/data/master/half_flat_violinplot.R")

# set seed for reproducible results
set.seed(1234321)

# path settings
figureFolder <- file.path("figures")
RFolder      <- file.path("R")
saveFolder    <- file.path("data")


#### Prepare and preprocess datasets ####
# load psychometrics
source(paste(RFolder, "01_psychometrics.R", sep = "/"))

# load nback
source(paste(RFolder, "02_nback.R", sep = "/"))

# load language survey
source(paste(RFolder, "03_language_survey.R", sep = "/"))

# load copying task
source(paste(RFolder, "04_copyingtask.R", sep = "/"))

# load fft data
source(paste(RFolder, "05_fft.R", sep = "/"))

# load fluency data
source(paste(RFolder, "06_fluency.R", sep = "/"))

# load accuracy data
source(paste(RFolder, "07_accuracy.R", sep = "/"))

# merge data 
source(paste(RFolder, "08_merging_data.R", sep = "/"))

# save resulting dataframe
write.csv(alldata,file.path("data/alldata_translators.csv"), row.names = FALSE)


#### remove unwanted  participants ####
exclude_subjects <- c("CA5", "CA6","CI2", "CI7", "CJ8", "CN1","CQ0","CU2" , "CA7","CM2", "CM4", "CN0", "CN4", "CK0")

psychometrics <- psychometrics %>% 
  filter(!(id %in% exclude_subjects))
psychometrics$id <- droplevels(psychometrics$id)

alldata <- alldata %>% 
  filter(!(id %in% exclude_subjects))
alldata$id <- droplevels(alldata$id)

fft <- fft %>% 
  filter(!(id %in% exclude_subjects))
fft$id <- droplevels(fft$id)

accuracy_results <- accuracy_results %>% 
  filter(!(id %in% exclude_subjects))
accuracy_results$id <- droplevels(accuracy_results$id)

fluency_results <- fluency_results %>% 
  filter(!(id %in% exclude_subjects))
fluency_results$id <- droplevels(fluency_results$id)


#### Sample Characteristics ####
# select variables
psychometrics_selected <- psychometrics %>% 
  select(group, age, gender,  handedness)

# effect size function with calculations from lsr
my_ES_test <- function(data, variable, by, ...) {
  aovmod = aov(data[[variable]] ~ data[[by]])
  lsr::etaSquared(aovmod)[1,1]
}

# create sample characteristics table
sample_char <- tbl_summary(
  psychometrics_selected,
  label = list(age ~ "Age", gender ~ "Gender", handedness ~ "Handedness"),
  by = group, # split table by group
  type = list(age ~ 'continuous2'),
  statistic = all_continuous() ~ c( "{mean}",
                                   "{median} ({p25}, {p75})", 
                                   "{min}, {max}"),
) %>%
  add_n() %>% # add column with total number of non-missing observations
  add_p(all_continuous() ~ "aov") %>%
  add_stat(fns = all_continuous() ~ my_ES_test) %>%
  modify_header(label = "**Variable**", add_stat_1 ~ "**\U03B7\U00B2**") %>% # add eta sign
  bold_labels() %>%
  italicize_levels()

# save table to figure folder
as_gt(sample_char) %>%
  gt::gtsave(filename = file.path(figureFolder, "sample_char.png"))


#### Psychometrics ####
# select variables
psychometrics_selected_2 <- psychometrics %>% 
  select(group, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U)

# create psychometrics table 
psycho <- tbl_summary(
  psychometrics_selected_2,
  label = list(english_score ~ "English score",
               Aoa_E ~ "Age of L2 aquisition",
               HAWIE_T_Value ~ "WAIS T-values", 
               auditory_dprime ~ "Auditory dprime", 
               visual_dprime ~ "Visual dprime", 
               cumTH_U ~ "Translating experience (cumulative training hours)",
               hpd_U ~ "Translating experience (hours per day) since age 17"),
  by = group, # split table by group
  type = list(english_score ~ 'continuous2', 
              Aoa_E ~ 'continuous2', 
              HAWIE_T_Value ~ 'continuous2', 
              auditory_dprime ~ 'continuous2', 
              visual_dprime ~ 'continuous2', 
              cumTH_U ~ 'continuous2', 
              hpd_U ~ 'continuous2'),
  statistic = all_continuous() ~ c("{mean}",
                                   "{median} ({p25}, {p75})", 
                                   "{min}, {max}"),
) %>%
  add_n() %>% # add column with total number of non-missing observations
  add_p(all_continuous() ~ "aov") %>% # test for a difference between groups
  add_stat(fns = all_continuous() ~ my_ES_test) %>%
  modify_header(label = "**Variable**", add_stat_1 ~ "**\U03B7\U00B2**") %>% 
  bold_labels() %>%
  italicize_levels()
  
# save table to figure folder
as_gt(psycho) %>%
#  gt::tab_source_note(gt::md("Mul = multilingual control group, TraPro = professional translators, TraStu = translation students")) %>%
  gt::gtsave(filename = file.path(figureFolder, "psychometrics.png"))


#### Unused psychometrics / linguistics ####
psychometrics_selected_3 <- psychometrics %>% 
  select(group, percCumTH_U_life, hpd_all, perchpd_all ,  hpw_DE_lj, hpw_E_lj)

# create table
psycho2 <- tbl_summary(
  psychometrics_selected_3,
  label = list(percCumTH_U_life ~ "Translating experience (% cumulative training hours)", 
               perchpd_all ~ "Lanugage use (% hours #per day, all) ", 
                
               hpd_all ~ "Language use (hours per day) ", 
               hpw_DE_lj ~ "German use (hours per week in last year) ", 
               hpw_E_lj ~ "English use (hours per week in last year) ", 
               perchpd_all ~ "Language use (% hours per day)"),
  by = group, # split table by group
  type = list(percCumTH_U_life ~ 'continuous2', 
              perchpd_all ~ 'continuous2', 

              hpd_all ~ 'continuous2', 
              hpw_DE_lj ~ 'continuous2', 
              hpw_E_lj ~ 'continuous2', 
              perchpd_all ~ 'continuous2' ),
  statistic = all_continuous() ~ c("{mean}",
                                   "{median} ({p25}, {p75})", 
                                   "{min}, {max}"),
) %>%
  add_n() %>% # add column with total number of non-missing observations
  add_p() %>% # test for a difference between groups
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels() %>%
  italicize_levels()

# save table to figure folder
as_gt(psycho2) %>%
 gt::gtsave(filename = file.path(figureFolder, "psychometrics_unused.png"))

# remove unwanted variables
remove(my_ES_test, sample_char, psycho, psycho2, psychometrics_selected, psychometrics_selected_2, psychometrics_selected_3)

 
#### FFT ####
# variable overview
alldata_overview <- alldata %>% 
  group_by(cond) %>% 
  summarise(n_condition = n())

fft_summarise <- alldata %>% 
  filter(task != "Reading_post") %>% 
  group_by(task, group) %>% 
  summarise(mean_fontal_theta = mean(frontal_theta), sd_fontal_theta = sd(frontal_theta), mean_parietal_alpha = mean(parietal_alpha), sd_parietal_alpha = sd(parietal_alpha))

## Stats
fft_select <- alldata %>% 
  select(id, group, text, task, condition,frontal_theta, parietal_alpha) %>% 
  filter(task != "Reading_post")
fft_select$task <- droplevels(fft_select$task)


## frontal theta 
fft_ft_null <- lmer(frontal_theta ~ (1|id), data= fft_select)
fft_ft_1 <- lmer(frontal_theta ~ task + (1|id), data= fft_select)
anova(fft_ft_null, fft_ft_1)

fft_ft_2 <- lmer(frontal_theta ~ task + text + (1|id), data= fft_select)
anova(fft_ft_1, fft_ft_2)

fft_ft_3 <- lmer(frontal_theta ~ task + condition + (1|id), data= fft_select)
anova(fft_ft_1, fft_ft_3)

fft_ft_4 <- lmer(frontal_theta ~ task + group + (1|id), data= fft_select)
anova(fft_ft_1, fft_ft_4)

fft_ft_5 <- lmer(frontal_theta ~ task + group + task : group +  (1|id), data= fft_select)
anova(fft_ft_4,fft_ft_5)

summary(fft_ft_5)

# create table for resulting model
fft1 <- tbl_regression(fft_ft_5, 
                     exponentiate = FALSE,
                     pvalue_fun = ~style_pvalue(.x, digits = 2),
                     label = list(task ~ "Task", group ~ "Group"),
                     intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")


## parietal alpha
fft_pa_null <- lmer(parietal_alpha ~ (1|id), data= fft_select)
fft_pa_1 <- lmer(parietal_alpha ~ task + (1|id), data= fft_select)
anova(fft_pa_null, fft_pa_1)

fft_pa_2 <- lmer(parietal_alpha ~ text + (1|id), data= fft_select)
anova(fft_pa_null, fft_pa_2)

fft_pa_3 <- lmer(parietal_alpha ~ condition + (1|id), data= fft_select)
anova(fft_pa_null, fft_pa_3)

fft_pa_4 <- lmer(parietal_alpha ~ group + (1|id), data= fft_select)
anova(fft_pa_null, fft_pa_4)

# create table for resulting model
fft2 <- tbl_regression(fft_pa_null, 
                       exponentiate = FALSE,
                       pvalue_fun = ~style_pvalue(.x, digits = 2),
                   #    label = list(task ~ "Task", group ~ "Group"),
                       intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")


## merge tables to final table for FFT
table_fft <- tbl_merge(
  tbls = list(fft1 , fft2),
  tab_spanner = c("**Frontal theta**", "**Parietal alpha**")
)

## save table to figure folder
as_gt(table_fft) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_fft.png"))

## plot frontal theta / parietal alpha
# separate data of both abstracts for plot 
fft_select_t1 <- fft_select %>% 
  filter(text == "Text1")

fft_select_t2 <- fft_select %>% 
  filter(text == "Text2")

filename <- file.path(figureFolder,"Plot_FFT_group_theta.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")

ggplot(fft_select_t1, aes(x = task, y = frontal_theta, group = id)) + 
  geom_point(aes(color = group)) +
  geom_line(aes(color = group)) + 
  facet_wrap( ~ group) +
  geom_point(data = fft_select_t2, aes(x = task, y = frontal_theta, group = id, color = group)) + 
  geom_line(data = fft_select_t2, aes(x = task, y = frontal_theta, group = id, color = group)) +
  facet_wrap( ~ group) +
  geom_half_boxplot(data = fft_select, aes(x = task, y = frontal_theta, group = task, fill = group), alpha = 0.3, outlier.shape = NA) +
  guides(color="none") +
  theme_bw() +
  theme(legend.position = "none") +
#  ggtitle("Frontal theta per group and task") +
  xlab("Task") +
  ylab(bquote('Theta Power '~(µV^2)))+
  theme(axis.title.y = element_text(size=20)) + 
  theme(axis.text.x = element_text(size=16)) + 
  theme(axis.title.x = element_text(size=20)) +
  theme(strip.text.x = element_text(size = 20))

dev.off()

# remove unwanted variables
remove(fft_select, fft_summarise, fft_select_t1, fft_select_t2, fft_ft_null, fft_ft_1, fft_ft_2, fft_ft_3, fft_ft_4, fft_ft_5, fft_pa_null, fft_pa_1, fft_pa_2, fft_pa_3, fft_pa_4, fft1, fft2, table_fft)


#### keyboard data ####
# variable overview
copy_summarise <- alldata %>%
  filter(task == "Translating" | task == "Copying") %>%
  mutate(relDel = charsTotal/charsErrors) %>% 
  group_by(task, condition, group) %>% 
  summarise(meanChars = mean(chars), sdChars = sd(chars), meanDeletions = mean(charsErrors), sdDeletions = sd(charsErrors), meanrelDel = mean(relDel), sdrelDel = sd(relDel), meanCopyStringdist = mean(copy_stringdist), sdCopyStringdist = sd(copy_stringdist))

# select variables
keys_select <- alldata %>%
  filter(task == "Translating" | task == "Copying") %>%
  mutate(percCharsErrors = charsErrors/charsTotal) %>% 
  select(id, group, text, task, condition,chars, charsErrors, charsTotal, percCharsErrors) 
keys_select$task <- droplevels(keys_select$task)


## stats charsTotal
chars_tot_null <- lmer(charsTotal ~ (1|id) , data= keys_select)
chars_tot_1 <- lmer(charsTotal ~ task +  (1|id), data= keys_select)
anova(chars_tot_null, chars_tot_1)

summary(chars_tot_1)

chars_tot_2 <- lmer(charsTotal ~ task + text +  (1|id), data= keys_select)
anova(chars_tot_1, chars_tot_2)

chars_tot_3 <- lmer(charsTotal ~ task + condition +  (1|id), data= keys_select)
anova(chars_tot_1, chars_tot_3)

chars_tot_4 <- lmer(charsTotal ~ task + group +  (1|id), data= keys_select)
anova(chars_tot_1, chars_tot_4)

# create table for resulting model
chars1 <- tbl_regression(chars_tot_1, 
                       exponentiate = FALSE,
                       pvalue_fun = ~style_pvalue(.x, digits = 2),
                       label = list(task ~ "Task"),
                       intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")


## percentage deletions
chars_del_null <- lmer(percCharsErrors ~ (1|id) , data= keys_select)
chars_del_1 <- lmer(percCharsErrors ~ task +  (1|id), data= keys_select)
anova(chars_del_null, chars_del_1)

chars_del_2 <- lmer(percCharsErrors ~ task + text+  (1|id), data= keys_select)
anova(chars_del_1, chars_del_2)

chars_del_3 <- lmer(percCharsErrors ~ task + text + condition +  (1|id), data= keys_select)
anova(chars_del_2, chars_del_3)

chars_del_4 <- lmer(percCharsErrors ~ task + text + condition + group +  (1|id), data= keys_select)
anova(chars_del_3, chars_del_4)

chars_del_5 <- lmer(percCharsErrors ~ task + text + condition + task:text +  (1|id), data= keys_select)
anova(chars_del_3, chars_del_5)

summary(chars_del_5)

chars_del_6 <- lmer(percCharsErrors ~ task + text + condition +task:text + text:condition +  (1|id), data= keys_select)
anova(chars_del_5, chars_del_6)

chars_del_7 <- lmer(percCharsErrors ~ task + text + condition +task:text  + task:condition +  (1|id), data= keys_select)
anova(chars_del_5, chars_del_7)

# create table for resulting model
chars2 <- tbl_regression(chars_del_5, 
                         exponentiate = FALSE,
                         pvalue_fun = ~style_pvalue(.x, digits = 2),
                         label = list(task ~ "Task", condition ~ "Condition", text ~ "Text"),
                         intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")

## merge tables
table_keys <- tbl_merge(
  tbls = list(chars1, chars2),
  tab_spanner = c("**Efficiency (total chars typed)**", "**Percentage deletions**")
)

# remove unwanted variables
remove(keys_select, copy_summarise, chars_tot_null, chars_tot_1, chars_tot_2, chars_tot_3, chars_tot_4, chars_del_null, chars_del_1, chars_del_2, chars_del_3, chars_del_4, chars_del_5, chars_del_6, chars_del_7, chars1, chars2, table_keys)


## save keyboard table to figure folder
as_gt(table_keys) %>%
#  gt::tab_source_note(gt::md("EdE = edited English, ELF = English as lingua franca")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_keys.png"))


#### perceived Difficulty ####
# variable overview
percDiff_summarise <- alldata_ext %>%
  filter(task == "Translating" | task == "Reading") %>% 
  group_by(task, condition, group) %>% 
  summarise(meanpercDiff = mean(perceivedDifficulty), sdpercDiff = sd(perceivedDifficulty), minpercDiff = min(perceivedDifficulty), maxpercDiff = max(perceivedDifficulty))

# select variables
percDiff_select <- alldata_ext %>%
  filter(task == "Translating" | task == "Reading") %>%
  select(id, group, text, task, condition, perceivedDifficulty) 
percDiff_select$task <- droplevels(percDiff_select$task)

## Stats
perceivedDifficulty_null <- lmer(perceivedDifficulty ~ (1|id) , data= percDiff_select)
perceivedDifficulty_1 <- lmer(perceivedDifficulty ~ task + (1|id), data= percDiff_select)
anova(perceivedDifficulty_null, perceivedDifficulty_1)

perceivedDifficulty_2 <- lmer(perceivedDifficulty ~ text + (1|id), data= percDiff_select)
anova(perceivedDifficulty_null, perceivedDifficulty_2)

summary(perceivedDifficulty_2)

perceivedDifficulty_3 <- lmer(perceivedDifficulty ~ text + group + (1|id), data= percDiff_select)
anova(perceivedDifficulty_2, perceivedDifficulty_3)

perceivedDifficulty_4 <- lmer(perceivedDifficulty ~ text + condition + (1|id), data= percDiff_select)
anova(perceivedDifficulty_2, perceivedDifficulty_4)

perceivedDifficulty_5 <- lmer(perceivedDifficulty ~ text + task + (1|id), data= percDiff_select)
anova(perceivedDifficulty_2, perceivedDifficulty_5)


# create table for resulting model
percDiff <- tbl_regression(perceivedDifficulty_2, 
                     exponentiate = FALSE,
                     pvalue_fun = ~style_pvalue(.x, digits = 2),
                     label = list(text ~ "Text"),
                     intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")

# save percDiff table to figure folder
as_gt(percDiff) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_percDiff.png"))

# remove unwanted variables
remove(percDiff_select, percDiff_summarise, perceivedDifficulty_null, perceivedDifficulty_1, perceivedDifficulty_2, perceivedDifficulty_3, perceivedDifficulty_4, perceivedDifficulty_5, percDiff)


#### percCQRes ####
# variable overview
percCQRes_summarise <- alldata %>%
  filter(task == "Reading") %>% 
  group_by(text, condition, group) %>% 
  summarise(meanpercCQRes = mean(percCQRes), sdpercDiff = sd(percCQRes))

# select variables
percCQRes_select <- alldata %>%
  filter(task == "Reading") %>%
  select(id, group, text, task, condition,percCQRes) 
percCQRes_select$task <- droplevels(percCQRes_select$task)


## Stats
percCQRes_null <- lmer(percCQRes ~ (1|id) , data= percCQRes_select)
percCQRes_1 <- lmer(percCQRes ~ text + (1|id), data= percCQRes_select)
anova(percCQRes_null, percCQRes_1)

percCQRes_2 <- lmer(percCQRes ~ condition + (1|id), data= percCQRes_select)
anova(percCQRes_null, percCQRes_2)

percCQRes_3 <- lmer(percCQRes ~ group + (1|id), data= percCQRes_select)
anova(percCQRes_null, percCQRes_3)

summary(percCQRes_3)

# create table for resulting model
percCQRes <- tbl_regression(percCQRes_3, 
                          exponentiate = FALSE,
                          pvalue_fun = ~style_pvalue(.x, digits = 2),
                          label = list(group ~ "Group"),
                          intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")


#### average reading Duration ####
# variable overview
avgReadDur_summarise <- alldata %>%
  filter(task == "Reading") %>% 
  group_by(text, condition, group) %>% 
  summarise(meanAvgReadDur = mean(avgReadingDuration), sdAvgReadDur = sd(avgReadingDuration), maxAvgReadDur = max(avgReadingDuration), minAvgReadDur = min(avgReadingDuration), medianAvgReadDur = median(avgReadingDuration), IQRAvgReadDur = IQR(avgReadingDuration), q75 = quantile(avgReadingDuration,probs =.75))

# select variables
avgReadDur_select <- alldata %>%  #<- full_join(avgReadDur_trim_T1, avgReadDur_trim_T2) %>% 
  select(id, age, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U, group, text, condition,avgReadingDuration) 


## Stats
avgReadDu_null <- lmer(avgReadingDuration ~ (1|id) , data= avgReadDur_select)
avgReadDu_1 <- lmer(avgReadingDuration ~ text + (1|id) , data= avgReadDur_select)
anova(avgReadDu_null, avgReadDu_1)

summary(avgReadDu_1)

avgReadDu_2 <- lmer(avgReadingDuration ~ text + condition + (1|id), data= avgReadDur_select)
anova(avgReadDu_1, avgReadDu_2)

avgReadDu_3 <- lmer(avgReadingDuration ~ text + group + (1|id), data= avgReadDur_select)
anova(avgReadDu_1, avgReadDu_3)

avgReadDu_4 <- lmer(avgReadingDuration ~ text + condition + (1|id), data= avgReadDur_select)
anova(avgReadDu_1, avgReadDu_4)

# create table for resulting model
avgReadDu <- tbl_regression(avgReadDu_1, 
                          exponentiate = FALSE,
                          pvalue_fun = ~style_pvalue(.x, digits = 2),
                          label = list(text ~ "Text"),
                          intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")

## merge tables
table_reading <- tbl_merge(
  tbls = list(percCQRes, avgReadDu),
  tab_spanner = c("**Percentage correct answers control questions**", "**Average reading duration per sentence**"))

## save reading table to figure folder
as_gt(table_reading) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_reading.png"))

# remove unwanted variables
remove(percCQRes_select, percCQRes_summarise, percCQRes_null, percCQRes_1, percCQRes_2, percCQRes_3, percCQRes, avgReadDur_select, avgReadDur_summarise, avgReadDu_null, avgReadDu_1, avgReadDu_2, avgReadDu_3, avgReadDu_4, avgReadDu, table_reading)


#### translation fluency ####
# variable overview
fluency_summarise <- alldata %>%
  filter(task == "Translating") %>% 
  group_by(condition, group) %>% 
  summarise(fluencyRating = mean(fluency_meanRater))

# calculate icc
fluency_icc <- alldata %>%
  filter(task == "Translating") %>% 
  select(fluency_meanR1, fluency_meanR2,fluency_meanR3)

icc(
  fluency_icc, model = "twoway", 
  type = "consistency", unit = "average"
)

# select variable
fluency_select<- alldata %>%
  filter(task == "Translating") %>%
  select(id, group, text, task, condition,fluency_meanRater) 
fluency_select$task <- droplevels(fluency_select$task)


## Stats
fluency_null <- lmer(fluency_meanRater ~ (1|id) , data= fluency_select)
fluency_1 <- lmer(fluency_meanRater ~ text + (1|id), data= fluency_select)
anova(fluency_null, fluency_1)

fluency_2 <- lmer(fluency_meanRater ~ condition + (1|id), data= fluency_select)
anova(fluency_null, fluency_2)

fluency_3 <- lmer(fluency_meanRater ~ group + (1|id), data= fluency_select)
anova(fluency_null, fluency_3)

# create table for resulting model
fluency <- tbl_regression(fluency_3, 
                           exponentiate = FALSE,
                           pvalue_fun = ~style_pvalue(.x, digits = 2),
                           label = list(group ~ "Group"),
                           intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")


#### translation accuracy ####
# variable overview
accuracy_summarise <- alldata %>%
  filter(task == "Translating") %>% 
  group_by(text, condition, group) %>% 
  summarise(accuracyRating = mean(accuracy_meanRater))

# calculate icc
accuracy_icc <- alldata %>%
  filter(task == "Translating") %>% 
  select(accuracy_meanR1, accuracy_meanR2,accuracy_meanR3)

icc(
  accuracy_icc, model = "twoway", 
  type = "consistency", unit = "average"
)

# select variables
accuracy_select<- alldata %>%
  filter(task == "Translating") %>%
  select(id, group, text, task, condition,accuracy_meanRater) 
accuracy_select$task <- droplevels(accuracy_select$task)


## Stats
accuracy_null <- lmer(accuracy_meanRater ~ (1|id) , data= accuracy_select)
accuracy_1 <- lmer(accuracy_meanRater ~ text + (1|id), data= accuracy_select)
anova(accuracy_null, accuracy_1)

accuracy_2 <- lmer(accuracy_meanRater ~ condition + (1|id), data= accuracy_select)
anova(accuracy_null, accuracy_2)

summary(accuracy_2)

accuracy_3 <- lmer(accuracy_meanRater ~ condition + group + (1|id), data= accuracy_select)
anova(accuracy_2, accuracy_3)

accuracy_4 <- lmer(accuracy_meanRater ~ condition * group + (1|id), data= accuracy_select)
anova(accuracy_3, accuracy_4)

# create table for resulting model
accuracy <- tbl_regression(accuracy_2, 
                          exponentiate = FALSE,
                          pvalue_fun = ~style_pvalue(.x, digits = 2),
                          label = list(condition ~ "Condition"),
                          intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")

# merge tables
table_translation <- tbl_merge(
  tbls = list(fluency, accuracy),
  tab_spanner = c("**Fluency rating**", "**Accuracy rating**")
)

# save table to figure folder
as_gt(table_translation) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_translation_output.png"))

# remove unwanted variables
remove(fluency_select, fluency_summarise, fluency_icc, fluency_null, fluency_1, fluency_2, fluency_3, fluency, accuracy_select, accuracy_summarise, accuracy_icc, accuracy_null, accuracy_1, accuracy_2, accuracy_3, accuracy_4, accuracy, table_translation)
