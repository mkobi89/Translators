############################
#### Limesurvey Dataset ####
############################
## Description :: loads and merges psychometrics raw data
## Input :::::::: csv data file 
## Libraries :::: dplyr, readr, eeptools, lubridate
## Output ::::::: psychometrics.Rdata
##########################################################

## libraries, packages, path ----

# install tidyverseif not installed already
if (!"tidyverse" %in% installed.packages()[, "Package"]) {
  install.packages("tidyverse")
}
if (!"readxl" %in% installed.packages()[, "Package"]) {
  install.packages("readxl")
}

# load tidyverse
library(tidyverse)
library(readxl)

# ddata path
dataFolderRaw   <- file.path("data/rawdata")
dataFolder   <- file.path("data")

## Read Dataset ----
#hgf_raw <- read_excel(file.path(dataFolderRaw,"limesurvey.xlsx"), sheet = "Hintergrundfragebogen")


hgf_raw <- read.csv(file.path(dataFolderRaw,"hintergrund.csv"), header = TRUE, sep = ";")
hgf_raw <- subset(hgf_raw, select = c(1:256))

# View(Hintergrundfragebogen_raw)


## Rename Variables ----

colnames(hgf_raw) <-
  c(
    "Antwort_ID",
    "Datum_abgeschickt",
    "letzte_Seite",
    "Sprache_Start",
    "Zufallswert",
    "Datum_Start",
    "Datum_last_activity",
    "Welcome_Text",
    "group",
    "VPN_Code",
    "Geschlecht",
    "Geschlechtsidentitaet",
    "Alter",
    "hoechste_Ausbildung",
    "hoechste_Ausbildung_sonstiges",
    "Fachgebiet_Abschluss",
    
    "Sprache_Studium_A",
    "Sprache_Studium_B",
    "Sprache_Studium_C",
    "Sprache_U_Arbeit_A",
    "Sprache_U_Arbeit_B",
    "Sprache_U_Arbeit_C",
    "Sprache_D_Arbeit_A",
    "Sprache_D_Arbeit_B",
    "Sprache_D_Arbeit_C",
    "Jahre_Berufserfahrung",
    "prof_Sprachmittler",
    "Beschreibung_Taetigkeit_Sprachmittler",
    "Berufsbeschaeftigungssituation",
    "Berufsbeschaeftigungssituation_sonstiges",
    "Beschaeftigungsgrad_U",
    "TageproletztesJahr_D",
    "Jahre_aktuelle_Konstellation",
    "Kunden",
    "Kunden_sonstiges",
    "Prozent_Community-D",
    "Prozent_Gerichts-D",
    "Prozent_Konsekutiv-D",
    "Prozent_Post-Editing",
    "Prozent_Revidieren",
    "Prozent_Simultan-D",
    "Prozent_U",
    "Prozent_Sonstiges",
    "Beschreibung_Sonstiges",
    "Erfahrung_andere_Bereiche",
    "Kommentar_andere_Bereiche",
    "avghpw_DodU_17-19J",
    "avghpw_DodU_20-22J",
    "avghpw_DodU_23-25J",
    "avghpw_DodU_26-28J",
    "avghpw_DodU_29-31J",
    "avghpw_DodU_32-34J",
    "avghpw_DodU_35-37J",
    "avghpw_DodU_38-40J",
    "avghpw_DodU_41-43J",
    "avghpw_DodU_44-46J",
    "avghpw_DodU_47-49J",
    "avghpw_DodU_50-52J",
    "avghpw_DodU_53-55J",
    "avghpw_DodU_56-58J",
    "avghpw_DodU_59-61J",
    "avghpw_DodU_62-64J",
    "avghpw_DodU_65+J",
    
    "Chinesisch",
    "Deutsch/Schweizerdeutsch",
    "Franzoesisch",
    "Englisch",
    "Italienisch",
    "weitere_Sprachen",
    "zus_Sprache1",
    "Alter_zS1",
    "heute_zS1",
    "hpw_letztesJahr_ZS1",
    "zus_Sprache2",
    "Alter_zS2",
    "heute_zS2",
    "hpw_letztesJahr_ZS2",
    "zus_Sprache3",
    "Alter_zS3",
    "heute_zS3",
    "hpw_letztesJahr_ZS3",
    "zus_Sprache4",
    "Alter_zS4",
    "heute_zS4",
    "hpw_letztesJahr_ZS4",
    "zus_Sprache5",
    "Alter_zS5",
    "heute_zS5",
    "hpw_letztesJahr_ZS5",
    "zus_Sprache6",
    "Alter_zS6",
    "heute_zS6",
    "hpw_letztesJahr_ZS6",
    
    "Alter_DE",
    "Familie_DE",
    "Schule_DE",
    "Sprachkurs_DE",
    "Freunde_DE",
    "Sprachtandem_DE",
    "Familie_Ausland_DE",
    "Au-Pair_DE",
    "Sprachaufenthalt_DE",
    "berufl_Ausland_DE",
    "Ausland_Studium_DE",
    "Sonstiges_DE",
    "DE_im_Alltag",
    "DE_im_Alltag_Sonstiges",
    "lesen_DE",
    "schreiben_DE",
    "verstehen_DE",
    "sprechen_DE",
    "Verwendung_Sonstiges_DE",
    "avghpw_Wachzeit_DE_ausgesetzt",
    "avghpw_letztesJahr_sprechen_DE",
    "avghpw_letztesJahr_lesen_DE",
    "avghpw_letztesJahr_hoeren_DE",
    "Anmerkungen_DE",
    
    "Alter_E",
    "Familie_E",
    "Schule_E",
    "Sprachkurs_E",
    "Freunde_E",
    "Sprachtandem_E",
    "Familie_Ausland_E",
    "Au-Pair_E",
    "Sprachaufenthalt_E",
    "berufl_Ausland_E",
    "Ausland_Studium_E",
    "Sonstiges_E",
    "E_im_Alltag",
    "E_im_Alltag_Sonstiges",
    "lesen_E",
    "schreiben_E",
    "verstehen_E",
    "sprechen_E",
    "Verwendung_Sonstiges_E",
    "avghpw_Wachzeit_E_ausgesetzt",
    "avghpw_letztesJahr_sprechen_E",
    "avghpw_letztesJahr_lesen_E",
    "avghpw_letztesJahr_hoeren_E",
    "Anmerkungen_E",
    
    "Alter_F",
    "Familie_F",
    "Schule_F",
    "Sprachkurs_F",
    "Freunde_F",
    "Sprachtandem_F",
    "Familie_Ausland_F",
    "Au-Pair_F",
    "Sprachaufenthalt_F",
    "berufl_Ausland_F",
    "Ausland_Studium_F",
    "Sonstiges_F",
    "F_im_Alltag",
    "F_im_Alltag_Sonstiges",
    "lesen_F",
    "schreiben_F",
    "verstehen_F",
    "sprechen_F",
    "Verwendung_Sonstiges_F",
    "avghpw_Wachzeit_F_ausgesetzt",
    "avghpw_letztesJahr_sprechen_F",
    "avghpw_letztesJahr_lesen_F",
    "avghpw_letztesJahr_hoeren_F",
    "Anmerkungen_F",
    
    "Alter_I",
    "Familie_I",
    "Schule_I",
    "Sprachkurs_I",
    "Freunde_I",
    "Sprachtandem_I",
    "Familie_Ausland_I",
    "Au-Pair_I",
    "Sprachaufenthalt_I",
    "berufl_Ausland_I",
    "Ausland_Studium_I",
    "Sonstiges_I",
    "I_im_Alltag",
    "I_im_Alltag_Sonstiges",
    "lesen_I",
    "schreiben_I",
    "verstehen_I",
    "sprechen_I",
    "Verwendung_Sonstiges_I",
    "avghpw_Wachzeit_I_ausgesetzt",
    "avghpw_letztesJahr_sprechen_I",
    "avghpw_letztesJahr_lesen_I",
    "avghpw_letztesJahr_hoeren_I",
    "Anmerkungen_I",
    
    "Alter_CN",
    "Familie_CN",
    "Schule_CN",
    "Sprachkurs_CN",
    "Freunde_CN",
    "Sprachtandem_CN",
    "Familie_Ausland_CN",
    "Au-Pair_CN",
    "Sprachaufenthalt_CN",
    "berufl_Ausland_CN",
    "Ausland_Studium_CN",
    "Sonstiges_CN",
    "CN_im_Alltag",
    "CN_im_Alltag_Sonstiges",
    "lesen_CN",
    "schreiben_CN",
    "verstehen_CN",
    "sprechen_CN",
    "Verwendung_Sonstiges_CN",
    "avghpw_Wachzeit_CN_ausgesetzt",
    "avghpw_letztesJahr_sprechen_CN",
    "avghpw_letztesJahr_lesen_CN",
    "avghpw_letztesJahr_hoeren_CN",
    "Anmerkungen_CN",
    
    "Erstsprache/n",
    "Erstsprache_Eltern1",
    "Erstsprache_Eltern2",    
    
    "Instument_ueb_Schule",
    "Hauptinstrument",
    "HI_sonstiges",
    "Alter_HI",
    "HI_letztes_Jahr",
    "Alter_Ende_HI",
    "hpw_letzesJahr_HI",
    "spielt_Zweitinstrument",
    "Zweitinstrument",
    "ZI_sonstiges",
    "Alter_ZI",
    "ZI_letztes_Jahr",
    "Alter_Ende_ZI",
    "hpw_letzesJahr_ZI",
    "avghpw_Musi_0-7J",
    "avghpw_Musi_8-10J",
    "avghpw_Musi_11-13J",
    "avghpw_Musi_14-16J",
    "avghpw_Musi_17-19J",
    "avghpw_Musi_20-22J",
    "avghpw_Musi_23-25J",
    "avghpw_Musi_26-28J",
    "avghpw_Musi_29-31J",
    "avghpw_Musi_32-34J",
    "avghpw_Musi_35-37J",
    "avghpw_Musi_38-40J",
    "avghpw_Musi_41-43J",
    "avghpw_Musi_44-46J",
    "avghpw_Musi_47-49J",
    "avghpw_Musi_50-52J",
    "avghpw_Musi_53-55J",
    "avghpw_Musi_56-58J",
    "avghpw_Musi_59-61J",
    "avghpw_Musi_62-64J",
    "avghpw_Musi_65+J",
    "Freizeit_Musik_Hoeren",
    "hpd_letztesJahr_Musikhoeren",
    "Absolutes_Gehoer",
    "Kommentar_musikalischer_Werdegang",

    "Anmerkungen"
  )

