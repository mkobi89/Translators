# Translators

This repository is used for the CLINT Translators Project from UZH and ZHAW.
For more information: matthias.kobi@gmail.com / matthias.kobi@uzh.ch

Folders with content description:

Task:
- a detailed task description can be found in the Manuskript_LDT.docx
- Stimulus material: 2 abstracts in two versions (ELF vs EdE) result in 4 texts, that can be found in "CLINT experiment"
	Text 1: 'ABS_Social_Info_SE.csv' --> SI_EdE
	Text 2: 'ABS_Social_Info_ELF.csv' --> SI_ELF
	Text 3: 'ABS_Energy_Advisors_SE.csv' --> EA_SE
	Text 4: 'ABS_Energy_Advisors_ELF.csv' --> EA_ELF
- For both abstracts (E1 and E2): 3 tasks, a reading task, a copying task (5 minutes), a translation task (5 minutes), (then LDT as described in other project), and E3 --> reading post (reading the texts in the other version, ELF or EdE)
- CLINT_MAIN.m in "CLINT experiment" was used to control experiment with Psychtoolbox 3
- Randomization: order of both text and version for first part (E1), but then other text in other version was used for E2 --> therefore, if SI_ELF was Exp1, EA_EdE was Exp2, EA_ELF was then reading_post 1 and EA_EdE was reading_post 2
		 reading task was always first, order of copying / translation task was randomized, but changed from E1 to E2
- files_new.m in "CLINT experiment" was used to read in stimulus material to Matlab, insert double spacing and double lines
- verst_fragen.csv in "CLINT experiment" contains control questions for both abstracts

Translators/data/rawdata:
- fft: contains exports from BVA for theta (4-7 Hz) and alpha (8-12 Hz)
- matlab_rawdata: contains all MATLAB answer files from CLINT task
- nback_logs: contains .txt logfiles from auditory and visual nback task
- task: "task/copying": contains answers of copying task from all participant in .csv, 
        "task/translation": contains answers of translation task from all participant in .csv, 
	"task/textfiles": contains answers of copying and translation task from all participant in .txt
	stimulus.csv: contains stimulus material used CLINT task, used for analysis of stringdist.R
	translation_rating_t1.csv: contains randomized answers from text 1 (SI_EdE and SI_ELF) translation task from all participants for rating of fluency and accuracy
	translation_rating_t2.csv: contains randomized answers from text 2 (EA_EdE and EA_ELF) translation task from all participants for rating of fluency and accuracy
- controlQuestions.csv: contains answers for control questions
- expControl.csv: contains experimental control variables (i.e., randomizations) for all participants
- hintergrund.csv: contains answers from language background questionaires for all CLINT participants (including simultaneous interpreters)
- perceivedDifficulties.csv: contains answers from perceived difficulties after reading and translation task
- quality_scores.csv: contains Automagic preprocessing scores for all participants
- readingDuration.csv: contains behavioural data from reading task
- readingFixations.csv: contains fixations from eyetracking for all participants
- textOutput.csv: contains keyboard data from copying and translation task 
- psychometrics.csv: psychometrics rawdata for participants in LDT

Translators/data/translation_rating:
- I know its a bit a mess, because we added more participants after initial attempt to rate all participants
- in "data/translation_rating/results" ratings from all 3 raters can be found (R1-R3)

Translators/data/alldata_translators.csv: contains all data from CLINT translator project used in the manuscript

All_data/C*/
- contains all data from CLINT translator project
- *_EEG.mat: EEG data from E1, E2, E3, LDT, Instructions and EEG resting state (_RS_EEG.mat)
- *_ET.mat: ET data from E1, E2, E3, LDT, Instructions and EEG resting state (_RS_EEG.mat)
- Fullresults*.mat: important variables from CLINT task
- Allvariables*.mat: all variables collected through Matlab / Psychtoolbox
- .GAIN: channel gains measured before Experiment
- .HIST: EEG history files with recording information and events
- .IMP: channel impedances (a total of 5 times optimized and measured)
- EEG raw file --> Netstation binary raw file

