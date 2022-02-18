library(readr)

chor <- read_csv("C:/Users/matth/Downloads/Anmeldung TiFiChor (Antworten) - Formularantworten 1(1).csv")

chor$Name <- as.factor(chor$Name)

chor$Stimmlage <- as.factor(chor$Stimmlage)

dplyr::count(chor,Stimmlage)

