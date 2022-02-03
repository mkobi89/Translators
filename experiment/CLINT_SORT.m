clear GLOBAL
clear VARIABLES
global h fileID %Define those globally to not pass them through all functions
clc;
pathAllSubjects = '/home/stimuluspc/CLINT/All_Subjects/';
addpath(genpath('/home/stimuluspc/Tools/Tooboxes/eeglab'))
subjectToProcess = inputdlg('Please enter Subject ID','SORT',1);
if exist(strjoin([pathAllSubjects subjectToProcess],''))~=7 %Checks wheter Dubject ID Folder exists
    error('SUBJECT ID DOESNT EXIST');
elseif isempty(subjectToProcess{1})
    error('SUBJECT ID DOESNT EXIST');
end
fileID = fopen(strjoin([pathAllSubjects subjectToProcess '/SORT.log'],''),'a'); %Logfile
choice = questdlg('Which ones to sort?', ...
    'SORT', ...
    'ET Only','EEG Only','Both','Both');
% Handle response
switch choice
    case 'ET Only'
        fprintf(fileID, '--------- ET ---------\n');
        h = waitbar(0,'ET Files sortieren');
        SortETFiles(pathAllSubjects, subjectToProcess);
    case 'EEG Only'
        fprintf(fileID, '--------- EEG --------\n');
        h = waitbar(0,'EEG Files sortieren');
        SortEEGFiles(pathAllSubjects, subjectToProcess);
    case 'Both'
        
        fprintf(fileID, '--------- BOTH -------\n');
        h = waitbar(0,'Alle Files sortieren');
        SortEEGFiles(pathAllSubjects, subjectToProcess);
        SortETFiles(pathAllSubjects, subjectToProcess);
    otherwise
        error('CANCELLED');
end
clc;
close(h);
fclose(fileID);

load gong.mat
sound(y);


msgbox('DONE');

function SortEEGFiles(pathAllSubjects, subjectToProcess)
if exist(strjoin([pathAllSubjects subjectToProcess '/ARCHIVE'],''))~=7 %Check wheter ARCHIVE Directory exists
    mkdir(strjoin([pathAllSubjects subjectToProcess '/ARCHIVE'],''));
end
global h fileID;
%antisaccCounter=1;
trigger = [... % DEFINING TRIGGERS
    122 ...  % Instructions & Resting EEG
    101 ... % Exp 1 Text 1 SE
    102 ... % Exp 1 Text 1 ELF
    103 ... % Exp 1 Text 2 SE
    104 ... % Exp 1 Text 2 ELF
    109 ... % Exp 2 Text 1 SE
    110 ... % Exp 2 Text 1 ELF
    111 ... % Exp 2 Text 2 SE
    112 ... % Exp 2 Text 2 ELF
    5 ...  % LDT
    7 ... % Exp 3 
    ];
files = dir(fullfile(strjoin([pathAllSubjects subjectToProcess '/'],''),'*.RAW'));
files = {files.name}; %Loading List of Files
for i=1:length(files) %And Looping through it
    waitbar(i/length(files),h,'EEG Files');
    filePath = strjoin([pathAllSubjects subjectToProcess '/' char(files(i))],'');
    current = strjoin([pathAllSubjects subjectToProcess '/' char(files(i))],'');
    EEG = pop_readegi(current, [],[],'auto');
    destination = strjoin([pathAllSubjects subjectToProcess '/' subjectToProcess],'');
    if not(isempty(EEG.event))
        switch str2num(EEG.event(1).type)%First event is Trigger, Move accordingly
            case trigger(1)
                out = MoveFile(current,destination,'_Instr_RS_EEG'); %Tests for File duplicates recursively
                SaveArchive(EEG, out);
            case trigger(2)
                out = MoveFile(current,destination,'_E1T1_SE_EEG');
                SaveArchive(EEG, out);
            case trigger(3)
                out = MoveFile(current,destination,'_E1T1_ELF_EEG');
                SaveArchive(EEG, out);
            case trigger(4)
                out = MoveFile(current,destination,'_E1T2_SE_EEG');
                SaveArchive(EEG, out);
            case trigger(5)
                out = MoveFile(current,destination,'_E1T2_ELF_EEG');
                SaveArchive(EEG, out);
            case trigger(6)
                out = MoveFile(current,destination,'_E2T1_SE_EEG');
                SaveArchive(EEG, out);
            case trigger(7)
                out = MoveFile(current,destination,'_E2T1_ELF_EEG');
                SaveArchive(EEG, out);
            case trigger(8)
                out = MoveFile(current,destination,'_E2T2_SE_EEG');
                SaveArchive(EEG, out);
            case trigger(9)
                out = MoveFile(current,destination,'_E2T2_ELF_EEG');
                SaveArchive(EEG, out);
            case trigger(10)
                out = MoveFile(current,destination,'_LDT_EEG');
                SaveArchive(EEG, out);
            case trigger(11)
                out = MoveFile(current,destination,'_E3_EEG');
                SaveArchive(EEG, out);
            otherwise
                out = MoveFile(current,destination,'_unknown_EEG');
                SaveArchive(EEG, out);
        end
    else
        out = MoveFile(current,destination,'_unknown_EEG');
        SaveArchive(EEG, out);
    end
    
