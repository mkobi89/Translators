##########################################################
##            COLLECT PREPROCESSED DATA                 ##
##########################################################
## Description :: gathers all preprocessed data (EEG, DDM
##                and psychometrics) in long format
##                for further analysis
## Input :::::::: psychometrics (02_psychometrics.R)
##                .txt file for DDM parameters (05_DDM_parameter_estimation.R)
##                .txt files for Liesefeld parameters in data/erp
## Libraries :::: tidyverse
## Output ::::::: all_tasks.Rdata
##########################################################

## libraries
library(tidyverse)

## data path
FFTFolder    <- file.path("data/rawdata/fft")

## read FFT theta parameters----
#theta_11_15 <- read.table(paste(FFTFolder, "theta_avg_11_15_2.txt", sep = "/"), header = TRUE)

#theta_11_15_long <- pivot_longer(
#  theta_11_15,
#  2:841,
#  names_to = c("electrode","cond"),
#  names_sep = 4,
#  values_to = "theta"
#  )

#theta_11_15_long$File <- gsub("_all", "", theta_11_15_long$File)
#theta_11_15_long$electrode <- gsub("REF","999",theta_11_15_long$electrode)
#theta_11_15_long$electrode <- gsub("[^0-9-]","",theta_11_15_long$electrode)
#theta_11_15_long$electrode <- gsub("999","REF",theta_11_15_long$electrode)
#theta_11_15_long$cond <- gsub(".avg_", "", theta_11_15_long$cond)
#theta_11_15_long$cond <- gsub("avg_", "", theta_11_15_long$cond)
#theta_11_15_long$cond <- gsub("vg_", "", theta_11_15_long$cond)
#theta_11_15_long$cond <- gsub("_2", "", theta_11_15_long$cond)


#theta_11_15_ROI_frontal <- theta_11_15_long %>% 
#  group_by(File,cond) %>% 
#  filter(electrode == "24" | electrode == "19" | electrode == "11" | electrode == "4" | electrode == "124") %>% 
#  summarise(frontal_theta = mean(theta))

#theta_11_15_elec <- theta_11_15_long %>% 
#  group_by(electrode, cond) %>% 
#  summarise(mean_theta = mean(theta), sd_theta = sd(theta))%>% 
#  filter(electrode == "11")


#### read FFT theta reading task 5 min 11_15

theta_11_15_r5min <- read.table(paste(FFTFolder, "theta_avg_11_15_2_r5min.txt", sep = "/"), header = TRUE)

theta_11_15_r5min_long <- pivot_longer(
  theta_11_15_r5min,
  2:841,
  names_to = c("electrode","cond"),
  names_sep = 4,
  values_to = "theta"
)


theta_11_15_r5min_long$File <- gsub("_all_r5min", "", theta_11_15_r5min_long$File)
theta_11_15_r5min_long$electrode <- gsub("REF","999",theta_11_15_r5min_long$electrode)
theta_11_15_r5min_long$electrode <- gsub("[^0-9-]","",theta_11_15_r5min_long$electrode)
theta_11_15_r5min_long$electrode <- gsub("999","REF",theta_11_15_r5min_long$electrode)
theta_11_15_r5min_long$cond <- gsub(".avg_", "", theta_11_15_r5min_long$cond)
theta_11_15_r5min_long$cond <- gsub("avg_", "", theta_11_15_r5min_long$cond)
theta_11_15_r5min_long$cond <- gsub("vg_", "", theta_11_15_r5min_long$cond)
theta_11_15_r5min_long$cond <- gsub("_2", "", theta_11_15_r5min_long$cond)


theta_11_15_r5min_ROI_frontal <- theta_11_15_r5min_long %>% 
  group_by(File,cond) %>% 
  filter(electrode == "24" | electrode == "19" | electrode == "11" | electrode == "4" | electrode == "124") %>% 
  summarise(frontal_theta = mean(theta))




#alpha_11_15 <- read.table(paste(FFTFolder, "alpha_avg_11_15_2.txt", sep = "/"), header = TRUE)

#alpha_11_15_long <- pivot_longer(
#  alpha_11_15,
#  2:841,
#  names_to = c("electrode","cond"),
#  names_sep = 4,
#  values_to = "alpha"
#)

#alpha_11_15_long$File <- gsub("_all", "", alpha_11_15_long$File)
#alpha_11_15_long$electrode <- gsub("REF","999",alpha_11_15_long$electrode)
#alpha_11_15_long$electrode <- gsub("[^0-9-]","",alpha_11_15_long$electrode)
#alpha_11_15_long$electrode <- gsub("999","REF",alpha_11_15_long$electrode)
#alpha_11_15_long$cond <- gsub(".avg_", "", alpha_11_15_long$cond)
#alpha_11_15_long$cond <- gsub("avg_", "", alpha_11_15_long$cond)
#alpha_11_15_long$cond <- gsub("vg_", "", alpha_11_15_long$cond)
#alpha_11_15_long$cond <- gsub("_2", "", alpha_11_15_long$cond)


