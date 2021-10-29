%%%% Preparing Behavioural Data %%%%
clearvars

%% Define Paths
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename)); % go to directory of the current file
cd('..'); % Go to parent wd

ldtWD = pwd;  % Path of Local Repository LDT

% Path to all data
if IsOSX == true
    ServerPath = '/Volumes/CLINT/';
else
    ServerPath = '130.60.235.123/users/neuro/Desktop/CLINT/';
end % Data on Server

savePathNBack = strjoin([ldtWD,{'/data/rawdata/nBack/'}],'');


if exist(savePathNBack)~=7 %#ok<*EXIST> %Check wheter Directory exists
   mkdir savePathNBack;
end


%% Copy n-Back files to n Back Folder on LDT Repository
cd([ServerPath 'n_back_logs/']);

vplist = dir('*-n_back_*.log');
vpNames = {vplist.name};

for zz = 1:length(vpNames)
    
    cd([ServerPath 'n_back_logs/']) %#ok<*CCAT1>
    
    files = dir('*-n_back_*.log');
    fileNames = {files.name};
    
    if exist(strjoin([savePathNBack fileNames],'/'))~=7 %Check wheter Directory exists
        copyfile(char(fileNames(zz)),savePathNBack);
    end
end

%% Process Matlab-Answer-Files

% cd(savePathMatlab);

% files = dir('Fullresults*.mat');
% fileNames = {files.name};
% 
% for zz = 1:length(fileNames)
%     load(fileNames{zz})
%     
%     %% LDT
%     % Read answer tables from LDT and write them to .csv
%     
%     writetable(answers_task_1,[savePathLDT, fileNames{zz}(17:19),'_answers_task_1.csv'],'FileType','text')
%     writetable(answers_task_2,[savePathLDT, fileNames{zz}(17:19),'_answers_task_2.csv'],'FileType','text')
%     writetable(answers_task_3,[savePathLDT, fileNames{zz}(17:19),'_answers_task_3.csv'],'FileType','text')
%     
% end
% 
% %Reset WD
% cd(strjoin([ldtWD,{'/Matlab'}],''));