clearvars
clear GLOBAL

cd('C:\Users\matth\Documents\Translators\Matlab')

%% Define paths and load data
cd('..');
transWD = pwd;

allDataPath = '//130.60.235.123/Users/neuro/Desktop/CLINT/All_Data/';

savePath = strjoin([transWD,{'/data/rawdata/'}],'');

% Select data
load([savePath, 'task/translation/','translation_rating_preparation_t1_20-Jul-2020 16-43-37.mat']);
load([savePath, 'task/translation/','translation_rating_preparation_t2_20-Jul-2020 16-43-40.mat']);

cd('C:\Users\matth\Documents\Translators\Matlab')

%% Define order of sentence presentation
rng(0,'twister');
order_sentences_t1_fl = randperm(length(translation_rating_preparation_t1));

rng(5000,'twister');
order_sentences_t1_acc = randperm(length(translation_rating_preparation_t1));

rng(10000,'twister');
order_sentences_t2_fl = randperm(length(translation_rating_preparation_t2));

rng(15000,'twister');
order_sentences_t2_acc = randperm(length(translation_rating_preparation_t2));

%% Fill in breaks in each sentence after 81 chars

translation_rating_preparation_t1(:,8) = cell(length(translation_rating_preparation_t1),1);
translation_rating_preparation_t2(:,8) = cell(length(translation_rating_preparation_t2),1);
maxChars = 81;

for i=1:length(translation_rating_preparation_t1)
    
    s=translation_rating_preparation_t1{i,7};
    
    if length(s)>maxChars
        
        j = maxChars;
        
        while true
            
            if strcmp(s(j+1),' ')
                s=[s(1:j) '\n' s(j+2:end)];
                j = j+2 + maxChars;
            else
                while ~strcmp(s(j),' ')
                    j=j-1;
                end
                s=[s(1:j-1) '\n' s(j+1:end)];
                j = j+1 + maxChars;
            end
            
            
            if j >= length(s)
                break
            end
        end
        translation_rating_preparation_t1{i,8}=s;
    else
        translation_rating_preparation_t1{i,8}=s;
    end
end

for i=1:length(translation_rating_preparation_t2)
    
    s=translation_rating_preparation_t2{i,7};
    
    if length(s)>maxChars
        
        j = maxChars;
        
        while true
            
            if strcmp(s(j+1),' ')
                s=[s(1:j) '\n' s(j+2:end)];
                j = j+2 + maxChars;
            else
                while ~strcmp(s(j),' ')
                    j=j-1;
                end
                s=[s(1:j-1) '\n' s(j+1:end)];
                j = j+1 + maxChars;
            end
            
            
            if j >= length(s)
                break
            end
        end
        translation_rating_preparation_t2{i,8}=s;
    else
        translation_rating_preparation_t2{i,8}=s;
    end
end


%% Get information about examiner, text and task



examinerID = inputdlg('Please enter examiner ID','SORT',1);

choiceTask = questdlg('Rating of fluency or accuracy?', ...
    'SORT', ...
    'Fluency','Accuracy','');

choiceText = questdlg('Rating of Text 1 or Text 2?', ...
    'SORT', ...
    'Text 1','Text 2','');

choiceSentence = inputdlg('Which sentence to start?', ...
    'SORT', 1);

% Handle response
switch choiceTask
    case 'Fluency'
        switch choiceText
            case 'Text 1'
                RatingFluencyText1(examinerID, order_sentences_t1_fl, translation_rating_preparation_t1, choiceSentence);
            case 'Text 2'
                RatingFluencyText2(examinerID, order_sentences_t2_fl, translation_rating_preparation_t2, choiceSentence);
            otherwise
                error('CANCELLED')
        end
    case 'Accuracy'
        switch choiceText
            case 'Text 1'
                RatingAccuracyText1(examinerID, order_sentences_t1_acc, translation_rating_preparation_t1, choiceSentence);
            case 'Text 2'
                RatingAccuracyText2(examinerID, order_sentences_t2_acc, translation_rating_preparation_t2, choiceSentence);
            otherwise
                error('CANCELLED')
        end
    otherwise
        error('CANCELLED');
end

sca;

load gong.mat
sound(y);


msgbox('DONE!  Thanks for your help, you are great!!');

function RatingFluencyText1(examinerID, order_sentences_t1_fl, translation_rating_preparation_t1, choiceSentence)

%% Settings Psychtoolbox

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);
% Hintergrundhelligkeit und Schrift

load gammafnCRT;   % load the gamma function parameters for this monitor - or some other CRT and hope they're similar! (none of our questions rely on precise quantification of physical contrast)
maxLum = GrayLevel2Lum(255,Cg,gam,b0);
par.BGcolor = Lum2GrayLevel(maxLum/2,Cg,gam,b0);
par.textSize = 30;
par.colorText = [0,0,0];

% Screen Setting
screens = Screen('Screens'); % Get the screen numbers
screenNumber = max(screens); % Select second screen

