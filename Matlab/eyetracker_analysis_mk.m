%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Eyetracker Analysis CLINT    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

%% Setting parameters and data paths

w_dev = 3;          %allowed deviation of the x-coordinate of a specific fixation to still be accounted for a word
h_dev = 30;         %allowed deviation of the y-coordinate of a specific fixation to still be accounted for a word
path_data = "E:/All_Data/"; % data path
path_savetable = "E:/";  %path to save result table

%% Change directory to the current m. file
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));


cd(path_data) %Change to data path

%% Preallocation of results table and group affiliation of subjects

T=cell(10,11); %Preallocation of results table
k = 0; %control variable for current row in T

%look through All_data folder to look for subjects and assign them to groups
group_pilot = [dir('C2*');dir('C3*')];
group_traba = [dir('CA*');dir('CB*');dir('CC*');dir('CD*')];
group_trama = [dir('CE*');dir('CF*');dir('CG*');dir('CH*')];
group_trapro = [dir('CI*');dir('CJ*');dir('CK*');dir('CL*')];
group_mulba = [dir('CM*');dir('CN*');dir('CO*');dir('CP*')];
group_mulma = [dir('CQ*');dir('CR*');dir('CS*');dir('CT*')];
group_mulpro = [dir('CU*');dir('CV*');dir('CW*');dir('CX*')];

group_all = [group_pilot;group_traba;group_trama;group_trapro;group_mulba;group_mulma;group_mulpro]; %Get all subjects

vpNames = {group_all.name};

% group_size_pilot = size(group_pilot); %Determining size of group to know, how long result tables have to be
% group_size_traba = size(group_traba);
% group_size_trama = size(group_trama);
% group_size_trapro = size(group_trapro);
% group_size_mulba = size(group_mulba);
% group_size_mulma = size(group_mulma);
% group_size_mulpro = size(group_mulpro);
% group_size_all = size(group_all);





%% extracting eyetracker features

