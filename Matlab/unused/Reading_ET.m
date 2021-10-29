clear

allDataPath = '\\130.60.235.127\daten\CLINT\04_Auswertungen\Eyetracking\';
savePath = '\\130.60.235.127\daten\CLINT\04_Auswertungen\Eyetracking\';

cd(allDataPath);

vplist = dir('C*');
vpNames = {vplist.name};

for zz = 1:length(vpNames)
    
    cd(strjoin([allDataPath {vpNames{zz}}],''))
    
    files = dir('Fullresults*.mat');
    files = dir(fullfile('Fullresults*.mat'));
    Results = {files.name};
    
    files = dir('*E1*_ET.mat');
    E1_ET = {files.name};
    
    load(Results{zz});
    load(E1_ET{zz});
    
    % Get Subject
    id{zz} = par.subjectID;
    
    % Get Group
    
    
    % Define, which text was read
    if event(1,2) == 101
        text = 'Text1';
        condition = 'SE';
        time = 'First';
        t = 1;
    elseif event(1,2) == 102
        text = 'Text1';
        condition = 'ELF';
        time = 'First';
        t = 2;
    elseif event(1,2) == 103
        text = 'Text2';
        condition = 'SE';
        time = 'First';
        t = 3;
    elseif event(1,2) == 104
        text = 'Text2';
        condition = 'ELF';
        time = 'First';
        t = 4;       
    end
    
    
%     ii = 1;
%     for jj = 1:length(eyeevent.fixations.data)
%         if eyeevent.fixations.data(jj,1) >= event(3,1) && eyeevent.fixations.data(jj,1) <= event(4,1)
%             if eyeevent.fixations.data(jj,4);
%                 is_word(ii) = 'something';
%                 ii = ii+1;
%             end
%         end
%     end
    
end