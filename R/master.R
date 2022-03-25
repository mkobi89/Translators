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

# load packages
library(tidyverse)
library(gtsummary)
library(webshot)
library(lme4)
library(gtsummary)
library(png)
library(ez)

##########################################################
##                       SETTINGS                       ##
##########################################################

# set seed for reproducible results
set.seed(1234321)

#dataFolderRaw   <- file.path("data/rawdata")
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
source(paste(RFolder, "06_fft.R", sep = "/"))

# merge data 
source(paste(RFolder, "07_merging_data.R", sep = "/"))



#### remove unwanted  participants ####

exclude_subjects <- c("CA5", "CA6","CI2", "CI7", "CJ8", "CN1","CQ0","CU2" , "CA7","CM2", "CM4", "CN0", "CN4")

psychometrics <- psychometrics %>% 
  filter(!(id %in% exclude_subjects))
psychometrics$id <- droplevels(psychometrics$id)

alldata <- alldata %>% 
  filter(!(id %in% exclude_subjects))
alldata$id <- droplevels(alldata$id)

fft <- fft %>% 
  filter(!(id %in% exclude_subjects))
fft$id <- droplevels(fft$id)



#### Sample Characteristics ####

psychometrics_selected <- psychometrics %>% 
  select(group, age, gender,  handedness)

# create table
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
  add_p() %>% # test for a difference between groups
  modify_header(label = "**Variable**") %>% # update the column header
  modify_caption("**Sample characteristics**") %>% 
  bold_labels() %>%
  italicize_levels()

# save
as_gt(sample_char) %>%
  gt::gtsave(filename = file.path(figureFolder, "sample_char.png"))


#### Psychometrics ####


psychometrics_selected_2 <- psychometrics %>% 
  select(group, english_score, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U)

