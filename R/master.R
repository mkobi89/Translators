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
library(graphics)
library(GGally)
library(ggpubr)
library(png)
library(ez)
library(irr)

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

alldata_ext <- alldata %>% 
  mutate(tfz_apz = frontal_theta/parietal_alpha)


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
  add_p(all_continuous() ~ "aov") %>% # test for a difference between groups
  modify_header(label = "**Variable**") %>% # update the column header
  modify_caption("**Sample characteristics**") %>% 
  bold_labels() %>%
  italicize_levels()

aov(age ~ as.factor(group), data = psychometrics_selected)

age_anova <- ezANOVA(
  psychometrics
  , age
  , id
  , within = NULL
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)


# save
as_gt(sample_char) %>%
  gt::tab_source_note(gt::md("Mul = multilingual control group, TraPro = professional translators, TraStu = translation students")) %>%
  gt::gtsave(filename = file.path(figureFolder, "sample_char.png"))

#plot
filename <- file.path(figureFolder,"ggairs_task_1_2_all.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")
ggpairs(psychometrics_selected, title = "Variable overview", cardinality_threshold = NULL) + theme_bw()
dev.off()


#### Psychometrics ####


psychometrics_selected_2 <- psychometrics %>% 
  select(group, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U)

# create table
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
  modify_header(label = "**Variable**") %>% # update the column header
  modify_caption("**Psychometrics**") %>% 
  bold_labels() %>%
  italicize_levels()


cumTH_U_anova <- ezANOVA(
  psychometrics
  , cumTH_U
  , id
  , within = NULL
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)
hpd_U_anova <- ezANOVA(
  psychometrics
  , hpd_U
  , id
  , within = NULL
  , between = c(group)
  , observed = NULL
  , diff = NULL
  , reverse_diff = FALSE
  , type = 2
  , white.adjust = FALSE
  , detailed = FALSE
  , return_aov = FALSE
)



# save table to figure folder
as_gt(psycho) %>%
  gt::tab_source_note(gt::md("Mul = multilingual control group, TraPro = professional translators, TraStu = translation students")) %>%
  gt::gtsave(filename = file.path(figureFolder, "psychometrics.png"))

#plot
filename <- file.path(figureFolder,"ggairs_task_1_2_all.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")
ggpairs(psychometrics_selected_2, title = "Variable overview", cardinality_threshold = NULL) + theme_bw()
dev.off()





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

alldata_overview <- alldata_ext %>% 
  group_by(cond) %>% 
  summarise(n_condition = n())


fft_summarise <- alldata_ext %>% 
  filter(task != "Reading_post") %>% 
  group_by(task, group) %>% 
  summarise(mean_fontal_theta = mean(frontal_theta), sd_fontal_theta = sd(frontal_theta), mean_parietal_alpha = mean(parietal_alpha), sd_parietal_alpha = sd(parietal_alpha), mean_tfz_apz = mean(tfz_apz), sd_tfz_apz = sd(tfz_apz))

## Stats

fft_select <- alldata_ext %>% 
  select(id, group, text, task, condition,frontal_theta, parietal_alpha, tfz_apz) %>% 
  filter(task != "Reading_post")
fft_select$task <- droplevels(fft_select$task)



## frontal theta 

fft_ft_null <- lmer(frontal_theta ~ (1|id), data= fft_select)
fft_ft_1 <- lmer(frontal_theta ~ task + (1|id), data= fft_select)

anova(fft_ft_null, fft_ft_1)

summary(fft_ft_1)

fft_ft_2 <- lmer(frontal_theta ~ task + text + (1|id), data= fft_select)

anova(fft_ft_1, fft_ft_2)

fft_ft_3 <- lmer(frontal_theta ~ task + condition + (1|id), data= fft_select)

anova(fft_ft_1, fft_ft_3)

fft_ft_4 <- lmer(frontal_theta ~ task + group + (1|id), data= fft_select)

anova(fft_ft_1, fft_ft_4)


fft_ft_5 <- lmer(frontal_theta ~ task + group + task : group +  (1|id), data= fft_select)


anova(fft_ft_4,fft_ft_5)

summary(fft_ft_5)

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




fftpa_full <- lmer(parietal_alpha ~ task + group + task : group  + (1|id), data= fft_select)