figures: contains all figures used for manuscript

Translators/Matlab:
- Translators_EEG_01_taskwise_segmentation_for_automagic.m: prepare raw EEG data of CLINT translator project ("All_data/C*/C*_E*T*_(SE/EFL)_EEG.mat", and "All_data/C*/C*_E3_EEG.mat") and split them into separate files per task for automagic preprocessing
- Translators_EEG_02_convert_to_BVA.m: merge preprocessed EEEG data and convert them to BVA
- BHD_preparing.m: copy all Fullanswers*.mat in "All_Data" to "Translators/data/rawdata/matlab_rawdata", collect all behavioral data from CLINT translator project and write .csv files found in "data/rawdata"
- Translators_eyetracker_analysis.m: collects fixations from reading task eyetracker files ("All_data/C*/C*_E*T*_(SE/EFL)_ET.mat") and compare them to word boundaries of presented stimulus material (variable wordbounds_reading in "Translators/data/rawdata/matlab_rawdata/Fullresults_ELF_C*.mat")


Translators/R: contains all RSkripts
- master.R: controls all R files, gets and organises data, excludes unwanted participants, produces table summaries, and calculates statistics
- 01_psychometrics.R: processes psychometrics.csv in "Translators/data/rawdata"
- 02_nback.R: processes nback log files in "Translators/data/rawdata/nback_logs" and calculates dprimes for both auditory and visual nback task
- 03_language_survey.R: processes hintergrund.csv in "Translators/data/rawdata" to collect information about language background and translation experience. Additional information can be found in "Translators/Mastersheet_languagebackground.docx" (line numbers might have changed slightly)
- 04_copyingtask.R: compares answers in copying task from "Translators/data/rawdata/task/copying" (.csv) with stimulus material using R package "stringdist"
- 05_fft.R: collects fft data from "Translators/data/rawdata/fft", and calculates frontal theta and parietal alpha
- 07_fluency.R: collects fluency rating data of translation task from all 3 raters in "Translators/data/translation_rating", and calculates a mean Rater (averaged for each text/version) and calculates icc
- 08_accuracy.R: collects accuracy rating data of translation task from all 3 raters in "Translators/data/translation_rating", and calculates a mean Rater (averaged for each text/version) and calculates icc
- 09_merging_data.R: collects and merges all data from previous R scripts and all other .csv files in "Translators/data/rawdata"
- translation_rating_randomisation.R: randomizes answers from translation task in "Translators/data/translation_rating/translation_rating_t*.csv" for rating of fluency and accuracy

Probandenauswahl.xlsx: contains information to exclude participants based on psychometrics and difficulties with CLINT task (translated instead of copyied)

EEG: EGI geodesics
- sampling rate: 500 Hz
- electrodes: 128
- reference electrode: Cz