# create table
psycho <- tbl_summary(
  psychometrics_selected_2,
  label = list(english_score ~ "English score", 
               HAWIE_T_Value ~ "HAWIE t score", 
               auditory_dprime ~ "Auditory dprime", 
               visual_dprime ~ "Visual dprime", 
               cumTH_U ~ "Translating experience (cumulative training hours)",
               hpd_U ~ "Translating experience (hours per day) "),
  by = group, # split table by group
  type = list(english_score ~ 'continuous2', 
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
  add_p() %>% # test for a difference between groups
  modify_header(label = "**Variable**") %>% # update the column header
  modify_caption("**Psychometrics**") %>% 
  bold_labels() %>%
  italicize_levels()


# save table to figure folder
as_gt(psycho) %>%
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
  modify_caption("**Psychometrics**") %>% 
  bold_labels() %>%
  italicize_levels()


# save table to figure folder
as_gt(psycho2) %>%
  gt::gtsave(filename = file.path(figureFolder, "psychometrics_unused.png"))



 
#### FFT ####
alldata_ext <- alldata %>% 
  mutate(tfz_apz = frontal_theta/parietal_alpha)

alldata_overview <- alldata_ext %>% 
  group_by(cond) %>% 
  summarise(n_condition = n())


fft_summarise <- alldata_ext %>% 
  group_by(task, group) %>% 
  summarise(mean_fontal_theta = mean(frontal_theta), sd_fontal_theta = sd(frontal_theta), mean_parietal_alpha = mean(parietal_alpha), sd_parietal_alpha = sd(parietal_alpha), mean_tfz_apz = mean(tfz_apz), sd_tfz_apz = sd(tfz_apz))

## Stats

fft_select <- alldata_ext %>% 
  select(id, group, text, task, condition,frontal_theta, parietal_alpha, tfz_apz) %>% 
  filter(task != "Reading_post")
fft_select$task <- droplevels(fft_select$task)

fft_anova <- ezANOVA(
  fft_select
  , frontal_theta
  , id
  , within = c(task, condition)
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)


## frontal theta

fft_full_task <- lmer(frontal_theta ~ task + (1|id), data= fft_select)

fft_full <- lmer(frontal_theta ~ task + group + task : group +  (1|id), data= fft_select)

fft_less <- lmer(frontal_theta ~ task + group + task : group + (1|id), data= fft_select)

anova(fft_full,fft_less)

summary(fft_full)

fft1 <- tbl_regression(fft_full, 
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

ffttask <- tbl_regression(fft_full_task, 
                       exponentiate = FALSE,
                       pvalue_fun = ~style_pvalue(.x, digits = 2),
                       label = list(task ~ "Task"), #, group ~ "Group"),
                       intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")


## parietal alpha
fftpa_full <- lmer(parietal_alpha ~ task + group + task : group  + (1|id) + (1|id:task), data= fft_select)

fftpa_less <- lmer(parietal_alpha ~ task + group + task : group  + (1|id) + (1|id:task), data= fft_select)

anova(fftpa_full,fftpa_less)

summary(fft_full)

fft2 <- tbl_regression(fftpa_full, 
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


## tfz_apz
fftq_full <- lmer(tfz_apz ~ task + (1|id) +  (1|id:condition), data= fft_select)

fftq_less <- lmer(tfz_apz ~ task + (1|id) +  (1|id:condition), data= fft_select)

anova(fftq_full,fftq_less)

summary(fft_full)

fft3 <- tbl_regression(fftq_full, 
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

## merge tables to final table for task 1 and 2
table_fft <- tbl_merge(
  tbls = list(ffttask, fft1 , fft2, fft3),
  tab_spanner = c("**Frontal theta task only**", "**Frontal theta**", "**Parietal alpha**", "**Frontal theta / Parietal alpha**")
) %>%
  modify_caption("**LMM Fixed Effects for the FFT**")

## save table
as_gt(table_fft) %>%
  gt::tab_source_note(gt::md("Mul = multilingual control group, TraPro = professional translators, TraStu = translation students*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_fft.png"))





#bxp_condition <- ggplot(fft_select, aes(x = condition, y = frontal_theta)) +
#  geom_boxplot() +
#  theme_bw() +
#  ggtitle("FFT per condition and task") +
#  xlab("Condition") + 
#  facet_wrap( ~ task)

filename <- file.path(figureFolder,"Plot_FFT_group.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")

ggplot(fft_select, aes(x = group, y = frontal_theta)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("FFT per group and task") +
  xlab("Group") +
  ylab("Frontal theta") +
  facet_wrap( ~ task)

dev.off()



#### keys data ####

copy_summarise <- alldata_ext %>%
  filter(task == "Translating" | task == "Copying") %>% 
  group_by(task, group) %>% 
  summarise(meanChars = mean(chars), sdChars = sd(chars), meanDeletions = mean(charsErrors), sdDeletions = sd(charsErrors),meanCopyStringdist = mean(copy_stringdist), sdCopyStringdist = sd(copy_stringdist))

keys_select <- alldata_ext %>%
  filter(task == "Translating" | task == "Copying") %>%
  mutate(percCharsErrors = charsErrors/charsTotal) %>% 
  select(id, group, text, task, condition,chars, charsErrors, charsTotal, percCharsErrors) 
keys_select$task <- droplevels(keys_select$task)

keys_copy_select <- alldata_ext %>%
  filter(task == "Copying") %>%
  select(id, group, text, task, condition, copy_stringdist) 
keys_copy_select$task <- droplevels(keys_copy_select$task)


## stats

chars_full <- lmer(chars ~ task + (1|id) + (1|id:task), data= keys_select)

chars_less <- lmer(chars ~ task  +  (1|id) + (1|id:task) , data= keys_select)

anova(chars_full,chars_less)

summary(chars_full)

chars1 <- tbl_regression(chars_full, 
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

##

charsTot_full <- lmer(charsTotal ~ task +  (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

charsTot_less <- lmer(charsTotal ~ (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(charsTot_full,charsTot_less)

summary(chars_full)

chars2 <- tbl_regression(charsTot_full, 
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


##


charsError_full <- lmer(percCharsErrors ~ task + condition + (1|id), data= keys_select)

charsError_less <- lmer(percCharsErrors ~ task + condition + (1|id) , data= keys_select)

anova(charsError_full,charsError_less)

summary(chars_full)

chars3 <- tbl_regression(charsError_full, 
                         exponentiate = FALSE,
                         pvalue_fun = ~style_pvalue(.x, digits = 2),
                         label = list(task ~ "Task", condition ~ "Condition"),
                         intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")

## merge tables
table_keys <- tbl_merge(
  tbls = list(chars1, chars2 , chars3),
  tab_spanner = c("**Efficiency (chars end version)**", "**Efficiency (total chars typed)**", "**Percentage deletions**")
) %>%
  modify_caption("**LMM Fixed Effects for the keyboard data**")

## save table
as_gt(table_keys) %>%
  gt::tab_source_note(gt::md("EdE = edited English, ELF = English as lingua franca*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_keys.png"))



copy_anova <- ezANOVA(
  keys_select
  , charsTotal
  , id
  , within = c(task, condition)
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)

copyErrors_anova <- ezANOVA(
  keys_select
  , charsErrors
  , id
  , within = c(task, condition)
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)

copydist_anova <- ezANOVA(
  keys_copy_select
  , copy_stringdist
  , id
  , within = c(condition)
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)


bxp_charsTotal_condition <- ggplot(keys_select, aes(x = condition, y = charsTotal)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Total chars typed per condition and task") +
  xlab("Condition") + 
  facet_wrap( ~ task)

bxp_charsTotal_group <- ggplot(keys_select, aes(x = group, y = charsTotal)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Total chars typed per group and task") +
  xlab("Group") + 
  facet_wrap( ~ task)

bxp_charsErrors_condition <- ggplot(keys_select, aes(x = condition, y = charsErrors)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Total errors per condition and task") +
  xlab("Condition") + 
  facet_wrap( ~ task)

bxp_charsErrors_group <- ggplot(keys_select, aes(x = group, y = charsErrors)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Total errors per group and task") +
  xlab("Group") + 
  facet_wrap( ~ task)

bxp_stringdist_group <- ggplot(keys_copy_select, aes(x = group, y = copy_stringdist)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("String distance to reference condition in copying task per group and condition") +
  xlab("Group") + 
  facet_wrap( ~ condition)


#### perceived Difficulty ####

percDiff_summarise <- alldata_ext %>%
  filter(task == "Translating" | task == "Reading") %>% 
  group_by(task,  group, condition,) %>% 
  summarise(meanpercDiff = mean(perceivedDifficulty), sdpercDiff = sd(perceivedDifficulty))


percDiff_select <- alldata_ext %>%
  filter(task == "Translating" | task == "Reading") %>%
  select(id, group, text, task, condition, perceivedDifficulty) 
percDiff_select$task <- droplevels(percDiff_select$task)

percDiff_reading_select <- percDiff_select %>% 
  filter(task == "Reading")

percDiff_translating_select <- percDiff_select %>% 
  filter(task == "Translating")

percDiff_full <- lmer(perceivedDifficulty ~ text +  group + group:text +  (1|id), data= percDiff_reading_select)
percDiff_full2 <- lmer(perceivedDifficulty ~ text+ condition *  group + group:text +  (1|id), data= percDiff_translating_select)


percDiff_less <- lmer(perceivedDifficulty ~ text +condition+ group + group:text +  (1|id), data= percDiff_translating_select)

anova(percDiff_full2,percDiff_less)


## fullest model with significant result
summary(drift_full)

## create table
percDiff <- tbl_regression(percDiff_full2, 
                     exponentiate = FALSE,
                     pvalue_fun = ~style_pvalue(.x, digits = 2),
                     label = list(text ~ "Text", group ~ "Group"),
                     intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")


## merge tables to final table for task 1 and 2
table_keys <- tbl_merge(
  tbls = list(chars1, chars2 , chars3),
  tab_spanner = c("**Efficiency (chars end version)**", "**Efficiency (total chars typed)**", "**Percentage deletions**")
) %>%
  modify_caption("**LMM Fixed Effects for the keyboard data**")

## save table
as_gt(table_keys) %>%
  gt::tab_source_note(gt::md("EdE = edited English, ELF = English as lingua franca*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_keys.png"))




fft_anova <- ezANOVA(
  percDiff_select
  , perceivedDifficulty
  , id
  , within = c(task, condition)
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)




bxp_stringdist_group <- ggplot(percDiff_select, aes(x = group, y = perceivedDifficulty)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Perceived difficulty reading task per group and condition") +
  xlab("Group") + 
  facet_wrap( ~ condition)

bxp_stringdist_group <- ggplot(percDiff_reading_select, aes(x = group, y = perceivedDifficulty)) +
  geom_boxplot() +
  theme_bw() +
  ggtitle("Perceived difficulty reading task per group and condition") +
  xlab("Group") + 
  facet_wrap( ~ condition)

#### percCQRes

percCQRes_summarise <- alldata_ext %>%
  filter(task == "reading") %>% 
  group_by(text, condition, group) %>% 
  summarise(meanpercCQRes = mean(percCQRes), sdpercDiff = sd(percCQRes))


percDiff_select <- alldata_ext %>%
  filter(task == "translating" | task == "reading") %>%
  select(id, group, text, task, condition,perceivedDifficulty) 
percDiff_select$task <- droplevels(percDiff_select$task)


fft_anova <- ezANOVA(
  percDiff_select
  , perceivedDifficulty
  , id
  , within = c(task,text)
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)

print(fft_anova)


#### average reading Duration

avgReadDur_summarise <- alldata_ext %>%
  filter(task == "reading") %>% 
  group_by(text, group) %>% 
  summarise(meanAvgReadDur = mean(avgReadingDuration), sdpercDiff = sd(avgReadingDuration))


percDiff_select <- alldata_ext %>%
  filter(task == "translating" | task == "reading") %>%
  select(id, group, text, task, condition,perceivedDifficulty) 
percDiff_select$task <- droplevels(percDiff_select$task)





