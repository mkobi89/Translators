%% EEG ERP calculation per subject %%

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
    EEGLDTPath = '/Volumes/CLINT/LDT/'; % LDT Path
    targetEEGLDTPath = '/Volumes/CLINT/LDT_preprocessed/';
    addpath('/Volumes/CLINT/fieldtrip-20200607/'); % add fieldtrip path
    addpath('/Volumes/CLINT/eeglab2020_0/');

else
    ServerPath = '//130.60.235.123/users/neuro/Desktop/CLINT/'; % Server Path
    allDataPath = '//130.60.235.123/users/neuro/Desktop/CLINT/All_Data/'; % All Data Path
    EEGLDTPath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT/'; % LDT Path
    targetEEGLDTPath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT_preprocessed/';
    addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
    addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/');
end

%Corona Homeoffice 2.0 Version
%allDataPath = 'E:/All_Data/'; % All Data Path
% EEGLDTPath = 'E:/LDT/'; % LDT Path
% targetEEGLDTPath = 'E:/LDT_doko/';
% addpath('//130.60.235.123/users/neuro/Desktop/CLINT/fieldtrip-20200607/'); % add fieldtrip path
% addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path
%% Starting fieldtrip

diary([targetEEGLDTPath 'settings_EEG_04_erp_log.txt'])
diary on

ft_defaults;
diary off

%% load files for headmodeling

% load('headmodeling/eeglabchans');
% load('headmodeling/elec_aligned');
load('headmodeling/labels105');
load('headmodeling/lay129_head');



%% Select desired subjects

cd(targetEEGLDTPath);

vplist = dir('C*');
vpNames = {vplist.name};


