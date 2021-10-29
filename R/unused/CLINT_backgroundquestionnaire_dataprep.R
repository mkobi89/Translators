# ##############################################################################.
#
#      CLINT background questionnaire -- data preparation
#      Author: Laura Keller/gies
#      Version: 26.03.19
#
# ##############################################################################. 

# This script allows for the LimeSurvey "Hintergrundfragebogen" output to be brought into a shape 
#that facilitates data analysis. It will generate one file with qualitative dataand descriptions, 
#three files (one for each group) with more quantitative data

# Clean up your R workspace if needed

rm(list = ls(all = TRUE))


# Load libraries (others can be added)
packages<-c("ggplot2", "plyr", "dplyr","readxl", "tm")
lapply(packages, require, character.only = TRUE)

# To check which libraries are loaded, run

sessionInfo()

#run functions
collapse_rows<-function(x, df){
  l<-apply(df[x], 1, paste, collapse=" ")
  l<-gsub("NA", "", l)
  l<-gsub(" ", " ", l)
  return(l)
}


collapse_colnames<-function(col, df){
  code<-c()
  for(i in 1:nrow(df)){
    row<-df[i, col]
    #print(row)
    code_seq<-apply(row, 1, function(x){
      ifelse(x>0, names(row), NA)
    })
    #print(code_seq)
    l<-paste(code_seq, collapse=" ")
    #print(l)
    l<-gsub("NA", "", l)
    l<-trimws(l)
    print(l)
    code[i]<-l
    #print(code)
  }
  return(code)
}

#functionto retrieve onlyfirst element in string
fun<-function(x){s<-lapply(x, strsplit, " ")
l<-sapply(s, "[[", 1)
l<-lapply(l, function(x){ifelse(identical(x, character(0)), is.na(x), x<-x)})
return(l)}

# ###########LOAD DATA 

#set working directory (if you work from VPN, establish connection and first navigate to shared$)
setwd("S:/pools/l/L-IUED-CLINT-data/Lime Survey Exporte")
#load most recent file (but searches only on upper level!)
filelist<-file.info(list.files("S:/pools/l/L-IUED-CLINT-data/Lime Survey Exporte", pattern=".csv", full.names = T))
filename<-rownames(filelist)[which.max(filelist$mtime)]

#pandemia code:
#filename<-"C:/Users/gies/Desktop/R Skripte und workspaces/hintergrund.csv"
#setwd("C:/Users/gies/Desktop/R Skripte und workspaces/Hintergrund")

# read most recent file = hintergrund but without the last columns. THese columns only indicate time on survey
hintergrund = read.csv(filename, header = TRUE, sep = ";", na.strings="", encoding="UTF-8")[,1:258]
#if it doesn't work specifiy filename
#hintergrund = read.csv("20200219_Hintergrund2.csv", header = TRUE, sep = ";")[,1:258]

#import column names for the hintergrund tabel 
col_hintergrund<-read_excel("S:/pools/l/L-IUED-CLINT-data/Lime Survey Exporte/info/colnames.xlsx")[1:258,]
#import participant table for matching
library(readxl)
participants<-read_excel("S:/pools/l/L-IUED-CLINT-data/Lime Survey Exporte/info/participants.xlsx")

#reset working directory to save files in the correct palce
setwd("S:/pools/l/L-IUED-CLINT-analysis/Hintergrund/output")

#double save the file for security
hintergrund1<-hintergrund
hintergrund<-hintergrund1

#save working space
save.image(paste(format(Sys.time(), "%Y_%b_%d"),"_hintergrund_","1.RData"))

##########PUT SOME ORDER INTO DATA
###### rename columns. Columns should always be in same order. 
colnames(hintergrund)<-col_hintergrund$name


###### delete empty rows and tests (they do not respond to the format) and participants that have not been here yet (not exactly 2 digits)
#delete empty rows (rows where participant_code is empty). THere are certainly more double entries. They will be deleted later in the process
hintergrund<-hintergrund[!(is.na(hintergrund$participant_code)|hintergrund$participant_code==""),]

#eliminating first trailing and leading white spaces as source of error
trimws(hintergrund$participant_code)

#eliminate all rows where participant_code is not composed of exactly 3 letters and 4 digits (they are tests). Set participant code to capital letters
hintergrund$participant_code<-as.character(hintergrund$participant_code)
for (i in 1: nrow(hintergrund)){
  code<-hintergrund$participant_code[i]
  if (grepl("^[a-zA-Z]{3}[0-9]{4}$", code)){
    print(paste(i, " ok"))
    code<-toupper(code)
    hintergrund$participant_code[i]<-code}
  
  else{
    print(i)
    print("other")
    hintergrund<-hintergrund[-i,]
  }
}

rownames(hintergrund)<-c(1:nrow(hintergrund))
unique(hintergrund$participant_code)
#save copy
hintergrund2<-hintergrund
hintergrund<-hintergrund2

#####----------------rename variable levels for those with answer codes
#first select whether you exported the data with answer codes or as full answers
answer<-"answer_full" #otherwise "answer_code
profile_levels<-levels(hintergrund$profile)
gender_levels<-levels(hintergrund$gender)
education_levels<-levels(hintergrund$education_level)

###profile, gender and education
if(answer=="answer_full"){
  hintergrund$profile<-mapvalues(hintergrund$profile, from=profile_levels,
                                 to=c("IntPro", "TraPro", "Mul", "TraBA", "IntBA", "TraMA", "IntMA"))
  
  hintergrund$gender<-mapvalues(hintergrund$gender, from=gender_levels,
                                to=c("divers", "kA", "male", "female"))
  hintergrund$education_level<-mapvalues(hintergrund$education_level, from=education_levels,
                                         to=c("BABsc","vocational training","MAMsc", "high school", "phdDrphil", "other")) 
}else{
  hintergrund$profile<-mapvalues(hintergrund$profile, from=c("A1", "A2", "A3", "A4", "A5", "A6", "A7"),
                                 to=c("IntBA", "TraBA", "TraMA", "IntMA", "TraPro", "IntPro", "Mul"))
  
  hintergrund$gender<-mapvalues(hintergrund$gender, from=c("A1", "A2", "A3", "A4"),
                                to=c("female", "male", "divers", "kA"))
  hintergrund$education_level<-mapvalues(hintergrund$education_level, from=c("", "-oth-","A1", "A2", "A3", "A4", "A5"),
                                         to=c(NA, "other", "divers", "vocational training", "BABsc", "MAMsc", "phdDrphil")) 
}


