%% EEG ERP calculation grand average %%

%% Preparation:
clear

%% Change directory to the current m. file
% by hand or by code:
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

%% Path to server depending on OS

if IsOSX == true
    ServerPath = '/Volumes/CLINT/'; % Server Path
    allDataPath = '/Volumes/CLINT/All_Data/'; % All Data Path
    EEGLDTPath = '/Volumes/CLINT/LDT_new/'; % LDT Path
    LDT_results = '/Volumes/CLINT/LDT_preprocessed/';
    addpath('/Volumes/CLINT/fieldtrip-20200607/'); % add fieldtrip path
    addpath('/Volumes/CLINT/eeglab2020_0/');
    
else
    ServerPath = '//130.60.235.123/users/neuro/Desktop/CLINT/'; % Server Path
    allDataPath = '//130.60.235.123/users/neuro/Desktop/CLINT/All_Data/'; % All Data Path
    EEGLDTPath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT_new/'; % LDT Path
    LDT_results = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT_preprocessed/'; % LDT Path
    addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
    addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path

end

% Corona Homeoffice 2.0 Version
% allDataPath = 'E:/All_Data/'; % All Data Path
% EEGLDTPath = 'E:/LDT_doko/'; % LDT Path
% LDT_results = 'E:/LDT_doko/';
% addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
% addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path

%% Starting fieldtrip

diary([EEGLDTPath 'settings_EEG_05_erp_grandaverage_log.txt'])
diary on

ft_defaults;
diary off

%% load files for headmodeling

load('headmodeling/eeglabchans');
load('headmodeling/elec_aligned');
load('headmodeling/labels105');
load('headmodeling/lay129_head');


%% Select desired subjects

cd(LDT_results);

vplist = dir('C*');
vpNames = {vplist.name};

% load quality ratings
quality_scores = readtable('quality_scores.csv');

