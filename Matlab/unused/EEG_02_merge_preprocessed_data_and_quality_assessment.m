%% Merge preprocessed LDT EEG data from each task into one file
% get Automagic quality assessment
% save files to Server

%% Preparation:
clear

%% Change directory to the current m. file
% by hand or by code:
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

%% Path to server depending on OS

% if IsOSX == true
%     allDataPath = '/Volumes/CLINT/All_Data/'; % All Data Path
%     savePath = '/Volumes/CLINT/LDT_preprocessed/'; % LDT Path
%     addpath('/Volumes/CLINT/eeglab2020_0/'); % add eeglab path
% else
%     allDataPath = '//130.60.235.123/users/neuro/Desktop/CLINT/All_Data/'; % All Data Path
%     savePath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT_preprocessed/'; % LDT Path
%     addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path

% end

%% Corona Homeoffice 2.0 path definition
allDataPath = 'E:/LDT_taskwise_segmented_results_0_1HZ/'; % All Data Path
savePath = 'E:/LDT_preprocessed/';

%savePath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT_preprocessed/'; % LDT Path

%% Add EEGlab
addpath('//130.60.235.123/users/neuro/Desktop/CLINT/eeglab2020_0/'); % add eeglab path


%% Starting EEGLAB
eeglab
close()


%% Select desired subjects
cd(allDataPath);

vplist = dir('C*');
vpNames = {vplist.name};

%% Check for target directory and create folders

for zz = 1:length(vpNames)
    if ~(exist([savePath vpNames{zz}])==7)
        mkdir([savePath vpNames{zz}]);
    else
        continue
    end
end


%% Merge data

for zz = 39:length(vpNames)
    
    cd([allDataPath vpNames{zz}]);
    
    file = dir('*p*_EEG_t1.mat');
    EEG_t1 = load(file.name);

    file = dir('*p*_EEG_t2.mat');
    EEG_t2 = load(file.name);    
    
    file = dir('*p*_EEG_t3.mat');
    EEG_t3 = load(file.name);
    
    quality_scores{zz,1} = vpNames{zz};
    quality_scores{zz,2} = EEG_t1.automagic.rate;
    quality_scores{zz,3} = EEG_t2.automagic.rate;
    quality_scores{zz,4} = EEG_t3.automagic.rate;

    
    EEG_merged_1 = pop_mergeset(EEG_t1.EEG, EEG_t2.EEG);
    EEG_final = pop_mergeset(EEG_merged_1, EEG_t3.EEG);
    
    del = 0;
    for i = 1:length(EEG_final.event)
        if isequal(EEG_final.event(i-del).type, 'boundary')
            EEG_final.event(i-del) = [];
            del = del+1;
        end
    end
    
    EEG_final.setname = 'EGI file';
    
    EEG = EEG_final;
    
    
    
    %% save each segment as a new file
    cd([savePath vpNames{zz}]);

    filename = strjoin([vpNames(zz) '_LDT_EEG_automagic.edf'], '');
    %save(filename, 'EEG');
    
    pop_writeeeg(EEG, filename);
    
    clearvars EEG EEG_final EEG_t1 EEG_t2 EEG_t3
end

% arrange quality score as table and save it
quality_scores = cell2table(quality_scores, 'VariableNames',{'SubjectID' 'quality_t1' 'quality_t2' 'quality_t3'});
writetable(quality_scores,[savePath 'quality_scores.csv'],'FileType','text')

cd(fileparts(tmp.Filename));