fftpa_less <- lmer(parietal_alpha ~ task + group  + (1|id), data= fft_select)

anova(fftpa_full,fftpa_less)

summary(fftpa_full)

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
  tbls = list(fft1 , fft2),
  tab_spanner = c("**Frontal theta**", "**Parietal alpha**")
) %>%
  modify_caption("**LMM Fixed Effects for the EEG data**")

## save table
as_gt(table_fft) %>%
  gt::tab_source_note(gt::md("Mul = multilingual control group, TraPro = professional translators, TraStu = translation students")) %>%
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
  mutate(relDel = charsTotal/charsErrors) %>% 
  group_by(task, condition, group) %>% 
  summarise(meanChars = mean(chars), sdChars = sd(chars), meanDeletions = mean(charsErrors), sdDeletions = sd(charsErrors), meanrelDel = mean(relDel), sdrelDel = sd(relDel), meanCopyStringdist = mean(copy_stringdist), sdCopyStringdist = sd(copy_stringdist))


keys_plot <- alldata_ext %>%
  filter(task == "Translating" | task == "Copying") %>%
  mutate(percCharsErrors = charsErrors/charsTotal) %>% 
  select(age, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U, charsTotal, percCharsErrors)

#plot
filename <- file.path(figureFolder,"keys_plot.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")
ggpairs(keys_plot, title = "Variable overview Keys", cardinality_threshold = NULL) + theme_bw()
dev.off()



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

chars_tot_1 <- lmer(charsTotal ~ task +  (1|id), data= keys_select)

anova(chars_tot_null, chars_tot_1)

summary(chars_tot_1)

chars_tot_2 <- lmer(charsTotal ~ task + text +  (1|id), data= keys_select)

anova(chars_tot_1, chars_tot_2)

chars_tot_3 <- lmer(charsTotal ~ task + condition +  (1|id), data= keys_select)

anova(chars_tot_1, chars_tot_3)

chars_tot_4 <- lmer(charsTotal ~ task + group +  (1|id), data= keys_select)

anova(chars_tot_1, chars_tot_4)





chars_tot_7 <- lmer(charsTotal ~ task + group + condition +  (1|id), data= keys_select)


chars_tot_8 <- lmer(charsTotal ~ task + group * condition +  (1|id), data= keys_select)

anova(chars_tot_7, chars_tot_8)



chars_tot_full <- lmer(chars ~ task + (1|id) + (1|id:task), data= keys_select)

chars_tot_less <- lmer(chars ~ task  +  (1|id) + (1|id:task) , data= keys_select)

anova(chars_tot_full,chars_tot_less)

summary(chars_tot_full)

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

## CHARS
chars_null <- lmer(chars ~ (1|id) , data= keys_select)

chars_1 <- lmer(chars ~ task +  (1|id), data= keys_select)

anova(chars_null, chars_1)

summary(chars_1)

chars_2 <- lmer(chars ~ task + text +  (1|id), data= keys_select)

anova(chars_1, chars_2)

chars_3 <- lmer(chars ~ task + condition +  (1|id), data= keys_select)

anova(chars_1, chars_3)

chars_4 <- lmer(chars ~ task + group+  (1|id), data= keys_select)

anova(chars_1, chars_4)



