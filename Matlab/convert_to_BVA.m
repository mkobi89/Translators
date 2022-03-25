clear

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

dataPath = 'F:\CLINT backup_15.02.2022\Translator_final_3_results\'; % All Data Path
addpath('F:\CLINT backup_15.02.2022\eeglab2021_0\');

% savePath = '//130.60.235.121/L/';
% cd(savePath)

eeglab
close()

cd(dataPath);

vplist = dir('C*');
vpNames = {vplist.name};

for zz = 25
    
    cd([dataPath vpNames{zz}]);
    
    quality_scores{zz,1} = vpNames{zz};
    
    
    %% Reading Task
    file = dir('*p*_e1_r_EEG.mat');
    EEG = load(file.name);
    EEG_e1_r = EEG.EEG;
    
    if EEG_e1_r.pnts >= 150003
        EEG_e1_r_5min = eeg_eegrej(EEG_e1_r, [150003 EEG_e1_r.pnts+1]);
        EEG_e1_r_5min.event(end+1).type = EEG_e1_r.event(end).type;
        EEG_e1_r_5min.event(end).latency = 150000;
        EEG_e1_r_5min.event(end).urevent = EEG_e1_r.event(end-1).urevent;
        EEG_e1_r_5min.event(end).duration = 0;
        
            EEG_e1_r = EEG_e1_r_5min;
    clearvars EEG_e1_r_5min
    end
    

    
    EEG_e1_r.event(2).type = EEG_e1_r.event(1).type;
    EEG_e1_r.event(1).type = '1   ';
    
    quality_scores{zz,2} = EEG.automagic.rate;
    
    file = dir('*p*_e2_r_EEG.mat');
    EEG = load(file.name);
    EEG_e2_r = EEG.EEG;
    
    if EEG_e2_r.pnts >= 150003
        EEG_e2_r_5min = eeg_eegrej(EEG_e2_r, [150003 EEG_e2_r.pnts+1]);
        EEG_e2_r_5min.event(end+1).type = EEG_e2_r.event(end).type;
        EEG_e2_r_5min.event(end).latency = 150000;
        EEG_e2_r_5min.event(end).urevent = EEG_e2_r.event(end-1).urevent;
        EEG_e2_r_5min.event(end).duration = 0;
        
        EEG_e2_r = EEG_e2_r_5min;
    clearvars EEG_e2_r_5min
    end
    

    
    
    quality_scores{zz,3} = EEG.automagic.rate;
    
    EEG_reading = pop_mergeset(EEG_e1_r, EEG_e2_r);
    EEG_reading.event(end+1).type = '2   ';
    EEG_reading.event(end).latency = EEG_reading.event(end-1).latency;
    EEG_reading.event(end).urevent = EEG_reading.event(end-1).urevent;
    EEG_reading.event(end).duration = 0;
    
    %% Copying Task
    file = dir('*p*_e1_c_EEG.mat');
    EEG = load(file.name);
    EEG_e1_c = EEG.EEG;
    
    EEG_e1_c.event(2).type = EEG_e1_c.event(1).type;
    EEG_e1_c.event(1).type = '3   ';
    
    quality_scores{zz,4} = EEG.automagic.rate;
    
    file = dir('*p*_e2_c_EEG.mat');
    EEG = load(file.name);
    EEG_e2_c = EEG.EEG;
    
    quality_scores{zz,5} = EEG.automagic.rate;
    
    EEG_copying = pop_mergeset(EEG_e1_c, EEG_e2_c);
    EEG_copying.event(end+1).type = '4   ';
    EEG_copying.event(end).latency = EEG_copying.event(end-1).latency;
    EEG_copying.event(end).urevent = EEG_copying.event(end-1).urevent;
    EEG_copying.event(end).duration = 0;
    
    %% Translating Task
    
    file = dir('*p*_e1_t_EEG.mat');
    EEG = load(file.name);
    EEG_e1_t = EEG.EEG;
    
    EEG_e1_t.event(2).type = EEG_e1_t.event(1).type;
    EEG_e1_t.event(1).type = '5   ';
    
    quality_scores{zz,6} = EEG.automagic.rate;
    
    file = dir('*p*_e2_t_EEG.mat');
    EEG = load(file.name);
    EEG_e2_t = EEG.EEG;
    
    quality_scores{zz,7} = EEG.automagic.rate;
    
    EEG_translating = pop_mergeset(EEG_e1_t, EEG_e2_t);
    EEG_translating.event(end+1).type = '6   ';
    EEG_translating.event(end).latency = EEG_translating.event(end-1).latency;
    EEG_translating.event(end).urevent = EEG_translating.event(end-1).urevent;
    EEG_translating.event(end).duration = 0;
    
    %% Reading Post
    
    file = dir('*p*_rpost_71_EEG.mat');
    if not(isempty(file))
        EEG = load(file.name);
        EEG_71 = EEG.EEG;
        
        if EEG_71.pnts >= 150003
            EEG_71_5min = eeg_eegrej(EEG_71, [150003 EEG_71.pnts+1]);
            EEG_71_5min.event(end+1).type = EEG_71.event(end).type;
            EEG_71_5min.event(end).latency = 150000;
            EEG_71_5min.event(end).urevent = EEG_71.event(end-1).urevent;
            EEG_71_5min.event(end).duration = 0;

        EEG_71 = EEG_71_5min;
        clearvars EEG_71_5min            
            
        end
        

        
        
        quality_scores{zz,8} = EEG.automagic.rate;
        
        EEG_71.event(2).type = EEG_71.event(1).type;
        EEG_71.event(1).type = '7   ';
        
        file = dir('*p*_rpost_74_EEG.mat');
        EEG = load(file.name);
        EEG_74 = EEG.EEG;
        
        if EEG_74.pnts >= 150003
            EEG_74_5min = eeg_eegrej(EEG_74, [150003 EEG_74.pnts+1]);
            EEG_74_5min.event(end+1).type = EEG_74.event(end).type;
            EEG_74_5min.event(end).latency = 150000;
            EEG_74_5min.event(end).urevent = EEG_74.event(end-1).urevent;
            EEG_74_5min.event(end).duration = 0;
 
                EEG_74 = EEG_74_5min;
        clearvars EEG_74_5min
        
        end
        

        
        quality_scores{zz,9} = EEG.automagic.rate;
        
        EEG_rpost = pop_mergeset(EEG_71, EEG_74);
        EEG_rpost.event(end+1).type = '8   ';
        EEG_rpost.event(end).latency = EEG_rpost.event(end-1).latency;
        EEG_rpost.event(end).urevent = EEG_rpost.event(end-1).urevent;
        EEG_rpost.event(end).duration = 0;
    end
    
    file = dir('*p*_rpost_72_EEG.mat');
    if not(isempty(file))
        EEG = load(file.name);
        EEG_72 = EEG.EEG;
        
        quality_scores{zz,8} = EEG.automagic.rate;
        
        if EEG_72.pnts >= 150003
            EEG_72_5min = eeg_eegrej(EEG_72, [150003 EEG_72.pnts+1]);
            EEG_72_5min.event(end+1).type = EEG_72.event(end).type;
            EEG_72_5min.event(end).latency = 150000;
            EEG_72_5min.event(end).urevent = EEG_72.event(end-1).urevent;
            EEG_72_5min.event(end).duration = 0;
 
                
        EEG_72 = EEG_72_5min;
        clearvars EEG_72_5min
        
            
        end

        
        
        EEG_72.event(2).type = EEG_72.event(1).type;
        EEG_72.event(1).type = '7   ';
        
        file = dir('*p*_rpost_73_EEG.mat');
        EEG = load(file.name);
        EEG_73 = EEG.EEG;
        
        if EEG_73.pnts >= 150003
            EEG_73_5min = eeg_eegrej(EEG_73, [150003 EEG_73.pnts+1]);
            EEG_73_5min.event(end+1).type = EEG_73.event(end).type;
            EEG_73_5min.event(end).latency = 150000;
            EEG_73_5min.event(end).urevent = EEG_73.event(end-1).urevent;
            EEG_73_5min.event(end).duration = 0;

                EEG_73 = EEG_73_5min;
        clearvars EEG_73_5min
        
        end
        
      
        quality_scores{zz,9} = EEG.automagic.rate;
        
        EEG_rpost = pop_mergeset(EEG_72, EEG_73);
        EEG_rpost.event(end+1).type = '8   ';
        EEG_rpost.event(end).latency = EEG_rpost.event(end-1).latency;
        EEG_rpost.event(end).urevent = EEG_rpost.event(end-1).urevent;
        EEG_rpost.event(end).duration = 0;
    end
    
    %% merging
    clearvars EEG EEG_e1_r EEG_e1_c EEG_e1_t EEG_e2_r EEG_e2_c EEG_e2_t EEG_71 EEG_72 EEG_73 EEG_74
    
    EEG_final = pop_mergeset(EEG_reading, EEG_copying);
    clearvars EEG_reading EEG_copying
    EEG_final = pop_mergeset(EEG_final, EEG_translating);
    clearvars EEG_translating
    EEG_final = pop_mergeset(EEG_final, EEG_rpost);
    
    
    del = 0;
    for i = 1:length(EEG_final.event)
        if isequal(EEG_final.event(i-del).type, 'boundary')
            EEG_final.event(i-del) = [];
            del = del+1;
        end
    end
    
    
    pop_writebva(EEG_final,['F:\BVA_Translator_final\',vpNames{zz}, '_all_eog']);
    
    clearvars EEG_final EEG_rpost
end

cd(fileparts(tmp.Filename));

% arrange quality score as table and save it
quality_scores = cell2table(quality_scores, 'VariableNames',{'SubjectID' 'quality_e1_r' 'quality_e2_r'  'quality_e1_c' 'quality_e2_c'  'quality_e1_t' 'quality_e2_t'  'quality_e3_1' 'quality_e3_2'});
writetable(quality_scores,[fileparts(tmp.Filename) '\quality_scores.csv'],'FileType','text')