Trigger:
- all triggers of the CLINT task can be found in matlab answer files in "Fullanswers*.mat" in "Translators/data/rawdata/matlab_rawdata", see variable par.trigger
- important triggers for CLINT task:
    % Start of different parts of CLINT project --> variable name, trigger number, description
 - par.trigger.rs_eo_start = 1; rs_eo = Resting state EEG eyes open (3 minutes)
 - par.trigger.rs_eo_stop = 2; 
 - par.trigger.rs_ec_start = 3; rs_ec = Resting state EEG eyes closed (3 minutes)
 - par.trigger.rs_ec_stop = 4;

 - par.trigger.ldt_start = 5; ldt = Lexical decision task
 - par.trigger.ldt_stop = 6;


 - par.trigger.exp_1_start = 101:104; exp_1 = E1, 101:104 = 101 (SI_EdE), 102 (SI_ELF), 103 (EA_SE), 104 (EA_ELF)
 - par.trigger.exp_1_stop = 105:108; 105:108 = 105 (SI_EdE), 106 (SI_ELF), 107 (EA_SE), 108 (EA_ELF)
 - par.trigger.exp_2_start = 109:112; exp_2 = E2, 109:112 = 109 (SI_EdE), 110 (SI_ELF), 111 (EA_SE), 112 (EA_ELF)
 - par.trigger.exp_2_stop = 113:116; 113:116 = 113 (SI_EdE), 114 (SI_ELF), 115 (EA_SE), 116 (EA_ELF)
 - par.trigger.exp_post_start = 7; exp_post = E3
 - par.trigger.exp_post_stop = 8;


 - par.trigger.lesen_start=11:14; lesen_start = start reading task, 11:14 = 11 (SI_EdE), 12 (SI_ELF), 13 (EA_SE), 14 (EA_ELF)
 - par.trigger.lesen_end=15:18; lesen_end = end reading task, 15:18 = 15 (SI_EdE), 16 (SI_ELF), 17 (EA_SE), 18 (EA_ELF)
 - par.trigger.lesen_sentence_start=21:24; lesen_sentence_start = start sentence in reading task, 21:24 = 21 (SI_EdE), 22 (SI_ELF), 23 (EA_SE), 24 (EA_ELF)

 - par.trigger.abschreiben_start=31:34; abschreiben_start = start copying task, 31:34 = 31 (SI_EdE), 32 (SI_ELF), 33 (EA_SE), 34 (EA_ELF)
 - par.trigger.abschreiben_end=35:38; abschreiben_end = end copying task, 35:38 = 35 (SI_EdE), 36 (SI_ELF), 37 (EA_SE), 38 (EA_ELF)
 - par.trigger.abschreiben_sentence_start=51:54; abschreiben_sentence_start = start sentence in copying task, 51:54 = 51 (SI_EdE), 52 (SI_ELF), 53 (EA_SE), 54 (EA_ELF)

 - par.trigger.uebersetzen_start=41:44; uebersetzen_start = start translating task, 41:44 = 41 (SI_EdE), 42 (SI_ELF), 43 (EA_SE), 44 (EA_ELF)
 - par.trigger.uebersetzen_end=45:48; uebersetzen_end = end translating task, 45:48 = 45 (SI_EdE), 46 (SI_ELF), 47 (EA_SE), 48 (EA_ELF)
 - par.trigger.uebersetzen_sentence_start=61:64; uebersetzen_sentence_start = start sentence in translating task, 61:64 = 61 (SI_EdE), 62 (SI_ELF), 63 (EA_SE), 64 (EA_ELF)

 - par.trigger.lesen_post_start=71:74; lesen_post_start = start reading post task (E3), 71:74 = 71 (SI_EdE), 72 (SI_ELF), 73 (EA_SE), 74 (EA_ELF)
 - par.trigger.lesen_post_end=75:78; lesen_post_end = end reading post task (E3), 75:78 = 75 (SI_EdE), 76 (SI_ELF), 77 (EA_SE), 78 (EA_ELF)
 - par.trigger.lesen_sentence_post_start=81:84; lesen_sentence_post_start = start sentence in reading post task (E3), 81:84 = 81 (SI_EdE), 82 (SI_ELF), 83 (EA_SE), 84 (EA_ELF)


 - par.trigger.subempfschwierigkeit_lesen = 91:94; subempfschwierigkeit_lesen = perceived difficulty after reading task, 91:94 = 91 (SI_EdE), 92 (SI_ELF), 93 (EA_SE), 94 (EA_ELF)
 - par.trigger.subempfschwierigkeit_uebersetzen = 95:98; subempfschwierigkeit_uebersetzen = perceived difficulty after translation task, 95:98 = 95 (SI_EdE), 96 (SI_ELF), 97 (EA_SE), 98 (EA_ELF)

 - par.trigger.control_question = 89; start control questions
 - par.trigger.control_question_answer = 99; answer in control question

 - par.trigger.recalibration_start=120; start EEG and ET recalibration
 - par.trigger.recalibration_end=121; end EEG and ET recalibration
 - par.trigger.instructions_start=122; start instructions
 - par.trigger.instructions_end=123; end instructions

# Futher infos for repository and paths

GitHub Commands:
git remote add origin https://github.com/mkobi89/Translators.git
git clone https://github.com/mkobi89/Translators.git
git push -u origin master