% check if order of quality_scores and vpNames is equal
if isequal((quality_scores.SubjectID)', vpNames)
    disp('Quality_scores.SubjectID and vpNames are equal')
else
    disp('Quality_scores.SubjectID and vpNames are NOT equal')
    quality_scores = sortrows(quality_scores, 1);
end

%%
cfg = [];

for zz= 1:length(vpNames)

        
    load([LDT_results vpNames{zz} '/' vpNames{zz} '_LDT_EEG_erp.mat']);
    
    if quality_scores(zz,:).quality_t1 ~= "Bad"
        all_erp_T1_G_HF{zz} = erp_T1_G_HF_correct_bl;
        all_erp_T1_G_LF{zz} = erp_T1_G_LF_correct_bl;
        all_erp_T1_G_NW{zz} = erp_T1_G_NW_correct_bl;
    end
    

    if quality_scores(zz,:).quality_t2 ~= "Bad"
        all_erp_T2_E_HF{zz} = erp_T2_E_HF_correct_bl;
        all_erp_T2_E_LF{zz} = erp_T2_E_LF_correct_bl;
        all_erp_T2_E_NW{zz} = erp_T2_E_NW_correct_bl;
    end
    

    if vpNames{zz} ~= "C50" || quality_scores(zz,:).quality_t3 ~= "Bad"
        all_erp_T3_G_G{zz} = erp_T3_G_G_correct_bl;
        all_erp_T3_G_E{zz} = erp_T3_G_E_correct_bl;
        all_erp_T3_G_NW{zz} = erp_T3_G_NW_correct_bl;
        
        all_erp_T3_E_G{zz} = erp_T3_E_G_correct_bl;
        all_erp_T3_E_E{zz} = erp_T3_E_E_correct_bl;
        all_erp_T3_E_NW{zz} = erp_T3_E_NW_correct_bl;
        
        all_erp_T3_NW_G{zz} = erp_T3_NW_G_correct_bl;
        all_erp_T3_NW_E{zz} = erp_T3_NW_E_correct_bl;
        all_erp_T3_NW_NW{zz} = erp_T3_NW_NW_correct_bl;
    end
    
    all_erp_correct{zz} = erp_correct_bl;
    all_erp_error{zz} = erp_error_bl;
end

% find indices for each task to include in ga
ind_keep_T1 = find(quality_scores.quality_t1 ~= "Bad");
ind_keep_T2 = find(quality_scores.quality_t2 ~= "Bad");
ind_keep_T3 = find(quality_scores.quality_t3 ~= "Bad");

% compute all erps german tasks 
all_erp_T1_G_HF = all_erp_T1_G_HF(ind_keep_T1);
all_erp_T1_G_LF = all_erp_T1_G_LF(ind_keep_T1);
all_erp_T1_G_NW = all_erp_T1_G_NW(ind_keep_T1);

% compute all erps without missing english tasks 
all_erp_T2_E_HF = all_erp_T2_E_HF(ind_keep_T2);
all_erp_T2_E_LF = all_erp_T2_E_LF(ind_keep_T2);
all_erp_T2_E_NW = all_erp_T2_E_NW(ind_keep_T2);


% compute all erps without missing switch tasks form C50 = 12 and CM7 = 54
all_erp_T3_G_G = all_erp_T3_G_G(ind_keep_T3);
all_erp_T3_G_E = all_erp_T3_G_E(ind_keep_T3);
all_erp_T3_G_NW = all_erp_T3_G_NW(ind_keep_T3);
all_erp_T3_E_G = all_erp_T3_E_G(ind_keep_T3);
all_erp_T3_E_E = all_erp_T3_E_E(ind_keep_T3);
all_erp_T3_E_NW = all_erp_T3_E_NW(ind_keep_T3);
all_erp_T3_NW_G = all_erp_T3_NW_G(ind_keep_T3);
all_erp_T3_NW_E = all_erp_T3_NW_E(ind_keep_T3);
all_erp_T3_NW_NW = all_erp_T3_NW_NW(ind_keep_T3);

%% compute grand average
cfg = [];
ga_erp_T1_G_HF = ft_timelockgrandaverage(cfg, all_erp_T1_G_HF{:});
ga_erp_T1_G_LF = ft_timelockgrandaverage(cfg, all_erp_T1_G_LF{:});
ga_erp_T1_G_NW = ft_timelockgrandaverage(cfg, all_erp_T1_G_NW{:});

ga_erp_T2_E_HF = ft_timelockgrandaverage(cfg, all_erp_T2_E_HF{:});
ga_erp_T2_E_LF = ft_timelockgrandaverage(cfg, all_erp_T2_E_LF{:});
ga_erp_T2_E_NW = ft_timelockgrandaverage(cfg, all_erp_T2_E_NW{:});

ga_erp_T3_G_G = ft_timelockgrandaverage(cfg, all_erp_T3_G_G{:});
ga_erp_T3_G_E = ft_timelockgrandaverage(cfg, all_erp_T3_G_E{:});
ga_erp_T3_G_NW = ft_timelockgrandaverage(cfg, all_erp_T3_G_NW{:});

ga_erp_T3_E_G = ft_timelockgrandaverage(cfg, all_erp_T3_E_G{:});
ga_erp_T3_E_E = ft_timelockgrandaverage(cfg, all_erp_T3_E_E{:});
ga_erp_T3_E_NW = ft_timelockgrandaverage(cfg, all_erp_T3_E_NW{:});

ga_erp_T3_NW_G = ft_timelockgrandaverage(cfg, all_erp_T3_NW_G{:});
ga_erp_T3_NW_E = ft_timelockgrandaverage(cfg, all_erp_T3_NW_E{:});
ga_erp_T3_NW_NW = ft_timelockgrandaverage(cfg, all_erp_T3_NW_NW{:});

ga_erp_correct = ft_timelockgrandaverage(cfg, all_erp_correct{:});
ga_erp_error = ft_timelockgrandaverage(cfg, all_erp_error{:});


save([LDT_results 'LDT_erp_ga.mat'], 'all_erp_T1_G_HF', 'all_erp_T1_G_LF', 'all_erp_T1_G_NW',...
    'all_erp_T2_E_HF', 'all_erp_T2_E_LF', 'all_erp_T2_E_NW',...
    'all_erp_T3_G_G', 'all_erp_T3_G_E', 'all_erp_T3_G_NW',...
    'all_erp_T3_E_G', 'all_erp_T3_E_E', 'all_erp_T3_E_NW',...
    'all_erp_T3_NW_G', 'all_erp_T3_NW_E', 'all_erp_T3_NW_NW',...
    ...    
    'ga_erp_T1_G_HF', 'ga_erp_T1_G_LF', 'ga_erp_T1_G_NW',...
    'ga_erp_T2_E_HF', 'ga_erp_T2_E_LF', 'ga_erp_T2_E_NW',...
    'ga_erp_T3_G_G', 'ga_erp_T3_G_E', 'ga_erp_T3_G_NW',...
    'ga_erp_T3_E_G', 'ga_erp_T3_E_E', 'ga_erp_T3_E_NW',...
    'ga_erp_T3_NW_G', 'ga_erp_T3_NW_E', 'ga_erp_T3_NW_NW')


cd(fileparts(tmp.Filename));