for zz = 1:length(vpNames) %loop through subjects
    
    cd(path_data + "\" + vpNames{zz}) %open folder of current subject
    
    fullresults = dir("Fullresults*");
    load(fullresults.name); %load original answer file
    
    %get rid of unnecessary space at the end of sentence 30
    sentences_ue{1, 1}{1, 30}  = strrep(sentences_ue{1, 1}{1, 30}, '.  ','.');
    
    %% define groups
    
    for i = 1:length(vpNames)
        for j = 1:size(group_pilot,1)
            if strcmp(vpNames{zz},group_pilot(j).name)
                group = 'Pilot';
                break
            end
        end
        
        %         elseif strcmp(vpNames{zz},group_traba(j).name) && j < size(group_traba,1)
        %             group = 'TraBa';
        %             break
        for j = 1:size(group_trama,1)
            if strcmp(vpNames{zz},group_trama(j).name)
                group = 'TraMa';
                break
            end
        end
        
        for j = 1:size(group_trapro,1)
            if strcmp(vpNames{zz},group_trapro(j).name)
                group = 'TraPro';
                break
            end
        end
        
        for j = 1:size(group_mulba,1)
            if strcmp(vpNames{zz},group_mulba(j).name)
                group = 'MulBa';
                break
            end
        end
        
        for j = 1:size(group_mulma,1)
            if strcmp(vpNames{zz},group_mulma(j).name)
                group = 'MulMa';
                break
            end
        end
        
        for j = 1:size(group_mulpro,1)
            if strcmp(vpNames{zz},group_mulpro(j).name)
                group = 'MulPro';
                break
            end
        end
    end
    
    %% loop trough eyetracking files
    
    for x = 1:2 %control variable for processing text 1 or text 2
        
        text = dir(strjoin("*_E"+x+"*ET.mat"));
        load(text.name);
        
        %% find i for start trigger event in event(i,2), should be 1 for all files
        
        i = 1;
        while event(i,2) < 101 && event(i,2) > 112
            i = i + 1;
        end
        
        %% processing if event is trigger 101
        
        if event (i,2) == 101
            
            q = k + 1; %take k+1 as new start trigger, important for regression evaluation in the end
            i = i + 2; %ignore second trigger (11), no implications for reading task, first trigger 21 is first sentence
            j = 1; %variable for current fixation
            sentence = 0; %variable for sentence nummeration
            
            while event (i,2) == 21 %as long as trigger is 21, subjects did the sentence reading task
                
                sentence = sentence + 1; %increase sentence variable
                splitsentence = strsplit(sentences_ue{1,1}{1,sentence+1},{' ', '\\n'}); %split current sentence out of presented sentence (sentences_ue) into words
                
                %% get first fixation within first sentence
                while eyeevent.fixations.data(j,1) < event(i,1) %compare latency of eyeevent.fixation with event, if lower --> no sentence related fixation
                    j=j+1; %increase current fixation until first fixation of current sentence
                end
                
                %% compare each fixation with wordbounds until fixations is no longer within the current sentence latencys, get values for results table T
                while eyeevent.fixations.data(j,1) < event(i+1,1) %compare latency of eyeevent.fixation with event of next sentence --> all in between are fixations of current sentence
                    k = k + 1; %increase current row in result table T
                    T{k,1}=vpNames{zz}; %get subjectID
                    T{k,2}=group; %get group
                    T{k,3}='Text1'; %get text --> depending on trigger 101
                    T{k,4}='SE'; %get condition of text
                    T{k,5}='first'; %get timepoint of text within experiment
                    T{k,6}=sentence; %get number of sentence
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1); %difference between latency of fixation onset and offset equals duration of fixation
                    T{k,10}=eyeevent.fixations.data(j,6); %get Avg.PS (average pupil size)
                    
                    % compare fixation x and y with wordbounds of current
                    % sentence (wordbounds_reading)
                    n=1; %index variable for words
                    words=size(wordbounds_reading{1,1}{1,sentence+1});%number of words (their coordinates) for current sentence
                    
                    
                    while wordbounds_reading{1,1}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,1}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,1}{1,sentence+1}(n,3)+w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,1}{sentence+1}(n,4)+h_dev < eyeevent.fixations.data(j,5) %as long as coordinates of a fixation are not within a word boundary, go to next word
                        
                        n = n + 1; %go to next word
                        
                        if words(1,1) < n %if n is larger than amount of words in a sentence, coordinats are not within a word
                            T{k,7}='unknown'; %"unknown" Fixation
                            T{k,8}='unknown'; 
                            break 
                        end
                    end
                    if words(1,1) >= n %if n is smaller or equal to amount of words, fixation is on one of the words
                        
                        T{k,7}= "word"; %"word" fixation
                        T{k,8}= splitsentence(1,n); %get word of the sentence
                        T{k,11}= n; %get word number
                        
                    end
                    j = j+1; %go to next fixation in eyeevent.fixations.data
                end
                i = i + 1; %go to next event, as long as trigger is 21
            end
            
        elseif event (i,2) == 102 %same block as for start trigger 101 above
            
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            
            while event (i,2) == 22
                
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,2}{1,sentence+1},{' ', '\\n'});
                
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    
                    k = k + 1;
                    T{k,1}=group_all(zz,1).name;
                    T{k,2}=group;
                    T{k,3}='Text1';
                    T{k,4}='ELF';
                    T{k,5}='first';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,2}{1,sentence+1});
                    
                    while wordbounds_reading{1,2}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,2}{1,sentence+1}(n,2) - h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,2}{1,sentence+1}(n,3) + w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,2}{sentence+1}(n,4) + h_dev < eyeevent.fixations.data(j,5)
                        
                        n = n + 1;
                        
                        if words(1,1) < n
                            T{k,7}='unknown';
                            T{k,8}='unknown';
                            break
                        end
                    end
                    
                    if words(1,1) >= n
                        
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
            
        elseif event (i,2) == 103 %same block as for start trigger 101 above
            
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            
            while event (i,2) == 23
                
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,3}{1,sentence+1},{' ', '\\n'});
                
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(zz,1).name;
                    T{k,2}=group;
                    T{k,3}='Text2';
                    T{k,4}='SE';
                    T{k,5}='first';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,3}{1,sentence+1});
                    
                    while wordbounds_reading{1,3}{1,sentence+1}(n,1) - w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,3}{1,sentence+1}(n,2) - h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,3}{1,sentence+1}(n,3) + w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,3}{sentence+1}(n,4) + h_dev < eyeevent.fixations.data(j,5)
                        
                        n = n + 1;
                        
                        if words(1,1) < n
                            T{k,7}='unknown';
                            T{k,8}='unknown';
                            break
                        end
                    end
                    
                    if words(1,1) >= n
                        
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
            
        elseif event (i,2) == 104 %same block as for start trigger 101 above
            
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            
            while event (i,2) == 24
                
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,4}{1,sentence+1},{' ', '\\n'});
                
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    
                    k = k + 1;
                    T{k,1}=group_all(zz,1).name;
                    T{k,2}=group;
                    T{k,3}='Text2';
                    T{k,4}='ELF';
                    T{k,5}='first';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,4}{1,sentence+1});
                    
                    while wordbounds_reading{1,4}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,4}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,4}{1,sentence+1}(n,3)+w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,4}{sentence+1}(n,4)+h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        
                        if words(1,1) < n
                            T{k,7}='unknown';
                            T{k,8}='unknown';
                            break
                        end
                    end
                    
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
            
        elseif event (i,2) == 109 %same block as for start trigger 101 above
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            
            while event (i,2) == 21
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,1}{1,sentence+1},{' ', '\\n'});
                
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(zz,1).name;
                    T{k,2}=group;
                    T{k,3}='Text1';
                    T{k,4}='SE';
                    T{k,5}='second';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,1}{1,sentence+1});
                    
                    while wordbounds_reading{1,1}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,1}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,1}{1,sentence+1}(n,3) +w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,1}{sentence+1}(n,4) + h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}='unknown';
                            T{k,8}='unknown';
                            break
                        end
                    end
                    
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
            
        elseif event (i,2) == 110 %same block as for start trigger 101 above
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            
            while event (i,2) == 22
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,2}{1,sentence+1},{' ', '\\n'});
                
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(zz,1).name;
                    T{k,2}=group;
                    T{k,3}='Text1';
                    T{k,4}='ELF';
                    T{k,5}='second';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,2}{1,sentence+1});
                    
                    while wordbounds_reading{1,2}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,2}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,2}{1,sentence+1}(n,3)+w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,2}{sentence+1}(n,4)+h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}='unknown';
                            T{k,8}='unknown';
                            break
                        end
                    end
                    
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
            
        elseif event (i,2) == 111 %same block as for start trigger 101 above
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            
            while event (i,2) == 23
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,3}{1,sentence+1},{' ', '\\n'});
                
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(zz,1).name;
                    T{k,2}=group;
                    T{k,3}='Text2';
                    T{k,4}='SE';
                    T{k,5}='second';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,3}{1,sentence+1});
                    
                    while wordbounds_reading{1,3}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,3}{1,sentence+1}(n,2)-h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,3}{1,sentence+1}(n,3)+w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,3}{sentence+1}(n,4)+h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}='unknown';
                            T{k,8}='unknown';
                            break
                        end
                    end
                    
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
            
        elseif event (i,2) == 112 %same block as for start trigger 101 above
            q = k + 1;
            i = i + 2;
            j = 1;
            sentence = 0;
            
            while event (i,2) == 24
                sentence= sentence + 1;
                splitsentence= strsplit(sentences_ue{1,4}{1,sentence+1},{' ', '\\n'});
                
                while eyeevent.fixations.data(j,1) < event(i,1)
                    j=j+1;
                end
                
                while eyeevent.fixations.data(j,1) < event(i+1,1)
                    k = k + 1;
                    T{k,1}=group_all(zz,1).name;
                    T{k,2}=group;
                    T{k,3}='Text2';
                    T{k,4}='ELF';
                    T{k,5}='second';
                    T{k,6}=sentence;
                    T{k,9}=eyeevent.fixations.data(j,2)-eyeevent.fixations.data(j,1);
                    T{k,10}=eyeevent.fixations.data(j,6);
                    n=1;
                    words=size(wordbounds_reading{1,4}{1,sentence+1});
                    
                    while wordbounds_reading{1,4}{1,sentence+1}(n,1)-w_dev > eyeevent.fixations.data(j,4) || wordbounds_reading{1,4}{1,sentence+1}(n,2) -h_dev > eyeevent.fixations.data(j,5) || wordbounds_reading{1,4}{1,sentence+1}(n,3) + w_dev < eyeevent.fixations.data(j,4) || wordbounds_reading{1,4}{sentence+1}(n,4)+ h_dev < eyeevent.fixations.data(j,5)
                        n = n + 1;
                        if words(1,1) < n
                            T{k,7}='unknown';
                            T{k,8}='unknown';
                            break
                        end
                    end
                    
                    if words(1,1) >= n
                        T{k,7}= "word";
                        T{k,8}= splitsentence(1,n);
                        T{k,11}= n;
                        
                    end
                    j = j+1;
                end
                i = i + 1;
            end
        end
        
        %% evaluate which fixations are regression (word fixated for the second time)
        
        while q < k %solange erste k-Zeile der Eventschleife (q) tiefer als jetziges k
            y=q+1; %y soll eine Zeile unter q starten
            while y <= k && T{y,6} == T{q,6} %solange y nicht grösser als k (also Ende der Tabelle) und Satznummer(sentence) von y und q gleich sind
                if T{y,11} == T{q,11} %wenn Wort aus Zeile q gleich wie Wort aus Zeile y dann ist es eine Regression
                    T{y,7}="regression";
                end
                y=y+1; %nächstes Wort eine Zeile tiefer mit q vergleichen
            end
            q=q+1; %wenn erstes Wort ganz verglichen mit allen Wörtern im Satzevent, gehe ich eine Zeile tiefer
        end
        %regression fertig
    end