#education_domain should remain, education_level_divmay not be necessary, but output later to file for qualitative data
qData<-hintergrund[,c("participant_code", "profile", "gender", "education_level", "education_level_div", "education_domain")]
#####languages
language_column<-c("l1_stud", "l3_stud", "l2_stud", "l1_tra", "l2_tra", "l3_tra", "l1_int", "l2_int", "l3_int")

#create a column number of languages for each participant
#turn all entries into small letters(works)
hintergrund[language_column]<-sapply(hintergrund[language_column], tolower)

hintergrund3<-hintergrund
hintergrund<-hintergrund3

#collapse l1, l2 and l3 for each group and
#add collapsed columns to hintergrund. Mul did not gave l1, l2 or l3! THese fields can be empty and it's normal
l1_col<-c("l1_stud", "l1_int", "l1_tra")
hintergrund$lang_a<-collapse_rows(l1_col, hintergrund)
l2_col<-c("l2_stud", "l2_int", "l2_tra")
hintergrund$lang_b<-collapse_rows(l2_col, hintergrund)
l3_col<-c("l3_stud", "l3_int", "l3_tra")
hintergrund$lang_c<-collapse_rows(l3_col, hintergrund)
#add these columns to our qData file
qData$lang_a<-hintergrund$lang_a
qData$lang_b<-hintergrund$lang_b
qData$lang_c<-hintergrund$lang_c

#work on the newly createdcolumns to simplify them
language_column<-c("lang_a", "lang_b","lang_c")
#remove "keine" as language: replace by +
hintergrund[language_column]<-data.frame(lapply(hintergrund[language_column], function(x){gsub("keine", "+", x)}), stringsAsFactors=F)
#replace in all language columns +, ; with space (works), 

#removetrailing spaces
hintergrund[language_column]<-sapply(hintergrund[language_column], trimws)
#remove all punctuation
hintergrund[language_column]<-sapply(hintergrund[language_column], removePunctuation)

#now loop through rows and columns and add a column total_lan_number with the total number of different languages per person
#length(row)=9
hintergrund$total_lang_n<-c()
for(i in 1:nrow(hintergrund)){
  print(paste("participant ", i))
  row<-hintergrund[i, language_column]
  words<-list()
  for(j in 1:length(row)){
    w<-list()
    w<-strsplit(row[[j]], " ")
    words[[j]]<-w
      if(j==length(row)){
        words<-unlist(words)
        words<-unique(words)
        lan_number<-length(words)
        print(paste("languages: ", words, " language number: ", lan_number))
        print("fertig")
        hintergrund$total_lang_n[i]<-lan_number
      }
  }
}


# #give all languages the same names. If several languages are names, only the first one counts
# #means: delete all languages after the first one. Problem: regex does not work with UTF-8
#deprecated: english always needs to be there and is not necessarily the first item!
# 
# for (i in 1:nrow(hintergrund)){
#   row<-hintergrund[i, language_column]
#   r<-fun(row)
#   row<-do.call("cbind", fun(row))
#   hintergrund[i, language_column]<-row
# }


#our main languages need to take similar values. It gives a warning whenever specific values are not present in a row
for(i in 1:nrow(hintergrund)){
  row<-hintergrund[i, language_column]
  print(row)
  for(j in 1:length(row)){
    initial_languages<-row[j]
    if(grepl(" ", initial_languages)==T){
      initial_languages<-c(strsplit(initial_languages[[1]], " "))
    }else{
      initial_languages<-initial_languages
    }
    print(initial_languages)
    new_languages<-sapply(initial_languages, mapvalues,
           from=c("englisch", "en", "e",
                  "deutsch", "de","d", 
                  "französisch", "fr","f", 
                  "italienisch", "it", "ital",
                  "chinesisch", "zh"),
           to=c(rep("english", 3),
                rep("german", 3),
                rep("french", 3),
                rep("italien", 3),
                rep("chinese", 2)))
    new_languages<-paste(new_languages, collapse=" ")
    print(new_languages)
    row[j]<-paste(new_languages)
  }
  hintergrund[i, language_column]<-row
}

#get the total variety of other languages (besides our main languages)
#here get unique values for a, b and c-language
all_languages<-unlist(unique(sapply(hintergrund[language_column], unique), use.names=F))
#some a double values. split double values and retrieve unique values
all_languages<-unique(unlist(unique(sapply(all_languages, strsplit, " "))))

#if other languages should be set to other
languages<-c("english", "german", "french", "italien", "chinese", NA)
other_languages<-setdiff(all_languages,languages)
for(i in 1:nrow(hintergrund)){
  print(i)
  row<-hintergrund[i, language_column]
  for(j in 1:length(row)){
    w<-row[j]
    word<-unlist(strsplit(w[[1]], " "))
    for(k in 1:length(word)){
      print(k)
      wo<-word[k]
      print(wo)
      wo<-ifelse(wo%in%other_languages, wo<-"other", wo<-wo)
      print(wo)
      word[k]<-wo
    }
    print(word)
    words<-paste(unlist(word), collapse=" ")
    print(words)
    row[j]<-words
  }
  hintergrund[i, language_column]<-row
}


#there are some rows that have only empty values. Do some sanity checks
hintergrund$group[is.na(hintergrund$lang_a)]

#now we can delete languages that do not correspond to our selection criteria. Full list is still there (qData)
#german should be included in a-language, if not, needs manual checking
for(i in 1:length(hintergrund$lang_a)){
  a<-hintergrund$lang_a[i]
  a<-ifelse(grepl("german", a)==T, "german", "CHECK")
  hintergrund$lang_a[i]<-a
}
hintergrund$lang_a<-factor(hintergrund$lang_a)

#english should be in or c (if english is indicated) to prove all participants had english in der combination
#if no english, keep first language
#this
for(i in 1:length(hintergrund$lang_b)){
  b<-hintergrund$lang_b[i]
  if(grepl("english", b)){
    b<-"english"
  }else{
    b<-unlist(strsplit(b, " "))[1]
  }
  hintergrund$lang_b[i]<-b
}
hintergrund$lang_b<-factor(hintergrund$lang_b)
levels(hintergrund$lang_b)

#how many have english as their b? Attention: Muls still included!
ftable(hintergrund$lang_b)

#same for c with one more condition: only english of english included and b is not english
for(i in 1:length(hintergrund$lang_c)){
  c<-hintergrund$lang_c[i]
  if(grepl("english", c)&& hintergrund$lang_b[i]!="english"){
    c<-"english"
  }else{
    c<-unlist(strsplit(c, " "))[1]
  }
  hintergrund$lang_c[i]<-c
}
hintergrund$lang_c<-factor(hintergrund$lang_c)
levels(hintergrund$lang_c)
ftable(hintergrund$lang_c)

