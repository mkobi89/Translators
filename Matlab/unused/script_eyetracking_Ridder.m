global recordname;
global eyeeventFile;
global sentenceFile;

recordname = 'CU4'; %Hier CU4 oder CE8 eintragen

if(recordname == 'CU4')
    eyeeventFile = 'CU4_E1T2_SE_ET.mat';
    sentenceFile = 'Fullresults_ELF_CU4.mat';
elseif(recordname == 'CE8')
    eyeeventFile = 'CE8_E1T1_SE_ET.mat';
    sentenceFile = 'Fullresults_ELF_CE8.mat';
else
    eyeeventFile = 'CE8_E1T1_SE_ET.mat';
    sentenceFile = 'Fullresults_ELF_CE8.mat';
end

load(eyeeventFile, 'data', 'event', 'eyeevent');
load(sentenceFile, 'par', 'sentences_ue', 'wordbounds_reading');

headings = {'id' 'group' 'text' 'condition' 'time' 'sentence' 'type' 'word' 'duration' 'AVG.PS'};

M = {};

for i=1 : length(eyeevent.fixations.data)
    
    %Spalte 1 - Anfang
    id = char(par.subjectID);
    M{i,1} = id;
    %Spalte 1 - Ende, Spalte 2 - Anfang
    group = getGroup(id);
    M{i,2} = char(group);
    %Spalte 2 - Ende, Spalte 3 - Anfang
    firstValue = event(1,2);
    M{i,3} = getText(firstValue);
    %Spalte 3 - Ende, Spalte 4 - Anfang
    M{i,4} = getCondition(firstValue);
    %Spalte 4 - Ende, Spalte 5 - Anfang
    M{i,5} = getTime(firstValue);
    %Spalte 5 - Ende, Spalte 6 - Anfang
    M{i,6} = getSentence(eyeevent.fixations.data(i,1));
    %Spalte 6 - Ende, Spalte 8 - Anfang
    M{i,8} = getWord(eyeevent.fixations.data(i,4),eyeevent.fixations.data(i,5),M{i,6});
    %Spalte 8 - Ende, Spalte 9 - Anfang
    t2 = eyeevent.fixations.data(i,2);
    t1 = eyeevent.fixations.data(i,1);
    dif = t2 - t1;
    M{i,9} = dif;
    %Spalte 9 - Ende, Spalte 10 - Anfang
    M{i,10} = eyeevent.fixations.data(i,6);
    %Spalte 10 - Ende
end

N = getType(M);

A = cell2table(N(1:end,:),'VariableNames',headings);
writetable(A,'data.csv');

% 101  T1_SE, E1 (time  first)
% 102  T1_ELF, E1 (time  first)
% 103  T2_SE, E1 (time  first)
% 104  T2_ELF, E1 (time  first)
% 109 T1_SE, E2 (time  first)
% 110  T1_ELF, E2 (time  first)
% 111  T2_SE, E2 (time  first)
% 112  T2_ELF, E2 (time  first)

function y = getText(x)
    y = "";
    
    if(x == 101 || x == 102 || x == 109 || x == 110)
        y = "Text1";
    end
    if(x == 103 || x == 104 || x == 111 || x == 112)
        y = "Text2";
    end
    if(y == "")
        y = "Fehler";
    end
end

function y = getCondition(x)
    y = "";
    
    if(x == 101 || x == 103 || x == 109 || x == 111)
        y = "SE";
    end
    if(x == 102 || x == 104 || x == 110 || x == 112)
        y = "ELF";
    end
    if(y == "")
        y = "Fehler";
    end
end

function y = getTime(x)
    y = "";
    
    if(x == 101 || x == 102 || x == 103 || x == 104)
        y = "First";
    end
    if(x == 109 || x == 110 || x == 111 || x == 112)
        y = "Second";
    end
    if(y == "")
        y = "Fehler";
    end
end

function y = getSentence(x)

    global eyeeventFile;
    
    load(eyeeventFile, 'event');

    trigger = 0;
    line = 0;
    for i = 1 : length(event) - 1
        if((event(i,1) <= x  && x <= event(i+1,1)))
            trigger = event(i,2);
            line = i;
        end
    end
    
    if (trigger ~= 21 && trigger ~= 22 && trigger ~= 23 && trigger ~= 24)
        y = "no text";
    else
        sentence = 0;
        for i = 1 : line
            if(event(i,2) == trigger)
                sentence = sentence + 1;
            end
        end
        y = sentence; 
    end
end


function Z = getType(M)

    dict = [];
    i = 1;

    while(i <= length(M))
        if(isa(M{i,6},"double"))
            dict(M{i,6},1) = M{i,6};
            dict(M{i,6},2) = i;
            for j = i : length(M)
                if(isa(M{j,6},"double") && M{j,6} ~= M{i,6})
                    dict(M{i,6},3) = j-1;
                    i = j-1;
                    break;
                elseif(isa(M{j,6},"double") && ~isa(M{j+1,6},"double"))
                    dict(M{i,6},3) = j;
                    i = j;
                    break;
                end
            end
        end
        i = i + 1;
    end
    
    for i = 1 : length(M)
        Z{i,1} = M{i,1};
        Z{i,2} = M{i,2};
        Z{i,3} = M{i,3};
        Z{i,4} = M{i,4};
        Z{i,5} = M{i,5};
        Z{i,6} = M{i,6};
        %Z{i,7} = M{i,7};
        Z{i,8} = M{i,8};
        Z{i,9} = M{i,9};
        Z{i,10} = M{i,10};
        
        if(~isa(M{i,6},"double"))
            Z{i,7} = "no text";
        elseif(strcmp(M{i,8}, " ")) 
            Z{i,7} = "unknown";
        else
            if(i == dict(M{i,6},2))
                Z{i,7} = "word";
            else
                for j = dict(M{i,6},2) : i-1
                    if(strcmp(M{j,8},M{i,8}))
                        Z{i,7} = "regression";
                        break;
                    end
                end
            end
            if(~strcmp(Z{i,7},"regression"))
                Z{i,7} = "word";
            end
        end
    end
