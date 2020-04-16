%%%% Preparing Behavioural Data %%%%
clearvars

%% Define Paths
allDataPath = 'F:\All_Data\';
savePath = 'C:\Users\matth\Documents\Translators\data\rawdata\';

savePathLDT = 'F:\Auswertung\LDT\';

savePathMatlab = strjoin([savePath,{'matlab_rawdata'}],'');
savePathTask = strjoin([savePath,{'task'}],'');


% if exist('F:\Auswertung\LDT')~=7 %#ok<*EXIST> %Check wheter Directory exists
%     mkdir F:\Auswertung\LDT;
% end
% if exist('F:\Auswertung\Matlab')~=7 %Check wheter Directory exists
%     mkdir F:\Auswertung\Matlab;
% end
% if exist('F:\Auswertung\Translation')~=7
%     mkdir F:\Auswertung\Translation;
% end
% if exist('F:\Auswertung\Behavioral_Data')~=7
%     mkdir F:\Auswertung\Behavioral_Data;
% end


%% Copy Answerfiles to Matlab Folder
cd(allDataPath);
vp_list = dir('C*');

for i = 1:length(vp_list)
    vp_name = vp_list(i);
    vpNames{i} = vp_name.name;
end

for zz = 1:length(vpNames)
    
    cd(strjoin([allDataPath {vpNames{zz}}],'')) %#ok<*CCAT1>
    
    filePattern = fullfile('*Fullresults*.mat');
    files = dir(filePattern);
    
    for i = 1:length(files)
        filename = files(i);
        fileNames{i} = filename.name;
    end
    
    if exist(strjoin([savePathMatlab fileNames],''))~=7 %Check wheter Directory exists
        copyfile(char(fileNames),savePathMatlab);
    end
end

%% Process Matlab-Answer-Files

cd(savePathMatlab);

filePattern = fullfile('*Fullresults*.mat');
files = dir(filePattern);

for i = 1:length(files)
    filename = files(i);
    fileNames{i} = filename.name;
end

text_output = []; %#ok<*NASGU>
ueb_saetze = zeros(length(fileNames),4);
ueb_chars = zeros(length(fileNames),4);
ueb_chars_tot = zeros(length(fileNames),4);
ueb_chars_errors = zeros(length(fileNames),4);
ab_saetze = zeros(length(fileNames),4);
ab_chars = zeros(length(fileNames),4);
ab_chars_tot = zeros(length(fileNames),4);
ab_chars_errors = zeros(length(fileNames),4);

exp_control = {};

