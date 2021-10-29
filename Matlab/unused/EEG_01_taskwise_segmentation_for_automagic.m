%% Segment LDT EEG data into each task

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
%     ResultsPath = '/Volumes/CLINT/LDT_results/'; % LDT results Path
%     automagicPath = '/Volumes/CLINT/CLINT_results/'; % Automagic results Path
% else
%     ServerPath = '130.60.235.123/users/neuro/Desktop/CLINT/'; % Server Path
%     allDataPath = '130.60.235.123/users/neuro/Desktop/CLINT/All_Data/'; % All Data Path
%     EEGLDTPath = '130.60.235.123/users/neuro/Desktop/CLINT/LDT/'; % LDT Path
%     ResultsPath = '130.60.235.123/users/neuro/Desktop/CLINT/LDT_results/'; % LDT Path
%     automagicPath = '130.60.235.123/users/neuro/Desktop/CLINT/CLINT_results/'; % Automagic results Path
% end

%% Corona Homeoffice 2.0 path definition
allDataPath = 'E:/All_Data/'; % All Data Path
savePath = 'E:/Data_translators/'; % LDT Path

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
    
end

%% Segment data
for zz = 1:length(vpNames)
    cd([allDataPath vpNames{zz}]);
    
    file = dir('*E1*EEG.mat');
    
    if ~isempty(file)
        
        file = file.name;
        load(file)
        
        
        %% find latencies of start and end point of the 3 tasks
        for i = 1:length(EEG.event)
            if isequal(EEG.event(i).type, '11  ') || isequal(EEG.event(i).type, '12  ') || isequal(EEG.event(i).type, '13  ') || isequal(EEG.event(i).type, '14  ')
                
                e1_r_start = i; %  position of the event
                e1_r_start_latency = EEG.event(i).latency; % latenncy of the event
                
            elseif isequal(EEG.event(i).type, '15  ') || isequal(EEG.event(i).type, '16  ') || isequal(EEG.event(i).type, '17  ') || isequal(EEG.event(i).type, '18  ')
                
                e1_r_end = i;
                e1_r_end_latency = EEG.event(i).latency;
                
            end
            
            if isequal(EEG.event(i).type, '31  ') || isequal(EEG.event(i).type, '32  ') || isequal(EEG.event(i).type, '33  ') || isequal(EEG.event(i).type, '34  ')
                
                e1_c_start = i; %  position of the event
                e1_c_start_latency = EEG.event(i).latency; % latenncy of the event
                
            elseif isequal(EEG.event(i).type, '35  ') || isequal(EEG.event(i).type, '36  ') || isequal(EEG.event(i).type, '37  ') || isequal(EEG.event(i).type, '38  ')
                
                e1_c_end = i;
                e1_c_end_latency = EEG.event(i).latency;
                
            end
            
            if isequal(EEG.event(i).type, '41  ') || isequal(EEG.event(i).type, '42  ') || isequal(EEG.event(i).type, '43  ') || isequal(EEG.event(i).type, '44  ')
                
                e1_t_start = i; %  position of the event
                e1_t_start_latency = EEG.event(i).latency; % latenncy of the event
                
            elseif isequal(EEG.event(i).type, '45  ') || isequal(EEG.event(i).type, '46  ') || isequal(EEG.event(i).type, '47  ') || isequal(EEG.event(i).type, '48  ')
                
                e1_t_end = i;
                e1_t_end_latency = EEG.event(i).latency;
                
            end
            
        end
        
        %% Cut EEG file
        % everything from 0 until start latency - 5 is removed and
        % everything from end latency + 5 until end of eeg data is removed
        
        EEG_e1_r = eeg_eegrej(EEG, [0 e1_r_start_latency-5; e1_r_end_latency+5 EEG.pnts+1]);
        EEG_e1_c = eeg_eegrej(EEG, [0 e1_c_start_latency-5; e1_c_end_latency+5 EEG.pnts+1]);
        EEG_e1_t = eeg_eegrej(EEG, [0 e1_t_start_latency-5; e1_t_end_latency+5 EEG.pnts+1]);
        
        %% remove boundary event
        del = 0;
        for i = 1:length(EEG_e1_r.event)
            if isequal(EEG_e1_r.event(i-del).type, 'boundary')
                EEG_e1_r.event(i-del) = [];
                del = del+1;
            end
        end

        del = 0;
        for i = 1:length(EEG_e1_c.event)
            if isequal(EEG_e1_c.event(i-del).type, 'boundary')
                EEG_e1_c.event(i-del) = [];
                del = del+1;
            end
        end
        
        del = 0;
        for i = 1:length(EEG_e1_t.event)
            if isequal(EEG_e1_t.event(i-del).type, 'boundary')
                EEG_e1_t.event(i-del) = [];
                del = del+1;
            end
        end
        
        if ~(exist([savePath vpNames{zz}])==7)
            mkdir([savePath vpNames{zz}]);
        end
        %% save each segment as a new file
        cd([savePath vpNames{zz}]);
        
        EEG_e1_r.event(1).type = EEG.event(1).type;
        EEG_e1_c.event(1).type = EEG.event(1).type;
        EEG_e1_t.event(1).type = EEG.event(1).type;
        
        EEG = EEG_e1_r;
        filename = strjoin([vpNames(zz) '_e1_r_EEG.mat'], '');
        save(filename, 'EEG');
        
        EEG = EEG_e1_c;
        filename = strjoin([vpNames(zz) '_e1_c_EEG.mat'], '');
        save(filename, 'EEG');
        
        EEG = EEG_e1_t;
        filename = strjoin([vpNames(zz) '_e1_t_EEG.mat'], '');
        save(filename, 'EEG');
        
        clearvars EEG EEG_e1_r EEG_e1_c EEG_e1_t
        
             
        
    end
    
    cd([allDataPath vpNames{zz}]);
    
    file = dir('*E2*EEG.mat');
    
    
    if ~isempty(file)
        
        file = file.name;
        load(file)
        
        
        %% find latencies of start and end point of the 3 tasks
        for i = 1:length(EEG.event)
            if isequal(EEG.event(i).type, '11  ') || isequal(EEG.event(i).type, '12  ') || isequal(EEG.event(i).type, '13  ') || isequal(EEG.event(i).type, '14  ')
                
                e2_r_start = i; %  position of the event
                e2_r_start_latency = EEG.event(i).latency; % latenncy of the event
                
            elseif isequal(EEG.event(i).type, '15  ') || isequal(EEG.event(i).type, '16  ') || isequal(EEG.event(i).type, '17  ') || isequal(EEG.event(i).type, '18  ')
                
                e2_r_end = i;
                e2_r_end_latency = EEG.event(i).latency;
                
            end
            
            if isequal(EEG.event(i).type, '31  ') || isequal(EEG.event(i).type, '32  ') || isequal(EEG.event(i).type, '33  ') || isequal(EEG.event(i).type, '34  ')
                
                e2_c_start = i; %  position of the event
                e2_c_start_latency = EEG.event(i).latency; % latenncy of the event
                
            elseif isequal(EEG.event(i).type, '35  ') || isequal(EEG.event(i).type, '36  ') || isequal(EEG.event(i).type, '37  ') || isequal(EEG.event(i).type, '38  ')
                
                e2_c_end = i;
                e2_c_end_latency = EEG.event(i).latency;
                
            end
            
            if isequal(EEG.event(i).type, '41  ') || isequal(EEG.event(i).type, '42  ') || isequal(EEG.event(i).type, '43  ') || isequal(EEG.event(i).type, '44  ')
                
                e2_t_start = i; %  position of the event
                e2_t_start_latency = EEG.event(i).latency; % latenncy of the event
                
            elseif isequal(EEG.event(i).type, '45  ') || isequal(EEG.event(i).type, '46  ') || isequal(EEG.event(i).type, '47  ') || isequal(EEG.event(i).type, '48  ')
                
                e2_t_end = i;
                e2_t_end_latency = EEG.event(i).latency;
                
            end
            
        end
        
        %% Cut EEG file
        % everything from 0 until start latency - 5 is removed and
        % everything from end latency + 5 until end of eeg data is removed
        
        EEG_e2_r = eeg_eegrej(EEG, [0 e2_r_start_latency-5; e2_r_end_latency+5 EEG.pnts+1]);
        EEG_e2_c = eeg_eegrej(EEG, [0 e2_c_start_latency-5; e2_c_end_latency+5 EEG.pnts+1]);
        EEG_e2_t = eeg_eegrej(EEG, [0 e2_t_start_latency-5; e2_t_end_latency+5 EEG.pnts+1]);
        
        %% remove boundary event
        del = 0;
        for i = 1:length(EEG_e2_r.event)
            if isequal(EEG_e2_r.event(i-del).type, 'boundary')
                EEG_e2_r.event(i-del) = [];
                del = del+1;
            end
        end

        del = 0;
        for i = 1:length(EEG_e2_c.event)
            if isequal(EEG_e2_c.event(i-del).type, 'boundary')
                EEG_e2_c.event(i-del) = [];
                del = del+1;
            end
        end
        
        del = 0;
        for i = 1:length(EEG_e2_t.event)
            if isequal(EEG_e2_t.event(i-del).type, 'boundary')
                EEG_e2_t.event(i-del) = [];
                del = del+1;
            end
        end
        
        if ~(exist([savePath vpNames{zz}])==7)
            mkdir([savePath vpNames{zz}]);
        end
        %% save each segment as a new file
        cd([savePath vpNames{zz}]);
        
        EEG_e2_r.event(1).type = EEG.event(1).type;
        EEG_e2_c.event(1).type = EEG.event(1).type;
        EEG_e2_t.event(1).type = EEG.event(1).type;
        
        EEG = EEG_e2_r;
        filename = strjoin([vpNames(zz) '_e2_r_EEG.mat'], '');
        save(filename, 'EEG');
        
        EEG = EEG_e2_c;
        filename = strjoin([vpNames(zz) '_e2_c_EEG.mat'], '');
        save(filename, 'EEG');
        
        EEG = EEG_e2_t;
        filename = strjoin([vpNames(zz) '_e2_t_EEG.mat'], '');
        save(filename, 'EEG');
        
        clearvars EEG EEG_e1_r EEG_e1_c EEG_e1_t
    end
    disp(['****** Segmentation of ' vpNames{zz} ' is done. ******' ])    
end

cd(fileparts(tmp.Filename));