end
end
function SortETFiles(pathAllSubjects, subjectToProcess)
global h fileID;
pathEdf2Asc = '/home/stimuluspc/Tools/Tools/edf2asc'; %Path of EDF2ASC CLI

if exist(strjoin([pathAllSubjects subjectToProcess '/ARCHIVE'],''))~=7 %Check wheter ARCHIVE Directory exists
    mkdir(strjoin([pathAllSubjects subjectToProcess '/ARCHIVE'],''));
end

% Move .edf Files to Archive
files = dir(fullfile(strjoin([pathAllSubjects subjectToProcess '/'],''),'*.edf'));
files = {files.name}; %Get Files
for i=1:length(files)
    filePath = strjoin([pathAllSubjects subjectToProcess '/' char(files(i))],'');
    fprintf(fileID, [datestr(datetime('now')) ' ARCHIVE: ' filePath '\n']);
    movefile(filePath,strjoin([pathAllSubjects subjectToProcess '/ARCHIVE/' char(files(i))],'')); %Move Files to Archive
end

% Move .asc Files to Archive
files = dir(fullfile(strjoin([pathAllSubjects subjectToProcess '/'],''),'*.asc'));
files = {files.name}; %Get Files
for i=1:length(files)
    filePath = strjoin([pathAllSubjects subjectToProcess '/' char(files(i))],'');
    fprintf(fileID, [datestr(datetime('now')) ' ARCHIVE: ' filePath '\n']);
    movefile(filePath,strjoin([pathAllSubjects subjectToProcess '/ARCHIVE/' char(files(i))],'')); %Move Files to Archive
end

% Copy .mat Files to Archive
files = dir(fullfile(strjoin([pathAllSubjects subjectToProcess '/'],''),'*ET.mat'));
fileNames = {files.name}; %Get Files

for i=1:length(fileNames) %And Looping through it
    filePath = strjoin([pathAllSubjects subjectToProcess '/' char(fileNames(i))],'');
    renamePath = strjoin([pathAllSubjects subjectToProcess],'');
   
    % Rename .mat Files
    trigger = [... % DEFINING TRIGGERS
        122 ...  % Instructions & Resting EEG
        101 ... % Exp 1 Text 1 SE
        102 ... % Exp 1 Text 1 ELF
        103 ... % Exp 1 Text 2 SE
        104 ... % Exp 1 Text 2 ELF
        109 ... % Exp 2 Text 1 SE
        110 ... % Exp 2 Text 1 ELF
        111 ... % Exp 2 Text 2 SE
        112 ... % Exp 2 Text 2 ELF
        5 ...  % LDT
        7 ... % Exp 3
        ];
    
    load(filePath)
    
    if not(isempty(event))
        if event(1,2) == trigger(1)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'')); 
        elseif event(1,2) ==  trigger(2)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E1T1_SE_ET.mat'],'')); 
        elseif event(1,2) ==   trigger(3)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E1T1_ELF_ET.mat'],'')); 
        elseif event(1,2) ==  trigger(4)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E1T2_SE_ET.mat'],'')); 
        elseif event(1,2) ==   trigger(5)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E1T2_ELF_ET.mat'],'')); 
        elseif event(1,2) ==  trigger(6)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E2T1_SE_ET.mat'],'')); 
        elseif event(1,2) ==   trigger(7)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E2T1_ELF_ET.mat'],'')); 
        elseif event(1,2) ==  trigger(8)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E2T2_SE_ET.mat'],'')); 
        elseif event(1,2) ==   trigger(9)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E2T2_ELF_ET.mat'],'')); 
        elseif event(1,2) ==  trigger(10)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_LDT_ET.mat'],'')); 
        elseif event(1,2) ==   trigger(11)
                fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
                copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_E3_ET.mat'],'')); 