## Recode Group Variable ----
hgf_raw$group <- gsub("\\(|)", "", hgf_raw$group)
#hgf_raw$group <- gsub("ü", "ue", hgf_raw$group)
#hgf_raw$group <- gsub("Ü", "Ue", hgf_raw$group)

hgf_raw$group <- gsub("...als Konferenzdolmetscher/in arbeite", "IntPro", hgf_raw$group)
hgf_raw$group <- gsub("...im Master Konferenzdolmetschen studiere", "IntMA", hgf_raw$group)
hgf_raw$group <- gsub("...im Bachelor Angewandte Sprachen Vertiefungsrichtung MSK studiere", "IntBA", hgf_raw$group)

hgf_raw$group <- gsub("...als uebersetzer/in arbeite", "TraPro", hgf_raw$group)
hgf_raw$group <- gsub("...im Master Fachuebersetzen studiere", "TraMA", hgf_raw$group)
hgf_raw$group <- gsub("...im Bachelor Angewandte Sprachen Vertiefungsrichtung MMK studiere", "TraBA", hgf_raw$group)

hgf_raw$group <- gsub("...Deutsch und Englisch gut beherrsche, aber ueber keine Ausbildung/Erfahrung im Bereich uebersetzen/Dolmetschen verfuege", "Mul", hgf_raw$group)

