

```{r warning= FALSE, message=FALSE, echo=FALSE}

fixation_evaluation_total_trimmed_select <- fixation_evaluation_total_trimmed_2 %>% 
  select(group,condition, percunknown, totalwordpersentence, regressionpersentence)


tbl_strata(
  fixation_evaluation_total_trimmed_select,
  strata = c(group),
  .tbl_fun =
    ~ .x %>%
    tbl_summary(by = condition,
                label = list(percunknown ~ "Percentage unknown fixations", totalwordpersentence ~ "Fixations on words per sentence",regressionpersentence ~ "Regressions per sentence"),
                type = list(percunknown ~ "continuous2",totalwordpersentence ~ "continuous2",regressionpersentence ~ "continuous2"),
                statistic = list(all_continuous() ~ 
                                   c("{mean}",
                                     "{median} ({p25}, {p75})", 
                                     "{min}, {max}")),
                missing = "no")
)    %>% 
  modify_header(label = "**Variable**") %>% # update the column header
  modify_caption("**Evaluation of fixations**") %>% 
  bold_labels() %>%
  italicize_levels()
```

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
# Operationalization
.left-column[
English-Test

Limesurvey

HAWIK-IV

TMT
  
N-Back
  
Control Questions
  
Perceived Difficulty
  
## Reading Task

Copying Task

Translating Task
]

.right-column[


]

---
# Reading Task
  
```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis"} 

rd <- readingDuration %>% 
  group_by(group, text, condition) %>%
  summarise(meanRDpS = mean(avgReadingDuration))

DT::datatable(rd,fillContainer = FALSE, options = list(pageLength = 6), editable = TRUE)
```

---

```{r echo = FALSE}
list_names = c("English-Test",
               "Limesurvey",
               "HAWIK-IV",
               "TMT",
               "N-Back",
               "Control Questions",
               "Perceived Difficulty",
               "Reading Task",
               "Copying Task",
               "Translating Task")
```
# Operationalization
.left-column[
`r list_names[1]`

`r list_names[2]`

`r list_names[3]`

`r list_names[4]`

`r list_names[5]`

`r list_names[6]`

`r list_names[7]`

`r list_names[8]`

##`r list_names[9]`

`r list_names[10]`
]

.right-column[



]
---
# Copying Task
  
```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis"} 
source(file.path("R/Preprocessing/copyingtask.R"))

group_data <- vpdata %>% 
  filter(id != c("C10","CXY","C20")) %>% 
  select(id, group)

copy <- full_join(group_data, res_copy, by="id")

copy <- copy %>%
  filter(id != c("C00")) %>% 
  pivot_longer(cols = c("T1_SE_copy","T1_ELF_copy", "T2_SE_copy", "T2_ELF_copy"), 
               names_to = "task", values_to = "stringDist")

stringDist <- copy %>%
  filter(!is.na(stringDist)) %>% 
  group_by(group, task) %>%
  summarise(meanStringDist = mean(stringDist))

```
---
# Copying Task
  
```{r error=FALSE, warning=FALSE, message=FALSE, comment = "", results = "asis"} 
DT::datatable(stringDist,fillContainer = FALSE, options = list(pageLength = 8), editable = TRUE)
```

---
# Operationalization
.left-column[
`r list_names[1]`

`r list_names[2]`

`r list_names[3]`

`r list_names[4]`

`r list_names[5]`

`r list_names[6]`

`r list_names[7]`

`r list_names[8]`

`r list_names[9]`

## Translating
]

.right-column[

]


---
# EEG
.pull-left[
### Workload

1) **Gevins (1997):**  

- Frontal midline theta:  
 Magnitude increases with workload

- Parietocentral alpha:  
Magnitude decreases with workload  

2) Frontal theta as indication<sup>1</sup>

3) **Holm et al. (2009):** Fz-theta / Pz-alpha - Ratio

.footnote[
  1) Cavanagh & Frank (2014), Doppelmayr, Finkenzeller & Sauseng (2008),  
  Ishii et al. (1999), Kubota et al. (2001), Luu, Tucker & Makeig (2004),  
  Rutishauser et. al. (2010), Sammer et al. (2007)
  ]
]
--
.pull-right[
### Fixation related potentials (FRP)
- Event related potentials
- Starting and ending with fixations
- Challenges: 
  - Coregistrate EEG and Eyetracking<sup>2</sup>
  - Eye movement artifacts
  - Differential overlap
  - Parafovea-on-fovea effects
  - Where is ELF in the text?
  
.footnote[
  2)Dimigen et al. (2011)]
 
]
???
Word your interested in would be Baseline-Corrected with P300 of previous word
---
class: inverse, mline, center, middle

# Tools I've used so far

---
  # Matlab
  .left-column[
    ## Psychtoolbox
    ]
.right-column[
  - Interface between computer hardware, EEG software,  Eyelink and Matlab
  
  - Open source
  
  - Set of functions for vision and neuroscience research
  
  - Easier than low-level programming languages (e.g. C, Pascal)
  
  - Accurate controlled visual and auditory stimuli
  
  - Interaction with participant
  
  ]
.footnote[https://psychtoolbox.org  
          https://github.com/Psychtoolbox-3/Psychtoolbox-3]
---
  # Matlab
  .left-column[
    ## Automagic
    ]
.right-column[
  - Standardized preprocessing of big EEG Data
  
  - Open source
  
  - eeglab plugin
  
  - Build by the group of Nicolas Langer
  
  ]
.footnote[https://github.com/methlabUZH/automagic]  

---
  # Matlab
  .left-column[
    ## EEGLAB
    ]
.right-column[
  - Toolbox for processing continuous and event-related EEG
  
  - Open source
  
  - Swartz Center for Computational Neuroscience
  ]
.footnote[https://sccn.ucsd.edu/eeglab/index.php]  

---
  # RStudio
  
  - Open Source

--
  
  - Fast growing community

--
  
  - Reproducible research

--
  
  - Structuring projects
- https://www.geo.uzh.ch/microsite/reproducible_research/post/rr-r-publication/
  
  --
  
  - Version controlling of source code via git

--
  
  - https://rstudio.com/resources/cheatsheets/
  
  ---
  # RMarkdown
  
  ![](figures/doko_presentation/markdown.png)

---
  # RMarkdown
  .pull-left[
    - Knitr
    - Rscript
    - Markdown
    - .bib
    - html
    - tikz
    - JavaScript / CSS / remark
    - Python
    - C++
      - C / Fortran
    
    - Output formats:
      - html / websites
    - LaTeX
    - pdf
    - word
    - powerpoint
    ]
.pull-right[
  
  - HTML widgets and Shiny documents
  
  - Journal articles 
  - papaja (Preparing APA Journal Articles)
  - rticles package
  - future: R Markdown submission
  
  - Books
  - Data presentation using Xaringan ;-)
.footnote[
  https://bookdown.org/yihui/rmarkdown/basics.html
  ]
]

---
  
  # GitHub
  
  ![](figures/doko_presentation/version_controlling.png)

---
  #GitHub
  
  * https://aberdeenstudygroup.github.io/studyGroup/lessons/SG-T1-GitHubVersionControl/VersionControl/
  
  * Synchronise GitHub repositories with RStudio projects

* Version controlling and collaborations

* Worldwide access to your files

* Synchronise with Overleaf

* Easy way to make your scripts and data analysis public

---
  
  class: inverse, mline, center, middle

# Thanks for listening
