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

# load fluency data
source(paste(RFolder, "07_fluency.R", sep = "/"))

# load accuracy data
source(paste(RFolder, "08_accuracy.R", sep = "/"))


# merge data 
source(paste(RFolder, "09_merging_data.R", sep = "/"))



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
  gt::tab_source_note(gt::md("*Mul = multilingual control group, TraPro = professional translators, TraStu = translation students*")) %>%
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
  gt::tab_source_note(gt::md("*Mul = multilingual control group, TraPro = professional translators, TraStu = translation students*")) %>%
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
  gt::tab_source_note(gt::md("*Mul = multilingual control group, TraPro = professional translators, TraStu = translation students*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "psychometrics_unused.png"))


remove(sample_char, psycho, psycho2, psychometrics_selected, psychometrics_selected_2, psychometrics_selected_3)

 
#### FFT ####
alldata_ext <- alldata %>% 
  mutate(tfz_apz = frontal_theta/parietal_alpha)

alldata_overview <- alldata_ext %>% 
  group_by(cond) %>% 
  summarise(n_condition = n())


fft_summarise <- alldata_ext %>% 
  filter(task != "Reading_post") %>% 
  group_by(task, condition, group) %>% 
  summarise(mean_fontal_theta = mean(frontal_theta), sd_fontal_theta = sd(frontal_theta), mean_parietal_alpha = mean(parietal_alpha), sd_parietal_alpha = sd(parietal_alpha), mean_tfz_apz = mean(tfz_apz), sd_tfz_apz = sd(tfz_apz))

## Stats

fft_select <- alldata_ext %>% 
  select(id, group, text, task, condition,frontal_theta, parietal_alpha, tfz_apz) %>% 
  filter(task != "Reading_post")
fft_select$task <- droplevels(fft_select$task)

fft_anova <- ezANOVA(
  fft_select_copytrans
  , frontal_theta
  , id
  , within = c(text, condition)
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)



## reading task only
# frontal theta
fft_select_reading <- alldata_ext %>% 
  select(id, group, text, task, condition,frontal_theta, parietal_alpha, tfz_apz) %>% 
  filter(task == "Reading")
fft_select_reading$task <- droplevels(fft_select_reading$task)


fft_reading_theta_null <- lmer(frontal_theta ~ (1|id), data= fft_select_reading)
fft_reading_theta_1 <- lmer(frontal_theta ~ group + (1|id), data= fft_select_reading)

anova(fft_reading_theta_null, fft_reading_theta_1)

#fft_reading_2 <- lmer(frontal_theta ~ group + (1|id) + (1|id:condition), data= fft_select_reading)

#anova(fft_reading_1, fft_reading_2)


fft_reading_theta <- tbl_regression(fft_reading_theta_1, 
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



# parietal alpha

fft_reading_alpha_null <- lmer(parietal_alpha ~ (1|id), data= fft_select_reading)
fft_reading_alpha_1 <- lmer(parietal_alpha ~ condition + (1|id), data= fft_select_reading)

anova(fft_reading_alpha_null, fft_reading_alpha_1)

fft_reading_alpha_2 <- lmer(parietal_alpha ~ text + condition + (1|id), data= fft_select_reading)

anova(fft_reading_alpha_1, fft_reading_alpha_2)

#fft_reading_alpha_3 <- lmer(parietal_alpha ~ text * condition + (1|id), data= fft_select_reading)

#anova(fft_reading_alpha_2, fft_reading_alpha_3)

fft_reading_alpha <- tbl_regression(fft_reading_alpha_2, 
                                    exponentiate = FALSE,
                                    pvalue_fun = ~style_pvalue(.x, digits = 2),
                                    label = list(condition ~ "Condition", text ~ "Text"),
                                    intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")

# tfz_apz

fft_reading_tfz_apz_null <- lmer(tfz_apz ~ (1|id), data= fft_select_reading)
fft_reading_tfz_apz_1 <- lmer(tfz_apz ~ condition + (1|id), data= fft_select_reading)

anova(fft_reading_tfz_apz_null, fft_reading_tfz_apz_1)

#fft_reading_tfz_apz_2 <- lmer(tfz_apz ~ text + condition + (1|id), data= fft_select_reading)

#anova(fft_reading_tfz_apz_1, fft_reading_tfz_apz_2)

#fft_reading_tfz_apz_3 <- lmer(tfz_apz ~ text * condition + (1|id), data= fft_select_reading)

#anova(fft_reading_tfz_apz_2, fft_reading_tfz_apz_3)

fft_reading_tfz_apz <- tbl_regression(fft_reading_tfz_apz_null, 
                                    exponentiate = FALSE,
                                    pvalue_fun = ~style_pvalue(.x, digits = 2),
                                    #label = list(condition ~ "Condition", text ~ "Text"),
                                    intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")

# merge tables
table_fft_reading <- tbl_merge(
  tbls = list(fft_reading_theta, fft_reading_alpha , fft_reading_tfz_apz),
  tab_spanner = c("**Frontal theta**", "**Parietal alpha**", "**Frontal theta / Parietal alpha**")
) %>%
  modify_caption("**LMM Fixed Effects for the FFT in reading task only**")

## save table
as_gt(table_fft_reading) %>%
  gt::tab_source_note(gt::md("*Mul = multilingual control group, TraPro = professional translators, TraStu = translation students, EdE = edited English, ELF = English as lingua franca*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_fft.png"))




## task only
fft_task_null <- lmer(frontal_theta ~ (1|id), data= fft_select)
fft_task_1 <- lmer(frontal_theta ~ task + (1|id), data= fft_select)

anova(fft_task_null, fft_task_1)

fft_task_2 <- lmer(frontal_theta ~ task + group + (1|id), data= fft_select)

anova(fft_task_1, fft_task_2)

fft_task_3 <- lmer(frontal_theta ~ task * group + (1|id), data= fft_select)

anova(fft_task_2, fft_task_3)


ffttask <- tbl_regression(fft_task_1, 
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
  modify_caption("**LMM Fixed Effects for the FFT all tasks**")

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


## copy / translating
fft_select_copytrans <- alldata_ext %>% 
  select(id, group, text, task, condition,frontal_theta, parietal_alpha, tfz_apz) %>% 
  filter(task == "Copying" | task == "Translating")
fft_select_copytrans$task <- droplevels(fft_select_copytrans$task)


fft_full <- lmer(frontal_theta ~ task + condition + group + condition : group + task : group + task:condition + task*condition*group + (1|id) + (1|id:task) + (1|id:condition), data= fft_select_copytrans)

fft_less1 <- lmer(frontal_theta ~ task + condition + group + condition : group + task : group + task:condition + task*condition*group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_full,fft_less1)

fft_less2 <- lmer(frontal_theta ~ task + condition + group + condition : group + task : group + task:condition + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_less1,fft_less2)

fft_less3 <- lmer(frontal_theta ~ task + condition + group + condition : group + task : group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_less2,fft_less3)

fft_less4 <- lmer(frontal_theta ~ task + condition + group + task : group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_less3,fft_less4)


fft_less5 <- lmer(frontal_theta ~ task + group + task : group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_less4,fft_less5)

fft_less6 <- lmer(frontal_theta ~ task + group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_less5,fft_less6)

fft_less7 <- lmer(frontal_theta ~ task + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_less6,fft_less7)

fft_less8 <- lmer(frontal_theta ~ (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_less7,fft_less8)

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
fft_ta_full <- lmer(tfz_apz ~ task + condition + group + condition : group + task : group + task:condition + task*condition*group + (1|id) + (1|id:condition), data= fft_select_copytrans)

fft_ta_less1 <- lmer(tfz_apz ~ task + condition + group + condition : group + task : group + task:condition + task*condition*group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_ta_full,fft_ta_less1)

fft_ta_less2 <- lmer(tfz_apz ~ task + condition + group + condition : group + task : group + task:condition + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_ta_less1,fft_ta_less2)

fft_ta_less3 <- lmer(tfz_apz ~ task + condition + group + condition : group + task : group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_ta_less2,fft_ta_less3)

fft_ta_less4 <- lmer(tfz_apz ~ task + condition + group + task : group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_ta_less3,fft_ta_less4)


fft_ta_less5 <- lmer(tfz_apz ~ task + group + task : group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_ta_less4,fft_ta_less5)

fft_ta_less6 <- lmer(tfz_apz ~ task + group + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_ta_less5,fft_ta_less6)

fft_ta_less7 <- lmer(tfz_apz ~ task + (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_ta_less6,fft_ta_less7)

fft_ta_less8 <- lmer(tfz_apz ~ (1|id) + (1|id:condition), data= fft_select_copytrans)

anova(fft_ta_less7,fft_ta_less8)

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
  modify_caption("**LMM Fixed Effects for the FFT all tasks**")

## save table
as_gt(table_fft) %>%
  gt::tab_source_note(gt::md("Mul = multilingual control group, TraPro = professional translators, TraStu = translation students*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_fft.png"))




#### keys data ####

copy_summarise <- alldata_ext %>%
  filter(task == "Translating" | task == "Copying") %>%
  mutate(relDel = charsTotal/charsErrors) %>% 
  group_by(task, condition, group) %>% 
  summarise(meanChars = mean(chars), sdChars = sd(chars), meanDeletions = mean(charsErrors), sdDeletions = sd(charsErrors), meanrelDel = mean(relDel), sdrelDel = sd(relDel), meanCopyStringdist = mean(copy_stringdist), sdCopyStringdist = sd(copy_stringdist))

keys_select <- alldata_ext %>%
  filter(task == "Translating" | task == "Copying") %>%
  mutate(percCharsErrors = charsErrors/charsTotal) %>% 
  select(id, group, text, task, condition,chars, charsErrors, charsTotal, percCharsErrors) 
keys_select$task <- droplevels(keys_select$task)

keys_copy_select <- alldata_ext %>%
  filter(task == "Copying") %>%
  select(id, group, text, task, condition, copy_stringdist) 
keys_copy_select$task <- droplevels(keys_copy_select$task)


## stats charsTotal

chars_tot_null <- lmer(charsTotal ~ (1|id) , data= keys_select)

chars_tot_1 <- lmer(charsTotal ~ (1|id) + (1|id:task) , data= keys_select)

anova(chars_tot_null, chars_tot_1)

chars_tot_2 <- lmer(charsTotal ~ (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(chars_tot_1, chars_tot_2)

chars_tot_3 <- lmer(charsTotal ~ task +  (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(chars_tot_2, chars_tot_3)


chars_tot_4 <- lmer(charsTotal ~ task + group+  (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(chars_tot_3, chars_tot_4)


chars_tot_5 <- lmer(charsTotal ~ task + condition +  (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(chars_tot_3, chars_tot_5)

chars_tot_6 <- lmer(charsTotal ~ task + text +  (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(chars_tot_3, chars_tot_6)

chars_tot_7 <- lmer(charsTotal ~ task + group + condition +  (1|id) + (1|id:task) + (1|id:condition), data= keys_select)


chars_tot_8 <- lmer(charsTotal ~ task + group * condition +  (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(chars_tot_7, chars_tot_8)



chars_tot_full <- lmer(chars ~ task + (1|id) + (1|id:task), data= keys_select)

chars_tot_less <- lmer(chars ~ task  +  (1|id) + (1|id:task) , data= keys_select)

anova(chars_tot_full,chars_tot_less)

summary(chars_tot_full)

chars1 <- tbl_regression(chars_tot_3, 
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

## CHARS
chars_null <- lmer(chars ~ (1|id) , data= keys_select)

chars_1 <- lmer(chars ~ (1|id) + (1|id:task) , data= keys_select)

anova(chars_null, chars_1)

chars_2 <- lmer(chars ~ (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(chars_1, chars_2)

chars_3 <- lmer(chars ~ task +  (1|id) + (1|id:task), data= keys_select)

anova(chars_1, chars_3)


chars_4 <- lmer(chars ~ task + group+  (1|id) + (1|id:task), data= keys_select)

anova(chars_3, chars_4)


chars_5 <- lmer(chars ~ task + condition +  (1|id) + (1|id:task), data= keys_select)

anova(chars_3, chars_5)

chars_6 <- lmer(chars ~ task + text +  (1|id) + (1|id:task), data= keys_select)

anova(chars_3, chars_6)

chars_7 <- lmer(chars ~ task + group + condition +  (1|id) + (1|id:task), data= keys_select)


chars_8 <- lmer(chars ~ task + group * condition +  (1|id) + (1|id:task), data= keys_select)

anova(chars_7, chars_8)


charsTot_full <- lmer(chars ~ task +  (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

charsTot_less <- lmer(chars ~ (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(charsTot_full,charsTot_less)

summary(chars_full)

chars2 <- tbl_regression(chars_3, 
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

chars_del_1 <- lmer(percCharsErrors ~ (1|id) + (1|id:task) , data= keys_select)

anova(chars_del_null, chars_del_1)

chars_del_2 <- lmer(percCharsErrors ~ (1|id) + (1|id:task) + (1|id:condition), data= keys_select)

anova(chars_del_1, chars_del_2)

chars_del_3 <- lmer(percCharsErrors ~ task +  (1|id) + (1|id:task), data= keys_select)

anova(chars_del_1, chars_del_3)


chars_del_4 <- lmer(percCharsErrors ~ task + group+  (1|id) + (1|id:task), data= keys_select)

anova(chars_del_3, chars_del_4)


chars_del_5 <- lmer(percCharsErrors ~ task + condition +  (1|id) + (1|id:task), data= keys_select)

anova(chars_del_3, chars_del_5)

chars_del_6 <- lmer(percCharsErrors ~ task + condition + text +  (1|id) + (1|id:task), data= keys_select)

anova(chars_del_5, chars_del_6)

chars_del_7 <- lmer(percCharsErrors ~ task + text + condition + task:text +  (1|id) + (1|id:task), data= keys_select)

anova(chars_del_6, chars_del_7)

chars_del_8 <- lmer(percCharsErrors ~ task + text + group * condition +  (1|id) + (1|id:task), data= keys_select)

anova(chars_del_7, chars_del_8)



charsError_full <- lmer(percCharsErrors ~ task + condition + (1|id), data= keys_select)

charsError_less <- lmer(percCharsErrors ~ task + condition + (1|id) , data= keys_select)

anova(charsError_full,charsError_less)

summary(chars_del_full)

chars3 <- tbl_regression(chars_del_7, 
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
  tbls = list(chars1, chars2 , chars3),
  tab_spanner = c("**Efficiency (total chars typed)**", "**Efficiency (chars chars endversion)**", "**Percentage deletions**")
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
  , within = c(condition, text)
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
  group_by(task, condition, group) %>% 
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



# stats
perceivedDifficulty_null <- lmer(perceivedDifficulty ~ (1|id) , data= percDiff_select)

perceivedDifficulty_1 <- lmer(perceivedDifficulty ~ task + (1|id), data= percDiff_select)

anova(perceivedDifficulty_null, perceivedDifficulty_1)

perceivedDifficulty_2 <- lmer(perceivedDifficulty ~ task + text + (1|id), data= percDiff_select)

anova(perceivedDifficulty_1, perceivedDifficulty_2)

perceivedDifficulty_3 <- lmer(perceivedDifficulty ~ task + text + group + (1|id), data= percDiff_select)

anova(perceivedDifficulty_2, perceivedDifficulty_3)

perceivedDifficulty_4 <- lmer(perceivedDifficulty ~ task + text + condition+ (1|id), data= percDiff_select)

anova(perceivedDifficulty_2, perceivedDifficulty_4)




perceivedDifficulty_full <- lmer(perceivedDifficulty ~  text + task+   + condition + group + condition : group + task : group+ text:task + text:group + (1|id) + (1|id:task) + (1|id:condition), data= percDiff_select)

perceivedDifficulty_less <- lmer(perceivedDifficulty ~ text + task + condition + group + condition : group + task : group  + text:task +text:group + (1|id) + (1|id:task) + (1|id:condition), data= percDiff_select)

anova(perceivedDifficulty_full, perceivedDifficulty_less)


## fullest model with significant result

## create table
percDiff <- tbl_regression(perceivedDifficulty_full, 
                     exponentiate = FALSE,
                     pvalue_fun = ~style_pvalue(.x, digits = 2),
                     label = list(text ~ "Text", group ~ "Group", condition ~"Condition", task ~ "Task"),
                     intercept= TRUE
) %>% 
  add_global_p() %>%
  bold_p(t = 0.10) %>%
  bold_labels() %>%
  italicize_levels() %>% 
  modify_header(label = "**Variable**")




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

#### percCQRes ####

percCQRes_summarise <- alldata_ext %>%
  filter(task == "Reading") %>% 
  group_by(text, condition, group) %>% 
  summarise(meanpercCQRes = mean(percCQRes), sdpercDiff = sd(percCQRes))


percCQRes_select <- alldata_ext %>%
  filter(task == "Translating" | task == "Reading") %>%
  select(id, group, text, task, condition,percCQRes) 
percCQRes_select$task <- droplevels(percCQRes_select$task)


# stats
percCQRes_null <- lmer(percCQRes ~ (1|id) , data= percCQRes_select)

percCQRes_1 <- lmer(percCQRes ~ text + (1|id), data= percCQRes_select)

anova(percCQRes_null, percCQRes_1)

percCQRes_2 <- lmer(percCQRes ~ condition + (1|id), data= percCQRes_select)

anova(percCQRes_null, percCQRes_2)

percCQRes_3 <- lmer(percCQRes ~ group + (1|id), data= percCQRes_select)

anova(percCQRes_null, percCQRes_3)


## create table
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


#### average reading Duration ####

avgReadDur_summarise <- alldata_ext %>%
  filter(task == "Reading") %>% 
  group_by(text, condition, group) %>% 
  summarise(meanAvgReadDur = mean(avgReadingDuration), sdpercDiff = sd(avgReadingDuration))


avgReadDur_select <- alldata_ext %>%
  filter(task == "Reading") %>%
  select(id, group, text, condition,avgReadingDuration) 
avgReadDur_select$task <- droplevels(avgReadDur_select$task)

# stats
avgReadDu_null <- lmer(avgReadingDuration ~ (1|id) , data= avgReadDur_select)

avgReadDu_1 <- lmer(avgReadingDuration ~  group + (1|id) , data= avgReadDur_select)

anova(avgReadDu_null, avgReadDu_1)

avgReadDu_2 <- lmer(avgReadingDuration ~ text + condition + (1|id), data= avgReadDur_select)

anova(avgReadDu_1, avgReadDu_2)

avgReadDu_3 <- lmer(avgReadingDuration ~ text * group + (1|id), data= avgReadDur_select)

anova(avgReadDu_1, avgReadDu_3)


avgReadDu_full <- lmer(avgReadingDuration ~ text  + group  + text : group +  (1|id), data= avgReadDur_select)

avgReadDu_less <- lmer(avgReadingDuration ~ text  + group  + text : group + (1|id), data= avgReadDur_select)

anova(avgReadDu_full, avgReadDu_less)

## create table
avgReadDu <- tbl_regression(avgReadDu_3, 
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
table_reading <- tbl_merge(
  tbls = list(percCQRes, avgReadDu, percDiff),
  tab_spanner = c("**Percentage correct answers control questions**", "**Average reading duration per sentence**", "**Perceived difficulty**")) %>%
  modify_caption("**LMM Fixed Effects for the reading task**")

## save table
as_gt(table_reading) %>%
  gt::tab_source_note(gt::md("*EdE = edited English, ELF = English as lingua franca, TraPro = professional translators, TraStu = translation students*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_reading.png"))



#### translation fluency ####


fluency_summarise <- alldata %>%
  filter(task == "Translating") %>% 
  group_by(condition, group) %>% 
  summarise(fluencyRating = mean(fluency_meanRater))

fluency_icc <- alldata %>%
  filter(task == "Translating") %>% 
  select(fluency_meanR1, fluency_meanR2,fluency_meanR3)

icc(
  fluency_icc, model = "twoway", 
  type = "consistency", unit = "average"
)

fluency_select<- alldata_ext %>%
  filter(task == "Translating") %>%
  select(id, group, text, task, condition,fluency_meanRater) 
fluency_select$task <- droplevels(fluency_select$task)


# stats
fluency_null <- lmer(fluency_meanRater ~ (1|id) , data= fluency_select)

fluency_1 <- lmer(fluency_meanRater ~ text + (1|id), data= fluency_select)

anova(fluency_null, fluency_1)

fluency_2 <- lmer(fluency_meanRater ~ condition + (1|id), data= fluency_select)

anova(fluency_null, fluency_2)

fluency_3 <- lmer(fluency_meanRater ~ group + (1|id), data= fluency_select)

anova(fluency_null, fluency_3)


## create table
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




## old stuff

fluency_results_icc <- fluency_results %>% 
  filter(!(is.na(fluency_R1))) %>% 
  select(fluency_R1, fluency_R2, fluency_R3)

icc(
  fluency_results_icc, model = "twoway", 
  type = "consistency", unit = "average"
)



fluency_results_avgR <- fluency_results_avg %>% 
  mutate(meanR = (meanR1+ meanR2 + meanR3)/3)

grande_results_fluency <- fluency_results_avgR %>% 
  group_by(text, condition) %>% 
  summarise(fluencyRating = mean(meanR), n_subjects = n(), n_obs = sum(n_obs))


#### translation accuracy ####


accuracy_summarise <- alldata %>%
  filter(task == "Translating") %>% 
  group_by(text, condition, group) %>% 
  summarise(accuracyRating = mean(accuracy_meanRater))

accuracy_icc <- alldata %>%
  filter(task == "Translating") %>% 
  select(accuracy_meanR1, accuracy_meanR2,accuracy_meanR3)

icc(
  accuracy_icc, model = "twoway", 
  type = "consistency", unit = "average"
)

accuracy_select<- alldata_ext %>%
  filter(task == "Translating") %>%
  select(id, group, text, task, condition,accuracy_meanRater) 
accuracy_select$task <- droplevels(accuracy_select$task)




# stats
accuracy_null <- lmer(accuracy_meanRater ~ (1|id) , data= accuracy_select)

accuracy_1 <- lmer(accuracy_meanRater ~ text + (1|id), data= accuracy_select)

anova(accuracy_null, accuracy_1)

accuracy_2 <- lmer(accuracy_meanRater ~ condition + (1|id), data= accuracy_select)

anova(accuracy_null, accuracy_2)

accuracy_3 <- lmer(accuracy_meanRater ~ condition + group + (1|id), data= accuracy_select)

anova(accuracy_2, accuracy_3)

accuracy_4 <- lmer(accuracy_meanRater ~ condition * group + (1|id), data= accuracy_select)

anova(accuracy_3, accuracy_4)

## create table
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




## merge tables to final table translation task
table_translation <- tbl_merge(
  tbls = list(fluency, accuracy),
  tab_spanner = c("**Fluency rating**", "**Accuracy rating**")
) %>%
  modify_caption("**LMM Fixed Effects for the translation task**")

## save table
as_gt(table_translation) %>%
  gt::tab_source_note(gt::md("EdE = edited English, ELF = English as lingua franca, Mul = multilingual control group, TraPro = professional translators, TraStu = translation students*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_keys.png"))




## old stuff
accuracy_results_icc <- accuracy_results %>% 
  filter(!(is.na(accuracy_R1))) %>% 
  select(accuracy_R1, accuracy_R2, accuracy_R3)

icc(
  accuracy_results_icc, model = "twoway", 
  type = "consistency", unit = "average"
)



accuracy_results_avgR <- accuracy_results_avg %>% 
  mutate(meanR = (meanR1+ meanR2 + meanR3)/3)

grande_results_accuracy <- accuracy_results_avgR %>% 
  group_by(text, condition) %>% 
  summarise(accuracyRating = mean(meanR), n_subjects = n(), n_obs = sum(n_obs))


## new stuff



