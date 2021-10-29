%% EEG ERP plotting statistics %%

%% Preparation:
clear

%% Change directory to the current m. file
% by hand or by code:
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

%% Path to server depending on OS

% if IsOSX == true
%     ServerPath = '/Volumes/CLINT/'; % Server Path
%     allDataPath = '/Volumes/CLINT/All_Data/'; % All Data Path
%     EEGLDTPath = '/Volumes/CLINT/LDT_new/'; % LDT Path
%     LDT_results = '/Volumes/CLINT/LDT_results/';
%     addpath('/Volumes/CLINT/fieldtrip-20200607/'); % add fieldtrip path
%     
% else
%     ServerPath = '//130.60.235.123/users/neuro/Desktop/CLINT/'; % Server Path
%     allDataPath = '//130.60.235.123/users/neuro/Desktop/CLINT/All_Data/'; % All Data Path
%     EEGLDTPath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT/'; % LDT Path
%     LDT_results = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT_results/'; % LDT Path
%     addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
% end

% Corona Homeoffice 2.0 Version
allDataPath = 'E:/All_Data/'; % All Data Path
EEGLDTPath = 'E:/LDT_doko/'; % LDT Path
LDT_results = 'E:/LDT_doko/';
addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path

%% Starting fieldtrip

diary([EEGLDTPath 'settings_EEG_05_plotting_statitics_log.txt'])
diary on

ft_defaults;
diary off

%% load files for headmodeling

load('headmodeling/eeglabchans');
load('headmodeling/elec_aligned');
load('headmodeling/labels105');
load('headmodeling/lay129_head');


%% Select desired subjects

cd(allDataPath);

vplist = dir('C*');
vpNames = {vplist.name};

cd(LDT_results);

%% load data

load('LDT_erp_ga.mat', 'all_erp_T1_G_HF','all_erp_T1_G_LF', 'all_erp_T1_G_NW',...
    'ga_erp_T1_G_HF', 'ga_erp_T1_G_LF', 'ga_erp_T1_G_NW');

clearvars all_erp_T1_G_HF
clearvars all_erp_T1_G_LF
clearvars all_erp_T1_G_NW

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));
cd('../data/dm_data_outliers/');

% word vs nonword response ? varying z 
corr_est_parms_word_nonword_G = readtable('corr_est_parms_word_nonword_G.txt');
corr_est_parms_word_nonword_E = readtable('corr_est_parms_word_nonword_E.txt');
corr_est_parms_word_nonword_SW = readtable('corr_est_parms_word_nonword_SW.txt');

% unerwünschte Probanden rausnehmen ? German task
sub2deleteG = find(corr_est_parms_word_nonword_G.dataset == "C67" | ...
    corr_est_parms_word_nonword_G.dataset == "C69" | ...
    corr_est_parms_word_nonword_G.dataset == "CE1" | ...
    corr_est_parms_word_nonword_G.dataset == "CI1" | ...
    corr_est_parms_word_nonword_G.dataset == "CI7" | ...
    corr_est_parms_word_nonword_G.dataset == "CM2");

corr_est_parms_word_nonword_G(sub2deleteG,:) = [];


% unerwünschte Probanden rausnehmen ? English task
sub2deleteE = find(corr_est_parms_word_nonword_E.dataset == "C67" | ...
    corr_est_parms_word_nonword_E.dataset == "C69" | ...
    corr_est_parms_word_nonword_E.dataset == "CE1" | ...
    corr_est_parms_word_nonword_E.dataset == "CI1" | ...
    corr_est_parms_word_nonword_E.dataset == "CI7" | ...
    corr_est_parms_word_nonword_E.dataset == "CM2" | ...
    corr_est_parms_word_nonword_E.dataset == "CE5");

corr_est_parms_word_nonword_E(sub2deleteE,:) = [];

% unerwünschte Probanden rausnehmen ? Switch task
sub2deleteSW = find(corr_est_parms_word_nonword_SW.dataset == "C67" | ...
    corr_est_parms_word_nonword_SW.dataset == "C69" | ...
    corr_est_parms_word_nonword_SW.dataset == "CE1" | ...
    corr_est_parms_word_nonword_SW.dataset == "CI1" | ...
    corr_est_parms_word_nonword_SW.dataset == "CI7" | ...
    corr_est_parms_word_nonword_SW.dataset == "CM2" | ...
    corr_est_parms_word_nonword_SW.dataset == "CM7" | ...
    corr_est_parms_word_nonword_SW.dataset == "C50");

corr_est_parms_word_nonword_SW(sub2deleteSW,:) = [];


%% Calculate diffusionvalues
% ()' brings the data into the desired format
% abs() calculates the absolute values