end

%% table just for words without unknown and regressions --> check for functionality of 
T_words=cell(10,11); %Preallocation
h=1; %index variable for T
o=1; %index variable for T_words
while h <= k %h is not allowd to be larger than k (length table T)
    if T{h,7} == "word" %if column 7 is "word" --> copy that row
        T_words{o,1}=T{h,1};
        T_words{o,2}=T{h,2};
        T_words{o,3}=T{h,3};
        T_words{o,4}=T{h,4};
        T_words{o,5}=T{h,5};
        T_words{o,6}=T{h,6};
        T_words{o,7}=T{h,7};
        T_words{o,8}=T{h,8};
        T_words{o,9}=T{h,9};
        T_words{o,10}=T{h,10};
        T_words{o,11}=T{h,11};
        o=o+1; 
    end
    h=h+1; 
end



%% save data as table
cd(path_savetable);

readingFixations = table(T(:,1),T(:,2),T(:,3),T(:,4),T(:,5),T(:,6),T(:,7),string(T(:,8)),T(:,9),T(:,10),T(:,11),'VariableNames', {'id','group','text','condition','time','sentence','type','word','duration','avgPS','wordNumber'});
writetable(readingFixations,'readingFixations.csv','FileType','spreadsheet');

cd(fileparts(tmp.Filename));