#### read FFT alpha reading task 5 min 11_15

alpha_11_15_r5min <- read.table(paste(FFTFolder, "alpha_avg_11_15_2_r5min.txt", sep = "/"), header = TRUE)

alpha_11_15_r5min_long <- pivot_longer(
  alpha_11_15_r5min,
  2:841,
  names_to = c("electrode","cond"),
  names_sep = 4,
  values_to = "alpha"
)

alpha_11_15_r5min_long$File <- gsub("_all_r5min", "", alpha_11_15_r5min_long$File)
alpha_11_15_r5min_long$electrode <- gsub("REF","999",alpha_11_15_r5min_long$electrode)
alpha_11_15_r5min_long$electrode <- gsub("[^0-9-]","",alpha_11_15_r5min_long$electrode)
alpha_11_15_r5min_long$electrode <- gsub("999","REF",alpha_11_15_r5min_long$electrode)
alpha_11_15_r5min_long$cond <- gsub(".avg_", "", alpha_11_15_r5min_long$cond)
alpha_11_15_r5min_long$cond <- gsub("avg_", "", alpha_11_15_r5min_long$cond)
alpha_11_15_r5min_long$cond <- gsub("vg_", "", alpha_11_15_r5min_long$cond)
alpha_11_15_r5min_long$cond <- gsub("_2", "", alpha_11_15_r5min_long$cond)


alpha_11_15_r5min_ROI_parietal <- alpha_11_15_r5min_long %>% 
  group_by(File,cond) %>% 
  filter(electrode == "52" | electrode == "61" | electrode == "62" | electrode == "78" | electrode == "92") %>% 
  summarise(parietal_alpha = mean(alpha))


#### merge 11_15

fft_11_15 <- full_join(theta_11_15_r5min_ROI_frontal, alpha_11_15_r5min_ROI_parietal)


for(i in 1:nrow(fft_11_15)){
  if(fft_11_15$cond[i] == "11_15"){
    fft_11_15$task[i] = "reading"
    fft_11_15$text[i] = "Text1"
    fft_11_15$condition[i] = "SE"
  }
  if(fft_11_15$cond[i] == "31_35"){
    fft_11_15$task[i] = "copying"
    fft_11_15$text[i] = "Text1"
    fft_11_15$condition[i] = "SE"
  }
  if(fft_11_15$cond[i] == "41_45"){
    fft_11_15$task[i] = "translating"
    fft_11_15$text[i] = "Text1"
    fft_11_15$condition[i] = "SE"
  }
  if(fft_11_15$cond[i] == "14_18"){
    fft_11_15$task[i] = "reading"
    fft_11_15$text[i] = "Text2"
    fft_11_15$condition[i] = "ELF"
  }
  if(fft_11_15$cond[i] == "34_38"){
    fft_11_15$task[i] = "copying"
    fft_11_15$text[i] = "Text2"
    fft_11_15$condition[i] = "ELF"
  }
  if(fft_11_15$cond[i] == "44_48"){
    fft_11_15$task[i] = "translating"
    fft_11_15$text[i] = "Text2"
    fft_11_15$condition[i] = "ELF"
  }
  if(fft_11_15$cond[i] == "72_76"){
    fft_11_15$task[i] = "reading_post"
    fft_11_15$text[i] = "Text1"
    fft_11_15$condition[i] = "ELF"
  }
  if(fft_11_15$cond[i] == "73_77"){
    fft_11_15$task[i] = "reading_post"
    fft_11_15$text[i] = "Text2"
    fft_11_15$condition[i] = "SE"
  }  
}

fft_11_15 <- fft_11_15 %>% 
  rename(id = File)


#### read FFT theta reading task 5 min 12 16 ----

theta_12_16_r5min <- read.table(paste(FFTFolder, "theta_avg_12_16_2_r5min.txt", sep = "/"), header = TRUE)


theta_12_16_r5min_long <- pivot_longer(
  theta_12_16_r5min,
  2:841,
  names_to = c("electrode","cond"),
  names_sep = 4,
  values_to = "theta"
)


theta_12_16_r5min_long$File <- gsub("_all_r5min", "", theta_12_16_r5min_long$File)
theta_12_16_r5min_long$electrode <- gsub("REF","999",theta_12_16_r5min_long$electrode)
theta_12_16_r5min_long$electrode <- gsub("[^0-9-]","",theta_12_16_r5min_long$electrode)
theta_12_16_r5min_long$electrode <- gsub("999","REF",theta_12_16_r5min_long$electrode)
theta_12_16_r5min_long$cond <- gsub(".avg_", "", theta_12_16_r5min_long$cond)
theta_12_16_r5min_long$cond <- gsub("avg_", "", theta_12_16_r5min_long$cond)
theta_12_16_r5min_long$cond <- gsub("vg_", "", theta_12_16_r5min_long$cond)
theta_12_16_r5min_long$cond <- gsub("_2", "", theta_12_16_r5min_long$cond)