% German task
diffusionvalues_T1_G_HF = abs((corr_est_parms_word_nonword_G.v_high_frequency)');
diffusionvalues_T1_G_LF = abs((corr_est_parms_word_nonword_G.v_low_frequency)');
diffusionvalues_T1_G_NW = abs((corr_est_parms_word_nonword_G.v_non_word)');

% English Task
diffusionvalues_T2_E_HF = abs((corr_est_parms_word_nonword_E.v_high_frequency)');
diffusionvalues_T2_E_LF = abs((corr_est_parms_word_nonword_E.v_low_frequency)');
diffusionvalues_T2_E_NW = abs((corr_est_parms_word_nonword_E.v_non_word)');

% Switch Task
diffusionvalues_T3_G_G = abs((corr_est_parms_word_nonword_SW.v_nsw_d_d)');
diffusionvalues_T3_G_E = abs((corr_est_parms_word_nonword_SW.v_sw_d_e)');
diffusionvalues_T3_E_E = abs((corr_est_parms_word_nonword_SW.v_nsw_e_e))';
diffusionvalues_T3_E_G = abs((corr_est_parms_word_nonword_SW.v_sw_e_d)');

%% plot multiple channels

cfg = [];
cfg.layout = lay129_head;
cfg.channel = {'all'};
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq   = 0.5;
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq   = 15;
cfg.showlabels = 'yes';
figure;
ft_multiplotER(cfg,ga_erp_T1_G_HF, ga_erp_T1_G_LF, ga_erp_T1_G_NW);

%ft_multiplotER(cfg,erp_T1_G_HF_correct_bl);
%% plot single channel
cfg = [];
cfg.layout = lay129_head;
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq   = 0.5;
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq   = 15;
cfg.showlegend = 'yes';
cfg.channel = {'E53', 'E54', 'E60', 'E61', 'E62', 'E66', 'E67', 'E71', 'E72', 'E76', 'E77',...
    'E78','E79', 'E84', 'E85', 'E86'};
figure;
ft_singleplotER(cfg,ga_erp_T1_G_HF, ga_erp_T1_G_LF, ga_erp_T1_G_NW);

%%  plot topography
% cfg = [];
% cfg.layout = lay129_head;
% cfg.preproc.hpfilter = 'yes';
% cfg.preproc.hpfreq   = 0.5;
% cfg.xlim = [0.375346 0.476728];
% figure;
% ft_topoplotER(cfg,ga_erp_T1_G_HF);

%% create neighbours
cfg = [];
cfg.elec = elec_aligned;
cfg.method = 'distance';
cfg.feedback = 'yes';
neighbours = ft_prepare_neighbours(cfg);

%% vorrelation with v_German hf
% compute statistics with correlationT
cfg = [];
cfg.statistic        = 'ft_statfun_correlationT';
cfg.method           = 'montecarlo';
cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.alpha            = 0.0025;% alpha 0.05 two tails thus 0.025 per tail, or  0.0017 beacuse of 15 correaltions
cfg.latency          = [0 2];
n1 = numel(diffusionvalues_T1_G_HF);    % n1 is the number of subjects
% diffusionvalues= randn(1,numel(vpNames));
design(1,1:n1)       = diffusionvalues_T1_G_HF; %here we insert our independent variable (behavioral data) in the cfg.design matrix, in this case reaction times of 3 subjects.

cfg.design           = design;
cfg.ivar             = 1;
cfg.neighbours       = neighbours;
stat = ft_timelockstatistics(cfg, all_erp_T1_G_HF{:});

%%
cfg = [];
cfg.layout = lay129_head;
cfg.channel = {'all'};
cfg.parameter = 'rho';
cfg.maskparameter = 'mask';
figure;
ft_multiplotER(cfg,stat);



%% vorrelation with v_German lf
% compute statistics with correlationT
cfg = [];
cfg.statistic        = 'ft_statfun_correlationT';
cfg.method           = 'montecarlo';
cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.alpha            = 0.025;% alpha 0.05 two tails thus 0.025 per tail, or  0.0017 beacuse of 15 correaltions
cfg.latency          = [0 2];

n1 = numel(diffusionvalues_T1_G_LF);    % n1 is the number of subjects
% diffusionvalues= randn(1,numel(vpNames));
design(1,1:n1)       = diffusionvalues_T1_G_LF; %here we insert our independent variable (behavioral data) in the cfg.design matrix, in this case reaction times of 3 subjects.

cfg.design           = design;
cfg.ivar             = 1;
cfg.neighbours       = neighbours;
stat = ft_timelockstatistics(cfg, all_erp_T1_G_LF{:});

%%
cfg = [];
cfg.layout = lay129_head;
cfg.channel = {'all'};
cfg.parameter = 'rho';
cfg.maskparameter = 'mask';
figure;
ft_multiplotER(cfg,stat);

%% vorrelation with v_German hf
% compute statistics with correlationT
cfg = [];
cfg.statistic        = 'ft_statfun_correlationT';
cfg.method           = 'montecarlo';
cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.alpha            = 0.025;% alpha 0.05 two tails thus 0.025 per tail, or  0.0017 beacuse of 15 correaltions
cfg.latency          = [0 2];
n1 = numel(diffusionvalues_T1_G_NW);    % n1 is the number of subjects
% diffusionvalues= randn(1,numel(vpNames));
design(1,1:n1)       = diffusionvalues_T1_G_NW; %here we insert our independent variable (behavioral data) in the cfg.design matrix, in this case reaction times of 3 subjects.

cfg.design           = design;
cfg.ivar             = 1;
cfg.neighbours       = neighbours;
stat = ft_timelockstatistics(cfg, all_erp_T1_G_NW{:});

%%
cfg = [];
cfg.layout = lay129_head;
cfg.channel = {'all'};
cfg.parameter = 'rho';
cfg.maskparameter = 'mask';
figure;
ft_multiplotER(cfg,stat);