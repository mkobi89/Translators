%% EEG preprocessing and ica labeling %%

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


%% Starting fieldtrip
diary([EEGLDTPath 'settings_EEG_02_preprocessing_ica_log.txt'])
diary on

ft_defaults;
diary off

%% load files for headmodeling

load('headmodeling/eeglabchans');
load('headmodeling/elec_aligned');
load('headmodeling/labels105');
load('headmodeling/lay129_head');


%% Select desired subjects

cd(EEGLDTPath);

vplist = dir('C*');
vpNames = {vplist.name};

%%
for zz = 1:length(vpNames)
    
    cd([EEGLDTPath vpNames{zz}]);
    if (exist([vpNames{zz} '_LDT_clean.mat'])==2) && ~(exist([vpNames{zz} '_LDT_preprocessed.mat'])==2)
        
        diary([EEGLDTPath vpNames{zz} '/' vpNames{zz} '_log.txt'])
        diary on
        
        load([vpNames{zz} '_LDT_orig.mat']);
        load([vpNames{zz} '_LDT_clean.mat']);
        
        if IsOSX == true
            addpath('/Volumes/CLINT/eeglab2020_0/'); % add eeglab path
        else
            addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path
        end
        
        %% eeg demean and detrend for downsamlping data and apply temporary high pass filter for ICA
        cfg = [];
        cfg.demean = 'yes';
        cfg.detrend = 'yes';
        
        cfg.hpfilter = 'yes'; %%
        cfg.hpfreqtype = 'firws';
        cfg.hpfreq    = 2;
        
        dataICAprocessing = ft_preprocessing(cfg,dataclean);
        
        %% downsample the data prior to component analysis, 120 is OK to identify cardiac and blinks
        cfg = [];
        cfg.resamplefs = 100;
        cfg.detrend    = 'no';
        dataICAprocessing = ft_resampledata(cfg, dataICAprocessing);
        dataICAprocessing.fsample= round(dataICAprocessing.fsample);
        
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
        
        %% ?? necessary?
        dataorig.elec = elec;
        dataorig.fsample = round(dataorig.fsample);
        
        %%
        data = dataICAprocessing;
        hdr = [];
        
        % data dimord for EEGLAB should be chan x time x trial double
        hdr.Fs = data.fsample;
        hdr.chantype = elec.chantype;
        hdr.chanunit = elec.chanunit;
        hdr.label    = elec.label;
        hdr.nChans   = numel(elec.label);
        hdr.elec = elec;
        hdr.nTrials = numel(data.trial);
        hdr.nSamples = length(data.time{1});
        hdr.nSamplesPre = 2*data.fsample;
        
        %% start EEGLAB and create EEGLAB structure
        eeglab
        close()
        
        %% create EEG lab structure
        alllabels=labels105;
        ind = find(ismember(alllabels,data.label)==1);
        newlocs = eeglabchans.chanlocs(ind);
        EEG     = fieldtrip2eeglab(hdr,data);
        EEG.nbchan = numel(data.label);
        EEG.trials = numel(data.trial);
        EEG.data = [];
        EEG.epoch = [];
        for i=1:numel(data.trial)
            EEG.data(:,:,i)= data.trial{i}(:,:);
        end
        EEG.xmin=data.time{1}(1);
        EEG.xmax=data.time{1}(end);
        EEG.chanlocs=newlocs;
        EEG.chaninfo=eeglabchans.chaninfo;
        EEG.urchanlocs=eeglabchans.urchanlocs;
        EEG.ref='common'; %% true?? referencing to average reference after ICA
        EEG.pnts = numel(data.time{1});
        EEG.times=data.time{1};
        

        
        %% do ICA
        outeeg=pop_runica(EEG,'icatype','runica');
        eeglabeled = iclabel(outeeg);
        
        %% Plot ica components
        % pop_viewprops(eeglabeled, 0); % for component properties
        
        
        %% rm eeglab not confusing fieldtrip
        if IsOSX == true
            rmpath(genpath('/Volumes/CLINT/eeglab2020_0/')); % remove eeglab path
        else
            rmpath(genpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/')); % remove eeglab path
        end
        
        %% upsample through ica components
        dataclean.label = data.label; % changed from dataorig
        cfg           = [];
        cfg.unmixing  = outeeg.icaweights*outeeg.icasphere;
        cfg.topolabel = data.label;
        comp = ft_componentanalysis(cfg, dataclean); %% use dataclean? or dataorig
        
        %% identify indeces of brain
        for i = 1:length(eeglabeled.etc.ic_classification.ICLabel.classifications(:,1))
            hitbrain = find(eeglabeled.etc.ic_classification.ICLabel.classifications(i,:)>.8);
            hitother = find(eeglabeled.etc.ic_classification.ICLabel.classifications(i,:)>.6);
            if hitbrain==1
            elseif hitother ==7
                ic2reject(i)=0;
            else
                ic2reject(i)=1;
            end
            
        end
        
        %% plot components with FT
        %     comp = rmfield(comp,'sampleinfo')
        %     comp.cfg=[]
        %     plotbrain=find(ic2reject==0);
        %     cfg = [];
        %     cfg.channel = plotbrain(1:5); % components to be plotted
        %     cfg.viewmode = 'component';
        %     cfg.compscale = 'local';
        %     cfg.layout = lay129_head;
        %     ft_databrowser(cfg, comp);
        
        %% reject components
        cfg = [];
        cfg.component = find(ic2reject==1);
        dataica = ft_rejectcomponent(cfg, comp); 
        
        %% interpolating bad channels
        cfg = [];
        cfg.badchannel = artif.badchannel;
        cfg.elec = elec;
        cfg.method = 'spline'; % not recommended?
        cfg.neighbours = neighbours;
        datapreprocessed = ft_channelrepair(cfg,dataica);

        %% rereferencing to average reference
        cfg = [];
        cfg.reref = 'yes';
        cfg.refchannel = 'all';
        cfg.implicitref   = 'Cz';
        
        %% eeg detrend

        cfg.detrend = 'yes';
        datapreprocessed = ft_preprocessing(cfg,datapreprocessed);
        
        %% review channels
%         cfg = [];
%         cfg.alim = 1e-12;
%         cfg.method   = 'summary';
%         dataclean_new = ft_rejectvisual(cfg,dataorig);
%         dataclean_new = ft_rejectvisual(cfg,dataica);
%         dataclean_new = ft_rejectvisual(cfg,datapreprocessed); 
        
        %% save
        save([vpNames{zz} '_LDT_preprocessed.mat'], 'datapreprocessed','-v7.3');
        
        diary off
    else
        continue
    end
    
end

cd(fileparts(tmp.Filename));


