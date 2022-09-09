###########################################################
##                            FFT                        ##
##                    data preprocessing                 ##
###########################################################
## Description :: gathers all EEG FFT data 
## Input :::::::: theta_11_15.txt, theta_12_16.txt, 
##                alpha_11_15.txt, alpha_12_16.txt
## Libraries :::: tidyverse
## Output ::::::: fft
###########################################################

## libraries
library(tidyverse)

## data path
FFTFolder    <- file.path("data/rawdata/fft")

# read FFT theta 11_15 (abstract randomization 1)
theta_11_15 <- read.table(paste(FFTFolder, "theta_11_15.txt", sep = "/"), header = TRUE)

# convert to long format
theta_11_15_long <- pivot_longer(
  theta_11_15,
  2:825,
  names_to = c("electrode","cond"),
  names_sep = 4,
  values_to = "theta"
)

# remove unwanted chars in dataframe
theta_11_15_long$File <- gsub("_all_eog", "", theta_11_15_long$File)
theta_11_15_long$electrode <- gsub("Cz","999",theta_11_15_long$electrode)
theta_11_15_long$electrode <- gsub("[^0-9-]","",theta_11_15_long$electrode)
theta_11_15_long$electrode <- gsub("999","Cz",theta_11_15_long$electrode)
theta_11_15_long$cond <- gsub(".avg_", "", theta_11_15_long$cond)
theta_11_15_long$cond <- gsub("avg_", "", theta_11_15_long$cond)
theta_11_15_long$cond <- gsub("vg_", "", theta_11_15_long$cond)
theta_11_15_long$cond <- gsub("_2", "", theta_11_15_long$cond)

# calculate mean of 8 frontal electrodes as frontal theta
theta_11_15_ROI_frontal <- theta_11_15_long %>% 
  group_by(File,cond) %>% 
  filter(electrode == "4" | electrode == "5" | electrode == "10" | electrode == "11" | electrode == "12" | electrode == "16" | electrode == "18" | electrode == "19") %>% 
  summarise(frontal_theta = mean(theta))

# read FFT alpha 11_15 (abstract randomization 1)
alpha_11_15 <- read.table(paste(FFTFolder, "alpha_11_15.txt", sep = "/"), header = TRUE)

# convert to long format
alpha_11_15_long <- pivot_longer(
  alpha_11_15,
  2:825,
  names_to = c("electrode","cond"),
  names_sep = 4,
  values_to = "alpha"
)

# remove unwanted chars in dataframe
alpha_11_15_long$File <- gsub("_all_eog", "", alpha_11_15_long$File)
alpha_11_15_long$electrode <- gsub("Cz","999",alpha_11_15_long$electrode)
alpha_11_15_long$electrode <- gsub("[^0-9-]","",alpha_11_15_long$electrode)
alpha_11_15_long$electrode <- gsub("999","Cz",alpha_11_15_long$electrode)
alpha_11_15_long$cond <- gsub(".avg_", "", alpha_11_15_long$cond)
alpha_11_15_long$cond <- gsub("avg_", "", alpha_11_15_long$cond)
alpha_11_15_long$cond <- gsub("vg_", "", alpha_11_15_long$cond)
alpha_11_15_long$cond <- gsub("_2", "", alpha_11_15_long$cond)

# calculate mean of 6 frontal electrodes as parietal alpha
alpha_11_15_ROI_parietal <- alpha_11_15_long %>% 
  group_by(File,cond) %>% 
  filter(electrode == "61" | electrode == "62" | electrode == "67" | electrode == "72" | electrode == "76" | electrode == "78") %>% 
  summarise(parietal_alpha = mean(alpha))


# merge theta and alpha and convert to long format for different conditions

fft_11_15 <- full_join(theta_11_15_ROI_frontal, alpha_11_15_ROI_parietal)

for(i in 1:nrow(fft_11_15)){
  if(fft_11_15$cond[i] == "11_15"){
    fft_11_15$task[i] = "Reading"
    fft_11_15$text[i] = "Text1"
    fft_11_15$condition[i] = "EdE"
  }
  if(fft_11_15$cond[i] == "31_35"){
    fft_11_15$task[i] = "Copying"
    fft_11_15$text[i] = "Text1"
    fft_11_15$condition[i] = "EdE"
  }
  if(fft_11_15$cond[i] == "41_45"){
    fft_11_15$task[i] = "Translating"
    fft_11_15$text[i] = "Text1"
    fft_11_15$condition[i] = "EdE"
  }
  if(fft_11_15$cond[i] == "14_18"){
    fft_11_15$task[i] = "Reading"
    fft_11_15$text[i] = "Text2"
    fft_11_15$condition[i] = "ELF"
  }
  if(fft_11_15$cond[i] == "34_38"){
    fft_11_15$task[i] = "Copying"
    fft_11_15$text[i] = "Text2"
    fft_11_15$condition[i] = "ELF"
  }
  if(fft_11_15$cond[i] == "44_48"){
    fft_11_15$task[i] = "Translating"
    fft_11_15$text[i] = "Text2"
    fft_11_15$condition[i] = "ELF"
  }
  if(fft_11_15$cond[i] == "72_76"){
    fft_11_15$task[i] = "Reading_post"
    fft_11_15$text[i] = "Text1"
    fft_11_15$condition[i] = "ELF"
  }
  if(fft_11_15$cond[i] == "73_77"){
    fft_11_15$task[i] = "Reading_post"
    fft_11_15$text[i] = "Text2"
    fft_11_15$condition[i] = "EdE"
  }  
}

fft_11_15 <- fft_11_15 %>% 
  rename(id = File)