## Set Variables to Factors, Numbers and Chars ----
as_factors <- c(1,4,	9,	10,	11,	14,	15,	16,	17,	18,	19,	20,	21,	22,	23,	24,	25,	27,	29,	34,	45,	64,	65,	66,	67,	68,	69,	70,	72,	74,	76,	78,	80,	82,	84,	86,	88,	90,	92,	95,	96,	97,	98	,99,	100,	101,	102,	103,	104, 105,	106,	108,	109,	110,	111,	112,	119,	120,	121,	122,	123,	124,	125,	126,	127,	128,	129,	130,	132, 133,	134,	135,	136,	143, 144,	145,146,	147,	148,	149,	150,	151,	152,	153,	154,	156,	157,	158,	159,	160,	167,	168,	169,	170,	171,	172,	173,	174,	175,	176,	177,	178,	180,	181,	182,	183,	184,	191,	192,	193,	194,	195,	196,	197,	198,	199,	200,	201,	202,	204,	205,	206,	207,	208,	214,	215,	216,	217,	218,	219,	221,	224,	225,	226,	228,	252,	254)
hgf_raw[, as_factors] <- lapply(hgf_raw[, as_factors], factor)

as_numeric <- c(26,	31,	33,	35,	36,	37,	38,	39,	40,	41,	42,	43,	47,	48,	49,	50,	51,	52,	53,	54,	55,	56,	57,	58, 59,	60,	61,	62,	63,	71,	73,	75,	77,	79,	81,	83,	85,	87,	89,	91,	93,	94,	113,	114,	115,	116,	118,	137,	138,	139,	140,	142,	161,	162,	163,	164,	166,	185, 186,	187,	188,	190,	209,	210,	211,	212,	220,	222,	223,	227,	229,	230,	231,	232,	233,	234,	235,	236,	237,	238,	239,	240,	241,	242,	243,	244,	245,	246,	247,	248,	249,	250,	251,	253)
hgf_raw[, as_numeric] <- lapply(hgf_raw[, as_numeric], as.numeric)