[window, windowRect] = Screen('OpenWindow', screenNumber, par.BGcolor);

[screenXpixels, screenYpixels] = Screen('WindowSize', window); % Get the size of the on screen window in pixels
[width, height] = Screen('DisplaySize', window); % Screen Size in mm
monitorwidth_mm = 400;
[xCenter, yCenter] = RectCenter(windowRect); % Get the centre coordinates
% center = [screenXpixels screenYpixels]/2;     % useful to have the pixel coordinates of the very center of the screen (usually where you have someone fixate)
% fixRect = [center-2 center+2];  % fixation dot

% Fixation Cross
fixCrossDimPix = 15;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

lineWidthPix = 3;

% Einstellung Ort Lesen/Instruktionen
par.x = 0.08*screenXpixels;
par.x_lesen = 0.1125*screenXpixels;
par.y = 0.15*screenYpixels;
par.y_lesen = 0.3*screenYpixels;


px2mm = screenXpixels/monitorwidth_mm; % Convert pixels to mm
px2cm = 10*px2mm; % Convert pixels to cm

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');% Set the blend funciton for the screen

ifi = Screen('GetFlipInterval', window); % Measure the vertical refresh rate of the monitor
numSecs = 1;
numFrames = round(numSecs / ifi); % Length of time and number of frames we will use for each drawing test
waitframes = 1; % Numer of frames to wait when specifying good timing.

topPriorityLevel = MaxPriority(window); % Retreive the maximum priority number

% Set up Keyboard
index = GetKeyboard_buro;
deviceIndex = index;

ListenChar(-1);
all_keys = KbName('KeyNames');
escapeKey = KbName('ESCAPE');
keyList = zeros(1,256);
keyList(10)=1; keyList(12)=1; keyList(92)=1; keyList(21) =1; keyList(18:19)=1; keyList(23)=1;  keyList(25:35)=1; keyList(37)=1; keyList(39:49)=1; keyList(51)=1; keyList(53:59)=1; keyList(60:63) = 1; keyList(66)=1; keyList(80:91)=1; keyList(105)=1; keyList(114:115)=1; keyList(120)=1;

KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);


%% Present sentences
nRating = 1;

for s = order_sentences_t1_fl
    
    if nRating >= str2double(choiceSentence)
        
        DrawFormattedText(window, translation_rating_preparation_t1{s,8}, 'center', yCenter-150, par.colorText,[],[],[],1);
        Screen('TextSize', window, par.textSize);
        
        Screen('DrawLine', window, [0,0,0], xCenter-5*px2cm, yCenter+30, xCenter+5*px2cm, yCenter+30, 5);
        DrawFormattedText(window, 'Wie flüssig finden Sie die Formulierung dieses Satzes?\n\nBitte klicken Sie mit der linken Maustaste\nam entsprechenden Ort auf die Linie.', 'center', par.y, par.colorText,[],[],[],1);
        DrawFormattedText(window, '-', xCenter-(14*px2cm)/2, yCenter+30, par.colorText,[],[],[],3);
        DrawFormattedText(window, '+', xCenter+(14*px2cm)/2, yCenter+30, par.colorText,[],[],[],3);
        
        actual_sentence = [num2str(nRating),' / ',num2str(length(translation_rating_preparation_t1))];
        DrawFormattedText(window, actual_sentence, screenXpixels-150, screenYpixels-20, par.colorText,[],[],[],4);
        Screen('Flip', window);
        
        
        SetMouse(xCenter, 100, window);
        
        while 1
            
            % Get the current position of the mouse
            [x, y, buttons] = GetMouse(window);
            
            
            x = min(x, screenXpixels);
            x = max(0, x);
            y = max(0, y);
            y = min(y, screenYpixels);
            
            % Button press
            if buttons(1) == 1 && x > xCenter-5*px2cm && x < xCenter+5*px2cm && y < yCenter+30+10 && y >  yCenter+30-10
                rating_fluency_t1 = x;
                rating_fluency_t1_cm = ((x-xCenter)/px2cm)+5;
                break
            end
            
            if firstPress(KbName('ESCAPE'))
                disp('USER EXIT!');
                userExit = 1;
                DrawFormattedText(window, 'Bitte warten Sie, die Versuchsleitung wird zu Ihnen kommen.', par.x, par.y, par.colorText,[],[],[],2);
                Screen('TextSize', window, par.textSize);
                Screen('Flip', window, [],[],1);
                while 1
                    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                    timeSecs = firstPress(find(firstPress));
                    if pressed == 1 && KbName(find(firstPress,1)) == string('w')
                        break;
                    end
                    if pressed == 1 && KbName(find(firstPress,1)) == string('b')
                        sca; close all; ListenChar(1);
                        return
                    end
                end
                break;
            end
            
            
        end
        
        nRating = nRating + 1;
        
        translation_rating_preparation_t1{s,9} = rating_fluency_t1_cm;
    else
        nRating = nRating + 1;
    end
    
end
end

