%% EEG read in data from RAW files %%

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
%     EEGLDTPath = '/Volumes/CLINT/LDT/'; % LDT Path
%     addpath('/Volumes/CLINT/fieldtrip-20200607/'); % add fieldtrip path
%     addpath('/Volumes/CLINT/eeglab2020_0/'); % add eeglab path
%
% else
%     ServerPath = '//130.60.235.123/users/neuro/Desktop/CLINT/'; % Server Path
%     allDataPath = '//130.60.235.123/users/neuro/Desktop/CLINT/All_Data/'; % All Data Path
%     EEGLDTPath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT/'; % LDT Path
%     addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
%     addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path
% end

% Corona Homeoffice 2.0 Version
allDataPath = 'E:/All_Data/'; % All Data Path
EEGLDTPath = 'E:/LDT/'; % LDT Path
addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path

%% Starting EEGLAB and fieldtrip
if ~(exist(EEGLDTPath)==7)
    mkdir(EEGLDTPath);
end

diary([EEGLDTPath 'settings_EEG_01_read_data_visualchannelrejection_log.txt'])
diary on

eeglab
close()

ft_defaults;
%open ft_trialfun_LDT.m
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



%% Check for target directory
%cd(EEGLDTPath);
for zz = 1:length(vpNames)
    if ~(exist([EEGLDTPath vpNames{zz}])==7)
        mkdir([EEGLDTPath vpNames{zz}]);
    else
        continue
    end
end


vpName = input('Subject to process: ','s');


if ~(exist([EEGLDTPath vpName '/' vpName '_LDT.mat'])==2)
    
    diary([EEGLDTPath vpName '/' vpName '_log.txt'])
    diary on
    
    %% Read data, define trials, low-pass filtering
    cfg = [];
    
    cfg.dataset = [allDataPath vpName '/ARCHIVE/' vpName '_LDT_EEG.RAW'];
   

    cfg.trialfun  = 'ft_trialfun_LDT';
    cfg.trialdef.prestim    = 2;
    cfg.trialdef.poststim   = 3; % it was 3
    cfg = ft_definetrial(cfg);
    
    % cfg.reref = 'yes';
    % cfg.refchannel = 'all';
    % cfg.implicitref   = 'Cz';
    
    cfg.lpfilter = 'yes';
    cfg.lpfreqtype = 'firws';
    cfg.lpfreq    = 40;
    
%     cfg.hpfilter = 'yes';
%     cfg.hpfreqtype = 'firws';
%     %cfg.hpfiltorder = 16;
%     cfg.hpfreq    = 0.25;
    
    dataorig = ft_preprocessing(cfg);
    
    %% Select 105 eeg channels
    cfg = [];
    cfg.channel = labels105;
    dataorig = ft_selectdata(cfg,dataorig);
    
    %% Save original data to EEGLDTPath
    save(fullfile([EEGLDTPath vpName '/' vpName '_LDT_orig.mat']), 'dataorig', '-v7.3');

    %% take elec
    ind=ismember(elec_aligned.label,dataorig.label);
    elec.chanpos= elec_aligned.chanpos(find(ind==1),:);
    elec.chantype= elec_aligned.chantype(find(ind==1));
    elec.chanunit= elec_aligned.chanunit(find(ind==1));
    elec.elecpos= elec_aligned.elecpos(find(ind==1),:);
    elec.homogeneous= elec_aligned.homogeneous;
    elec.label= elec_aligned.label(find(ind==1));
    elec.type= elec_aligned.type;
    elec.unit= elec_aligned.unit;
        
    %% create neighbours for interpolation after ICA
    cfg = [];
    cfg.elec = elec;
    cfg.method = 'distance';
    % cfg.feedback = 'yes';
    neighbours = ft_prepare_neighbours(cfg, dataorig);
    
    % exclude bad channels and rename dataset to dataclean
    cfg = [];
    cfg.hpfilter = 'yes';
    cfg.hpfreqtype = 'firws';
    cfg.hpfreq    = 0.3;
    data_hp = ft_preprocessing(cfg, dataorig);
    
    
    cfg = [];
    cfg.alim = 1e-12;
    cfg.method   = 'summary';
    dataclean = ft_rejectvisual(cfg,data_hp);
    
    % write down bad channels as cell-array : {'E7';'Oz'} for
    % interpolating after ICA
    artif.badchannel  = input('write badchannels: ');
    
    save(fullfile([EEGLDTPath vpName '/' vpName '_LDT_clean.mat']), 'dataclean', 'neighbours', 'artif', '-v7.3');
    
    diary off
   
else
    disp('Subject already processed');
end

cd(fileparts(tmp.Filename));