as_char <- c(28,	30,	44,	46,	107,	117,	131,	141,	155,	165,	179,	189,	203,	213,	255)
hgf_raw[, as_char] <- lapply(hgf_raw[, as_char], as.character)


#str(hgf_raw)

remove(as_char,as_factors, as_numeric)


## Clear dataset ----
# Remove empty lines
hgf_raw <- hgf_raw %>% 
  filter(VPN_Code != "")

# Keep incomplete data before removal
hgf_incomplete <- hgf_raw %>% 
  filter(letzte_Seite != 15)

# Remove fake data with age < 17 and incomplete data
hgf_raw <- hgf_raw %>% 
  filter(Alter > 16, letzte_Seite == 15)

## replace all VPN_Codes with upper case
hgf_raw$VPN_Code <- toupper(hgf_raw$VPN_Code)

## Create subsets of dataframe ----

Pers_def <- subset(hgf_raw, select = c(1:7,9:16,256))
Dol_def <- subset(hgf_raw, select = c(10, (17:63),1))
Sprachen_def <- subset(hgf_raw, select = c(10, (64:216),1))
Musik_def <- subset(hgf_raw, select = c(10, (217:255),1))


## Variable-Selection ----
# Pers-Datensatz
Pers_select <- subset(Pers_def, select = c(1,9,8,3,2,10:16))

# Sprachen-Datensatz
Sprachen_select <-
  subset(
    Sprachen_def,
    select = -c(
      10,
      11,
      14,
      15,
      18,
      19,
      22,
      23,
      26,
      27,
      30,
      31,
      33:50,
      52:54,
      57:74,
      76:78,
      81:98,
      100:102,
      105:122,
      124:126,
      129:146,
      148:150
    )
  )

# Musik-Datensatz
Musik_select <- subset(Musik_def, select = -c(6, 13, 16:37, 40))

