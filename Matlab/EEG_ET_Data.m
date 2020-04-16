clear all

allDataPath = 'F:\All_Data\Pilot\';

savePathEEGLDT = 'F:\Auswertung\EEG\LDT\';

if exist('F:\Auswertung\EEG\LDT')~=7
    mkdir F:\Auswertung\EEG\LDT;
end


%% Copy Matlab-Answer-Files to savePathMatlab

cd(allDataPath);
vp_list = dir('C*');

for i = 1:length(vp_list)
    vp_name = vp_list(i);
    vpNames{i} = vp_name.name;
end

for zz = 1:length(vpNames)
    
    cd(strjoin([allDataPath {vpNames{zz}}],''))
    
    filePattern = fullfile('*LDT_EEG.mat');
    files = dir(filePattern);
    
    if not(isempty(files))
        for i = 1:length(files)
            filename = files(i);
            fileNames{i} = filename.name;
        end
        
        if exist(strjoin([savePathEEGLDT vpNames(zz)],''))~=7
            mkdir(strjoin([savePathEEGLDT vpNames(zz)],''));
        end
        
        if exist(strjoin([savePathEEGLDT fileNames],''))~=7 %Check wheter Directory exists
            copyfile(char(fileNames),strjoin([savePathEEGLDT vpNames(zz)],''));
        end
    end
end