for zz = 1:length(fileNames)
    load(fileNames{zz})
    
    %% LDT
    % Read answer tables from LDT and write them to .csv
    
    writetable(answers_task_1,[savePathLDT, fileNames{zz}(17:19),'_answers_task_1.csv'],'FileType','text')
    writetable(answers_task_2,[savePathLDT, fileNames{zz}(17:19),'_answers_task_2.csv'],'FileType','text')
    writetable(answers_task_3,[savePathLDT, fileNames{zz}(17:19),'_answers_task_3.csv'],'FileType','text')
    
    %% Task Order
    
    if par.order(1) == 2 || par.order(2) == 2
        t1_is_ELF(zz) = 1;
    else
        t1_is_ELF(zz) = 0;
    end
    
    if par.order(1) == 1 || par.order(1) == 2
        t1_is_first(zz) = 1;
    else
        t1_is_first(zz) = 0;
    end
    
    %% Task
    % Read Text from Task and Write them to .txt per Subject
    % Count numbers of sentences and chars in Text Output and write them to .csv
    
    FID = fopen([strjoin([savePathTask,{'textfiles\'}],'\'),par.subjectID,'_translation.txt'],'w');
    for t = 1:4
        for s = 1:38
            if ~isempty(results_text_uebersetzen{t,s})
                fprintf(FID,'Text %d, Satz %d\n',t,s-1);
                fprintf(FID,'%s\n\n',results_text_uebersetzen{t, s});
                ueb_saetze(zz,t) = ueb_saetze(zz,t) + 1;
                ueb_chars(zz,t) = ueb_chars(zz,t) + length(results_text_uebersetzen{t, s});
                ueb_chars_tot(zz,t) = ueb_chars_tot(zz,t) + (length(results_output_uebersetzen{t, s})-2);
                ueb_chars_errors(zz,t) = ueb_chars_errors(zz,t)+sum(results_output_uebersetzen{t,s} == "BackSpace");
            end
        end
    end
    fclose(FID);
    
    FID = fopen([strjoin([savePathTask,{'textfiles\'}],'\'),par.subjectID,'_copying.txt'],'w');
    for t = 1:4
        for s = 1:38
            if ~isempty(results_text_abschreiben{t,s})
                fprintf(FID,'Text %d, Satz %d\n',t,s-1);
                fprintf(FID,'%s\n\n',results_text_abschreiben{t, s});
                ab_saetze(zz,t) = ab_saetze(zz,t) + 1;
                ab_chars(zz,t) = ab_chars(zz,t) + length(results_text_abschreiben{t, s});
                ab_chars_tot(zz,t) = ab_chars_tot(zz,t) + (length(results_output_abschreiben{t, s})-2);
                ab_chars_errors(zz,t) = ab_chars_errors(zz,t)+sum(results_output_abschreiben{t,s} == "BackSpace");
            end
        end
    end
    fclose(FID);
    subject{zz} = par.subjectID;
    
    % Export Task Results as .csv 
    results_copying = table(results_text_abschreiben(1,:)',results_text_abschreiben(2,:)',results_text_abschreiben(3,:)',results_text_abschreiben(4,:)', 'VariableNames', {'T1_SE_copy','T1_ELF_copy','T2_SE_copy','T2_ELF_copy'});
    writetable(results_copying,[strjoin([savePathTask,{'copying\'}],'\'),par.subjectID,'_copying.csv'],'FileType','spreadsheet')
    
    results_translating = table(results_text_uebersetzen(1,:)',results_text_uebersetzen(2,:)',results_text_uebersetzen(3,:)',results_text_uebersetzen(4,:)', 'VariableNames', {'T1_SE_translated','T1_ELF_translated','T2_SE_translated','T2_ELF_translated'});
    writetable(results_translating,[strjoin([savePathTask,{'translation\'}],'\'),par.subjectID,'_translated.csv'],'FileType','spreadsheet')
     
    
    %% Control Question
    contr_quest_table(zz,1:11) = results_control_questions(2,:);
    for i = 1:length(results_control_questions)
        if  contr_quest_table(zz,i) == "correct"
            contr_quest(zz,i) = 1;
        else
            contr_quest(zz,i) = 0;
        end
    end
    
    contr_quest(zz,12) = sum(contr_quest(zz,2:6));
    contr_quest(zz,13) = sum(contr_quest(zz,7:11));
    
    
    %%  Perceived Difficulty
    
    if length(sub_empf_schwierigkeit_lesen) == 3
        sub_empf_schwierigkeit_lesen(4) = NaN;
    end
    if length(sub_empf_schwierigkeit_uebersetzen) == 3
        sub_empf_schwierigkeit_uebersetzen(4) = NaN;
    end
    for i = 1:4
        if sub_empf_schwierigkeit_lesen(i) == 0
            sub_empf_schwierigkeit_lesen(i) = NaN;
        end
        if sub_empf_schwierigkeit_uebersetzen(i) == 0
            sub_empf_schwierigkeit_uebersetzen(i) = NaN;
        end
    end
    
    pd_r(zz,1:4) = sub_empf_schwierigkeit_lesen;
    pd_t(zz,1:4) = sub_empf_schwierigkeit_uebersetzen;
    
    %% Reading Duration Sentences
    if iscell(timing_reading_sentence{1,1}) || iscell(timing_reading_sentence{1,2})
        for i = 1:length(timing_reading_sentence)
            readingDuration(zz,i) = sum(cell2mat(timing_reading_sentence{1,i}));
        end
        if length(timing_reading_sentence) == 3
            readingDuration(zz,4) = NaN;
        end
        
        for i = 5:7
            readingDuration(zz,i) = readingDuration(zz,i-4)/length(timing_reading_sentence{i-4});
        end
        if length(timing_reading_sentence) == 4
            readingDuration(zz,8) = readingDuration(zz,4)/length(timing_reading_sentence{4});
        else
            readingDuration(zz,8) = NaN;
        end
    else
        for i = 1:length(timing_reading_sentence)
            readingDuration(zz,i) = sum(cell2mat(timing_reading_sentence(1,i)));
        end
        if length(timing_reading_sentence) == 3
            readingDuration(zz,4) = NaN;
        end
        
        for i = 5:7
            readingDuration(zz,i) = readingDuration(zz,i-4)/length(timing_reading_sentence{i-4});
        end
        if length(timing_reading_sentence) == 4
            readingDuration(zz,8) = readingDuration(zz,4)/length(timing_reading_sentence{4});
        else
            readingDuration(zz,8) = NaN;
        end
    end
    
    %% Experiment_Control
    
    exp_control{zz,1} = par.subjectID;
    exp_control{zz,2} = par.time_for_task;
    exp_control{zz,3} = par.time_rs;
    exp_control{zz,4} = par.recordEEG;
    exp_control{zz,5} = par.useEL;
    exp_control{zz,6} = par.useEL_Calib;
    exp_control{zz,7} = par.recordFullEXP;
    exp_control{zz,8} = par.order_index;
    exp_control{zz,9} = par.order;
    exp_control{zz,10} = par.order_index_task;
    exp_control{zz,11} = par.order_task;
    exp_control{zz,12} = par.order_index_LDT;
    exp_control{zz,13} = par.order_LDT;
    
end


%% Define Groups
group.pilot = {'C00','C21','C22','C23', 'C24', 'C25', 'C26', 'CT','CXY'};
group.traba = {'CA0','CA1','CA2','CA3','CA4','CA5','CA6','CA7','CA8','CA9','CB0','CB1','CB2','CB3','CB4','CB5','CB6','CB7','CB8','CB9','CC0','CC1','CC2','CC3','CC4','CC5','CC6','CC7','CC8','CC9','CD0','CD1','CD2','CD3','CD4','CD5','CD6','CD7','CD8','CD9'};
group.trama = {'CE0','CE1','CE2','CE3','CE4','CE5','CE6','CE7','CE8','CE9','CF0','CF1','CF2','CF3','CF4','CF5','CF6','CF7','CF8','CF9','CG0','CG1','CG2','CG3','CG4','CG5','CG6','CG7','CG8','CG9','CH0','CH1','CH2','CH3','CH4','CH5','CH6','CH7','CH8','CH9'};
group.trapro = {'CI0','CI1','CI2','CI3','CI4','CI5','CI6','CI7','CI8','CI9','CJ0','CJ1','CJ2','CJ3','CJ4','CJ5','CJ6','CJ7','CJ8','CJ9','CK0','CK1','CK2','CK3','CK4','CK5','CK6','CK7','CK8','CK9','CL0','CL1','CL2','CL3','CL4','CL5','CL6','CL7','CL8','CL9'};

group.mulba = {'CM0','CM1','CM2','CM3','CM4','CM5','CM6','CM7','CM8','CM9','CN0','CN1','CN2','CN3','CN4','CN5','CN6','CN7','CN8','CN9','CO0','CO1','CO2','CO3','CO4','CO5','CO6','CO7','CO8','CO9','CP0','CP1','CP2','CP3','CP4','CP5','CP6','CP7','CP8','CP9'};
group.mulma = {'CQ0','CQ1','CQ2','CQ3','CQ4','CQ5','CQ6','CQ7','CQ8','CQ9','CR0','CR1','CR2','CR3','CR4','CR5','CR6','CR7','CR8','CR9','CS0','CS1','CS2','CS3','CS4','CS5','CS6','CS7','CS8','CS9','CT0','CT1','CT2','CT3','CT4','CT5','CT6','CT7','CT8','CT9'};
group.mulpro = {'CU0','CU1','CU2','CU3','CU4','CU5','CU6','CU7','CU8','CU9','CV0','CV1','CV2','CV3','CV4','CV5','CV6','CV7','CV8','CV9','CW0','CW1','CW2','CW3','CW4','CW5','CW6','CW7','CW8','CW9','CX0','CX1','CX2','CX3','CX4','CX5','CX6','CX7','CX8','CX9'};

for i = 1:length(subject)
    if sum(strcmp(subject(1,i),group.pilot)) > 0
        subject(2,i) = {'Pilot'};
    elseif sum(strcmp(subject(1,i),group.traba)) > 0
        subject(2,i) = {'TraBa'};
    elseif sum(strcmp(subject(1,i),group.trama)) > 0
        subject(2,i) = {'TraMa'};
    elseif sum(strcmp(subject(1,i),group.trapro)) > 0
        subject(2,i) = {'TraPro'};
    elseif sum(strcmp(subject(1,i),group.mulba)) > 0
        subject(2,i) = {'MulBa'};
    elseif sum(strcmp(subject(1,i),group.mulma)) > 0
        subject(2,i) = {'MulMa'};
    elseif sum(strcmp(subject(1,i),group.mulpro)) > 0
        subject(2,i) = {'MulPro'};
    end
end

%% Collect Data

text_output = table(subject(1,:)',subject(2,:)',num2cell(ueb_saetze(:,1)),num2cell(ueb_saetze(:,2)),num2cell(ueb_saetze(:,3)),num2cell(ueb_saetze(:,4)), num2cell(ueb_chars(:,1)),num2cell(ueb_chars(:,2)),num2cell(ueb_chars(:,3)),num2cell(ueb_chars(:,4)),num2cell(ueb_chars_tot(:,1)),num2cell(ueb_chars_tot(:,2)),num2cell(ueb_chars_tot(:,3)),num2cell(ueb_chars_tot(:,4)), num2cell(ueb_chars_errors(:,1)),num2cell(ueb_chars_errors(:,2)),num2cell(ueb_chars_errors(:,3)),num2cell(ueb_chars_errors(:,4)), num2cell(ab_saetze(:,1)),num2cell(ab_saetze(:,2)),num2cell(ab_saetze(:,3)),num2cell(ab_saetze(:,4)),num2cell(ab_chars(:,1)),num2cell(ab_chars(:,2)),num2cell(ab_chars(:,3)),num2cell(ab_chars(:,4)), num2cell(ab_chars_tot(:,1)),num2cell(ab_chars_tot(:,2)),num2cell(ab_chars_tot(:,3)),num2cell(ab_chars_tot(:,4)), num2cell(ab_chars_errors(:,1)),num2cell(ab_chars_errors(:,2)),num2cell(ab_chars_errors(:,3)),num2cell(ab_chars_errors(:,4)), 'VariableNames', {'id','group','traSenT1','traSenT2','traSenT3','traSenT4','traCharT1','traCharT2','traCharT3','traCharT4','traCharTotT1','traCharTotT2','traCharTotT3','traCharTotT4','traCharErrT1','traCharErrT2','traCharErrT3','traCharErrT4','copSenT1','copSenT2','copSenT3','copSenT4','copCharT1','copCharT2','copCharT3','copCharT4','copCharTotT1','copCharTotT2','copCharTotT3','copCharTotT4','copCharErrT1','copCharErrT2','copCharErrT3','copCharErrT4'});
control_questions_pd_r_t = table(subject(1,:)',subject(2,:)', contr_quest(:,1),contr_quest(:,2),contr_quest(:,3),contr_quest(:,4),contr_quest(:,5),contr_quest(:,6),contr_quest(:,7),contr_quest(:,8),contr_quest(:,9),contr_quest(:,10),contr_quest(:,11),contr_quest(:,12),contr_quest(:,13), t1_is_ELF',t1_is_first',pd_r(:,1),pd_r(:,2),pd_r(:,3),pd_r(:,4),pd_t(:,1),pd_t(:,2),pd_t(:,3),pd_t(:,4), 'VariableNames', {'id','group','instr_cq', 'cq1_t1','cq2_t1','cq3_t1','cq4_t1','cq5_t1','cq1_t2','cq2_t2','cq3_t2','cq4_t2','cq5_t2','cq_sum_t1','cq_sum_t2','T1_is_ELF','T1_is_first','Perc_diff_R_T1_SE','Perc_diff_R_T1_ELF','Perc_diff_R_T2_SE','Perc_diff_R_T2_ELF','Perc_diff_T_T1_SE','Perc_diff_T_T1_ELF','Perc_diff_T_T2_SE','Perc_diff_T_T2_ELF'});
readingDuration = table(subject(1,:)',subject(2,:)', readingDuration(:,1),readingDuration(:,2),readingDuration(:,3),readingDuration(:,4),readingDuration(:,5),readingDuration(:,6),readingDuration(:,7),readingDuration(:,8), t1_is_ELF',t1_is_first', 'VariableNames', {'id','group','SumReadingDuration_T1_SE','SumReadingDuration_T1_ELF','SumReadingDuration_T2_SE','SumReadingDuration_T2_ELF','AvgReadingDuration_T1_SE','AvgReadingDuration_T1_ELF','AvgReadingDuration_T2_SE','AvgReadingDuration_T2_ELF','T1_is_ELF','T1_is_first'});


%% Export Sentences to Copy

sentences_t1 = sentences_ue{:,1}';
sentences_t2 = sentences_ue{:,2}';
sentences_t3 = sentences_ue{:,3}';
sentences_t4 = sentences_ue{:,4}';

sentences = {};

for i = 2:38
    sentences(i,1) = {sentences_t1{i,1}};
    sentences(i,2) = {sentences_t2{i,1}};
    if i <= 28
        sentences(i,3) = {sentences_t3{i,1}};
    else
        sentences(i,3) = {''};
    end
    if i <= 26
        sentences(i,4) = {sentences_t4{i,1}};
    else
        sentences(i,4) = {''};
    end
end
            

%% Rearrange Reading Duration

for j = 1:size(readingDuration,1)
    if readingDuration{j,3} == 0
        readingDuration{j,3} = NaN;
    end
    if readingDuration{j,4} == 0
        readingDuration{j,4} = NaN;
    end
    if readingDuration{j,5} == 0
        readingDuration{j,5} = NaN;
    end
end


n_row = 1;
for j = 1: size(readingDuration,1)
    for k = 1:4
        if k == 1
            
            if ~isnan(readingDuration{j,3})
                readingDuration_long_format(n_row,1) = readingDuration.id(j);
                readingDuration_long_format(n_row,2) = readingDuration.group(j);
                readingDuration_long_format{n_row,3} = 'Text1';
                readingDuration_long_format{n_row,4} = 'SE';
                
                if  readingDuration.T1_is_first(j) == 1
                    readingDuration_long_format{n_row,5} = 'First';
                else
                    readingDuration_long_format{n_row,5} = 'Second';
                end
                
                readingDuration_long_format{n_row,6} = readingDuration.SumReadingDuration_T1_SE(j);
                readingDuration_long_format{n_row,7} = readingDuration.AvgReadingDuration_T1_SE(j);
                
                n_row = n_row+1;
            end
        elseif k == 2
            if ~isnan(readingDuration{j,4})
                readingDuration_long_format(n_row,1) = readingDuration.id(j);
                readingDuration_long_format(n_row,2) = readingDuration.group(j);
                readingDuration_long_format{n_row,3} = 'Text1';
                readingDuration_long_format{n_row,4} = 'ELF';
                
                
                if  readingDuration.T1_is_first(j) == 1
                    readingDuration_long_format{n_row,5} = 'First';
                else
                    readingDuration_long_format{n_row,5} = 'Second';
                end
                
                
                readingDuration_long_format{n_row,6} = readingDuration.SumReadingDuration_T1_ELF(j);
                readingDuration_long_format{n_row,7} = readingDuration.AvgReadingDuration_T1_ELF(j);
                
                n_row = n_row+1;
            end
        elseif k == 3
            if ~isnan(readingDuration{j,5})
                readingDuration_long_format(n_row,1) = readingDuration.id(j);
                readingDuration_long_format(n_row,2) = readingDuration.group(j);
                readingDuration_long_format{n_row,3} = 'Text2';
                readingDuration_long_format{n_row,4} = 'SE';
                
                if  readingDuration.T1_is_first(j) == 1
                    readingDuration_long_format{n_row,5} = 'Second';
                else
                    readingDuration_long_format{n_row,5} = 'First';
                end
                
                
                readingDuration_long_format{n_row,6} = readingDuration.SumReadingDuration_T2_SE(j);
                readingDuration_long_format{n_row,7} = readingDuration.AvgReadingDuration_T2_SE(j);
                
                n_row = n_row+1;
            end
        elseif k == 4
            if ~isnan(readingDuration{j,6})
                readingDuration_long_format(n_row,1) = readingDuration.id(j);
                readingDuration_long_format(n_row,2) = readingDuration.group(j);
                readingDuration_long_format{n_row,3} = 'Text2';
                readingDuration_long_format{n_row,4} = 'ELF';
                
                if  readingDuration.T1_is_first(j) == 1
                    readingDuration_long_format{n_row,5} = 'Second';
                else
                    readingDuration_long_format{n_row,5} = 'First';
                end
                
                readingDuration_long_format{n_row,6} = readingDuration.SumReadingDuration_T2_ELF(j);
                readingDuration_long_format{n_row,7} = readingDuration.AvgReadingDuration_T2_ELF(j);
                
                n_row = n_row+1;
            end
        end
    end
end


%% Rearrange Control Questions

n_row = 1;
for j = 1: size(control_questions_pd_r_t,1)
    for k = 1:10
        control_questions_pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
        control_questions_pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
        if k == 1
            control_questions_pd_r_t_long_format{n_row,3} = 'Text1';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question1';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq1_t1(j);
            
        elseif k == 2
            control_questions_pd_r_t_long_format{n_row,3} = 'Text1';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question2';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq2_t1(j);
            
        elseif k == 3
            control_questions_pd_r_t_long_format{n_row,3} = 'Text1';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question3';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq3_t1(j);
            
        elseif k == 4
            control_questions_pd_r_t_long_format{n_row,3} = 'Text1';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question4';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq4_t1(j);
            
        elseif k == 5
            control_questions_pd_r_t_long_format{n_row,3} = 'Text1';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question5';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq5_t1(j);
            
        elseif k == 6
            control_questions_pd_r_t_long_format{n_row,3} = 'Text2';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question1';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq1_t2(j);
            
            
        elseif k == 7
            control_questions_pd_r_t_long_format{n_row,3} = 'Text2';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question2';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq2_t2(j);
            
        elseif k == 8
            control_questions_pd_r_t_long_format{n_row,3} = 'Text2';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question3';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq3_t2(j);
            
        elseif k == 9
            control_questions_pd_r_t_long_format{n_row,3} = 'Text2';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question4';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq4_t2(j);
            
        elseif k == 10
            control_questions_pd_r_t_long_format{n_row,3} = 'Text2';
            
            if control_questions_pd_r_t.T1_is_ELF(j) == 1
                control_questions_pd_r_t_long_format{n_row,4} = 'SE';
            else
                control_questions_pd_r_t_long_format{n_row,4} = 'ELF';
            end
            
            if control_questions_pd_r_t.T1_is_first(j) == 1
                control_questions_pd_r_t_long_format{n_row,5} = 'Second';
            else
                control_questions_pd_r_t_long_format{n_row,5} = 'First';
            end
            
            control_questions_pd_r_t_long_format{n_row,6} = 'Question5';
            control_questions_pd_r_t_long_format{n_row,7} = control_questions_pd_r_t.cq5_t2(j);
            
        end
        
        n_row = n_row+1;
    end
    
end

%% Rearrange Text Output

n_row = 1;
for j = 1: size(text_output,1)
    for k = 1:8
        if k == 1
            if cell2mat(text_output{j,3}) ~= 0
                text_output_long_format(n_row,1) = text_output.id(j);
                text_output_long_format(n_row,2) = text_output.group(j);
                text_output_long_format{n_row,3} = 'Translating';
                
                if t1_is_first(j) == 1
                    if exp_control{j,11}(1) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(3) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                end
                
                text_output_long_format{n_row,5} = 'Text1';
                text_output_long_format{n_row,6} = 'SE';
                
                if  t1_is_first(j) == 1
                    text_output_long_format{n_row,7} = 'First';
                else
                    text_output_long_format{n_row,7} = 'Second';
                end
                
                text_output_long_format{n_row,8} = text_output.traSenT1{j};
                text_output_long_format{n_row,9} = text_output.traCharT1{j};
                text_output_long_format{n_row,10} = text_output.traCharTotT1{j};
                text_output_long_format{n_row,11} = text_output.traCharErrT1{j};
                
                n_row = n_row+1;
            end
        elseif k == 2
            if cell2mat(text_output{j,4}) ~= 0
                text_output_long_format(n_row,1) = text_output.id(j);
                text_output_long_format(n_row,2) = text_output.group(j);
                text_output_long_format{n_row,3} = 'Translating';
                
                if t1_is_first(j) == 1
                    if exp_control{j,11}(1) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(3) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                end
                
                text_output_long_format{n_row,5} = 'Text1';
                text_output_long_format{n_row,6} = 'ELF';
                
                if  t1_is_first(j) == 1
                    text_output_long_format{n_row,7} = 'First';
                else
                    text_output_long_format{n_row,7} = 'Second';
                end
                
                text_output_long_format{n_row,8} = text_output.traSenT2{j};
                text_output_long_format{n_row,9} = text_output.traCharT2{j};
                text_output_long_format{n_row,10} = text_output.traCharTotT2{j};
                text_output_long_format{n_row,11} = text_output.traCharErrT2{j};
                
                n_row = n_row+1;
            end
        elseif k == 3
            if cell2mat(text_output{j,5}) ~= 0
                text_output_long_format(n_row,1) = text_output.id(j);
                text_output_long_format(n_row,2) = text_output.group(j);
                text_output_long_format{n_row,3} = 'Translating';
                
                if t1_is_first(j) == 1
                    if exp_control{j,11}(3) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(1) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                end
                
                text_output_long_format{n_row,5} = 'Text2';
                text_output_long_format{n_row,6} = 'SE';
                
                if  t1_is_first(j) == 1
                    text_output_long_format{n_row,7} = 'Second';
                else
                    text_output_long_format{n_row,7} = 'First';
                end
                
                text_output_long_format{n_row,8} = text_output.traSenT3{j};
                text_output_long_format{n_row,9} = text_output.traCharT3{j};
                text_output_long_format{n_row,10} = text_output.traCharTotT3{j};
                text_output_long_format{n_row,11} = text_output.traCharErrT3{j};
                
                n_row = n_row+1;
                
            end
        elseif k == 4
            if cell2mat(text_output{j,6}) ~= 0
                text_output_long_format(n_row,1) = text_output.id(j);
                text_output_long_format(n_row,2) = text_output.group(j);
                text_output_long_format{n_row,3} = 'Translating';
                
                if t1_is_first(j) == 1
                    if exp_control{j,11}(3) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(1) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                end
                
                text_output_long_format{n_row,5} = 'Text2';
                text_output_long_format{n_row,6} = 'ELF';
                
                if  t1_is_first(j) == 1
                    text_output_long_format{n_row,7} = 'Second';
                else
                    text_output_long_format{n_row,7} = 'First';
                end
                
                text_output_long_format{n_row,8} = text_output.traSenT4{j};
                text_output_long_format{n_row,9} = text_output.traCharT4{j};
                text_output_long_format{n_row,10} = text_output.traCharTotT4{j};
                text_output_long_format{n_row,11} = text_output.traCharErrT4{j};
                
                n_row = n_row+1;
            end
        elseif k == 5
            if cell2mat(text_output{j,19}) ~= 0
                text_output_long_format(n_row,1) = text_output.id(j);
                text_output_long_format(n_row,2) = text_output.group(j);
                text_output_long_format{n_row,3} = 'Copying';
                
                if t1_is_first(j) == 1
                    if exp_control{j,11}(1) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(3) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                end
                
                text_output_long_format{n_row,5} = 'Text1';
                text_output_long_format{n_row,6} = 'SE';
                
                if  t1_is_first(j) == 1
                    text_output_long_format{n_row,7} = 'First';
                else
                    text_output_long_format{n_row,7} = 'Second';
                end
                
                text_output_long_format{n_row,8} = text_output.copSenT1{j};
                text_output_long_format{n_row,9} = text_output.copCharT1{j};
                text_output_long_format{n_row,10} = text_output.copCharTotT1{j};
                text_output_long_format{n_row,11} = text_output.copCharErrT1{j};
                
                n_row = n_row+1;
            end
        elseif k == 6
            if cell2mat(text_output{j,20}) ~= 0
                text_output_long_format(n_row,1) = text_output.id(j);
                text_output_long_format(n_row,2) = text_output.group(j);
                text_output_long_format{n_row,3} = 'Copying';
                
                if t1_is_first(j) == 1
                    if exp_control{j,11}(1) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(3) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                end
                
                text_output_long_format{n_row,5} = 'Text1';
                text_output_long_format{n_row,6} = 'ELF';
                
                if  t1_is_first(j) == 1
                    text_output_long_format{n_row,7} = 'First';
                else
                    text_output_long_format{n_row,7} = 'Second';
                end
                
                text_output_long_format{n_row,8} = text_output.copSenT2{j};
                text_output_long_format{n_row,9} = text_output.copCharT2{j};
                text_output_long_format{n_row,10} = text_output.copCharTotT2{j};
                text_output_long_format{n_row,11} = text_output.copCharErrT2{j};
                
                n_row = n_row+1;
            end
        elseif k == 7
            if cell2mat(text_output{j,21}) ~= 0
                text_output_long_format(n_row,1) = text_output.id(j);
                text_output_long_format(n_row,2) = text_output.group(j);
                text_output_long_format{n_row,3} = 'Copying';
                
                if t1_is_first(j) == 1
                    if exp_control{j,11}(3) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(1) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                end
                
                text_output_long_format{n_row,5} = 'Text2';
                text_output_long_format{n_row,6} = 'SE';
                
                if  t1_is_first(j) == 1
                    text_output_long_format{n_row,7} = 'First';
                else
                    text_output_long_format{n_row,7} = 'Second';
                end
                
                text_output_long_format{n_row,8} = text_output.copSenT3{j};
                text_output_long_format{n_row,9} = text_output.copCharT3{j};
                text_output_long_format{n_row,10} = text_output.copCharTotT3{j};
                text_output_long_format{n_row,11} = text_output.copCharErrT3{j};
                
                n_row = n_row+1;
            end
        elseif k == 8
            if cell2mat(text_output{j,22}) ~= 0
                text_output_long_format(n_row,1) = text_output.id(j);
                text_output_long_format(n_row,2) = text_output.group(j);
                text_output_long_format{n_row,3} = 'Copying';
                
                if t1_is_first(j) == 1
                    if exp_control{j,11}(3) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(1) == 1
                        text_output_long_format{n_row,4} = 'TraFirst';
                    else
                        text_output_long_format{n_row,4} = 'TraSecond';
                    end
                end
                
                text_output_long_format{n_row,5} = 'Text2';
                text_output_long_format{n_row,6} = 'ELF';
                
                if  t1_is_first(j) == 1
                    text_output_long_format{n_row,7} = 'First';
                else
                    text_output_long_format{n_row,7} = 'Second';
                end
                
                text_output_long_format{n_row,8} = text_output.copSenT4{j};
                text_output_long_format{n_row,9} = text_output.copCharT4{j};
                text_output_long_format{n_row,10} = text_output.copCharTotT4{j};
                text_output_long_format{n_row,11} = text_output.copCharErrT4{j};
                
                n_row = n_row+1;
                
            end
        end
    end
end

%% Rearrange Perceived Difficulty

n_row = 1;
for j = 1: size(control_questions_pd_r_t,1)
    for k = 1:8
        if k == 1
            if ~isnan(control_questions_pd_r_t.Perc_diff_R_T1_SE(j))
                pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
                pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
                pd_r_t_long_format{n_row,3} = 'Reading';
                pd_r_t_long_format{n_row,4} = 'Text1';
                pd_r_t_long_format{n_row,5} = 'SE';
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    pd_r_t_long_format{n_row,6} = 'First';
                else
                    pd_r_t_long_format{n_row,6} = 'Second';
                end
                pd_r_t_long_format{n_row,8} = control_questions_pd_r_t.Perc_diff_R_T1_SE(j);
                
                n_row = n_row + 1;
            end
        elseif k == 2
            if ~isnan(control_questions_pd_r_t.Perc_diff_R_T1_ELF(j))
                pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
                pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
                pd_r_t_long_format{n_row,3} = 'Reading';
                pd_r_t_long_format{n_row,4} = 'Text1';
                pd_r_t_long_format{n_row,5} = 'ELF';
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    pd_r_t_long_format{n_row,6} = 'First';
                else
                    pd_r_t_long_format{n_row,6} = 'Second';
                end
                pd_r_t_long_format{n_row,8} = control_questions_pd_r_t.Perc_diff_R_T1_ELF(j);
                
                n_row = n_row + 1;
            end
        elseif k == 3
            if ~isnan(control_questions_pd_r_t.Perc_diff_R_T2_SE(j))
                pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
                pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
                pd_r_t_long_format{n_row,3} = 'Reading';
                pd_r_t_long_format{n_row,4} = 'Text2';
                pd_r_t_long_format{n_row,5} = 'SE';
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    pd_r_t_long_format{n_row,6} = 'Second';
                else
                    pd_r_t_long_format{n_row,6} = 'First';
                end
                pd_r_t_long_format{n_row,8} = control_questions_pd_r_t.Perc_diff_R_T2_SE(j);
                
                n_row = n_row + 1;
            end
        elseif k == 4
            if ~isnan(control_questions_pd_r_t.Perc_diff_R_T2_ELF(j))
                pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
                pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
                pd_r_t_long_format{n_row,3} = 'Reading';
                pd_r_t_long_format{n_row,4} = 'Text2';
                pd_r_t_long_format{n_row,5} = 'ELF';
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    pd_r_t_long_format{n_row,6} = 'Second';
                else
                    pd_r_t_long_format{n_row,6} = 'First';
                end
                pd_r_t_long_format{n_row,8} = control_questions_pd_r_t.Perc_diff_R_T2_ELF(j);
                
                n_row = n_row + 1;
            end
        elseif k == 5
            if ~isnan(control_questions_pd_r_t.Perc_diff_T_T1_SE(j))
                pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
                pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
                pd_r_t_long_format{n_row,3} = 'Translating';
                pd_r_t_long_format{n_row,4} = 'Text1';
                pd_r_t_long_format{n_row,5} = 'SE';
                
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    pd_r_t_long_format{n_row,6} = 'First';
                else
                    pd_r_t_long_format{n_row,6} = 'Second';
                end
                
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    if exp_control{j,11}(1) == 1
                        pd_r_t_long_format{n_row,7} = 'TraFirst';
                    else
                        pd_r_t_long_format{n_row,7} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(3) == 1
                        pd_r_t_long_format{n_row,7} = 'TraFirst';
                    else
                        pd_r_t_long_format{n_row,7} = 'TraSecond';
                    end
                end
                
                pd_r_t_long_format{n_row,8} = control_questions_pd_r_t.Perc_diff_T_T1_SE(j);
                
                n_row = n_row + 1;
                
            end
        elseif k == 6
            if ~isnan(control_questions_pd_r_t.Perc_diff_T_T1_ELF(j))
                pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
                pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
                pd_r_t_long_format{n_row,3} = 'Translating';
                pd_r_t_long_format{n_row,4} = 'Text1';
                pd_r_t_long_format{n_row,5} = 'ELF';
                
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    pd_r_t_long_format{n_row,6} = 'First';
                else
                    pd_r_t_long_format{n_row,6} = 'Second';
                end
                
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    if exp_control{j,11}(1) == 1
                        pd_r_t_long_format{n_row,7} = 'TraFirst';
                    else
                        pd_r_t_long_format{n_row,7} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(3) == 1
                        pd_r_t_long_format{n_row,7} = 'TraFirst';
                    else
                        pd_r_t_long_format{n_row,7} = 'TraSecond';
                    end
                end
                
                pd_r_t_long_format{n_row,8} = control_questions_pd_r_t.Perc_diff_T_T1_ELF(j);
                
                n_row = n_row + 1;
            end
        elseif k == 7
            if ~isnan(control_questions_pd_r_t.Perc_diff_T_T2_SE(j))
                pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
                pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
                pd_r_t_long_format{n_row,3} = 'Translating';
                pd_r_t_long_format{n_row,4} = 'Text2';
                pd_r_t_long_format{n_row,5} = 'SE';
                
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    pd_r_t_long_format{n_row,6} = 'Second';
                else
                    pd_r_t_long_format{n_row,6} = 'First'; %#ok<*SAGROW>
                end
                
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    if exp_control{j,11}(3) == 1
                        pd_r_t_long_format{n_row,7} = 'TraFirst';
                    else
                        pd_r_t_long_format{n_row,7} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(1) == 1
                        pd_r_t_long_format{n_row,7} = 'TraFirst';
                    else
                        pd_r_t_long_format{n_row,7} = 'TraSecond';
                    end
                end
                
                pd_r_t_long_format{n_row,8} = control_questions_pd_r_t.Perc_diff_T_T2_SE(j);
                
                n_row = n_row + 1;
            end
        elseif k == 8
            if ~isnan(control_questions_pd_r_t.Perc_diff_T_T2_ELF(j))
                pd_r_t_long_format(n_row,1) = control_questions_pd_r_t.id(j);
                pd_r_t_long_format(n_row,2) = control_questions_pd_r_t.group(j);
                pd_r_t_long_format{n_row,3} = 'Translating';
                pd_r_t_long_format{n_row,4} = 'Text2';
                pd_r_t_long_format{n_row,5} = 'ELF';
                
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    pd_r_t_long_format{n_row,6} = 'Second';
                else
                    pd_r_t_long_format{n_row,6} = 'First';
                end
                
                if control_questions_pd_r_t.T1_is_first(j) == 1
                    if exp_control{j,11}(3) == 1
                        pd_r_t_long_format{n_row,7} = 'TraFirst';
                    else
                        pd_r_t_long_format{n_row,7} = 'TraSecond';
                    end
                else
                    if exp_control{j,11}(1) == 1
                        pd_r_t_long_format{n_row,7} = 'TraFirst';
                    else
                        pd_r_t_long_format{n_row,7} = 'TraSecond';
                    end
                end
                
                pd_r_t_long_format{n_row,8} = control_questions_pd_r_t.Perc_diff_T_T2_ELF(j);
                
                n_row = n_row + 1;
            end
        end
    end
end

%% Export .csv

exp_control = table(exp_control(:,1),exp_control(:,2),exp_control(:,3),exp_control(:,4),exp_control(:,5),exp_control(:,6),exp_control(:,7),exp_control(:,8),exp_control(:,9),exp_control(:,10),exp_control(:,11),exp_control(:,12),exp_control(:,13),'VariableNames', {'id','timeTask','timeRS','recordEEG','useEL','useEL_Calib','recordFullEXP','order_index','order','order_index_task','order_task','order_index_LDT','order_LDT'});
writetable(exp_control,[savePath, 'expControl.csv'],'FileType','spreadsheet')

control_questions = table(control_questions_pd_r_t_long_format(:,1),control_questions_pd_r_t_long_format(:,2),control_questions_pd_r_t_long_format(:,3),control_questions_pd_r_t_long_format(:,4),control_questions_pd_r_t_long_format(:,5),control_questions_pd_r_t_long_format(:,6),control_questions_pd_r_t_long_format(:,7),'VariableNames', {'id','group','text','condition','time','question','correct'});
writetable(control_questions,[savePath, 'controlQuestions.csv'],'FileType','spreadsheet')

pd_r_t = table(pd_r_t_long_format(:,1),pd_r_t_long_format(:,2),pd_r_t_long_format(:,3),pd_r_t_long_format(:,4),pd_r_t_long_format(:,5),pd_r_t_long_format(:,6),pd_r_t_long_format(:,7),pd_r_t_long_format(:,8),'VariableNames', {'id','group','task','text','condition', 'time','timeTra', 'perceivedDifficulty'});
writetable(pd_r_t,[savePath, 'perceivedDifficulty.csv'],'FileType','spreadsheet')

text_output = table(text_output_long_format(:,1),text_output_long_format(:,2),text_output_long_format(:,3),text_output_long_format(:,4),text_output_long_format(:,5),text_output_long_format(:,6),text_output_long_format(:,7),text_output_long_format(:,8),text_output_long_format(:,9),text_output_long_format(:,10),text_output_long_format(:,11),'VariableNames', {'id','group','task','timeTra', 'text', 'condition', 'time','sentences','chars','charsTotal','charsErrors'});
writetable(text_output,[savePath, 'textOutput.csv'],'FileType','spreadsheet')

readingDuration = table(readingDuration_long_format(:,1),readingDuration_long_format(:,2),readingDuration_long_format(:,3),readingDuration_long_format(:,4),readingDuration_long_format(:,5),readingDuration_long_format(:,6),readingDuration_long_format(:,7),'VariableNames', {'id','group','text','condition','time','sumReadingDuration','avgReadingDuration'});
writetable(readingDuration,[savePath, 'readingDuration.csv'],'FileType','spreadsheet')

sentences_copying = table(sentences(:,1),sentences(:,2),sentences(:,3),sentences(:,4), 'VariableNames', {'T1_SE_copy_stimulus','T1_ELF_copy_stimulus','T2_SE_copy_stimulus','T2_ELF_copy_stimulus'});
%writetable(sentences_copying,[savePathTask,'copying_stimulus.csv'],'FileType','spreadsheet')