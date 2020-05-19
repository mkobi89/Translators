# Overview

--
  
  1. The Project

--
  
  2. Experiment with Translators

--
  
  3. Tools used to organise my PhD

--
  
  4. Psychtoolbox

.footnote[Style of slides by Metropolis Theme in Xaringan]
---
  
  class: inverse, mline, center, middle

# The Project

---
  
  # UZH Website
  ![](figures/doko_presentation/clint_ch_project.png)

.footnote[https://psy-klipsy-web01.uzh.ch/anmeldung-clint-u/about-clint-u/]
---
  # ZHAW Website
  
  ```{r fig.width=12, fig.height=6.5,echo=FALSE}
library(png)
library(grid)
img <- readPNG(file.path("figures/doko_presentation/zhaw_project.png"))
grid.raster(img)
```

.footnote[https://www.zhaw.ch/de/linguistik/institute-zentren/iued/forschung/clint/]
---
  # Research Question
  
  - English as Lingua Franca (ELF)

???
  Communication between two non-native speakers in English
Example: to keep the ball flat vs. to keep our feet on the ground
--
  
  - Increasingly more text and speeches in non-native English

--
  
  -  Challenging for translators

???
  ELF is more time and work demanding
--
  
  - Enhanced cognitive load while translating
---
  
  # Research Question
  
  Mixed method approach that addresses:
  
  --
  
  - Problems reading and translating ELF text vs. EdE text (Edited English)

--
  
  - Language proficiency depending differences while reading and translating ELF text vs. EdE text

--
  
  - Cognitive load while reading and translating ELF text vs. EdE text

--
  
  
  
  <t>using:</t>
  
  
  --
  
  - EEG

- Eyetracking

- Inputs from Translating and ELF science
---
  class: inverse, mline, center, middle

# Experiment with Translators

---
  # Participants
  
  L1: German

L2: English (Level C1)
--
  
  .pull-left[
    #### Translators (measured / recruited)
    
    - 30 Professionals (5 / 12) 
    
    - 30 Masters (7 / 6)
    
    - 30 Bachelors (0 / 0)]
--
  .pull-right[
    #### Multilinguals (measured / recruited)
    
    - 30 Professionals (5 / 1) 
    
    - 30 Masters (1 / 1)
    
    - 30 Bachelors (1 / 6)]
---
  # Methods
  
  .left-column[
    ## EEG
    
    ### Eyetracking
    
    ### Psychometrics
    
    ### LDT
    ]
.right-column[
  EGI 128-channel Geodesic Sensor Net<sup>1</sup>
    
    ![](figures/doko_presentation/geodesic.png)
  ]

.footnote[
  1) https://blricrex.hypotheses.org/files/2015/05/geodesic-sensor-net.pdf]

---
  # Methods
  .left-column[
    ### EEG
    
    ## Eyetracking
    
    ### Psychometrics
    
    ### LDT
    ]
.right-column[
  EyeLink 1000 Plus, SR Research<sup>2</sup>
    ![](figures/doko_presentation/eyelink.png)
  ]

.footnote[
  1) https://blricrex.hypotheses.org/files/2015/05/geodesic-sensor-net.pdf  
2) https://twitter.com/SRResearchLtd/status/993860152867590144/photo/1]

???
  infrared video-based eye tracker
---
  # Methods
  .left-column[
    ### EEG
    
    ### Eyetracking
    
    ## Psychometrics
    
    ### LDT
    ] 
.right-column[
  * HAWIE (short form)
  
  * TMT
  
  * N-Back (visual/auditory)
  ]

---
  # Methods
  .left-column[
    ### EEG
    
    ### Eyetracking
    
    ### Psychometrics
    
    ## LDT
    ] 
.right-column[
Visual Lexical Decision Task
  
  * German
  
  * English
  
  * Switch
  ]

---
  # Paradigm
  
  Picture of paradigm from tikZ

---
  # Reading Task
  
  Social Information and Energy Conservation - Environmental Identity and Social Norms  
ELF - Version

![](figures/doko_presentation/SI_ELF_1.png)

???
  Sentence by sentence
Double spacing

---
  # Reading Task
  
  Social Information and Energy Conservation - Environmental Identity and Social Norms  
ELF - Version

![](figures/doko_presentation/SI_ELF_1_2.png)

---
  # Reading Task
  
  Social Information and Energy Conservation - Environmental Identity and Social Norms  
ELF - Version

![](figures/doko_presentation/SI_ELF_2.png)

---
  # Reading Task
  
  Social Information and Energy Conservation - Environmental Identity and Social Norms  
EdE - Version

![](figures/doko_presentation/SI_ELF_1.png)

---
  # Reading Task
  
  Social Information and Energy Conservation - Environmental Identity and Social Norms  
EdE - Version

![](figures/doko_presentation/SI_EdE_2.png)

---
  # Perceived Difficulty
  
  ![](figures/doko_presentation/perceived_diff.png)


---
  # Control Questions
  
  Welches ist kein Element vom Home Electricity Report (HER)?
  
  1) Vergleich von Energieverbrauchlevel

2) Rückmeldung zur individuellen Performanz

3) Tipps, wie man mehr Energie verbrauchen kann

---
  # Copying Task
  
  Social Information and Energy Conservation - Environmental Identity and Social Norms  
EdE - Version

![](figures/doko_presentation/SI_EdE_copy.png)

---
  # Translating Task
  
  Social Information and Energy Conservation - Environmental Identity and Social Norms  