#Dol-Datensatz
Dol_select <- subset(Dol_def, select = -c(14:15, 18:26, 30:48))

#remove(Dol_def,Musik_def,Pers_def,Sprachen_def)

## Calculations ----
## Sprachen-Datensatz

# Stunden pro Woche und gesamt letztes Jahr andere Sprachen
Sprachen_select$hpw_letztesJahr_andereSprachen <-
  rowSums(Sprachen_def[, c(seq(11, 31, 4))],
          na.rm = TRUE)
Sprachen_select$h_letztesJahr_andereSprachen <-
  52 * rowSums(Sprachen_def[, c(seq(11, 31, 4))],
               na.rm = TRUE)

# Stunden pro Woche und gesamt letztes Jahr D
Sprachen_select$hpw_letztesJahr_DE <-
  rowSums(Sprachen_def[, c(52:54)],
          na.rm = TRUE)
Sprachen_select$h_letztesJahr_DE <-
  52 * rowSums(Sprachen_def[, c(52:54)],
               na.rm = TRUE)

# Stunden pro Woche und gesamt letztes Jahr E
Sprachen_select$hpw_letztesJahr_E <-
  rowSums(Sprachen_def[, c(76:78)],
          na.rm = TRUE)
Sprachen_select$h_letztesJahr_E <-
  52 * rowSums(Sprachen_def[, c(76:78)],
               na.rm = TRUE)

# Stunden pro Woche und gesamt letztes Jahr F
Sprachen_select$hpw_letztesJahr_F <-
  rowSums(Sprachen_def[, c(100:102)],
          na.rm = TRUE)
Sprachen_select$h_letztesJahr_F <-
  52 * rowSums(Sprachen_def[, c(100:102)],
               na.rm = TRUE)

# Stunden pro Woche und gesamt letztes Jahr I
Sprachen_select$hpw_letztesJahr_I <-
  rowSums(Sprachen_def[, c(124:126)],
          na.rm = TRUE)
Sprachen_select$h_letztesJahr_I <-
  52 * rowSums(Sprachen_def[, c(124:126)],
               na.rm = TRUE)

# Stunden pro Woche und gesamt letztes Jahr CN
Sprachen_select$hpw_letztesJahr_CN <-
  rowSums(Sprachen_def[, c(148:150)],
          na.rm = TRUE)
Sprachen_select$h_letztesJahr_CN <-
  52 * rowSums(Sprachen_def[, c(148:150)],
               na.rm = TRUE)

# Summe alle Sprachen
Sprachen_select$h_letztesJahr_ALLE <-
  Sprachen_select$h_letztesJahr_CN +
  Sprachen_select$h_letztesJahr_I + Sprachen_select$h_letztesJahr_F + Sprachen_select$h_letztesJahr_E +
  Sprachen_select$h_letztesJahr_DE + Sprachen_select$h_letztesJahr_andereSprachen

# ?berpr?fung
Sprachen_select$hpd_ALLE <-
  Sprachen_select$h_letztesJahr_ALLE / (7 * 52)

Sprachen_select$Prozent_ALLE_pd <-
  (Sprachen_select$h_letztesJahr_ALLE / (52 * 16 * 7)) * 100


# Stunden gesamt letztes Jahr F, I, CN, andere
Sprachen_select$h_letztesJahr_FICNa <-
  Sprachen_select$h_letztesJahr_CN +
  Sprachen_select$h_letztesJahr_I + Sprachen_select$h_letztesJahr_F +
  Sprachen_select$h_letztesJahr_andereSprachen

# Prozent Deutsch
Sprachen_select$Prozent_DE <-
  100 * (Sprachen_select$h_letztesJahr_DE / Sprachen_select$h_letztesJahr_ALLE)

# Prozent Englisch
Sprachen_select$Prozent_E <-
  100 * (Sprachen_select$h_letztesJahr_E / Sprachen_select$h_letztesJahr_ALLE)

