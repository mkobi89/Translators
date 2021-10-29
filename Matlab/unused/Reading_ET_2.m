clear all

allDataPath = 'F:\All_Data\Pilot\C26';

savePath = 'F:\Auswertung';

cd(allDataPath);
vp_list = dir('C*');


for i = 1:length(vp_list)
    vp_name = vp_list(i);
    vpNames{i} = vp_name.name;
end

filePattern = fullfile('*Fullresults*.mat');
files = dir(filePattern);

for i = 1:length(files)
    filename = files(i);
    fileNames{i} = filename.name;
end

load(fileNames{:});

%
filePattern = fullfile('*E1*_ET.mat');
files = dir(filePattern);

for i = 1:length(files)
    filename = files(i);
    fileNames{i} = filename.name;
end

load(fileNames{:})

% Define, which text was read
if event(1,2) == 101
    t = 1;
    is_first = true;
elseif event(1,2) == 102
    t = 2;
    is_first = true;
elseif event(1,2) == 103
    t = 3;
    is_first = true;
elseif event(1,2) == 104
    t = 4;
    is_first = true;
end

ii = 1;
for jj = 1:length(eyeevent.fixations.data)
    if eyeevent.fixations.data(jj,1) >= event(3,1) && eyeevent.fixations.data(jj,1) <= event(4,1)
        if eyeevent.fixations.data(jj,4);
        is_word(ii) = 'something';
         ii = ii+1;
    end
end