theta_12_16_r5min_ROI_frontal <- theta_12_16_r5min_long %>% 
  group_by(File,cond) %>% 
  filter(electrode == "24" | electrode == "19" | electrode == "11" | electrode == "4" | electrode == "124") %>% 
  summarise(frontal_theta = mean(theta))


#### read FFT alpha reading task 5 min ----

alpha_12_16_r5min <- read.table(paste(FFTFolder, "alpha_avg_12_16_2_r5min.txt", sep = "/"), header = TRUE)

alpha_12_16_r5min_long <- pivot_longer(
  alpha_12_16_r5min,
  2:841,
  names_to = c("electrode","cond"),
  names_sep = 4,
  values_to = "alpha"
)

alpha_12_16_r5min_long$File <- gsub("_all_r5min", "", alpha_12_16_r5min_long$File)
alpha_12_16_r5min_long$electrode <- gsub("REF","999",alpha_12_16_r5min_long$electrode)
alpha_12_16_r5min_long$electrode <- gsub("[^0-9-]","",alpha_12_16_r5min_long$electrode)
alpha_12_16_r5min_long$electrode <- gsub("999","REF",alpha_12_16_r5min_long$electrode)
alpha_12_16_r5min_long$cond <- gsub(".avg_", "", alpha_12_16_r5min_long$cond)
alpha_12_16_r5min_long$cond <- gsub("avg_", "", alpha_12_16_r5min_long$cond)
alpha_12_16_r5min_long$cond <- gsub("vg_", "", alpha_12_16_r5min_long$cond)
alpha_12_16_r5min_long$cond <- gsub("_2", "", alpha_12_16_r5min_long$cond)


alpha_12_16_r5min_ROI_parietal <- alpha_12_16_r5min_long %>% 
  group_by(File,cond) %>% 
  filter(electrode == "52" | electrode == "61" | electrode == "62" | electrode == "78" | electrode == "92") %>% 
  summarise(parietal_alpha = mean(alpha))



fft_12_16 <- full_join(theta_12_16_r5min_ROI_frontal, alpha_12_16_r5min_ROI_parietal)


for(i in 1:nrow(fft_12_16)){
  if(fft_12_16$cond[i] == "12_16"){
    fft_12_16$task[i] = "reading"
    fft_12_16$text[i] = "Text1"
    fft_12_16$condition[i] = "ELF"
  }
  if(fft_12_16$cond[i] == "32_36"){
    fft_12_16$task[i] = "copying"
    fft_12_16$text[i] = "Text1"
    fft_12_16$condition[i] = "ELF"
  }
  if(fft_12_16$cond[i] == "42_46"){
    fft_12_16$task[i] = "translating"
    fft_12_16$text[i] = "Text1"
    fft_12_16$condition[i] = "ELF"
  }
  if(fft_12_16$cond[i] == "13_17"){
    fft_12_16$task[i] = "reading"
    fft_12_16$text[i] = "Text2"
    fft_12_16$condition[i] = "SE"
  }
  if(fft_12_16$cond[i] == "33_37"){
    fft_12_16$task[i] = "copying"
    fft_12_16$text[i] = "Text2"
    fft_12_16$condition[i] = "SE"
  }
  if(fft_12_16$cond[i] == "43_47"){
    fft_12_16$task[i] = "translating"
    fft_12_16$text[i] = "Text2"
    fft_12_16$condition[i] = "SE"
  }
  if(fft_12_16$cond[i] == "71_75"){
    fft_12_16$task[i] = "reading_post"
    fft_12_16$text[i] = "Text1"
    fft_12_16$condition[i] = "SE"
  }
  if(fft_12_16$cond[i] == "74_78"){
    fft_12_16$task[i] = "reading_post"
    fft_12_16$text[i] = "Text2"
    fft_12_16$condition[i] = "ELF"
  }  
}

fft_12_16 <- fft_12_16 %>% 
  rename(id = File)


## join datasets
fft <- full_join(fft_11_15,fft_12_16)

## arrange variables

fft <- fft %>% 
  select(1,2,5,6,7,3,4)

fft$id <- as.factor(fft$id)

## clean workspace
remove(i, FFTFolder, alpha_11_15_r5min, alpha_11_15_r5min_long, alpha_11_15_r5min_ROI_parietal, alpha_12_16_r5min, alpha_12_16_r5min_long, alpha_12_16_r5min_ROI_parietal, theta_11_15_r5min, theta_11_15_r5min_long, theta_11_15_r5min_ROI_frontal, theta_12_16_r5min, theta_12_16_r5min_long, theta_12_16_r5min_ROI_frontal, fft_11_15,fft_12_16)