# Prozent FICNa
Sprachen_select$Prozent_FICNa <-
  100 * (Sprachen_select$h_letztesJahr_FICNa / Sprachen_select$h_letztesJahr_ALLE)

# Ueberpruefung
Sprachen_select$Prozent_zsm <-
  Sprachen_select$Prozent_DE + Sprachen_select$Prozent_E + Sprachen_select$Prozent_FICNa




## Dolmetscher-Datensatz
Dol_select$Prozent_D <- rowSums(Dol_def[, c(21:26)], na.rm = TRUE)

#Ueberpruefung
Dol_select$Prozent_DodU_zsm <-
  Dol_select$Prozent_D + Dol_select$Prozent_U + Dol_select$Prozent_Sonstiges


# Funktion fuer Stunden ueber Leben berechnen -----

# fuer Dolmetschen:
cum_train_h_Dol = function(x, m, n) {
  # x = Dataset
  # m = 1. Spalte im Datensatz x mit 1. Alterskategorie
  # n = letzte Spalte im Datensatz x mit letzter Alterskategorie
  # p = Anzahl Personen
  p = nrow(x)
  A = matrix(17:100, nrow = 1, ncol = (100 - 17 + 1)) # Matrix mit Alter
  B = matrix(nrow = p, ncol = (100 - 17 + 1)) # End-Matrix
  C = as.matrix(x[, m:n]) # C = Matrix aus Datensat
  j = 1
  
  # loop, geht durch C durch bis vorletze Spalte und setzt in B ein
  for (i in rep(1:16, each = 3)) {
    B[, j] = C[, i]
    j = j + 1
  }
  
  # loop, nimmt letzte Spalte von C und setzt diese in B ein von 65 bis 100
  for (i in (65 - 17 + 1):(100 - 17 + 1)) {
    B[, i] = C[, 17]
  }
  
  # setzt in jeder Zeile bei den Spalte > Alter 0 ein
  age = as.matrix(Pers_select$Alter, nrow = p, ncol = 1)
  for (i in 1:p) {
    b = age[i] + 1 # Alter + 1 -> Grenze
    c = b - 17 + 1 # korrespondierende Spalte für Alter + 1
    B[i, c:84] = 0
  }
  
  # macht ein Data.frame mit dem Alter als Spaltenvariable
  # alle NAs werden mit 0 ersetzt
  # Berechnung Summe Stunden pro Woche
  # Berchnung cummulative Traning hours
  avghpw_DodU = data.frame(B)
  colnames(avghpw_DodU) <- A
  avghpw_DodU[is.na(avghpw_DodU)] <- 0
  avghpw_DodU$cum_train_hpw <- rowSums(avghpw_DodU)
  cum_train_h <- 52 * avghpw_DodU$cum_train_hpw
  
  return(cum_train_h)
}

Dol_select$cum_trainingh_DuU <- cum_train_h_Dol(Dol_def, 32, 48)

age = as.matrix(Pers_select$Alter, nrow = p, ncol = 1)

Dol_select$Prozent_cumth_Life <-
  (Dol_select$cum_trainingh_DuU / ((age - 17) * 52 * 16 * 7)) * 100

Dol_select$hpd_DuU <- (Dol_select$cum_trainingh_DuU / ((age - 17) * 52 *
                                                         7))


