%% EEG read in data from RAW files %%

%% Preparation:
clear

%% Change directory to the current m. file
% by hand or by code:
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

%% Path to server depending on OS
if IsOSX == true
    allDataPath = '/Volumes/CLINT/All_Data/'; % All Data Path
    savePath = '/Volumes/CLINT/LDT_preprocessed/'; % LDT Path
    addpath('/Volumes/CLINT/fieldtrip-20200607/'); % add fieldtrip path
    addpath('/Volumes/CLINT/eeglab2020_0/'); % add eeglab path
    
else
    allDataPath = '//130.60.235.123/users/neuro/Desktop/CLINT/All_Data/'; % All Data Path
    savePath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT_preprocessed/'; % LDT Path
    addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
    addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path
end

% Corona Homeoffice 2.0 Version
% allDataPath_old = 'E:/All_Data/'; % All Data Path
%
% allDataPath = 'E:/LDT_preprocessed/'; % All Data Path
% savePath = 'E:/LDT_preprocessed/'; % LDT Path

%% Add EEGLAB and Fieldtrip
% addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
% addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path

%% Starting EEGLAB and fieldtrip
% if ~(exist(EEGLDTPath)==7)
%     mkdir(EEGLDTPath);
% end

diary([savePath 'settings_EEG_03_read_data_new_log.txt'])
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

cd(fileparts(tmp.Filename));

%% Check for target directory
%cd(EEGLDTPath);
% for zz = 1:length(vpNames)
%     if ~(exist([savePath vpNames{zz}])==7)
%         mkdir([savePath vpNames{zz}]);
%     else
%         continue
%     end
% end


% vpName = input('Subject to process: ','s');

% if ~(exist([EEGLDTPath vpName '/' vpName '_LDT.mat'])==2)

%     diary([EEGLDTPath vpName '/' vpName '_log.txt'])
%     diary on

%% Old Version --> functioning, but does not work with automagic preprocessed files
% cd(fileparts(tmp.Filename));
% cfg =[];
%
% cfg.dataset = [allDataPath vpName '/ARCHIVE/' vpName '_LDT_EEG.RAW'];
% cfg.trialfun  = 'ft_trialfun_LDT';
% cfg.trialdef.prestim    = 2;
% cfg.trialdef.poststim   = 3; % it was 3
% cfg = ft_definetrial(cfg);
%
% cfg.lpfilter = 'yes';
% cfg.lpfreqtype = 'firws';
% cfg.lpfreq    = 40;
%
% data_old = ft_preprocessing(cfg);
%
%
%
% cfg = [];
% cfg.dataset = [allDataPath vpName '/'  vpName '_LDT_EEG_automagic.mat'];
% cfg.trialdef.eventtype  = '?';
% ft_definetrial(cfg);