chars2 <- tbl_regression(chars_1, 
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

summary(chars_del_1)

chars_del_2 <- lmer(percCharsErrors ~ task + text+  (1|id), data= keys_select)

anova(chars_del_1, chars_del_2)

summary(chars_del_2)

chars_del_3 <- lmer(percCharsErrors ~ task + text + condition +  (1|id), data= keys_select)

anova(chars_del_2, chars_del_3)

summary(chars_del_3)

chars_del_4 <- lmer(percCharsErrors ~ task + text + condition + group +  (1|id), data= keys_select)

anova(chars_del_3, chars_del_4)

chars_del_5 <- lmer(percCharsErrors ~ task + text + condition + task:text +  (1|id), data= keys_select)

anova(chars_del_3, chars_del_5)

summary(chars_del_5)


chars_del_6 <- lmer(percCharsErrors ~ task + text + condition +task:text + text:condition +  (1|id), data= keys_select)

anova(chars_del_5, chars_del_6)


chars_del_7 <- lmer(percCharsErrors ~ task + text + condition +task:text  + task:condition +  (1|id), data= keys_select)

anova(chars_del_5, chars_del_7)




summary(chars_del_full)

chars3 <- tbl_regression(chars_del_5, 
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
  tab_spanner = c("**Efficiency (total chars typed)**", "**Efficiency (chars endversion)**", "**Percentage deletions**")
) %>%
  modify_caption("**LMM Fixed Effects for the keyboard data**")

## save table
as_gt(table_keys) %>%
  gt::tab_source_note(gt::md("EdE = edited English, ELF = English as lingua franca")) %>%
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


percDiff_plot <- alldata_ext %>%
  filter(task == "Translating" | task == "Reading") %>%
  select(age, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U, perceivedDifficulty)

#plot
filename <- file.path(figureFolder,"percDiff_plot.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")
ggpairs(percDiff_plot, title = "Variable overview Keys", cardinality_threshold = NULL) + theme_bw()
dev.off()



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


# stats
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


perceivedDifficulty_6 <- lmer(perceivedDifficulty ~ text * condition + condition*group +  (1|id), data= percDiff_select)

anova(perceivedDifficulty_4, perceivedDifficulty_6)




perceivedDifficulty_full <- lmer(perceivedDifficulty ~  text + task+   + condition + group + condition : group + task : group+ text:task + text:group + (1|id) + (1|id:task) + (1|id:condition), data= percDiff_select)

perceivedDifficulty_less <- lmer(perceivedDifficulty ~ text + task + condition + group + condition : group + task : group  + text:task +text:group + (1|id) + (1|id:task) + (1|id:condition), data= percDiff_select)

anova(perceivedDifficulty_full, perceivedDifficulty_less)


## fullest model with significant result

## create table
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
  modify_header(label = "**Variable**") %>% 
  modify_caption("**LMM Fixed Effects for the perceived difficulty**")

as_gt(percDiff) %>%
#  gt::tab_source_note(gt::md("EdE = edited English, ELF = English as lingua franca*")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_percDiff.png"))


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
  filter(task == "Reading") %>%
  select(id, group, text, task, condition,percCQRes) 
percCQRes_select$task <- droplevels(percCQRes_select$task)

percCQRes_plot <- alldata_ext %>%
  filter(task == "Reading") %>%
  select(age, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U, percCQRes)

#plot
filename <- file.path(figureFolder,"percCQRes_plot")
png(filename,pointsize = 20,width=1000, height=600,units = "px")
ggpairs(percCQRes_plot, title = "Variable psychometrics and behavioral data", cardinality_threshold = NULL) + theme_bw()
dev.off()


# stats
percCQRes_null <- lmer(percCQRes ~ (1|id) , data= percCQRes_select)

percCQRes_1 <- lmer(percCQRes ~ text + (1|id), data= percCQRes_select)

anova(percCQRes_null, percCQRes_1)

percCQRes_2 <- lmer(percCQRes ~ condition + (1|id), data= percCQRes_select)

anova(percCQRes_null, percCQRes_2)

percCQRes_3 <- lmer(percCQRes ~ group + (1|id), data= percCQRes_select)

anova(percCQRes_null, percCQRes_3)

summary(percCQRes_3)



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
  summarise(meanAvgReadDur = mean(avgReadingDuration), sdAvgReadDur = sd(avgReadingDuration), maxAvgReadDur = max(avgReadingDuration), minAvgReadDur = min(avgReadingDuration), medianAvgReadDur = median(avgReadingDuration), IQRAvgReadDur = IQR(avgReadingDuration), q75 = quantile(avgReadingDuration,probs =.75))

## trimming with .75 quantile + 1.5 * IQR

avgReadDur_t1 <- alldata_ext %>%
  filter(task == "Reading") %>% 
  filter(text == "Text1") 

iqrAvgReadDurT1 = IQR(avgReadDur_t1$avgReadingDuration)

UpperQuantilesAvgReadDurT1 = quantile(avgReadDur_t1$avgReadingDuration,probs =.75)


avgReadDur_trim_T1 <- alldata_ext %>%
  filter(task == "Reading") %>% 
  filter(text == "Text1") %>% 
  filter(avgReadingDuration < UpperQuantilesAvgReadDurT1 + 1.5*iqrAvgReadDurT1)



  
avgReadDur_t2 <- alldata_ext %>%
  filter(task == "Reading") %>% 
  filter(text == "Text2") 

iqrAvgReadDurT2 = IQR(avgReadDur_t2$avgReadingDuration)

UpperQuantilesAvgReadDurT2 = quantile(avgReadDur_t2$avgReadingDuration,probs =.75)


avgReadDur_trim_T2 <- alldata_ext %>%
  filter(task == "Reading") %>% 
  filter(text == "Text2") %>% 
  filter(avgReadingDuration < UpperQuantilesAvgReadDurT2 + 1.5*iqrAvgReadDurT2)



avgReadDur_select <- full_join(avgReadDur_trim_T1, avgReadDur_trim_T2) %>% 
  select(id, age, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U, group, text, condition,avgReadingDuration) 

avgReadDur_plot <- avgReadDur_select %>%
  select(age, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U, avgReadingDuration)

#plot
filename <- file.path(figureFolder,"avgReadDur_plot")
png(filename,pointsize = 20,width=1000, height=600,units = "px")
ggpairs(avgReadDur_plot, title = "Variable psychometrics and behavioral data", cardinality_threshold = NULL) + theme_bw()
dev.off()


# stats
avgReadDu_null <- lmer(avgReadingDuration ~ (1|id) , data= avgReadDur_select)

avgReadDu_1 <- lmer(avgReadingDuration ~ text + (1|id) , data= avgReadDur_select)

anova(avgReadDu_null, avgReadDu_1)

summary(avgReadDu_1)

avgReadDu_2 <- lmer(avgReadingDuration ~ text + condition + (1|id), data= avgReadDur_select)

anova(avgReadDu_1, avgReadDu_2)



avgReadDu_3 <- lmer(avgReadingDuration ~ text + condition + (1|id), data= avgReadDur_select)

anova(avgReadDu_1, avgReadDu_3)

avgReadDu_4 <- lmer(avgReadingDuration ~ text + condition + group + (1|id), data= avgReadDur_select)

anova(avgReadDu_3, avgReadDu_4)


avgReadDu_full <- lmer(avgReadingDuration ~ text + (1|id), data= avgReadDur_select)

avgReadDu_less <- lmer(avgReadingDuration ~ (1|id), data= avgReadDur_select)

anova(avgReadDu_full, avgReadDu_less)

## create table
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


## merge tables to final table for task 1 and 2
table_reading <- tbl_merge(
  tbls = list(percCQRes, avgReadDu),
  tab_spanner = c("**Percentage correct answers control questions**", "**Average reading duration per sentence**")) %>%
  modify_caption("**LMM Fixed Effects for the reading task**")

## save table
as_gt(table_reading) %>%
  gt::tab_source_note(gt::md("Mul = multilingual control group, TraPro = professional translators, TraStu = translation students")) %>%
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

rating_plot <- alldata_ext %>%
  filter(task == "Translating") %>%
  select(age, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U, fluency_meanRater, accuracy_meanRater)

#plot
filename <- file.path(figureFolder,"rating_plot")
png(filename,pointsize = 20,width=1000, height=600,units = "px")
ggpairs(rating_plot, title = "Variable rating", cardinality_threshold = NULL) + theme_bw()
dev.off()


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

summary(accuracy_2)

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
  gt::tab_source_note(gt::md("EdE = edited English, ELF = English as lingua franca, Mul = multilingual control group, TraPro = professional translators, TraStu = translation students")) %>%
  gt::gtsave(filename = file.path(figureFolder, "Statistics_translation_output.png"))




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





#### plot psychometrics and behavioral data ####

ggpairs_plot <- alldata_ext %>%
  mutate(percCharsErrors = charsErrors/charsTotal) %>%
  select(age, english_score,Aoa_E, HAWIE_T_Value, auditory_dprime, visual_dprime, cumTH_U, hpd_U, charsTotal, percCharsErrors, perceivedDifficulty, percCQRes, avgReadingDuration, fluency_meanRater, accuracy_meanRater)

#plot
filename <- file.path(figureFolder,"ggpairs_plot.png")
png(filename,pointsize = 20,width=1000, height=600,units = "px")
ggpairs(ggpairs_plot, title = "Variable psychometrics and behavioral data", cardinality_threshold = NULL) + theme_bw()
dev.off()