# Berechnung Musik Datensatz
cum_train_h_Musik = function(x, m, n) {
  # x = Dataset
  # m = 1. Spalte im Datensatz x mit 1. Alterskategorie
  # n = letzte Spalte im Datensatz x mit letzter Alterskategorie
  p = nrow(x)
  A = matrix(0:100, nrow = 1, ncol = (101)) # Matrix mit Alter
  B = matrix(nrow = p, ncol = (101)) # End-Matrix
  C = as.matrix(x[, m:n]) # C = Matrix aus Datensat
  age_upper = matrix(nrow= p, ncol =1)
  age_under = matrix(nrow= p, ncol =1)
  j = 9
  
  # loop, geht durch C durch und setzt in B ein
  # für die Jahre 0 bis 7
  for (i in 1:8) {
    B[, i] = C[, 1]
  }
  
  # für die Jahre 8 bis 64
  for (i in rep(2:20, each = 3)) {
    B[, j] = C[, i]
    j = j + 1
  }
  
  # loop, nimmt letzte Spalte von C und setzt diese in B ein von 65 bis 100
  for (i in (65 + 1):(100 + 1)) {
    B[, i] = C[, 21]
  }
  
  # obere und untere Grenze setzten
  Musik_select$Alter_Ende_HI[is.na(Musik_select$Alter_Ende_HI)] <- 0
  Musik_select$Alter_Ende_ZI[is.na(Musik_select$Alter_Ende_ZI)] <- 0
  Musik_select$Alter_HI[is.na(Musik_select$Alter_HI)] <- 0
  Musik_select$Alter_ZI[is.na(Musik_select$Alter_ZI)] <- 0
  
  for (i in 1:p) {
    if (Musik_select$Instument_ueb_Schule[i] == "Ja") {
      age_upper[i] = Pers_select$Alter[i]
      if (Musik_select$Alter_Ende_HI[i] != 0) {
        age_upper[i] = Musik_select$Alter_Ende_HI[i]}
      age_under[i] = Musik_select$Alter_HI[i]
      if (Musik_select$spielt_Zweitinstrument[i] == "Ja") {
        if (age_upper[i] < Musik_select$Alter_Ende_ZI[i]) {
          age_upper[i] = Musik_select$Alter_Ende_ZI[i] }
        if (age_under[i] > Musik_select$Alter_ZI[i] ) {
          age_under[i] = Musik_select$Alter_ZI[i] }
      } # 2. if
      if (age_upper[i] > Pers_select$Alter[i]) {
        age_upper[i] = Pers_select$Alter[i]
      }
      x = age_under[i] - 1
      B[i, x:0] = 0 
      y = age_upper[i] + 1
      B[i, y:101] = 0
    } else {# 1. if
      B[i, 1:101] = 0 }# 1. if
  }# for
  
  
  avghpw_M = data.frame(B)
  colnames(avghpw_M) <- A
  avghpw_M[is.na(avghpw_M)] <- 0
  avghpw_M$cum_train_hpw <- rowSums(avghpw_M)
  cum_train_h <- 52 * avghpw_M$cum_train_hpw
  
  return(cum_train_h)
}


Musik_select$cum_trainingh_Musik <-
  cum_train_h_Musik(Musik_def, 16, 36)

Musik_select$Prozent_cumth_Life <-
  (Musik_select$cum_trainingh_Musik / (age * 52 * 16 * 7)) * 100

Musik_select$hpd_Musik <- (Musik_select$cum_trainingh_Musik / (age * 52 *
                                                         7))


##Join Datasets----
hgf <- full_join(Pers_select,Dol_select, by = c("VPN_Code","Antwort_ID"))
hgf <- full_join(hgf, Sprachen_select, by = c("VPN_Code","Antwort_ID"))
hgf <- full_join(hgf, Musik_select, by = c("VPN_Code","Antwort_ID"))

## Set Dataset as Tibble ----
hgf <- hgf %>% 
  as_tibble()


## Clean up workspace
remove(age, Dol_def, Dol_select,Musik_def, Musik_select, Pers_def,Pers_select,Sprachen_def, Sprachen_select, hgf_incomplete, hgf_raw, dataFolder, dataFolderRaw, cum_train_h_Dol, cum_train_h_Musik)




#doubles_df <- doubles_df %>% 
#  as_tibble()
#hgf_incomplete <- hgf_incomplete %>% 
#  as_tibble()


## Save Dataframes ----

#save(hgf, file = file.path(dataFolder,"hgf.RData"))
#save(hgf_incomplete, file = file.path(dataFolder,"hgf_incomplete.RData"))
#save(doubles_df, file = file.path(dataFolder,"hgf_doubles.RData"))