%%
for zz = 1:length(vpNames)
    cd([targetEEGLDTPath vpNames{zz}]);
    if (exist([vpNames{zz} '_LDT_EEG_preprocessed.mat'])==2) %&& ~(exist([vpNames{zz} '_LDT_erp.mat'])==2)
        
        diary([targetEEGLDTPath vpNames{zz} '/' vpNames{zz} '_log.txt'])
        diary on
        
        load([vpNames{zz} '_LDT_EEG_preprocessed.mat']);
        
           %% average refernence
        cfg = [];
        cfg.reref = 'yes';
        cfg.refchannel = 'all';
        cfg.refmethod = 'avg';
        cfg.implicitref = 'Cz';
       
        datapreprocessed = ft_preprocessing(cfg,dataorig);
        
        %% Select 105 eeg channels
        cfg = [];
        cfg.channel = labels105;
        datapreprocessed = ft_selectdata(cfg,datapreprocessed);
        

        %% calculating cutoffs
        
        trim = 3;
        
        german_mean = mean(dataorig.trialinfo((datapreprocessed.trialinfo(:,2) ==  150 | datapreprocessed.trialinfo(:,2) ==  151 | datapreprocessed.trialinfo(:,2) ==  152),1));
        german_std = std(dataorig.trialinfo((datapreprocessed.trialinfo(:,2) ==  150 | datapreprocessed.trialinfo(:,2) ==  151 | datapreprocessed.trialinfo(:,2) ==  152),1));
        german_uppercutoff = german_mean + trim * german_std;
        
        english_mean = mean(datapreprocessed.trialinfo((datapreprocessed.trialinfo(:,2) ==  250 | datapreprocessed.trialinfo(:,2) ==  251 | datapreprocessed.trialinfo(:,2) ==  252),1));
        english_std = std(datapreprocessed.trialinfo((datapreprocessed.trialinfo(:,2) ==  250 | datapreprocessed.trialinfo(:,2) ==  251 | datapreprocessed.trialinfo(:,2) ==  252),1));
        english_uppercutoff = english_mean + trim * english_std;
        
        switch_mean = mean(datapreprocessed.trialinfo((datapreprocessed.trialinfo(:,2) ==  301 | datapreprocessed.trialinfo(:,2) ==  302 | ...
            datapreprocessed.trialinfo(:,2) ==  303 | datapreprocessed.trialinfo(:,2) ==  304 | datapreprocessed.trialinfo(:,2) ==  305 |...
            datapreprocessed.trialinfo(:,2) ==  306 | datapreprocessed.trialinfo(:,2) ==  307 | datapreprocessed.trialinfo(:,2) ==  308 | datapreprocessed.trialinfo(:,2) ==  309),1));
        
        switch_std = std(datapreprocessed.trialinfo((datapreprocessed.trialinfo(:,2) ==  301 | datapreprocessed.trialinfo(:,2) ==  302 | ...
            datapreprocessed.trialinfo(:,2) ==  303 | datapreprocessed.trialinfo(:,2) ==  304 | datapreprocessed.trialinfo(:,2) ==  305 |...
            datapreprocessed.trialinfo(:,2) ==  306 | datapreprocessed.trialinfo(:,2) ==  307 | datapreprocessed.trialinfo(:,2) ==  308 | datapreprocessed.trialinfo(:,2) ==  309),1));
        
        switch_uppercutoff = switch_mean + trim * switch_std;
        
        lowercutoff = 250;
        
        %% split into conditions
        ind_correct = find(datapreprocessed.trialinfo(:,4)==1);
        ind_error = find(datapreprocessed.trialinfo(:,4)==0);
        
        % T1: german Task
        ind_T1_G_LF_correct = find(datapreprocessed.trialinfo(:,1) <= german_uppercutoff & datapreprocessed.trialinfo(:,2)==150 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T1_G_HF_correct = find(datapreprocessed.trialinfo(:,1) <= german_uppercutoff & datapreprocessed.trialinfo(:,2)==151 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T1_G_NW_correct = find(datapreprocessed.trialinfo(:,1) <= german_uppercutoff & datapreprocessed.trialinfo(:,2)==152 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        
        % T2: english Task
        ind_T2_E_LF_correct = find(datapreprocessed.trialinfo(:,1) <= english_uppercutoff & datapreprocessed.trialinfo(:,2)==250 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T2_E_HF_correct = find(datapreprocessed.trialinfo(:,1) <= english_uppercutoff & datapreprocessed.trialinfo(:,2)==251 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T2_E_NW_correct = find(datapreprocessed.trialinfo(:,1) <= english_uppercutoff & datapreprocessed.trialinfo(:,2)==252 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        
        % Switch Task
        ind_T3_G_G_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==301 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T3_G_E_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==302 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T3_G_NW_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==303 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        
        ind_T3_E_G_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==304 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T3_E_E_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==305 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T3_E_NW_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==306 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        
        ind_T3_NW_G_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==307 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T3_NW_E_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==308 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        ind_T3_NW_NW_correct = find(datapreprocessed.trialinfo(:,1) <= switch_uppercutoff & datapreprocessed.trialinfo(:,2)==309 & datapreprocessed.trialinfo(:,4)==1 & datapreprocessed.trialinfo(:,1) >= lowercutoff);
        
        
        %% compute ERP
        % correct trials
        cfg = [];
        cfg.trials = ind_correct;
        erp_correct = ft_timelockanalysis(cfg,datapreprocessed);
        
        % incorrect trials
        cfg.trials = ind_error;
        erp_error   = ft_timelockanalysis(cfg,datapreprocessed);
        
        % german task
        cfg.trials = ind_T1_G_LF_correct;
        erp_T1_G_LF_correct   = ft_timelockanalysis(cfg,datapreprocessed);
        cfg.trials = ind_T1_G_HF_correct;
        erp_T1_G_HF_correct   = ft_timelockanalysis(cfg,datapreprocessed);
        cfg.trials = ind_T1_G_NW_correct;
        erp_T1_G_NW_correct   = ft_timelockanalysis(cfg,datapreprocessed);
        
        % english task
        %if ~(vpNames{zz}== "CE5")
            cfg.trials = ind_T2_E_LF_correct;
            erp_T2_E_LF_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            cfg.trials = ind_T2_E_HF_correct;
            erp_T2_E_HF_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            cfg.trials = ind_T2_E_NW_correct;
            erp_T2_E_NW_correct   = ft_timelockanalysis(cfg,datapreprocessed);
        %end
        
        % switch task
        if ~(vpNames{zz}== "C50") %|| vpNames{zz} == "CM7")
            cfg.trials = ind_T3_G_G_correct;
            erp_T3_G_G_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            cfg.trials = ind_T3_G_E_correct;
            erp_T3_G_E_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            cfg.trials = ind_T3_G_NW_correct;
            erp_T3_G_NW_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            
            cfg.trials = ind_T3_E_G_correct;
            erp_T3_E_G_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            cfg.trials = ind_T3_E_E_correct;
            erp_T3_E_E_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            cfg.trials = ind_T3_E_NW_correct;
            erp_T3_E_NW_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            
            cfg.trials = ind_T3_NW_G_correct;
            erp_T3_NW_G_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            cfg.trials = ind_T3_NW_E_correct;
            erp_T3_NW_E_correct   = ft_timelockanalysis(cfg,datapreprocessed);
            cfg.trials = ind_T3_NW_NW_correct;
            erp_T3_NW_NW_correct   = ft_timelockanalysis(cfg,datapreprocessed);
        end
        %% baseline
        cfg = [];
        cfg.baseline = [-.5 0];
        erp_error_bl = ft_timelockbaseline(cfg,erp_error);
        erp_correct_bl = ft_timelockbaseline(cfg,erp_correct);
        
        erp_T1_G_LF_correct_bl = ft_timelockbaseline(cfg,erp_T1_G_LF_correct);
        erp_T1_G_HF_correct_bl = ft_timelockbaseline(cfg,erp_T1_G_HF_correct);
        erp_T1_G_NW_correct_bl = ft_timelockbaseline(cfg,erp_T1_G_NW_correct);
        
        %if ~(vpNames{zz}== "CE5")
            erp_T2_E_LF_correct_bl = ft_timelockbaseline(cfg,erp_T2_E_LF_correct);
            erp_T2_E_HF_correct_bl = ft_timelockbaseline(cfg,erp_T2_E_HF_correct);
            erp_T2_E_NW_correct_bl = ft_timelockbaseline(cfg,erp_T2_E_NW_correct);
        %end
        
        if ~(vpNames{zz}== "C50") %|| vpNames{zz} == "CM7")
            erp_T3_G_G_correct_bl = ft_timelockbaseline(cfg,erp_T3_G_G_correct);
            erp_T3_G_E_correct_bl = ft_timelockbaseline(cfg,erp_T3_G_E_correct);
            erp_T3_G_NW_correct_bl = ft_timelockbaseline(cfg,erp_T3_G_NW_correct);
            
            erp_T3_E_G_correct_bl = ft_timelockbaseline(cfg,erp_T3_E_G_correct);
            erp_T3_E_E_correct_bl = ft_timelockbaseline(cfg,erp_T3_E_E_correct);
            erp_T3_E_NW_correct_bl = ft_timelockbaseline(cfg,erp_T3_E_NW_correct);
            
            erp_T3_NW_G_correct_bl = ft_timelockbaseline(cfg,erp_T3_NW_G_correct);
            erp_T3_NW_E_correct_bl = ft_timelockbaseline(cfg,erp_T3_NW_E_correct);
            erp_T3_NW_NW_correct_bl = ft_timelockbaseline(cfg,erp_T3_NW_NW_correct);
        end
        
        %% cut data around time of interest
        cfg = [];
        cfg.latency = [-.5 2];
        erp_error_bl = ft_selectdata(cfg,erp_error_bl);
        erp_correct_bl = ft_selectdata(cfg,erp_correct_bl);
        
        erp_T1_G_LF_correct_bl = ft_selectdata(cfg,erp_T1_G_LF_correct_bl);
        erp_T1_G_HF_correct_bl = ft_selectdata(cfg,erp_T1_G_HF_correct_bl);
        erp_T1_G_NW_correct_bl = ft_selectdata(cfg,erp_T1_G_NW_correct_bl);
        
        %if ~(vpNames{zz}== "CE5")
            erp_T2_E_LF_correct_bl = ft_selectdata(cfg,erp_T2_E_LF_correct_bl);
            erp_T2_E_HF_correct_bl = ft_selectdata(cfg,erp_T2_E_HF_correct_bl);
            erp_T2_E_NW_correct_bl = ft_selectdata(cfg,erp_T2_E_NW_correct_bl);
        %end
        
        if ~(vpNames{zz}== "C50") %|| vpNames{zz} == "CM7")
            erp_T3_G_G_correct_bl = ft_selectdata(cfg,erp_T3_G_G_correct_bl);
            erp_T3_G_E_correct_bl = ft_selectdata(cfg,erp_T3_G_E_correct_bl);
            erp_T3_G_NW_correct_bl = ft_selectdata(cfg,erp_T3_G_NW_correct_bl);
            
            erp_T3_E_G_correct_bl = ft_selectdata(cfg,erp_T3_E_G_correct_bl);
            erp_T3_E_E_correct_bl = ft_selectdata(cfg,erp_T3_E_E_correct_bl);
            erp_T3_E_NW_correct_bl = ft_selectdata(cfg,erp_T3_E_NW_correct_bl);
            
            erp_T3_NW_G_correct_bl = ft_selectdata(cfg,erp_T3_NW_G_correct_bl);
            erp_T3_NW_E_correct_bl = ft_selectdata(cfg,erp_T3_NW_E_correct_bl);
            erp_T3_NW_NW_correct_bl = ft_selectdata(cfg,erp_T3_NW_NW_correct_bl);
        end
        %% save erp
        
        targetDirectory = [targetEEGLDTPath,vpNames{zz},'/'];
            
            if ~(exist(targetDirectory)==7)
                mkdir(targetDirectory);
            end
        
        if ~(vpNames{zz}== "C50") %|| vpNames{zz} == "CM7" || vpNames{zz} == "CE5")
            save([targetDirectory vpNames{zz} '_LDT_EEG_erp.mat'], 'erp_error_bl','erp_correct_bl','erp_T1_G_LF_correct_bl','erp_T1_G_HF_correct_bl', 'erp_T1_G_NW_correct_bl', ...
                'erp_T2_E_LF_correct_bl', 'erp_T2_E_HF_correct_bl', 'erp_T2_E_NW_correct_bl', 'erp_T3_G_G_correct_bl', 'erp_T3_G_E_correct_bl', 'erp_T3_G_NW_correct_bl', ...
                'erp_T3_E_G_correct_bl', 'erp_T3_E_E_correct_bl', 'erp_T3_E_NW_correct_bl', 'erp_T3_NW_G_correct_bl', 'erp_T3_NW_E_correct_bl', 'erp_T3_NW_NW_correct_bl');
        elseif vpNames{zz}== "C50" %|| vpNames{zz} == "CM7"
            save([targetDirectory vpNames{zz} '_LDT_EEG_erp.mat'], 'erp_error_bl','erp_correct_bl','erp_T1_G_LF_correct_bl','erp_T1_G_HF_correct_bl', 'erp_T1_G_NW_correct', ...
                'erp_T2_E_LF_correct_bl', 'erp_T2_E_HF_correct_bl', 'erp_T2_E_NW_correct_bl');
        %else
%             save([targetDirectory vpNames{zz} '_LDT_erp.mat'], 'erp_error_bl','erp_correct_bl','erp_T1_G_LF_correct_bl','erp_T1_G_HF_correct_bl', 'erp_T1_G_NW_correct_bl', ...
%                 'erp_T2_E_LF_correct_bl', 'erp_T2_E_HF_correct_bl', 'erp_T2_E_NW_correct_bl');
        end
        
        diary off
        
        %% plot
%                 cfg = [];
%                 cfg.layout = lay129_head;
%                 figure;
%                 ft_multiplotER(cfg,erp_T3_G_G_correct_bl, erp_T3_E_E_correct_bl, ...
%                     erp_T3_G_E_correct_bl, erp_T3_E_G_correct_bl);
%              
        
    else
        continue
    end
end

cd(fileparts(tmp.Filename));