%         else
%                 fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
%                 copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_unknown_ET.mat'],'')); 

        end
    else
        fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' filePath ' TO: ' strjoin([renamePath '/' subjectToProcess '_Instr_RS_ET.mat'],'') '\n']);
        copyfile(filePath,strjoin([renamePath '/' subjectToProcess '_unknown_ET.mat'],''));

    end

    fprintf(fileID, [datestr(datetime('now')) ' ARCHIVE: ' filePath '\n']);
    movefile(filePath,strjoin([pathAllSubjects subjectToProcess '/ARCHIVE/' char(fileNames(i))],'')); %Move Files to Archive
end

% for i=1:length(files) %Loop through files
%     waitbar(i/length(files),h,'ET Files');
%     disp(['Processing File: ' i ' of ' length(files)]);
%     filePath = strjoin([pathAllSubjects subjectToProcess '/' char(files(i))],'');
%     fprintf(fileID, [datestr(datetime('now')) ' EDF2ASC: ' filePath '\n']);
%     system([pathEdf2Asc ' "' filePath '" -y']); %Convert Files to ASC using EDF2ASC CLI
%     fprintf(fileID, [datestr(datetime('now')) ' ARCHIVE: ' filePath '\n']);
%     movefile(filePath,strjoin([pathAllSubjects subjectToProcess '/ARCHIVE/' char(files(i))],'')); %Move Files to Archive
%     parseeyelink(strrep(filePath,'.edf','.asc'),[strrep(filePath,'.edf','') '_ET.mat'],'TR');
%     fprintf(fileID, [datestr(datetime('now')) ' PARSE: ' strrep(filePath,'.edf','.asc') '\n']);
%     movefile(strrep(filePath,'.edf','.asc'),strjoin([pathAllSubjects subjectToProcess '/ARCHIVE/' strrep(char(files(i)),'.edf', '.asc')],'')); %Move Files to Archive
%     fprintf(fileID, [datestr(datetime('now')) ' ARCHIVE: ' strrep(filePath,'.edf','.asc') '\n']);
% end
end
function out = MoveFile(current, destination, name, iter)
% Recursively checks wheter File exists and names it accordingly _x where X
% is revision of the File...
global fileID
if nargin < 4
    iter =  0; %if called with 3 Arguments it's first iteration
end
if iter==0
    fullName= [name '.RAW'];
else
    fullName= [name '_' num2str(iter) '.RAW']; %not in First iteration anymore
end
paths = strsplit(destination,'/');
subjNr = [paths(end)'];
archivePath = [strjoin([paths(1:end-1)'],'/') '/ARCHIVE' '/'];
if ~(exist(strjoin([archivePath subjNr fullName],''), 'file') == 2)
    if ~strcmp(strjoin({[destination fullName]},''),current)
        movefile(current,[destination fullName]);
        fprintf(fileID, [datestr(datetime('now')) ' RENAME: ' current ' TO: ' fullName '\n']);
    end
    out = [destination fullName];
else
    out = MoveFile(current, destination, name ,iter+1); %Recursion with iterator
end
end
function SaveArchive(EEG, in)
global fileID
paths = strsplit(in,'/');
filename = strsplit(paths{end},'.');
path = [strjoin([paths(1:end-1)'],'/') '/'];
if ~(exist([path filename{1} '.mat'], 'file') == 2) && (exist([in], 'file') == 2)
    fprintf(fileID, [datestr(datetime('now')) ' TOMAT: ' in '\n']);
    save([path filename{1} '.mat'], 'EEG');
    movefile([in],[path 'ARCHIVE/' [filename{1} '.' filename{2}]]); %Move Files to Archive
    fprintf(fileID, [datestr(datetime('now')) ' ARCHIVE: ' in '\n']);
elseif (exist([clepath filename{1} '.mat'], 'file') == 2) && (exist([in], 'file') == 2)
    movefile([in],[path 'ARCHIVE/' [filename{1} '.' filename{2}]]); %Move Files to Archive
    fprintf(fileID, [datestr(datetime('now')) ' ARCHIVE: ' in '\n']);
end
end