#check levels
sapply(hintergrund[language_column], unique)
hintergrund[language_column]

#delete some columns
cols<-c(l1_col, l2_col, l3_col, c("submitdate", "lastpage", "language_survey", "seed", "startdate", 
                                  "welcome", "welcome_group_time", "general_comment", 
                                  "education_domain", "education_level_div", "gender_spec"))
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

hintergrund4<-hintergrund
hintergrund<-hintergrund4
save.image(paste(format(Sys.time(), "%Y_%b_%d"),"_hintergrund_","2.RData"))

#####employement and experience
#years_employment, years_experience and percentage_work_tra, percentage of activity do not need any treatment
#percentage activity and tra_pract is important for tra and int but not mul

if(answer=="answer_full"){
  hintergrund$exp_stud<-mapvalues(hintergrund$exp_stud, from=c("Ja", "Nein", "N/A"),
                                  to=c("yes", "no", NA))
  
  hintergrund$employment<-mapvalues(hintergrund$employment, from=c("Freelancer/in", "Festangestellte/r", "Sonstiges", ""),
                                    to=c("freelance","employed", "other", NA))
  #somehow it seems that excel converted 1-20 to january 2020!
  hintergrund$days_int<-mapvalues(hintergrund$days_int, from=c("Jan 20", "21-40", "41-60", "61-80", "81-100", "101+", ""),
                                  to=c("1-20", "21-40", "41-60", "61-80", "81-100", "+101", NA))
  hintergrund$client_type<-mapvalues(hintergrund$client_type, from=c("Privatmarkt/Privatwirtschaft"  , "Öffentliche Institutionen & Internationale Organisationen", "Sonstiges", ""), 
                                     to=c("private", "institution", "other", NA))
}else{
  hintergrund$exp_stud<-mapvalues(hintergrund$exp_stud, from=c(2,1,NA),
                                  to=c("yes", "no", NA))
  
  hintergrund$employment<-mapvalues(hintergrund$employment, from=c("A1", "A2", "-oth-", ""),
                                    to=c("freelance","employed", "other", NA))
  
  hintergrund$days_int<-mapvalues(hintergrund$days_int, from=c("A1", "A2", "A3", "A4", "A5", "A6", ""),
                                  to=c("1-20", "21-40", "41-60", "61-80", "81-100", "+101", NA))
  hintergrund$client_type<-mapvalues(hintergrund$client_type, from=c("A1", "A2", "-oth-", ""), 
                                     to=c("private", "institution", "other", NA))
}

#classes are already correct here.
# for checking, use unique for numerical variables or level for categorical ones

cols<-c("client_type", "days_int", "exp_stud", "employment")
sapply(hintergrund[cols], levels)


#paste qualitative data zu qData file
qData$descr_activity_stud<-hintergrund$descr_activity_stud
qData$employment<-hintergrund$employment
qData$employment_details<-hintergrund$employment_div
qData$client<-hintergrund$client_type
qData$client_details<-hintergrund$client_type_div
qData$descr_activity<-hintergrund$descr_activity_all
qData$exp_work_other_domain<-hintergrund$exp_work_other_domain
qData$exp_work_comment<-hintergrund$exp_work_comment


#save copies
hintergrund5<-hintergrund
hintergrund<-hintergrund5
save.image(paste(format(Sys.time(), "%Y_%b_%d"),"_hintergrund_","5.RData"))

#delete unnecessary columns
cols<-c("employment_div", "descr_activity_stud", "descr_activity_tra", "client_type_div", 
        "exp_work_other_domain", "exp_work_comment")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

####generate an avarage over years for tra_practise and keep also the current value
practice_columns<-c("tra_pract_17", "tra_pract_20", "tra_pract_23", "tra_pract_26", "tra_pract_29", "tra_pract_32",
                    "tra_pract_35", "tra_pract_38", "tra_pract_41", "tra_pract_44", "tra_pract_47", "tra_pract_50",
                    "tra_pract_53", "tra_pract_56", "tra_pract_59", "tra_pract_62", "tra_pract_65")

#first clean data: get rid of all characters and punctuation marks
hintergrund[practice_columns]<-sapply(hintergrund[practice_columns], as.character)
#first replace comma by dots(other wise we don't get half hours)
hintergrund[practice_columns]<-sapply(hintergrund[practice_columns], function(x){gsub("\\,", ".", x) })
hintergrund[practice_columns]<-sapply(hintergrund[practice_columns], function(x){gsub("[^0-9\\.]", "", x) })
#check values. There is a mysterious 0.01 value, but it appears to be correct....
sapply(hintergrund[practice_columns], unique)

#set as numeric. Empty values are automatically set to NA. How convenient.
hintergrund[practice_columns]<-sapply(hintergrund[practice_columns],as.numeric)

#now we can calculate an average and retrieve the current value. But there are a bunch of problems:
#not everybody filled in the first fields..
#The current value depends on age. There are no NA is age. To retrieve the current value,
#we need to retrieve the value in the corresponding column. The number in the column name gives the start age
#first set values in columns before age to 0
average<-c()
current_value<-c()

for(i in 1:nrow(hintergrund)){
  age<-hintergrund$age[i]
  if(is.na(age)){
    average[i]<-NA
    current_value[i]<-NA
    next
  }else{
    age<-hintergrund$age[i]
    row<-hintergrund[i,]
    if(age<20){
      col<-"tra_pract_17"
    }else if(age<23){
      col<-"tra_pract_20"
    }else if(age<26){
      col<-"tra_pract_23"
    }else if(age<29){
      col<-"tra_pract_26"
    }else if(age<32){
      col<-"tra_pract_29"
    }else if(age<35){
      col<-"tra_pract_32"
    }else if(age<38){
      col<-"tra_pract_35"
    }else if(age<41){
      col<-"tra_pract_38"
    }else if(age<44){
      col<-"tra_pract_41"
    }else if(age<47){
      col<-"tra_pract_44"
    }else if(age<50){
      col<-"tra_pract_47"
    }else if(age<53){
      col<-"tra_pract_50"
    }else if(age<56){
      col<-"tra_pract_53"
    }else if(age<59){
      col<-"tra_pract_56"
    }else if(age<62){
      col<-"tra_pract_59"
    }else if(age<65){
      col<-"tra_pract_62"
    }else if(age>=65){
      col<-"tra_pract_65"
    }else{col<-NA}
    print(age)
    print(col)
    #retrieve current value
    current_value[i]<-hintergrund[i, col]
    #number of columns for average
    ncol<-which(practice_columns==col)
    cols<-practice_columns[1:ncol]
    #set values before age to 0 if NA
    row[cols]<-sapply(row[cols], function(x){ifelse(is.na(x), 0, x)})
    average[i]<-median(unlist(row[cols]), na.rm=T)
  }
  
}
hintergrund$pract_current<-current_value
hintergrund$pract_mean<-average