%% New attempt
% Load eeglab structure matlab file, convert to fieldtrip, get hdr,
% recreate events in fieldtrip, save as matlab file, try to use
% trialfun_LDT_automagic, but fails because of dataformat defined as
% 'matlab'
for zz = 1:length(vpNames)
    %if (exist([savePath vpNames{zz} '/'  vpNames{zz} '_LDT_EEG_automagic.mat'])==2 && ~(exist([vpNames{zz} '_LDT_EEG_fieldtrip.mat'])==2) && ~(exist([vpNames{zz} '_LDT_EEG_preprocessed.mat'])==2))
        %% load automagic fiel, transform to fieldtrip
        load([savePath vpNames{zz} '/'  vpNames{zz} '_LDT_EEG_automagic.mat']);
        
        data = eeglab2fieldtrip(EEG, 'raw','none');
        
        hdr = ft_fetch_header(data);
        data.hdr = hdr;
        
        
        %% take elec --> unused
        ind=ismember(elec_aligned.label,data.label);
        elec.chanpos= elec_aligned.chanpos(find(ind==1),:);
        elec.chantype= elec_aligned.chantype(find(ind==1));
        elec.chanunit= elec_aligned.chanunit(find(ind==1));
        elec.elecpos= elec_aligned.elecpos(find(ind==1),:);
        elec.homogeneous= elec_aligned.homogeneous;
        elec.label= elec_aligned.label(find(ind==1));
        elec.type= elec_aligned.type;
        elec.unit= elec_aligned.unit;
        
        
        % create hdr for ft data; dimord for EEGLAB should be chan x time x trial double
        % hdr.Fs = data.fsample;
        % hdr.chantype = elec.chantype;
        % hdr.chanunit = elec.chanunit;
        % hdr.label    = elec.label;
        % hdr.nChans   = numel(elec.label);
        % hdr.elec = elec;
        % hdr.nTrials = numel(data.trial);
        % hdr.nSamples = length(data.time{1});
        % hdr.nSamplesPre = 2*data.fsample;
        
        %% create fieldtrip event structure
        for fn = 1:numel(EEG.event)
            data.event(fn).sample = EEG.event(fn).latency;
            data.event(fn).offset = [];
            data.event(fn).duration = 0;
            data.event(fn).type = 'trigger';
            data.event(fn).value = str2double(EEG.event(fn).type(1:3));
        end
        
        %% save to folder
        %save([savePath vpNames{zz} '/'  vpNames{zz} '_LDT_EEG_fieldtrip.mat'], 'data', '-v7.3');
        
        %type = ft_filetype([savePath vpName '/'  vpName '_LDT_EEG_fieldtrip.mat']);
        
        
        %% new trialfunction --> working so far
        
        % load fieldtrip dataset
        % load([savePath vpNames{zz} '/'  vpNames{zz} '_LDT_EEG_fieldtrip.mat']);
        
        % define trials
        cfg = [];
        cfg.dataset = [savePath vpNames{zz} '/'  vpNames{zz} '_LDT_EEG_fieldtrip.mat'];
        cfg.trialfun  = 'ft_trialfun_LDT_automagic';
        cfg.trialdef.prestim    = 2;
        cfg.trialdef.poststim   = 3; % it was 3
        cfg = ft_definetrial(cfg);
        
        %dataorig = ft_preprocessing(cfg);
        dataorig = ft_redefinetrial(cfg,data);
        
        %% save as preprocessed
        save([savePath vpNames{zz} '/'  vpNames{zz} '_LDT_EEG_preprocessed.mat'], 'dataorig', '-v7.3');
    %else
     %   continue
    %end
end


%% Select 105 eeg channels
% cfg = [];
% cfg.channel = labels105;
% dataorig = ft_selectdata(cfg,dataorig);
%
% %% Save original data to EEGLDTPath
% save(fullfile([EEGLDTPath vpName '/' vpName '_LDT_orig.mat']), 'dataorig', '-v7.3');
%
% %% take elec
% ind=ismember(elec_aligned.label,dataorig.label);
% elec.chanpos= elec_aligned.chanpos(find(ind==1),:);
% elec.chantype= elec_aligned.chantype(find(ind==1));
% elec.chanunit= elec_aligned.chanunit(find(ind==1));
% elec.elecpos= elec_aligned.elecpos(find(ind==1),:);
% elec.homogeneous= elec_aligned.homogeneous;
% elec.label= elec_aligned.label(find(ind==1));
% elec.type= elec_aligned.type;
% elec.unit= elec_aligned.unit;
%
% %% create neighbours for interpolation after ICA
% cfg = [];
% cfg.elec = elec;
% cfg.method = 'distance';
% % cfg.feedback = 'yes';
% neighbours = ft_prepare_neighbours(cfg, dataorig);
%
% % exclude bad channels and rename dataset to dataclean
% cfg = [];
% cfg.hpfilter = 'yes';
% cfg.hpfreqtype = 'firws';
% cfg.hpfreq    = 0.3;
% data_hp = ft_preprocessing(cfg, dataorig);
%
%
% cfg = [];
% cfg.alim = 1e-12;
% cfg.method   = 'summary';
% dataclean = ft_rejectvisual(cfg,data_hp);
%
% % write down bad channels as cell-array : {'E7';'Oz'} for
% % interpolating after ICA
% artif.badchannel  = input('write badchannels: ');
%
% save(fullfile([EEGLDTPath vpName '/' vpName '_LDT_clean.mat']), 'dataclean', 'neighbours', 'artif', '-v7.3');
%
% diary off
%
% % else
%     disp('Subject already processed');
% %     end
%
%     cd(fileparts(tmp.Filename));