# read FFT theta 12_16 (abstract randomization 2)
theta_12_16 <- read.table(paste(FFTFolder, "theta_12_16.txt", sep = "/"), header = TRUE)

# convert to long format
theta_12_16_long <- pivot_longer(
  theta_12_16,
  2:825,
  names_to = c("electrode","cond"),
  names_sep = 4,
  values_to = "theta"
)

# remove unwanted chars in dataframe
theta_12_16_long$File <- gsub("_all_eog", "", theta_12_16_long$File)
theta_12_16_long$electrode <- gsub("Cz","999",theta_12_16_long$electrode)
theta_12_16_long$electrode <- gsub("[^0-9-]","",theta_12_16_long$electrode)
theta_12_16_long$electrode <- gsub("999","Cz",theta_12_16_long$electrode)
theta_12_16_long$cond <- gsub(".avg_", "", theta_12_16_long$cond)
theta_12_16_long$cond <- gsub("avg_", "", theta_12_16_long$cond)
theta_12_16_long$cond <- gsub("vg_", "", theta_12_16_long$cond)
theta_12_16_long$cond <- gsub("_2", "", theta_12_16_long$cond)

# calculate mean of 8 frontal electrodes as frontal theta
theta_12_16_ROI_frontal <- theta_12_16_long %>% 
  group_by(File,cond) %>% 
  filter(electrode == "4" | electrode == "5" | electrode == "10" | electrode == "11" | electrode == "12" | electrode == "16" | electrode == "18" | electrode == "19") %>% 
  summarise(frontal_theta = mean(theta))


# read FFT alpha 12_16 (abstract randomization 2)
alpha_12_16 <- read.table(paste(FFTFolder, "alpha_12_16.txt", sep = "/"), header = TRUE)

# convert to long format
alpha_12_16_long <- pivot_longer(
  alpha_12_16,
  2:825,
  names_to = c("electrode","cond"),
  names_sep = 4,
  values_to = "alpha"
)

# remove unwanted chars in dataframe
alpha_12_16_long$File <- gsub("_all_eog", "", alpha_12_16_long$File)
alpha_12_16_long$electrode <- gsub("Cz","999",alpha_12_16_long$electrode)
alpha_12_16_long$electrode <- gsub("[^0-9-]","",alpha_12_16_long$electrode)
alpha_12_16_long$electrode <- gsub("999","Cz",alpha_12_16_long$electrode)
alpha_12_16_long$cond <- gsub(".avg_", "", alpha_12_16_long$cond)
alpha_12_16_long$cond <- gsub("avg_", "", alpha_12_16_long$cond)
alpha_12_16_long$cond <- gsub("vg_", "", alpha_12_16_long$cond)
alpha_12_16_long$cond <- gsub("_2", "", alpha_12_16_long$cond)

# calculate mean of 6 frontal electrodes as parietal alpha
alpha_12_16_ROI_parietal <- alpha_12_16_long %>% 
  group_by(File,cond) %>% 
  filter(electrode == "61" | electrode == "62" | electrode == "67" | electrode == "72" | electrode == "77" | electrode == "78") %>%   summarise(parietal_alpha = mean(alpha))

# merge theta and alpha and convert to long format for different conditions
fft_12_16 <- full_join(theta_12_16_ROI_frontal, alpha_12_16_ROI_parietal)

for(i in 1:nrow(fft_12_16)){
  if(fft_12_16$cond[i] == "12_16"){
    fft_12_16$task[i] = "Reading"
    fft_12_16$text[i] = "Text1"
    fft_12_16$condition[i] = "ELF"
  }
  if(fft_12_16$cond[i] == "32_36"){
    fft_12_16$task[i] = "Copying"
    fft_12_16$text[i] = "Text1"
    fft_12_16$condition[i] = "ELF"
  }
  if(fft_12_16$cond[i] == "42_46"){
    fft_12_16$task[i] = "Translating"
    fft_12_16$text[i] = "Text1"
    fft_12_16$condition[i] = "ELF"
  }
  if(fft_12_16$cond[i] == "13_17"){
    fft_12_16$task[i] = "Reading"
    fft_12_16$text[i] = "Text2"
    fft_12_16$condition[i] = "EdE"
  }
  if(fft_12_16$cond[i] == "33_37"){
    fft_12_16$task[i] = "Copying"
    fft_12_16$text[i] = "Text2"
    fft_12_16$condition[i] = "EdE"
  }
  if(fft_12_16$cond[i] == "43_47"){
    fft_12_16$task[i] = "Translating"
    fft_12_16$text[i] = "Text2"
    fft_12_16$condition[i] = "EdE"
  }
  if(fft_12_16$cond[i] == "71_75"){
    fft_12_16$task[i] = "Reading_post"
    fft_12_16$text[i] = "Text1"
    fft_12_16$condition[i] = "EdE"
  }
  if(fft_12_16$cond[i] == "74_78"){
    fft_12_16$task[i] = "Reading_post"
    fft_12_16$text[i] = "Text2"
    fft_12_16$condition[i] = "ELF"
  }  
}

fft_12_16 <- fft_12_16 %>% 
  rename(id = File)


# join datasets for both abstract randomisations
fft <- full_join(fft_11_15,fft_12_16)

# rearrange variables
fft <- fft %>% 
  select(1,2,5,6,7,3,4)

# redefine factor
fft$id <- as.factor(fft$id)

## clean workspace
remove(i, FFTFolder, alpha_11_15, alpha_11_15_long, alpha_11_15_ROI_parietal, alpha_12_16, alpha_12_16_long, alpha_12_16_ROI_parietal, theta_11_15, theta_11_15_long, theta_11_15_ROI_frontal, theta_12_16, theta_12_16_long, theta_12_16_ROI_frontal, fft_11_15,fft_12_16)