#save copy
hintergrund6<-hintergrund
hintergrund<-hintergrund6

#delete unnecessary columns
cols<-c(practice_columns)
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

########linguistic background -German
#keep rows lan_zh, lan_de, lan_fr, lan_en, lan_it: collapsing not reasonable, easiest way to find out whether people 
#speak Chinese, English, German, Italien or French. But collapse rows for qData
lan_spoken<-collapse_colnames(c("lan_zh","lan_de", "lan_en", "lan_fr", "lan_it"), hintergrund)
#now delete lan_
lan_spoken<-gsub("lan_", "", lan_spoken)
qData$lan_spoken<-lan_spoken

#delete row lan_other (double info)
#copy rows lan_supp_1...la_supp_6 to qData
cols<-c("lan_supp_1_id",
        "lan_supp_1_age",
        "lan_supp_1_use",
        "lan_supp_1_exposition",
        "lan_supp_2_id",
        "lan_supp_2_age",
        "lan_supp_2_use",
        "lan_supp_2_exposition",
        "lan_supp_3_id",
        "lan_supp_3_age",
        "lan_supp_3_use",
        "lan_supp_3_exposition",
        "lan_supp_4_id",
        "lan_supp_4_age",
        "lan_supp_4_use",
        "lan_supp_4_exposition",
        "lan_supp_5_id",
        "lan_supp_5_age",
        "lan_supp_5_use",
        "lan_supp_5_exposition",
        "lan_supp_6_id",
        "lan_supp_6_age",
        "lan_supp_6_use",
        "lan_supp_6_exposition"
)
qData[cols]<-hintergrund[cols]
#delete cols
cols<-c(cols, "lan_other")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

#####------German
#there are some NA in all profiles. Not clear why as question was mandatory...
hintergrund$profile[which(is.na(hintergrund$de_age_acquisition))]
na<-hintergrund$participant_code[which(is.na(hintergrund$de_age_acquisition))]
#"RAE0333" "RWG0209" "KWH0500" "NPN0933" "HMF0122" "AWS0158" "RZM0604" "KFS0603" "NNB0585"
#check if corona
na%in%participants$code[participants$corona=="ja"]
#concerns only the last ones.

#collapse and put to qData
cols<-c("de_acquisition_family",
        "de_acquisition_school",
        "de_acquisition_cursus",
        "de_acquisition_friends",
        "de_acquisition_tandam",
        "de_acquisition_family_abroad",
        "de_acquisition_aupair",
        "de_acquisition_language_abroad",
        "de_acquisition_work_abroad",
        "de_acquisition_study_abroad",
        "de_acquisition_other"
)

de_acquisition_how<-collapse_colnames(cols, hintergrund)
#delete "de_acquisition_"
de_acquisition_how<-gsub("de_acquisition_", "", de_acquisition_how)
qData$de_acquistion_how<-de_acquisition_how

#does it make sense to keep those rows?Let's say no
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