end

function z = getWord(x,y,s)
    
    z = ' ';
    
    global sentenceFile;
    global recordname;
    
    load(sentenceFile, 'wordbounds_reading','sentences_ue');
    
    if(recordname == 'CE8')
        index = 1;
    elseif(recordname == 'CU4')
        index = 2;
    else
        index = 1;
    end
    

    if(isa(s, 'double'))
        for i = 1 : length(wordbounds_reading{1, index}{1, s+1})
            if(wordbounds_reading{1, index}{1, s+1}(i,1) <= x && x <= wordbounds_reading{1, index}{1, s+1}(i,3))
                if(wordbounds_reading{1, index}{1, s+1}(i,2) <= y && y <= wordbounds_reading{1, index}{1, s+1}(i,4))
                    sen = sentences_ue{1,index}{1,s+1};
                    sen = strrep(sen,'\n',' ');
                    sen = strrep(sen,',','');
                    sen = strrep(sen,'.','');
                    sen_a = split(sen);
                    z = sen_a{i};
                end
            end
        end
    end 
end

function y = getGroup(x)

    y = "";
    
    group.pilot = {'C00','C21','C22','C23', 'C24', 'C25', 'C26', 'CT','CXY'};
    group.traba = {'CA0','CA1','CA2','CA3','CA4','CA5','CA6','CA7','CA8','CA9','CB0','CB1','CB2','CB3','CB4','CB5','CB6','CB7','CB8','CB9','CC0','CC1','CC2','CC3','CC4','CC5','CC6','CC7','CC8','CC9','CD0','CD1','CD2','CD3','CD4','CD5','CD6','CD7','CD8','CD9'};
    group.trama = {'CE0','CE1','CE2','CE3','CE4','CE5','CE6','CE7','CE8','CE9','CF0','CF1','CF2','CF3','CF4','CF5','CF6','CF7','CF8','CF9','CG0','CG1','CG2','CG3','CG4','CG5','CG6','CG7','CG8','CG9','CH0','CH1','CH2','CH3','CH4','CH5','CH6','CH7','CH8','CH9'};
    group.trapro = {'CI0','CI1','CI2','CI3','CI4','CI5','CI6','CI7','CI8','CI9','CJ0','CJ1','CJ2','CJ3','CJ4','CJ5','CJ6','CJ7','CJ8','CJ9','CK0','CK1','CK2','CK3','CK4','CK5','CK6','CK7','CK8','CK9','CL0','CL1','CL2','CL3','CL4','CL5','CL6','CL7','CL8','CL9'};

    group.mulba = {'CM0','CM1','CM2','CM3','CM4','CM5','CM6','CM7','CM8','CM9','CN0','CN1','CN2','CN3','CN4','CN5','CN6','CN7','CN8','CN9','CO0','CO1','CO2','CO3','CO4','CO5','CO6','CO7','CO8','CO9','CP0','CP1','CP2','CP3','CP4','CP5','CP6','CP7','CP8','CP9'};
    group.mulma = {'CQ0','CQ1','CQ2','CQ3','CQ4','CQ5','CQ6','CQ7','CQ8','CQ9','CR0','CR1','CR2','CR3','CR4','CR5','CR6','CR7','CR8','CR9','CS0','CS1','CS2','CS3','CS4','CS5','CS6','CS7','CS8','CS9','CT0','CT1','CT2','CT3','CT4','CT5','CT6','CT7','CT8','CT9'};
    group.mulpro = {'CU0','CU1','CU2','CU3','CU4','CU5','CU6','CU7','CU8','CU9','CV0','CV1','CV2','CV3','CV4','CV5','CV6','CV7','CV8','CV9','CW0','CW1','CW2','CW3','CW4','CW5','CW6','CW7','CW8','CW9','CX0','CX1','CX2','CX3','CX4','CX5','CX6','CX7','CX8','CX9'};
    
    for i = 1 : length(group.pilot)
        if(strcmp(x,group.pilot{i}))
            y = 'Pilot';
        end
    end
    
    for i = 1 : length(group.traba)
        if(strcmp(x,group.traba{i}))
            y = 'TraBa';
        end
    end
    
    for i = 1 : length(group.trama)
        if(strcmp(x,group.trama{i}))
            y = 'TraMa';
        end
    end
    
    for i = 1 : length(group.trapro)
        if(strcmp(x,group.trapro{i}))
            y = 'TraPro';
        end
    end
    
    for i = 1 : length(group.mulba)
        if(strcmp(x,group.mulba{i}))
            y = 'MulBa';
        end
    end
    
    for i = 1 : length(group.mulma)
        if(strcmp(x,group.mulma{i}))
            y = 'MulMa';
        end
    end
    
    for i = 1 : length(group.mulpro)
        if(strcmp(x,group.mulpro{i}))
            y = 'MulPro';
        end
    end
    
    if(y == "")
        y = "Fehler";
    end
end