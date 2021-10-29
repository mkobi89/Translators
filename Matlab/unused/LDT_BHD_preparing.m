%%%% Preparing Behavioural Data %%%%
clearvars

%% Define Paths
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename)); % go to directory of the current file
cd('..'); % Go to parent wd

ldtWD = pwd;  % Path of Local Repository LDT

% Path to all data
if IsOSX == true
    allDataPath = '/Volumes/CLINT/All_Data/';
    targetEEGLDTPath = '/Volumes/CLINT/LDT_new/';
else
    allDataPath = '//130.60.235.123/users/neuro/Desktop/CLINT/All_Data/';
    targetEEGLDTPath = '//130.60.235.123/users/neuro/Desktop/CLINT/LDT_new/';
end % Data on Server

savePathMatlab = strjoin([ldtWD,{'/data/rawdata/matlab_rawdata/'}],''); 
savePathLDT = strjoin([ldtWD,{'/data/rawdata/answers/'}],'');

if exist(savePathMatlab)~=7 %#ok<*EXIST> %Check wheter Directory exists
   mkdir savePathMatlab;
end
if exist(savePathLDT)~=7 %#ok<*EXIST> %Check wheter Directory exists
   mkdir savePathLDT;
end


%% Copy Answerfiles to Matlab Folder on LDT Repository
cd(allDataPath);

vplist = dir('C*');
vpNames = {vplist.name};


for zz = 1:length(vpNames)
    
    cd(strjoin([allDataPath {vpNames{zz}}],'')) %#ok<*CCAT1>
    
    files = dir('Fullresults*.mat');
    fileNames = {files.name};
    
    if exist(strjoin([savePathMatlab fileNames],'/'))~=7 %Check wheter Directory exists
        copyfile(char(fileNames),savePathMatlab);
    end
    
    if exist(strjoin([savePathMatlab fileNames],'/'))~=7 %Check wheter Directory exists
        copyfile(char(fileNames),[targetEEGLDTPath, vpNames{zz},'/']);
    end
    
end

%% Process Matlab-Answer-Files

cd(savePathMatlab);

files = dir('Fullresults*.mat');
fileNames = {files.name};

for zz = 1:length(fileNames)
    load(fileNames{zz})
    
    %% LDT
    % Read answer tables from LDT and write them to .csv
    
    writetable(answers_task_1,[savePathLDT, fileNames{zz}(17:19),'_answers_task_1.csv'],'FileType','text')
    writetable(answers_task_2,[savePathLDT, fileNames{zz}(17:19),'_answers_task_2.csv'],'FileType','text')
    writetable(answers_task_3,[savePathLDT, fileNames{zz}(17:19),'_answers_task_3.csv'],'FileType','text')
    
end

%Reset WD
cd(strjoin([ldtWD,{'/Matlab'}],''));