#keep de_use_day, but adapt levels
if(answer=="answer_full"){
  hintergrund$de_use_day<-mapvalues(hintergrund$de_use_day, from=c("täglich", "oft", "manchmal", "selten", "Sonstiges:"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}else{
  hintergrund$de_use_day<-mapvalues(hintergrund$de_use_day, from=c("A1", "A2", "A3", "A4", "-oth-"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}


#copy comment to qData
qData$de_use_comment<-hintergrund$de_use_comment

#keep de_expo_hours and de_speak_hours, de_write_hours, de_listen_hours, de_read_hours
#copy de_expo_comment to qData
qData$de_expo_comment<-hintergrund$de_expo_comment

#delete rows that convey doubled information
cols<-c("de_use_comment", "de_use_read", "de_use_write", "de_use_listen", "de_use_speak", "de_expo_comment")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

#####-----------english
#there are some NA in all profiles. Not clear why as question was mandatory...
hintergrund$participant_code[which(is.na(hintergrund$en_age_acquisition))]
#"LLB0818" "CSW0893" "RZM0604" "KFS0603"

#collapse and put to qData
cols<-c("en_acquisition_family",
        "en_acquisition_school",
        "en_acquisition_cursus",
        "en_acquisition_friends",
        "en_acquisition_tandam",
        "en_acquisition_family_abroad",
        "en_acquisition_aupair",
        "en_acquisition_language_abroad",
        "en_acquisition_work_abroad",
        "en_acquisition_study_abroad",
        "en_acquisition_other"
)

en_acquisition_how<-collapse_colnames(cols, hintergrund)
#delete "de_acquisition_"
en_acquisition_how<-gsub("en_acquisition_", "", en_acquisition_how)
qData$en_acquistion_how<-en_acquisition_how

#does it make sense to keep those rows?Let's say no
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

#keep en_use_day, but adapt levels
if(answer=="answer_full"){
  hintergrund$en_use_day<-mapvalues(hintergrund$en_use_day, from=c("täglich", "oft", "manchmal", "selten", "Sonstiges:"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}else{
  hintergrund$en_use_day<-mapvalues(hintergrund$en_use_day, from=c("A1", "A2", "A3", "A4", "-oth-"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}




#copy comment to qData
qData$en_use_comment<-hintergrund$en_use_comment

#keep expo_hours and hours in reading, writing, speaking and listening, but notcomment
qData$en_expo_comment<-hintergrund$en_expo_comment

#delete rows that convey doubled information
cols<-c("en_use_comment", "en_use_read", "en_use_write", "en_use_listen", "en_use_speak", "en_expo_comment")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

####--------------------french

#there are some NA in all profiles. Not clear why as question was mandatory...
hintergrund$participant_code[which(is.na(hintergrund$fr_age_acquisition))]
#"LLB0818" "CSS1266" "OGS0635" "CSW0893" "RZM0604" "KFS0603"

#collapse and put to qData
cols<-c("fr_acquisition_family",
        "fr_acquisition_school",
        "fr_acquisition_cursus",
        "fr_acquisition_friends",
        "fr_acquisition_tandam",
        "fr_acquisition_family_abroad",
        "fr_acquisition_aupair",
        "fr_acquisition_language_abroad",
        "fr_acquisition_work_abroad",
        "fr_acquisition_study_abroad",
        "fr_acquisition_other"
)

fr_acquisition_how<-collapse_colnames(cols, hintergrund)
#delete "fr_acquisition_"
fr_acquisition_how<-gsub("fr_acquisition_", "", fr_acquisition_how)
qData$fr_acquistion_how<-fr_acquisition_how

#does it make sense to keep those rows?Let's say no
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

#keep de_use_day, but adapt levels
if(answer=="answer_full"){
  hintergrund$fr_use_day<-mapvalues(hintergrund$fr_use_day, from=c("täglich", "oft", "manchmal", "selten", "Sonstiges:"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}else{
  hintergrund$fr_use_day<-mapvalues(hintergrund$fr_use_day, from=c("A1", "A2", "A3", "A4", "-oth-"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}


#copy comment to qData
qData$fr_use_comment<-hintergrund$fr_use_comment

#keep expo_hours and hours in reading, writing, speaking and listening, but notcomment

qData$fr_expo_comment<-hintergrund$fr_expo_comment

#delete rows that convey doubled information
cols<-c("fr_use_comment", "fr_use_read", "fr_use_write", "fr_use_listen", "fr_use_speak", "fr_expo_comment")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]



####-------------------italien

#there are some NA in all profiles. Not clear why as question was mandatory...
hintergrund$participant_code[which(is.na(hintergrund$it_age_acquisition))]
# # [1] "SWD0318" "RBB0517" "SLO0589" "CBM1293" "DZU1289" "SWS1107" "JWA0666" "VLG1100" "LLB0818" "ATI0167" "ATI0167"
# [12] "FTJ0215" "AGI0915" "ASR1017" "ABG0163" "DBF0125" "RWG0209" "JBK0462" "CSS1266" "LDJ0380" "SHN0451" "BMI0684"
# [23] "NPN0933" "KHH0997" "MWS0766" "MSF0259" "DBZ0796" "OGS0635" "MCS0364" "KPA0272" "KSG0322" "AWD0883" "AWS0158"
# [34] "DOI0462" "CSW0893" "JKH0682" "AUU0189" "OSW1027" "CEG0921" "AUA0310" "ABA0516" "RZM0604" "KFS0603" "IWR0962"
# [45] "SZP0142" "ATS1240" "ATS1240" "CSB0480" "SWB1280" "SWB0543" "CHB1071" "MDG1232" "JKI0958" "SHI1007"

#collapse and put to qData
cols<-c("it_acquisition_family",
        "it_acquisition_school",
        "it_acquisition_cursus",
        "it_acquisition_friends",
        "it_acquisition_tandam",
        "it_acquisition_family_abroad",
        "it_acquisition_aupair",
        "it_acquisition_language_abroad",
        "it_acquisition_work_abroad",
        "it_acquisition_study_abroad",
        "it_acquisition_other"
)

it_acquisition_how<-collapse_colnames(cols, hintergrund)
#delete "it_acquisition_"
it_acquisition_how<-gsub("it_acquisition_", "", it_acquisition_how)
qData$it_acquistion_how<-it_acquisition_how

#does it make sense to keep those rows?Let's say no
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

#keep it_use_day, but adapt levels
if(answer=="answer_full"){
  hintergrund$it_use_day<-mapvalues(hintergrund$it_use_day, from=c("täglich", "oft", "manchmal", "selten", "Sonstiges:"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}else{
  hintergrund$it_use_day<-mapvalues(hintergrund$it_use_day, from=c("A1", "A2", "A3", "A4", "-oth-"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}

#copy comment to qData
qData$it_use_comment<-hintergrund$it_use_comment

#keep expo_hours and hours in reading, writing, speaking and listening, but notcomment
qData$it_expo_comment<-hintergrund$it_expo_comment

#delete rows that convey doubled information
cols<-c("it_use_comment", "it_use_read", "it_use_write", "it_use_listen", "it_use_speak", "it_expo_comment")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]


####-------------------chinese

#there are some NA in all profiles. Not clear why as question was mandatory...
hintergrund$profile[which(is.na(hintergrund$zh_age_acquisition))]
hintergrund$participant_code[which(is.na(hintergrund$zh_age_acquisition))]
# [1] "LFD0356" "RZB1142" "SWD0318" "RBB0517" "IBT1242" "SLO0589" "CBM1293" "DZU1289" "TDN0914" "SFH0167" "SWS1107"
# [12] "SZU0400" "RTT0750" "JWA0666" "VLG1100" "DBR0362" "LLB0818" "ATI0167" "SSR0555" "ATI0167" "FTJ0215" "GAH0391"
# [23] "AGI0915" "RAE0333" "ASR1017" "KWS0749" "ABG0163" "DBF0125" "RBM1071" "CWS1204" "RWG0209" "JBK0462" "KWH0500"
# [34] "CSS1266" "LDJ0380" "SHN0451" "BMI0684" "KFH0356" "NPN0933" "KHH0997" "HMF0122" "MWS0766" "MSF0259" "DBZ0796"
# [45] "RSZ0704" "OGS0635" "LBH1136" "CBO0272" "MCS0364" "KPA0272" "KSG0322" "AWD0883" "CZA1165" "FRB0187" "AWS0158"
# [56] "MOB1083" "DOI0462" "CSW0893" "JKH0682" "RBK0125" "AUU0189" "DSB0753" "OSW1027" "CEG0921" "DBS1057" "DWI0402"
# [67] "AUA0310" "LZI0550" "RGW0611" "ABA0516" "RZM0604" "RZM0604" "FRR0934" "RZM0604" "THB0984" "KFS0603" "TFT1064"
# [78] "IWR0962" "VRS0857" "NNB0585" "SZP0142" "TRD1149" "ATS1240" "ATS1240" "CSB0480" "SWB1280" "SWB0543" "CHB1071"
# [89] "MDG1232" "JKI0958" "CLH0466" "SHI1007"

#collapse and put to qData
cols<-c("zh_acquisition_family",
        "zh_acquisition_school",
        "zh_acquisition_cursus",
        "zh_acquisition_friends",
        "zh_acquisition_tandam",
        "zh_acquisition_family_abroad",
        "zh_acquisition_aupair",
        "zh_acquisition_language_abroad",
        "zh_acquisition_work_abroad",
        "zh_acquisition_study_abroad",
        "zh_acquisition_other"
)

zh_acquisition_how<-collapse_colnames(cols, hintergrund)
#delete "de_acquisition_"
zh_acquisition_how<-gsub("zh_acquisition_", "", zh_acquisition_how)
qData$zh_acquistion_how<-zh_acquisition_how

#does it make sense to keep those rows?Let's say no
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

#keep zh_use_day, but adapt levels
if(answer=="answer_full"){
  hintergrund$zh_use_day<-mapvalues(hintergrund$zh_use_day, from=c("täglich", "oft", "manchmal", "selten", "Sonstiges:"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}else{
  hintergrund$zh_use_day<-mapvalues(hintergrund$zh_use_day, from=c("A1", "A2", "A3", "A4", "-oth-"), 
                                    to=c("daily", "often", "sometimes", "rarely", "other"))
}



#copy comment to qData
qData$zh_use_comment<-hintergrund$zh_use_comment

#keep expo hours and hours reading, writing, listening and speaking
qData$zh_expo_comment<-hintergrund$zh_expo_comment

#delete rows that convey doubled information
cols<-c("zh_use_comment", "zh_use_read", "zh_use_write", "zh_use_listen", "zh_use_speak", "zh_expo_comment")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]

######---------------------native language/parental language
#output should be something like german, german+, for qData:more detailed. 
#first output orgonal row to qData
cols<-c("lan_l1", "lan_l1_parents_1", "lan_l1_parents_2")

qData[cols]<-hintergrund[cols]
hintergrund[cols]<-qData[cols]

#some basic cleaning so that we don't need to bother about capitals, trailing spaces, etc.
hintergrund[cols]<-sapply(hintergrund[cols], function(x){gsub("/", " ", x)})
hintergrund[cols]<-sapply(hintergrund[cols], function(x) {gsub("([[:lower:]])([[:upper:]])", "\\1 \\2", x)})
hintergrund[cols]<-sapply(hintergrund[cols], removePunctuation)
hintergrund[cols]<-sapply(hintergrund[cols], tolower)

#check what people said for german and swiss german and complete if necessary the vectors
sapply(hintergrund[cols], unique)
DE<-c("deutsch", "dE", "d", "Hochdeutsch")
CH<-c("schweizerdeutsch", "schweizerdutsch", "sensler", "dialekt", "dialekt", "schweizerdütsch", "schwyzerdütsch", "schweizer", "berndeutsch")
GER<-c(DE, CH)


#for native language

#split, if there are more than two elements and german in there: german+, 
#if german, then german, else: other

for(i in 1: length(hintergrund$lan_l1)){
  lan<-hintergrund$lan_l1[i]
  l<-unlist(strsplit(lan, " "))

#if one non-germanic language, pick german+
  if(length(l)>1 && length(setdiff(l, GER))>0){
    lan<-"german+"

  }else if(length(l)==2 && length(intersect(l, DE))>=1 && length(intersect(l, CH)>= 1)){
    lan<-"germanCH"

  }else if(length(l)==1 && length(intersect(l, CH)>=1)){
    lan<-"germanCH"

  }else if(length(l)==1  && length(intersect(l, DE)>=1)){
    lan<-"german"

  }else if(is.numeric(l)||l=="NA"){
    lan<-NA
  }else{
     lan<-"other"
   }
   print(lan)
   hintergrund$lan_l1[i]<-lan
}

#check values
unique(hintergrund$lan_l1)


##language parent 1:first copy original data into qData, then simplify data (german, swiss german, other)
for(i in 1: length(hintergrund$lan_l1_parents_1)){
  lan<-hintergrund$lan_l1_parents_1[i]
  l<-unlist(strsplit(lan, " "))
  
  #if one non-germanic language, pick german+
  if(length(l)>1 && length(setdiff(l, GER))>0){
    lan<-"german+"
    
  }else if(length(l)==2 && length(intersect(l, DE))>=1 && length(intersect(l, CH)>= 1)){
    lan<-"germanCH"
    
  }else if(length(l)==1 && length(intersect(l, CH)>=1)){
    lan<-"germanCH"
    
  }else if(length(l)==1  && length(intersect(l, DE)>=1)){
    lan<-"german"
    
  }else if(is.numeric(l)||l=="NA"){
    lan<-NA
  }else if(length(l)>3 && intersect(l, GER)>1){
    lan<-"german"
  }else{
    lan<-"other"
  }
  print(lan)
  hintergrund$lan_l1_parents_1[i]<-lan
}

#check values
unique(hintergrund$lan_l1_parents_1)


##language parent 2: first copy original data into qData, then simplify data (german, swiss german, other)
for(i in 1: length(hintergrund$lan_l1_parents_2)){
  lan<-hintergrund$lan_l1_parents_2[i]
  l<-unlist(strsplit(lan, " "))
  
  #if one non-germanic language, pick german+
  if(length(l)>1 && length(setdiff(l, GER))>0){
    lan<-"german+"
    
  }else if(length(l)==2 && length(intersect(l, DE))==1 && length(intersect(l, CH)== 1)){
    lan<-"germanCH"
    
  }else if(length(l)==1 && length(intersect(l, CH)==1)){
    lan<-"germanCH"
    
  }else if(length(l)==1  && length(intersect(l, DE)==1)){
    lan<-"german"
    
  }else if(is.numeric(l)||identical(l, character(0))){
    lan<-NA
  }else{
    lan<-"other"
  }
  print(lan)
  hintergrund$lan_l1_parents_2[i]<-lan
}

#check values
unique(hintergrund$lan_l1_parents_2)


#save copy
hintergrund7<-hintergrund
hintergrund<-hintergrund7
save.image(paste(format(Sys.time(), "%Y_%b_%d"),"_hintergrund_","4.RData"))

#######------------musical background-----------------------
#adjust levels of music
hintergrund$music<-mapvalues(hintergrund$music, from=c(1, 2, NA), to=c("yes", "no", NA))
#it might be necessary to export wit complete answers
instruments_D<-c("Fagott", "Flöte", "Gesang", "Gitarre", "Harfe", "Horn", "Klarinette", "Klavier",
                 "Oboe", "Perkussion", "Posaune", "Saxofon", "Schlagzeug", "Trompete", "Violine", "Violoncello", "Sonstiges")
instruments_E<-c("bassoon", "flute", "voice", "guitar", "harp", "horn", "carinet", "piano", 
                 "oboe", "percussion", "trombone", "saxofone", "drums", "trumpet", "violine","cello", "other")

if(answer=="answer_full"){
  hintergrund$instrument_main<-mapvalues(hintergrund$instrument_main, 
                                         from=instruments_D,
                                         to=instruments_E)
}else{
  hintergrund$instrument_main<-mapvalues(hintergrund$instrument_main, 
                                         from=c("A1", "A12", "A16", "A9", "A12",
                                                "A", "A2", "A11", "A",
                                                "A", "A8", "A",
                                                "A14", "A", "A3", "A4","-oth-"),
                                         to=c("bassoon", "flute", "voice","guitar", "harp", 
                                              "horn", "clarinet","piano", "oboe",
                                              "percussion", "trombone", "saxofone",
                                              "drums", "trumpet", "violine", "cello", "other"))
}


#instrument_main_age instrument_main_hours and instrument_main_stop can stay as it is.
#For hintergrund, we just keep hours main instrument and instrument_age
if(answer=="answer_full"){
  hintergrund$instrument_main_activ<-mapvalues(hintergrund$instrument_main_activ, from=c("Ja", "Nein", "N/A", NA), to=c("yes", "no", NA, NA))
  
}else{
  hintergrund$instrument_main_activ<-mapvalues(hintergrund$instrument_main_activ, from=c(1, 2, NA), to=c("yes", "no", NA))
  
}
#caluclate number of years
instrument_main_years<-c()
for(i in 1:nrow(hintergrund)){
  age<-hintergrund$instrument_main_age[i]
  print(age)
  stop<-hintergrund$instrument_main_stop[i]
  print(stop)
  years<-stop-age
  instrument_main_years[i]<-years
}
hintergrund$instrument_main_years<-instrument_main_years

###second instrument
if(answer=="answer_full"){
  hintergrund$instrument_sec<-mapvalues(hintergrund$instrument_sec, 
                                         from=instruments_D,
                                         to=instruments_E)
}else{
  hintergrund$instrument_sec<-mapvalues(hintergrund$instrument_sec, 
                                         from=c("A1", "A12", "A16", "A9", "A12",
                                                "A", "A2", "A11", "A",
                                                "A", "A8", "A",
                                                "A14", "A", "A3", "A4","-oth-"),
                                         to=c("bassoon", "flute", "voice","guitar", "harp", 
                                              "horn", "clarinet","piano", "oboe",
                                              "percussion", "trombone", "saxofone",
                                              "drums", "trumpet", "violine", "cello", "other"))
}


#instrument_main_age instrument_main_hours and instrument_main_stop can stay as it is.
#For hintergrund, we just keep hours main instrument and instrument_age
if(answer=="answer_full"){
  hintergrund$instrument_sec_activ<-mapvalues(hintergrund$instrument_sec_activ, from=c("Ja", "Nein", "N/A", NA), to=c("yes", "no", NA, NA))
  
}else{
  hintergrund$instrument_sec_activ<-mapvalues(hintergrund$instrument_sec_activ, from=c(1, 2, NA), to=c("yes", "no", NA))
  
}

#calculate number of years
instrument_sec_years<-c()
for(i in 1:nrow(hintergrund)){
  age<-hintergrund$instrument_sec_age[i]
  print(age)
  stop<-hintergrund$instrument_sec_stop[i]
  print(stop)
  years<-stop-age
  instrument_sec_years[i]<-years
}
hintergrund$instrument_sec_years<-instrument_sec_years

#copy columns to qData
cols<-c("instrument_main", "instrument_main_other", "instrument_main_stop", "instrument_sec", "instrument_sec_other", "instrument_sec_stop")
qData[cols]<-hintergrund[cols]
#delete columns in hintergrund
cols<-c("instrument_main", "instrument_main_other", "instrument_main_activ", "instrument_main_stop", "music", 
        "instrument_sec_yes","instrument_sec", "instrument_sec_other", "instrument_sec_activ", "instrument_sec_stop")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]
save.image(paste(format(Sys.time(), "%Y_%b_%d"),"_hintergrund_","5.RData"))

#calculate median and last music hours
#define columns
music_columns<-c("music_hours_0",
                 "music_hours_8",
                 "music_hours_11",
                 "music_hours_14",
                 "music_hours_17",
                 "music_hours_20",
                 "music_hours_23",
                 "music_hours_26",
                 "music_hours_29",
                 "music_hours_32",
                 "music_hours_35",
                 "music_hours_38",
                 "music_hours_41",
                 "music_hours_44",
                 "music_hours_47",
                 "music_hours_50",
                 "music_hours_53",
                 "music_hours_56",
                "music_hours_59",
                 "music_hours_62",
                 "music_hours_65"
)

#first replace commata with points and set all to numeric

hintergrund[music_columns]<-sapply(hintergrund[music_columns], function(x){gsub(",", ".", x)})
hintergrund[music_columns]<-sapply(hintergrund[music_columns], as.numeric)
average<-c()
current_value<-c()

for(i in 1:nrow(hintergrund)){
  if(is.na(age)){
    current_value[i]
    average[i]<-NA
  }else{
    age<-hintergrund$age[i]
    row<-hintergrund[i,]
    if(age<20){
      col<-"music_hours_17"
    }else if(age<23){
      col<-"music_hours_20"
    }else if(age<26){
      col<-"music_hours_23"
    }else if(age<29){
      col<-"music_hours_26"
    }else if(age<32){
      col<-"music_hours_29"
    }else if(age<35){
      col<-"music_hours_32"
    }else if(age<38){
      col<-"music_hours_35"
    }else if(age<41){
      col<-"music_hours_38"
    }else if(age<44){
      col<-"music_hours_41"
    }else if(age<47){
      col<-"music_hours_44"
    }else if(age<50){
      col<-"music_hours_47"
    }else if(age<53){
      col<-"music_hours_50"
    }else if(age<56){
      col<-"music_hours_53"
    }else if(age<59){
      col<-"music_hours_56"
    }else if(age<62){
      col<-"music_hours_59"
    }else if(age<65){
      col<-"music_hours_62"
    }else if(age>=65){
      col<-"music_hours_65"
    }else{col<-NA}
    print(age)
    print(col)
    #retrieve current value
    current_value[i]<-hintergrund[i, col]
    #number of columns for average
    ncol<-which(music_columns==col)
    print(ncol)
    cols<-music_columns[1:ncol]
    print(cols)
    row[cols]<-sapply(row[cols],as.numeric)
    row[cols]<-as.numeric(row[cols])
    average[i]<-median(unlist(row[cols]), na.rm=T)
  }
  
}
hintergrund$music_current<-current_value
hintergrund$music_median<-average

#delete columns music_hours
hintergrund<-hintergrund[,-which(names(hintergrund) %in% music_columns)]
save.image(paste(format(Sys.time(), "%Y_%b_%d"),"_hintergrund_","6.RData"))

#other music exposure
if(answer=="answer_full"){
  hintergrund$music_listening<-mapvalues(hintergrund$music_listening, from=c("Ja", "Nein", "N/A", NA), to=c("yes", "no", NA, NA))
  hintergrund$music_abs_hearing<-mapvalues(hintergrund$music_abs_hearing, from=c("Ja", "Nein", "N/A", NA), to=c("yes", "no", NA, NA))
}else{
  hintergrund$music_listening<-mapvalues(hintergrund$music_listening, from=c(1, 2, NA), to=c("yes", "no", NA))
  hintergrund$music_abs_hearing<-mapvalues(hintergrund$music_abs_hearing, from=c(1, 2, NA), to=c("yes", "no", NA))
}

#keep music_listening_hours

qData$music_comment<-hintergrund$music_comment
cols<-c("music_abs_hearing", "music_comment", "surveytime", "music_listening", "id", "date", "emplymen_div", 
        "client_type_div", "de_use_comment.1", "en_cuse_comment.1", "zh_use_comment.1", "it_use_comment.1", "fr_use_comment.1")
hintergrund<-hintergrund[,-which(names(hintergrund) %in% cols)]
save.image(paste(format(Sys.time(), "%Y_%b_%d"),"_hintergrund_","6.RData"))

#remove unnecessary variables
rm("hintergrund1", "hintergrund2", "hintergrund3", "hintergrund4", hintergrund5, hintergrund6, r, row, w, 
   word, age, all_languages,average, CH, code, cols, col, current_value, DE, de_acquistion_how, en_acquisition_how,
   fr_acquisition_how, it_acquisition_how, zh_acquisition_how,i, instrument_main_years,j, i,l, l1_col, l2_col, l3_col, lan, lan_number,
   language_column, music_columns, n, ncol, languages, other_languages, stop, words, x, years, GER, lan_spoken, practice_columns)



#####-----------------add participant as variable, toupper to correct capital and non-capital letters
#pandemia
#participants<-read_excel("C:/Users/gies/Desktop/R Skripte und workspaces/Hintergrund/participants.xlsx")

#before matching, it would be good to check participants code for errors
participants$code<-toupper(participants$code)
participants$data<-strptime(participants$data, format=c("%Y-%m-%d"))

hintergrund$participant_name<-hintergrund$participant_code
zhaw_date<-as.Date(rep(NA, 109))
for(i in 1:nrow(participants)){
  name<-participants$name[i]
  code<-participants$code[i]
  date_zhaw<-participants$data[i]
  rows<-which(hintergrund$participant_code==code)
  print(rows)
  hintergrund$participant_name[rows]<-name
  zhaw_date[rows]<-date_zhaw
}
hintergrund$zhaw_date<-zhaw_date
#4 cases have double entries, 31 have no zhaw_date

#check overlap. Untill 15/05/2020,we had 76 participants and 30 corona cases
length(intersect(hintergrund$participant_name, participants$name))#76, corresponds to number today
#which are in hintergrund but not in participants
setdiff(hintergrund$participant_name, participants$name)#manual checking: appears to be correct. Concerns 12 candidates
# [1] "TDN0914" (UZH, but not ZHAW) "SZU0400" (at UZH but not ZHAW) "DBR0362" (unentschuldigt)
#"LLB0818" (not found, start date in august 2019, IntPro male)
#"FTJ0215" (not found, start date in august 2019, MulMA male)
#"GAH0391" (not found, start date in august 2019, MuMA male)
#"ASR1017" (not found, start date september 2019, IntPro female -> Pilot (ich))
#"KHH0997" (abgesagt)"CSW0893" (unentschuldigt)
#"ATS1240" (abgesagt) "CLH0466" (abgesagt)
# [12] "LBL1106" (UZH but not ZHAW) "RMR0956"(abgesagt)

#which are in participants but not in hintergrund
setdiff(participants$name, hintergrund$participant_name)
#"TraPro05" "MulBA01" 

participants$code[participants$name=="TraPro05"] #JSH0185, "SMA0406"for MulBA01
#participant code on switchdrive: SMA kam am 08.02., JSH kam am 06.02, beide sind in der Original-Tabelle-> check

#same for qData
qData$participant_name<-qData$participant_code
for(i in 1:nrow(participants)){
  name<-participants$name[i]
  code<-participants$code[i]
  rows<-which(qData$participant_code==code)
  print(rows)
  qData$participant_name[rows]<-name
}


#create variable group and expertise
hintergrund$group<-factor(substr(hintergrund$profile, 1, 3))
hintergrund$expertise<-factor(substr(hintergrund$profile, 4, 6))
hintergrund$expertise<-gsub("[0-9]", "", hintergrund$expertise)

#same for qData
qData$group<-factor(substr(qData$profile, 1, 3))

#now delete double entries for participants
hintergrund[which(duplicated(hintergrund$participant_code)),]#there are not many cases

#delete rows that aredouble and have more na than the other. Date is uninformative
for (i in 1:nrow(hintergrund)){
  code<-hintergrund$participant_code[i]
  rows<-which(hintergrund$participant_code==code)
  print(paste("i is ", i))
  print(paste("rows are", rows))
  if(length(rows>1)){
    for(j in 1:length(rows)){
      r<-rows[j]
      row<-hintergrund[r]
      l<-length(which(is.na(row)))
      print(l)
    }

  }else{
    next
  }
}


#################------creating subsamples per group-----------------
interpreters<-hintergrund[hintergrund$group=="Int",]
translators<-hintergrund[hintergrund$group=="Tra",]
qData_translators<-qData[qData$group=="Tra",]





#


#write tables
setwd("S:/pools/l/L-IUED-CLINT-analysis/Hintergrund/tables")
group<-"interpreters"
filename<-paste(format(Sys.time(), "%Y_%b_%d_"), group, "_.csv")
write.csv2(hintergrund, paste(format(Sys.time(), "%Y_%b_%d"), "hintergrund_all.csv"))
write.csv2(interpreters, filename)

write.csv2(translators, filename, fileEncoding="UTF-8")
write.csv2(qData_translators, paste(format(Sys.time(), "%Y_%b_%d"), "translators_qualitative_data.csv")

#Fehler in translators: SZP0142 wurde als MulMA eingeladen, hat BA vertiefte Sprachen angekreuzt



# Preliminary analysis ---------------------------------------------

# to calculate means etc., replace 'Alter' by any numerical variable in the data set
# to calculate the same values for a subset only, indicate which dataframe you want to look at

data1$Alter
# all entries: 31 31 32 52 34 59 91

mean(data1$Alter)
# 47.14286
range(data1$Alter)
# 31 91


# Comparing means for a variable per group
# again, replace the variable you want to compare if needed

tapply(data1$Alter, list(data1$Gruppe), mean)

# IntBA  IntMA IntPro   Mult  TraBA  TraMA TraPro 
# 31     52     59     91     31     32     34 


tapply(data1$Alter, list(data1$Gruppe, data1$Geschlecht), mean)

#           divers keine Angabe mÃ¤nnlich weiblich
#IntBA      NA           NA       NA       31
#IntMA      NA           NA       52       NA
#IntPro     NA           59       NA       NA
#Mult       91           NA       NA       NA
#TraBA      NA           NA       31       NA
#TraMA      NA           32       NA       NA
#TraPro     NA           NA       NA       34