EdE - Version

![](figures/doko_presentation/SI_EdE_translate.png)

??? 
  Shortcommings: keyboard is limited

---
  # Translating Task
  
  memoQ

![](figures/doko_presentation/translating.png)

---
  
  # Operationalization
  .left-column[
    ### Behavioral Data
    ]
.right-column[
  * English-Test
  
  * Language Survey
  
  * WIE
  
  * TMT
  
  * N-Back
  
  * Reading Duration
  
  * Control Questions
  
  * Perceived Difficulty
  
  * Translating Task
  
  * Copying Task
  ]

---
  # English Test
  
  ```{r error=FALSE, warning=FALSE, comment="" }
source(file.path("R/Preprocessing/psychometrics.R"))
glimpse(vpdata)
```

---
  # English-Test
  
  ```{r fig.height=5, fig.width=10}
SpT <- vpdata %>% 
  filter(SpT_Score != 0) %>%
  group_by(group) %>% 
  summarise(SpT_means = mean(SpT_Score))

plot(with(SpT,SpT_means,group), type = "h")
```
---
  
  # English-Test
  
  ```{r plotSpT, fig.height=5, fig.width=10, message=FALSE, tidy = TRUE}
SpT <- vpdata %>% 
  filter(SpT_Score != 0) %>%
  group_by(group) %>% 
  summarise(SpT_means = mean(SpT_Score))

plot(with(SpT,SpT_means,group), main = "Language proficiency", xlab = "Group", ylab = "Score", type = "h")
remove(SpT)
```

---
  
  # English-Test
  
  ```{r finalplotSpT, dpi=600, fig.height= 3, warning= FALSE, message=FALSE}
source(file.path("R/Plots/PlotLanguageProficiency.R"))
```

---
  # Language Survey
  
  - Age of commencement

- Exposure to language

- Experience (cumulative training hours)

---
  # Language Survey
  ```{r error=FALSE, warning=FALSE, message=FALSE, comment = ""}
load(file.path("data/hgf.Rdata"))
load(file.path("data/hgf_doubles.Rdata"))

hgf <- hgf %>% 
  filter(group != "IntPro", group != "IntMA", group != "IntBA") %>% 
  select(VPN_Code, group, cum_trainingh_DuU, Prozent_cumth_Life.x,hpd_DuU, hpd_ALLE, Prozent_ALLE_pd)

colnames(hgf) <- c("id", "group", "cumTH_U", "percCumTH_U", "HpD_U", "HpD_L", "percHpD_L")

glimpse(hgf)
```

---
  # Language Survey
  
  ```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis"} 

doubles_df <- doubles_df %>% 
  select(VPN_Code, cum_trainingh_DuU, Prozent_cumth_Life.x,hpd_DuU)

colnames(doubles_df) <- c("id", "cumTH_U", "percCumTH_U", "HpD_U")

print(xtable(doubles_df,caption = "Doubled Datasets"), type = "html", html.table.attributes = "border=0")

```

---
  # Extraordinary long days
  ```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis", echo=FALSE} 

hgf_res <- hgf %>% 
  filter(percCumTH_U >= 15 | percHpD_L >= 100)

DT::datatable(
  hgf_res,
  fillContainer = FALSE, options = list(pageLength = 8), editable = TRUE
)

#print(xtable(hgf_res,caption = "Extraordinary long days"), type = "html", html.table.attributes = "border=0")

```

---
  # Language Survey
  ```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis"} 

hgf_res <- hgf %>% 
  group_by(group) %>% 
  summarise(meanCumTH_DuD = mean(cumTH_U), meanHpD_L = mean(HpD_L))

print(xtable(hgf_res,caption = "TraMa live longer!"), type = "html", html.table.attributes = "border=0")

```

---
  # Language Survey
  ```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis"} 

hgf_res <- hgf %>% 
  filter(group == "TraMA")

print(xtable(hgf_res,caption = "Study Translating!"), type = "html", html.table.attributes = "border=0")

```

---
  # WIE
  
  Short form with 4 subtests:
  
  - Gemeinsamkeiten finden

- Zahlen nachsprechen (vorwärts und rückwärts)

- Mosaik-Test

- Zahlensymboltest

--
  
  
  
  T-Values

**Highly correlating with full WIE**
  
  ---
  # WIE
  
  ```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis"} 
load(file.path("data/vpdata.Rdata"))

wie <- vpdata %>% 
  filter(!is.na(HAWIE_T_Value), id != "C24") %>% 
  group_by(group) %>%
  summarise(meanWIE = mean(HAWIE_T_Value), sdWIE = sd(HAWIE_T_Value))

print(xtable(wie,caption = "WIE"), type = "html", html.table.attributes = "border=0")
```

---
  # Trail Making Test
  
  - 2 subtests

- Processing speed

--
  
  - Mean processing time and errors 

---
  # Trail Making Test
  
  ```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis"} 

tmt <- vpdata %>% 
  filter(!is.na(t_TMT_A_in_s)) %>% 
  group_by(group) %>%
  summarise(meanTMT_A = mean(t_TMT_A_in_s), sdTMT_A = sd(t_TMT_A_in_s), meanF_A = mean(F_TMT_A), meanTMT_B = mean(t_TMT_B_in_s), sdTMT_B = sd(t_TMT_B_in_s),meanF_B = mean(F_TMT_B))

print(xtable(tmt,caption = "WIE"), type = "html", html.table.attributes = "border=0")
```

---
  
  
  