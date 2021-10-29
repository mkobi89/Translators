%%%% Matlab-Skribt CLINT-ELF %%%%

close all; clearvars; clc; sca;
startSecs = GetSecs;
Timing = startSecs;
userExit=0;

par.time_for_task = 300;
par.time_rs = 180;




%% Settings Psychtoolbox

PsychDefaultSetup(2);

% Hintergrundhelligkeit und Schrift

load gammafnCRT;   % load the gamma function parameters for this monitor - or some other CRT and hope they're similar! (none of our questions rely on precise quantification of physical contrast)
maxLum = GrayLevel2Lum(255,Cg,gam,b0);
par.BGcolor = Lum2GrayLevel(maxLum/2,Cg,gam,b0);
par.textSize = 20;
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

% Eyetracker
edfFileCell=[];

%% Saving Parameters

savePathAllSubjects= '/home/stimuluspc/CLINT/All_Subjects/';


par.subjectID=input('Enter subject ID? ','s');
savePath = [savePathAllSubjects par.subjectID, '/'];


if exist(savePath)~=7 %Check wheter ARCHIVE Directory exists
    mkdir(savePath);
    
else
    while 1
        par.subjectID=input('Subject ID already exists. Type in new one: ','s');
        savePath = [savePathAllSubjects par.subjectID, '/'];
        if exist(savePath)~=7 %Check wheter ARCHIVE Directory exists
            mkdir(savePath);
            break
        end
        
    end
end

%% use EEG and Eyetracker?

par.recordEEG=input('Use EEG? (y/n):','s');
while ~ (strcmp(par.recordEEG,'y')||strcmp(par.recordEEG,'n'))
    par.recordEEG=input('Try again! Use EEG? (y/n):','s');
end

par.useEL=input('Use eyetracking? (y/n):','s');
while ~ (strcmp(par.useEL,'y')||strcmp(par.useEL,'n'))
    par.useEL=input('Try again! Use eyetracking? (y/n):','s');
end

par.useEL_Calib=input('Calibrate eyetracker? (y/n):','s');
while ~ (strcmp(par.useEL_Calib,'y')||strcmp(par.useEL_Calib,'n'))
    par.useEL_Calib=input('Try again! Calibrate Eyetracker? (y/n):','s');
end

par.recordEEG= strcmp(par.recordEEG,'y');
par.useEL= strcmp(par.useEL,'y');
par.useEL_Calib= strcmp(par.useEL_Calib,'y');

par.recordFullEXP=input('Do Full Experiment randomly? (y/n):','s');
while ~ (strcmp(par.recordFullEXP,'y')||strcmp(par.recordFullEXP,'n'))
    par.recordFullEXP=input('Do Full Experiment randomly? (y/n):','s');
end

par.recordFullEXP= strcmp(par.recordFullEXP,'y');

%% Randomising or Choose Task
if par.recordFullEXP == 1
    
    order_possibilities = [1 4 3 2; 4 1 2 3; 2 3 4 1; 3 2 1 4];
    rng('shuffle');
    par.order_index =  randi(4);
    par.order = order_possibilities(par.order_index,:);
    
    
    order_possibilities_task = [1 2 1 2; 2 1 1 2; 2 1 2 1; 1 2 2 1];
    rng('shuffle');
    par.order_index_task =  randi(4);
    par.order_task = order_possibilities_task(par.order_index_task,:);
    
    
    order_possibilities_LDT = [1 2 3; 1 3 2; 2 1 3; 2 3 1; 3 1 2; 3 2 1];
    rng('shuffle');
    par.order_index_LDT =  randi(6);
    par.order_LDT = order_possibilities_LDT(par.order_index_LDT,:);
    
    
    par.recordExp_Trial = true;
    par.recordRS = true;
    par.recordELF_Exp = true;
    par.recordLDT = true;
    par.recordReading_Post = true;
    
else
    % Trial
    par.recordExp_Trial=input('Do ELF Exp Trial? (y/n):','s');
    while ~ (strcmp(par.recordExp_Trial,'y')||strcmp(par.recordExp_Trial,'n'))
        par.recordExp_Trial=input('Try again! Do ELF Exp Trial? (y/n):','s');
    end
    
    par.recordExp_Trial= strcmp(par.recordExp_Trial,'y');
    
    % Resting State
    par.recordRS=input('Do RS? (y/n):','s');
    while ~ (strcmp(par.recordRS,'y')||strcmp(par.recordRS,'n'))
        par.recordRS=input('Try again! Do RS? (y/n):','s');
    end
    
    par.recordRS= strcmp(par.recordRS,'y');
    
    % EXP
    par.recordELF_Exp=input('Do ELF Exp? (y/n):','s');
    while ~ (strcmp(par.recordELF_Exp,'y')||strcmp(par.recordELF_Exp,'n'))
        par.recordEEG=input('Try again! Do ELF Exp? (y/n):','s');
    end
    
    par.recordELF_Exp= strcmp(par.recordELF_Exp,'y');
    
    % Order EXP
    
    order_possibilities = [1 4 3 2; 4 1 2 3; 2 3 4 1; 3 2 1 4];
    order_possibilities_checkup = {'1432';'4123';'2341';'3214'};
    
    
    if par.recordELF_Exp
        par.manualorder=input('Which Text Order? (y for random / 1432 or 4123 or 2341 or 3214):','s');
        while true
            if strcmp(par.manualorder,'y')
                break
            elseif sum(strcmp((par.manualorder),order_possibilities_checkup)) > 0
                break
            else
                par.manualorder=input('Try again! Which Text Order? (y for random / 1432 or 4123 or 2341 or 3214):','s');
            end
        end
    else
        par.manualorder = 'n';
    end
    
    if par.manualorder ~= 'y'
        indexing = strcmp((par.manualorder),order_possibilities_checkup);
        par.order_index =  find(indexing,1);
        par.order = order_possibilities(par.order_index,:);
    else
        rng('shuffle');
        par.order_index =  randi(4);
        par.order = order_possibilities(par.order_index,:);
    end
    
    % Order_EXP_Task
    
    order_possibilities_exp_task = [1 2 1 2; 2 1 1 2; 2 1 2 1; 1 2 2 1];
    order_possibilities_checkup = {'1212';'2112' ;'2121';'1221'};
    
    
    if par.recordELF_Exp
        par.manualorder=input('Which Task Order? (y for random / 1212 or 2112 or 2121 or 1221):','s');
        while true
            if strcmp(par.manualorder,'y')
                break
            elseif sum(strcmp((par.manualorder),order_possibilities_checkup)) > 0
                break
            else
                par.manualorder=input('Try again! Which Task Order? (y for random / 1212 or 2112 or 2121 or 1221):','s');
            end
        end
    else
        par.manualorder = 'n';
    end
    
    if par.manualorder ~= 'y'
        indexing = strcmp((par.manualorder),order_possibilities_checkup);
        par.order_index =  find(indexing,1);
        par.order_task = order_possibilities_exp_task(par.order_index,:);
    else
        rng('shuffle');
        par.order_index =  randi(4);
        par.order_task = order_possibilities_exp_task(par.order_index,:);
    end
    
    
    % LDT
    par.recordLDT=input('Do LDT? (y/n):','s');
    while ~ (strcmp(par.recordLDT,'y')||strcmp(par.recordLDT,'n'))
        par.useEL=input('Try again! Do LDT? (y/n):','s');
    end
    
    par.recordLDT= strcmp(par.recordLDT,'y');
    
    % Order LDT
    
    order_possibilities_LDT = [1 2 3; 1 3 2; 2 1 3; 2 3 1; 3 1 2; 3 2 1];
    order_possibilities_LDT_checkup = {'123';'132';'213';'231';'312';'321'};
    
    if par.recordLDT
        par.manualorder_LDT=input('Which LTD Order? (y for random / 123 or 132 or 213 or 231 or 312 or 321):','s');
        while true
            if strcmp(par.manualorder_LDT,'y')
                break
            elseif sum(strcmp((par.manualorder_LDT),order_possibilities_LDT_checkup)) > 0
                break
            else
                par.manualorder_LDT=input('Try again! Which LTD Order? (y for random / 123 or 132 or 213 or 231 or 312 or 321):','s');
            end
        end
    else
        par.manualorder_LDT = 'n';
    end
    
    if par.manualorder_LDT ~= 'y'
        indexing = strcmp((par.manualorder_LDT),order_possibilities_LDT_checkup);
        par.order_index_LDT =  find(indexing,1);
        par.order_LDT = order_possibilities_LDT(par.order_index_LDT,:);
    else
        rng('shuffle');
        par.order_index_LDT =  randi(6);
        par.order_LDT = order_possibilities_LDT(par.order_index_LDT,:);
    end
    
    
    % Reading post
    
    order_possibilities = [1 4 3 2; 4 1 2 3; 2 3 4 1; 3 2 1 4];
    order_possibilities_checkup = {'1432';'4123';'2341';'3214'};
    
    par.recordReading_Post=input('Do Reading Post? (y/n):','s');
    while ~ (strcmp(par.recordReading_Post,'y')||strcmp(par.recordReading_Post,'n'))
        par.useEL_Calib=input('Try again! Do Reading Post? (y/n):','s');
    end
    
    par.recordReading_Post= strcmp(par.recordReading_Post,'y');
    
    if par.recordReading_Post == 1 && par.recordELF_Exp == 0
        par.manualorder_RP=input('Which Text Order for Reading Post? (1432 or 4123 or 2341 or 3214):','s');
        while true
            if sum(strcmp((par.manualorder_RP),order_possibilities_checkup)) > 0
                break
            else
                par.manualorder_RP=input('Try again! Which Text Order? (1432 or 4123 or 2341 or 3214):','s');
            end
        end
    end
    
    if par.recordReading_Post == 1 && par.recordELF_Exp == 0
        if par.manualorder_RP ~= 'y'
            indexing = strcmp((par.manualorder_RP),order_possibilities_checkup);
            par.order_index =  find(indexing,1);
            par.order = order_possibilities(par.order_index,:);
        end
    end
end

%% Connect Eyetracker & Calibrate

if par.useEL
    %    window=Screen('OpenWindow', screenNumber, par.BGcolor);
    EL_Connect; %Connect the Eytracker, it needs a window
    disp('before try');
    
    try % open file to record data to
        disp('creating edf file');
        edfFileCell{end+1}=[par.subjectID '_ELF' num2str(length(edfFileCell)+1) '.edf'];
        Eyelink('Openfile', edfFileCell{end});
    catch
        disp('Error creating the file on Tracker');
    end;
    
    if par.useEL_Calib
        EL_Calibrate
    end
    Eyelink('command', 'record_status_message "ELF EEG"');
else
    %window=Screen('OpenWindow', whichScreen, par.BGcolor);
    disp('No Eyetracker');
end

%% Initiate NetStation Connection, Synchronization, and Recording

if par.recordEEG
    %try and set up connection to eeg
    try
        i = NetStation('Synchronize');
        if i == 0
            disp('already connected');
        else
            disp('need to connect');
        end
    catch
    end
    [status,info] = NetStation('Connect','100.1.1.3',55513);
    WaitSecs(1);
    if status ~= 0
        error(info);
    end
    NetStation('Synchronize');
else
    disp('No EEG');
end

HideCursor(screenNumber);


%% Setup Keyboard Use

index = GetKeyboard;
deviceIndex = index;

ListenChar(-1);
all_keys = KbName('KeyNames');
escapeKey = KbName('ESCAPE');
keyList = zeros(1,256);
keyList(10)=1; keyList(12)=1; keyList(92)=1; keyList(21) =1; keyList(18:19)=1; keyList(23)=1;  keyList(25:35)=1; keyList(37)=1; keyList(39:49)=1; keyList(51)=1; keyList(53:59)=1; keyList(60:63) = 1; keyList(66)=1; keyList(80:91)=1; keyList(105)=1; keyList(114:115)=1; keyList(120)=1;

KbQueueCreate(deviceIndex,keyList);
KbQueueStart(deviceIndex);


%% ELF TASK Settings
% Trigger
par.trigger.lesen_start=11:14;
par.trigger.lesen_end=15:18;
par.trigger.lesen_sentence_start=21:24;

par.trigger.abschreiben_start=31:34;
par.trigger.abschreiben_end=35:38;
par.trigger.uebersetzen_start=41:44;
par.trigger.uebersetzen_end=45:48;
par.trigger.abschreiben_sentence_start=51:54;
par.trigger.uebersetzen_sentence_start=61:64;

par.trigger.lesen_post_start=71:74;
par.trigger.lesen_post_end=75:78;
par.trigger.lesen_sentence_post_start=81:84;


par.trigger.subempfschwierigkeit_lesen = 91:94;
par.trigger.subempfschwierigkeit_uebersetzen = 95:98;


par.trigger.exp_1_start = 101:104;
par.trigger.exp_1_stop = 105:108;
par.trigger.exp_2_start = 109:112;
par.trigger.exp_2_stop = 113:116;


par.trigger.rs_eo_start = 1;
par.trigger.rs_eo_stop = 2;
par.trigger.rs_ec_start = 3;
par.trigger.rs_ec_stop = 4;

par.trigger.ldt_start = 5;
par.trigger.ldt_stop = 6;

par.trigger.exp_post_start = 7;
par.trigger.exp_post_stop = 8;


par.trigger.control_question = 89;
par.trigger.control_question_answer = 99;

par.trigger.recalibration_start=120;
par.trigger.recalibration_end=121;
par.trigger.instructions_start=122;
par.trigger.instructions_end=123;


% Allgemeine Instruktionen
instructions.trial{1} = 'Herzlich willkommen zu unserem Experiment zur \nSprachverarbeitung.\n\nBevor wir mit den eigentlichen Aufgaben starten können,\nmöchten wir Sie mit ein paar grundlegenden Aspekten\nder EEG-Messung im Allgemeinen und mit unseren Aufgaben\nim Speziellen vertraut machen.\n\nBitte drücken Sie ENTER, um fortzufahren.\nEs funktionieren dafür immer beide Enter-Tasten.';
instructions.trial{2} = 'Zur EEG-Messung: Da die Messmethode sehr sensitiv auf Muskelaktivität\n(Bewegungsartefakte von Schultern und Kiefermuskulatur) ist,\nbitten wir Sie, während des gesamten Experimentes möglichst ruhig und\nentspannt zu sitzen sowie mit dem Kinn keinen Druck auf die Kinnstütze\nauszuüben. Zwischen den Aufgaben - während den Instruktionen -\ndürfen Sie sich natürlich bewegen.\n\nBitte drücken Sie ENTER, um fortzufahren.';
instructions.trial{3} = 'Nun gehen wir Schritt für Schritt alle Aufgaben durch, welche Sie\nim ersten Teil des Versuchs bearbeiten werden.\n\nEs wird zwei Texte zum Thema Energie oder Verbrauchsgewohnheiten geben,\nzu denen Sie verschiedene Aufgaben lösen werden.\n\nZuerst wird Ihnen einer der Texte Satz für Satz präsentiert.\nWenn Sie den Satz jeweils gelesen haben, können Sie mit der\nENTER-Taste fortfahren. Es folgen ein paar Beispiele.\n\nBitte drücken Sie ENTER, um fortzufahren.';

instructions.trial{4} = 'Dies ist der erste Beispielsatz, der Ihnen zeigen soll, wie\n\nIhnen der Text während des Experimentes präsentiert wird.';
instructions.trial{5} = 'Sie haben dabei keine Möglichkeit, zum letzten Satz zurückzukehren.';
instructions.trial{6} = 'Es ist wichtig, dass Sie die Texte aufmerksam lesen, da\n\nIhnen anschliessend inhaltliche Fragen dazu gestellt werden,\n\nwelche Sie beantworten müssen.';
instructions.trial{7} = 'Bei Fragen wenden Sie sich an die Versuchsleitung.';

instructions.trial{8} = 'Falls Sie keine Fragen haben, fahren wir mit der zweiten\n\nAufgabenstellung fort.';
instructions.trial{9} = 'Nun werden Sie gefragt, wie verständlich Sie den Text fanden.\n\nKlicken Sie dazu mit der Maus auf den entsprechenden Ort auf den Balken.\nEs folgt ein Beispiel.\n\nBitte drücken Sie ENTER, um fortzufahren.';
instructions.trial{10} = 'Im Anschluss werden Ihnen jeweils fünf Verständnisfragen\nzum gelesenen Text gestellt, welche Sie mit den Ziffern 1-3 auf dem\nNummern-Pad beantworten sollen.\n\nWiederum folgt ein Beispiel.\n\nBitte drücken Sie ENTER, um fortzufahren.';
instructions.trial{11} = 'Anschliessend erfolgt entweder die Aufgabe des Übersetzens oder Abschreibens.\nDazu wird Ihnen derselbe Text nochmals Satz für Satz präsentiert. Bitte achten Sie\ndabei genau auf die Instruktionen, wie die Textstelle zu bearbeiten ist.\n\nSobald Sie den präsentierten Satz bearbeitet haben, können Sie durch\nDrücken der ENTER-Taste zum nächsten Satz fortfahren.\n\nBitte drücken Sie ENTER, um fortzufahren.';
instructions.trial{12} = 'Ihre Übersetzung muss nicht druckreif sein und dient lediglich Forschungszwecken.\n\nDabei ist zu beachten, dass Sie keine Möglichkeit haben, die Sätze im\nNachhinein zu überbearbeiten. Zudem haben Sie weder Zugriff aufs Internet\nnoch auf den gesamten Originaltext.\n\nBitte drücken Sie ENTER, um fortzufahren.';
instructions.trial{13} = 'Aus technischen Gründen ist das Hin- und Herspringen innerhalb Ihrer\nÜbersetzung nicht möglich. Deshalb bitten wir Sie, falls Sie beispielsweise\nin der Mitte des Satzes mit dem Beginn Ihrer Übersetzung nicht mehr\nzufrieden sind, nicht alles zu löschen und neu zu beginnen.\n\nEs geht uns nicht um Perfektion, sondern um die zugrunde\nliegende Sprachverarbeitung.\n\nBitte drücken Sie ENTER, um fortzufahren.';

instructions.trial{14} = 'Nun werden Sie Zeit erhalten, sich mit der Tastatur vertraut zu machen.\nBitte schreiben Sie den Satz auf der nächsten Seite inkl. Gross-\nund Kleinschreibung und Klammern ab und drücken danach auf ENTER.\n\nSie müssen dabei keine manuellen Zeilenwechsel (nicht auf ENTER drücken)\nvornehmen, diese erfolgen automatisch.\n\nBitte drücken Sie ENTER, um fortzufahren.';
instructions.trial{15} = 'Heute Morgen um (Zahlen auf dem Nummern-Pad eingeben) 08.00 Uhr bin ich vom\n(um aufeinanderfolgende Grossbuchstaben zu machen, muss nochmals\nauf LEFT oder RIGHT SHIFT gedrückt werden - "Caps Lock" funktioniert nicht)\nHB Zürich mit dem Zug nach Oerlikon gefahren.';

instructions.trial{16} = 'Haben Sie noch Fragen? Die Instruktionen werden im Verlauf des\nExperimentes immer wiederholt.\n\nBevor es mit dem Experiment losgehen kann, erfolgt eine dreiminütige Messung\nder Hirnaktivität im Ruhezustand. Wir bitten Sie, währenddessen je nach\nInstruktionstext die Augen zu schliessen oder offen zu halten\nund an nichts Spezifisches zu denken.\n\nBitte drücken Sie ENTER, um fortzufahren.';
instructions.trial{17} = 'Zu guter Letzt: Während des gesamten Experimentes ist die Versuchsleitung\nim Vorraum. Durch ziehen an den "Gummibändeli" zu Ihrer Linken können Sie\nim Notfall jederzeit auf sich aufmerksam machen.\n\nUnd nicht vergessen: Bleiben Sie ruhig und entspannt :-)\n\nBitte drücken Sie ENTER, um fortzufahren.';

instructions.rs{1} = 'Nun geht es los mit der Ruhezustandsmessung. Bitte schauen Sie auf\ndas Kreuz in der Mitte des Bildschirms und lassen Sie\nihren Gedanken freien Lauf. \n\nSobald Sie bereit sind, drücken Sie bitte ENTER, um zu starten.';
instructions.rs{2} = 'Vielen Dank. Nun erfolgt dieselbe Messung mit geschlossenen Augen. Bitte\nlassen Sie ihren Gedanken wiederum freien Lauf und warten Sie,\nbis die Versuchsleitung den Raum betritt.\n\nSobald Sie bereit sind, drücken Sie bitte ENTER, um zu starten.';


% Instruktionen EXP

instructions.task.reading{1} = 'In der Folge wird Ihnen ein Text Satz für Satz präsentiert.\n\nWenn Sie die Zeile gelesen haben, drücken Sie bitte ENTER, \num fortzufahren.\n\nBitte lesen Sie den Text aufmerksam durch,\nSie werden ihn anschliessend übersetzen müssen.\n\nBitte drücken Sie ENTER, um zu beginnen.';

instructions.task.t_c{1} = 'Nun wird Ihnen der Text Satz für Satz präsentiert.\n\nBitte ÜBERSETZEN Sie den Satz ins Deutsche.\nJegliche Eigennamen (Projekte, Institutionen) können einfach so\nübernommen werden.\n\nWenn Sie mit dem Satz fertig sind, drücken Sie bitte ENTER, \num mit dem nächsten Satz fortzufahren.\n\nDie Aufgabe dauert 6 Minuten. Danach geht es automatisch weiter,\nunabhängig davon, wo im Satz Sie gerade sind.\n\nBitte drücken Sie ENTER, um zu beginnen.';
instructions.task.t_c{2} = 'Nun wird Ihnen der Text Satz für Satz präsentiert.\n\nBitte SCHREIBEN Sie den Satz in englischer Sprache AB.\n\nWenn Sie mit dem Satz fertig sind, drücken Sie bitte ENTER \num mit dem nächsten Satz fortzufahren.\n\nDie Aufgabe dauert 6 Minuten. Danach geht es automatisch weiter,\nunabhängig davon, wo im Satz Sie gerade sind.\n\nBitte drücken Sie ENTER, um zu beginnen.';
instructions.task.t_c{3} = 'Vielen Dank für Ihren Effort.\n\nBitte drücken Sie ENTER, um mit dem nächsten Abschnitt fortzufahren.';


% Read in sentences and control questions
[sentences_l,sentences_l_g,sentences_ue]=files_new;

ctrl_questions_file = 'verst_fragen.csv';
ctrl_questions = readtable(ctrl_questions_file,'FileEncoding', 'UTF-8');
ctrl_questions = rmmissing(ctrl_questions);


% Preallocation Result Variables ELF Task
size_all=[length(sentences_ue{1,1}),length(sentences_ue{1,2}),length(sentences_ue{1,3}),length(sentences_ue{1,4})];

results_text_uebersetzen = cell(4,max(size_all));
results_text_abschreiben = cell(4,max(size_all));
results_output_uebersetzen = cell(4,max(size_all));
results_output_abschreiben = cell(4,max(size_all));
results_timestamp_uebersetzen = cell(4,max(size_all));
results_timestamp_abschreiben = cell(4,max(size_all));

results_control_questions = cell(2,11);


%% Start EEG/ET Recording

if par.useEL
    Eyelink('StartRecording');
    Eyelink('command', 'record_status_message "Start Recording"');
end
if par.recordEEG, NetStation('StartRecording'); end

WaitSecs(0.5);

if par.recordEEG
    NetStation('Event', num2str(par.trigger.instructions_start)); end
disp('DID THE EEG START RECORDING DATA? IF NOT, PRESS THE RECORD BUTTON!');
if par.useEL
    Eyelink('Message',['TR',num2str(par.trigger.instructions_start)]);
    Eyelink('command', 'record_status_message "Instructions_start"');
end

actSecs = GetSecs;
Timing = [Timing, actSecs-startSecs];

%% Trial
% Instruktion allgemein und Lesen
if par.recordExp_Trial
    KbQueueStart(deviceIndex);
    
    for s = 1:3
        
        DrawFormattedText(window, instructions.trial{s}, par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress)); %#ok<*FNDSB>
            
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
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
    end
    
    for s = 4:8
        
        DrawFormattedText(window, instructions.trial{s}, par.x_lesen, par.y_lesen, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
    end
    
    % Subjektiv empfundene Schwierigkeit
    
    Screen('DrawLine', window, [0,0,0], xCenter-5*px2cm, yCenter, xCenter+5*px2cm, yCenter, 5);
    DrawFormattedText(window, 'Wie schwierig fanden Sie das Verständnis der Instruktionen?\n\nBitte klicken Sie mit der linken Maustaste\nam entsprechenden Ort auf die Linie.', 'center', par.y, par.colorText,[],[],[],1);
    DrawFormattedText(window, 'Leicht', xCenter-(21*px2cm)/2, yCenter, par.colorText,[],[],[],3);
    DrawFormattedText(window, 'Schwierig', xCenter+(14*px2cm)/2, yCenter, par.colorText,[],[],[],3);
    Screen('Flip', window);
    
    ShowCursor('CrossHair', screenNumber);
    
    SetMouse(xCenter, 100, window);
    
    while 1
        
        % Get the current position of the mouse
        [x, y, buttons] = GetMouse(window);
        
        
        x = min(x, screenXpixels);
        x = max(0, x);
        y = max(0, y);
        y = min(y, screenYpixels);
        
        % Button press
        if buttons(1) == 1 && x > xCenter-5*px2cm && x < xCenter+5*px2cm && y < yCenter+10 && y >  yCenter-10
            Schwierigkeit = x;
            Schwierigkeit_cm = ((x-xCenter)/px2cm)+5;
            break
        end
        
    end
    
    HideCursor(screenNumber);
    
    % Instruktion
    for s = 10
        
        DrawFormattedText(window, instructions.trial{s}, par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
    end
    
    % Control Questions
    for s = 1
        quest = [cell2mat(ctrl_questions{s,3}) '\n\n'...
            '1) ' cell2mat(ctrl_questions{s,4}) '\n'...
            '2) ' cell2mat(ctrl_questions{s,5}) '\n'...
            '3) ' cell2mat(ctrl_questions{s,6}) '\n\n'...
            'Bitte drücken Sie die entsprechende Nummer auf dem Nummern-Pad.'];
        
        DrawFormattedText(window, quest, par.x, par.y, par.colorText,[],[],[],2);
        Screen('Flip', window, [],[],1);
        
        while true
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
            if pressed == 1 && KbName(find(firstPress,1)) == string('1')
                results_control_questions{1,s} = 1;
                if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                    results_control_questions{2,s} = 'correct';
                else
                    results_control_questions{2,s} = 'incorrect';
                end
                break;
            elseif pressed == 1 && KbName(find(firstPress,1)) == string('2')
                results_control_questions{1,s} = 2;
                if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                    results_control_questions{2,s} = 'correct';
                else
                    results_control_questions{2,s} = 'incorrect';
                end
                break;
            elseif pressed == 1 && KbName(find(firstPress,1)) == string('3')
                results_control_questions{1,s} = 3;
                if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                    results_control_questions{2,s} = 'correct';
                else
                    results_control_questions{2,s} = 'incorrect';
                end
                break;
                
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
    end
    
    % Instruktion
    for s = 11:14
        
        DrawFormattedText(window, instructions.trial{s}, par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
    end
    
    % Trial Tastatur
    for s = 15
        
        DrawFormattedText(window, instructions.trial{s}, par.x, par.y, par.colorText,[],[],[],4);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        
        % Keyboard
        Text = [];
        text_presented = [];
        Timestamp = [NaN];
        Output = [NaN];
        startSecs = GetSecs;
        maxChars = 81;
        zeilen=1;
        
        KbQueueStart(deviceIndex);
        
        while 1 % Keyboard Input
            
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
            
            if pressed
                
                actual_letter = KbName(find(firstPress,1));
                Output = [Output, string(actual_letter)];
                
                if actual_letter == string('LeftShift') || actual_letter == string('RightShift') || actual_letter == string('BackSpace') || actual_letter == string('space') || actual_letter == string('udiaeresis') || actual_letter == string('odiaeresis') || actual_letter == string('adiaeresis') || actual_letter == string('Return') || actual_letter == string(',<') || actual_letter == string('.>') || actual_letter == string('-_') || actual_letter == string('8*') || actual_letter == string('9(') || actual_letter == string('2@')
                    actual_letter = [];
                end
                
                if isequal(Output(end), string('BackSpace')) == 1
                    Text = Text(1:length(Text)-1);
                elseif isequal(Output(end-1), string('LeftShift')) == 1 && length(Output) > 1
                    actual_letter = upper(actual_letter);
                elseif isequal(Output(end-1), string('RightShift')) == 1 && length(Output) > 1
                    actual_letter = upper(actual_letter);
                elseif isequal(Output(end), string('space')) == 1
                    Text = [Text,' '];
                elseif isequal(Output(end), string('udiaeresis')) == 1
                    Text = [Text,'ü'];
                elseif isequal(Output(end), string('odiaeresis')) == 1
                    Text = [Text,'ö'];
                elseif isequal(Output(end), string('adiaeresis')) == 1
                    Text = [Text,'ä'];
                elseif isequal(Output(end), string('-_')) == 1
                    Text = [Text,'-'];
                end
                
                if isequal(Output(end-1), string('LeftShift')) == 1 && isequal(Output(end), string('8*')) == 1
                    Text = [Text,'('];
                elseif isequal(Output(end-1), string('LeftShift')) == 1 && isequal(Output(end), string('9(')) == 1
                    Text = [Text,')'];
                elseif isequal(Output(end-1), string('LeftShift')) == 1 && isequal(Output(end), string('2@')) == 1
                    Text = [Text,'"'];
                elseif isequal(Output(end), string(',<')) == 1 && ~isequal(Output(end-1), string('LeftShift')) == 1 && ~isequal(Output(end-1), string('RightShift')) == 1
                    Text = [Text,','];
                elseif isequal(Output(end), string(',<')) == 1 && isequal(Output(end-1), string('LeftShift')) == 1 && ~isequal(Output(end-1), string('RightShift')) == 1
                    Text = [Text,';'];
                elseif isequal(Output(end), string('.>')) == 1 && ~isequal(Output(end-1), string('LeftShift')) == 1 && ~isequal(Output(end-1), string('RightShift')) == 1
                    Text = [Text,'.'];
                elseif isequal(Output(end), string('.>')) == 1 && isequal(Output(end-1), string('LeftShift')) == 1 && ~isequal(Output(end-1), string('RightShift')) == 1
                    Text = [Text,':'];
                end
                
                if isequal(Output(end-1), string('RightShift')) == 1 && isequal(Output(end), string('8*')) == 1
                    Text = [Text,'('];
                elseif isequal(Output(end-1), string('RightShift')) == 1 && isequal(Output(end), string('9(')) == 1
                    Text = [Text,')'];
                elseif isequal(Output(end-1), string('RightShift')) == 1 && isequal(Output(end), string('2@')) == 1
                    Text = [Text,'"'];
                elseif isequal(Output(end), string(',<')) == 1 && isequal(Output(end-1), string('RightShift')) == 1 && ~isequal(Output(end-1), string('LeftShift')) == 1
                    Text = [Text,';'];
                elseif isequal(Output(end), string('.>')) == 1 && isequal(Output(end-1), string('RightShift')) == 1 && ~isequal(Output(end-1), string('LeftShift')) == 1
                    Text = [Text,':'];
                end
                
                Text = [Text, actual_letter];
                Timestamp = [Timestamp, timeSecs - startSecs];
                
                text_presented = char(Text);
                
                text_presented = strrep(text_presented,' ','  ');
                p = text_presented;
                
                if length(text_presented)>maxChars+1
                    text_presented = [];
                    while true
                        j = maxChars;
                        if strcmp(p(j+1),' ')
                        else
                            while ~ strcmp(p(j),' ')
                                j=j-1;
                            end
                        end
                        
                        if ~strcmp(p(j),' ') && strcmp(p(j+1),' ')
                            text_presented=[text_presented,p(1:j),'\n'];
                            p=[p(j+3:end)];
                        elseif strcmp(p(j),' ') && strcmp(p(j+1),' ')
                            text_presented=[text_presented,p(1:j-1),'\n'];
                            p=[p(j+2:end)];
                            
                        elseif strcmp(p(j),' ') && ~strcmp(p(j+1),' ')
                            text_presented=[text_presented,p(1:j-2) '\n'];
                            p=[p(j+1:end)];
                        end
                        
                        if length(p) <= maxChars
                            text_presented=[text_presented,p];
                            break
                        end
                    end
                end
            end
            
            DrawFormattedText(window, instructions.trial{s}, par.x, par.x, par.colorText,[],[],[],3);
            DrawFormattedText(window, text_presented, 0.08*screenXpixels, yCenter * 1.15, par.colorText,[],[],[],3);
            Screen('Flip', window, [],[],[],1);
            
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                
                results_text_trial = Text;
                
                break
                
            end
        end
    end
    
    % Instruktion
    for s = 16:17
        
        DrawFormattedText(window, instructions.trial{s}, par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
    end
end

if par.recordEEG
    NetStation('Event', num2str(par.trigger.instructions_end)); end
if par.useEL
    Eyelink('Message',['TR',num2str(par.trigger.instructions_end)]);
    Eyelink('command', 'record_status_message "Instructions_end"');
end

actSecs = GetSecs;
Timing = [Timing, actSecs-startSecs];

%% Resting State
if par.recordRS
    % Instruktion
    for s = 1
        
        DrawFormattedText(window, instructions.rs{s}, par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
    end
    
    % Eyes Open
    
    disp('RS_EO Start');
    
    if par.recordEEG
        NetStation('Event', num2str(par.trigger.rs_eo_start)); end
    if par.useEL
        Eyelink('Message',['TR',num2str(par.trigger.rs_eo_start)]);
        Eyelink('command', 'record_status_message "RS_EO_start"');
    end
    
    timing_RS_EO_beginn = GetSecs;
    
    %     DrawFormattedText(window, '+', 'center', 'center', par.colorText,[],[],[],3);
    %     Screen('Flip', window,[],[],1);
    
    Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
    Screen('Flip', window,[],[],1);
    
    while true
        timing_RS_EO_end = GetSecs;
        if timing_RS_EO_end - timing_RS_EO_beginn > par.time_rs
            timing_RS_EO = timing_RS_EO_end - timing_RS_EO_beginn;
            break
        end
    end
    
    if par.recordEEG
        NetStation('Event', num2str(par.trigger.rs_eo_stop)); end
    if par.useEL
        Eyelink('Message',['TR',num2str(par.trigger.rs_eo_stop)]);
        Eyelink('command', 'record_status_message "RS_EO_stop"');
    end
    
    
    disp('RS_EO End');
    
    % Instructions Eyes Closed
    
    for s = 2
        
        DrawFormattedText(window, instructions.rs{s}, par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
    end
    
    % Eyes Closed
    
    disp('RS_EC Start');
    
    if par.recordEEG
        NetStation('Event', num2str(par.trigger.rs_ec_start)); end
    if par.useEL
        Eyelink('Message',['TR',num2str(par.trigger.rs_ec_start)]);
        Eyelink('command', 'record_status_message "RS_EC_start"');
    end
    
    timing_RS_EC_beginn = GetSecs;
    
    Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
    Screen('Flip', window,[],[],1);
    
    warning = true;
    
    while true
        timing_RS_EC_end = GetSecs;
        
        if timing_RS_EC_end - timing_RS_EC_beginn > par.time_rs - 20 && warning == true
            disp('Get Ready');
            warning = false;
        end
        if timing_RS_EC_end - timing_RS_EC_beginn > par.time_rs
            timing_RS_EC = timing_RS_EC_end - timing_RS_EC_beginn;
            break
        end
    end
    
    if par.recordEEG
        NetStation('Event', num2str(par.trigger.rs_ec_stop)); end
    if par.useEL
        Eyelink('Message',['TR',num2str(par.trigger.rs_ec_stop)]);
        Eyelink('command', 'record_status_message "RS_EC_stop"');
    end
    
    disp('RS_EC End');
    
    DrawFormattedText(window, 'Vielen Dank.\n\nNun folgt eine kurze Pause und\ndie Versuchsleitung wird zu Ihnen kommen.', par.x, par.y, par.colorText,[],[],[],2);
    Screen('TextSize', window, par.textSize);
    Screen('Flip', window, [],[],1);
end

actSecs = GetSecs;
Timing = [Timing, actSecs-startSecs];

%% Stop EEG/ET for Recalibration 1
WaitSecs(2);

if par.useEL && par.useEL_Calib
    if par.recordEEG,  NetStation('Event', num2str(par.trigger.recalibration_start)); end
    if par.recordEEG, pause(2); NetStation('StopRecording'); end;
    Screen('Flip', window, [],[],1);
    
    fprintf('Stop Recording Track\n');
    
    %send trigger for start of calibration
    Eyelink('StopRecording'); %Stop Recording
    Eyelink('CloseFile');
    edfFile= edfFileCell{end};
    EL_DownloadDataFile
    
    
    % ----- EL_Cleanup:
    Eyelink('Command', 'clear_screen 0');
    
    
    % Shutdown Eyelink:
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    Eyelink('Shutdown'); %DN: commented out for now. Uncomment later
    fprintf('Stopped the Eyetracker\n');
    % ----- end EL_Cleanup
    
    DrawFormattedText(window, 'Vielen Dank.\n\nNun folgt eine kurze Pause und\ndie Versuchsleitung wird zu Ihnen kommen.', par.x, par.y, par.colorText,[],[],[],2);
    Screen('TextSize', window, par.textSize);
    Screen('Flip', window, [],[],1);
    
    KbQueueStart(deviceIndex);
    
    while 1 % Wait for VL  continue
        
        [ pressed, firstPress]=KbQueueCheck(deviceIndex);
        timeSecs = firstPress(find(firstPress));
        
        if pressed == 1 && KbName(find(firstPress,1)) == string('w')
            break;
        end
    end
    KbQueueStop(deviceIndex);
    
    EL_Connect;
    
    
    try % open file to record data to
        disp('creating edf file');
        edfFileCell{end+1}=[par.subjectID '_ELF' num2str(length(edfFileCell)+1) '.edf'];
        Eyelink('Openfile', edfFileCell{end});
    catch
        disp('Error creating the file on Tracker');
    end;
    
    EL_Calibrate
    Eyelink('StartRecording');
    Eyelink('command', 'record_status_message "RECALIBRATED"');
%     Eyelink('Message',['TR',num2str(par.trigger.recalibration_end)]);
    Eyelink('command', 'record_status_message "Calibration END"');
    if par.recordEEG, NetStation('StartRecording'); end;
    pause(2);
    
    
%     if par.recordEEG,  NetStation('Event', num2str(par.trigger.recalibration_end)); end
    HideCursor(screenNumber);
    disp('DID THE EEG START RECORDING DATA? IF NOT, PRESS THE RECORD BUTTON!');
else
    
    KbQueueStart(deviceIndex);
    
    while 1 % Wait for VL to continue
        
        [ pressed, firstPress]=KbQueueCheck(deviceIndex);
        timeSecs = firstPress(find(firstPress));
        
        if pressed == 1 && KbName(find(firstPress,1)) == string('w')
            break;
        end
    end
end

WaitSecs(0.5);


%% EXP

if par.recordELF_Exp
    
    text_two = false;
    task_count = 1;
    finished = false;
    
    actSecs = GetSecs;
    Timing = [Timing, actSecs-startSecs];   
        
    for t = par.order(1:2)
        

        
        if text_two == false
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.exp_1_start(t))); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.exp_1_start(t))]);
                Eyelink('command', 'record_status_message "Exp_1_Start"');
            end
        else
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.exp_2_start(t))); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.exp_2_start(t))]);
                Eyelink('command', 'record_status_message "Exp_2_Start"');
            end
        end
        
        disp(['Lesen ',num2str(t)])
        
        
        %% Lesen
        KbQueueStart(deviceIndex);
        
        % Instruktion Lesen
        DrawFormattedText(window, instructions.task.reading{1}, par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1 % Wait for VP to finish instruction
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
        
        WaitSecs(0.5);
        
        if par.recordEEG
            NetStation('Event', num2str(par.trigger.lesen_start(t))); end
        if par.useEL
            Eyelink('Message',['TR',num2str(par.trigger.lesen_start(t))]);
            Eyelink('command', 'record_status_message "Lesen_start"');
        end
        
        start_reading{t} = GetSecs;
        
        for s = 2:length(sentences_ue{t})
            
            timing_reading = GetSecs;
            
            [nx, ny, textbounds, wordbounds] = DrawFormattedText(window, sentences_ue{t}{s}, par.x_lesen, par.y_lesen, par.colorText,[],[],[],4);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            textbounds_reading{t}{s} = textbounds;
            wordbounds_reading{t}{s} = wordbounds;
            
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.lesen_sentence_start(t))); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.lesen_sentence_start(t))]);
                Eyelink('command', 'record_status_message "Lesen_Zeile"');
            end
            
            while 1
                [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                timeSecs = firstPress(find(firstPress));
                
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
                if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                    
                    break;
                end
            end
            
            timeSecs = GetSecs;
            timing_reading_sentence{t}(s) = timeSecs - timing_reading;
        end
        
        WaitSecs(0.3);
        
        if par.recordEEG
            NetStation('Event', num2str(par.trigger.lesen_end(t))); end
        if par.useEL
            Eyelink('Message',['TR',num2str(par.trigger.lesen_end(t))]);
            Eyelink('command', 'record_status_message "Lesen_ende"');
        end
        
        %% Subjektiv empfundene Schwierigkeit
        WaitSecs(0.3);
        
        if par.recordEEG
            NetStation('Event', num2str(par.trigger.subempfschwierigkeit_lesen(t))); end
        if par.useEL
            Eyelink('Message',['TR',num2str(par.trigger.subempfschwierigkeit_lesen(t))]);
            Eyelink('command', 'record_status_message "SubjempfSchwierigkeit_lesen"');
        end
        
        Screen('DrawLine', window, [0,0,0], xCenter-5*px2cm, yCenter, xCenter+5*px2cm, yCenter, 5);
        DrawFormattedText(window, 'Wie schwierig fanden Sie das Verständnis dieses Textes?\n\nBitte klicken Sie mit der linken Maustaste\nam entsprechenden Ort auf die Linie.', 'center', par.y, par.colorText,[],[],[],1);
        DrawFormattedText(window, 'Leicht', xCenter-(21*px2cm)/2, yCenter, par.colorText,[],[],[],3);
        DrawFormattedText(window, 'Schwierig', xCenter+(14*px2cm)/2, yCenter, par.colorText,[],[],[],3);
        Screen('Flip', window);
        
        ShowCursor('CrossHair', screenNumber);
        
        SetMouse(xCenter, 100, window);
        
        while 1
            
            % Get the current position of the mouse
            [x, y, buttons] = GetMouse(window);
            
            x = min(x, screenXpixels);
            x = max(0, x);
            y = max(0, y);
            y = min(y, screenYpixels);
            
            % Button press
            if buttons(1) == 1 && x > xCenter-5*px2cm && x < xCenter+5*px2cm && y < yCenter+10 && y >  yCenter-10
                Schwierigkeit = x;
                Schwierigkeit_cm = ((x-xCenter)/px2cm)+5;
                break
            end
        end
        
        sub_empf_schwierigkeit_lesen(t) = Schwierigkeit_cm;
        
        HideCursor(screenNumber);
        
        %% Control Questions
        
        disp(['Control Questions ',num2str(t)])
        
        if t == 1 || t == 2
            for s = 2:6
                quest = [cell2mat(ctrl_questions{s,3}) '\n\n'...
                    '1) ' cell2mat(ctrl_questions{s,4}) '\n'...
                    '2) ' cell2mat(ctrl_questions{s,5}) '\n'...
                    '3) ' cell2mat(ctrl_questions{s,6}) '\n\n'...
                    'Bitte drücken Sie die entsprechende Nummer auf dem Nummern-Pad.'];
                
                DrawFormattedText(window, quest, par.x, par.y, par.colorText,[],[],[],2);
                Screen('Flip', window, [],[],1);
                
                if par.recordEEG,  NetStation('Event', num2str(par.trigger.control_question)); end
                if par.useEL
                    Eyelink('Message',['TR',num2str(par.trigger.control_question)]);
                    Eyelink('command', 'record_status_message "Control Question"');
                end
                
                while true
                    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                    timeSecs = firstPress(find(firstPress));
                    
                    if pressed == 1 && KbName(find(firstPress,1)) == string('1')
                        results_control_questions{1,s} = 1;
                        if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                            results_control_questions{2,s} = 'correct';
                        else
                            results_control_questions{2,s} = 'incorrect';
                        end
                        break;
                    elseif pressed == 1 && KbName(find(firstPress,1)) == string('2')
                        results_control_questions{1,s} = 2;
                        if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                            results_control_questions{2,s} = 'correct';
                        else
                            results_control_questions{2,s} = 'incorrect';
                        end
                        break;
                    elseif pressed == 1 && KbName(find(firstPress,1)) == string('3')
                        results_control_questions{1,s} = 3;
                        if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                            results_control_questions{2,s} = 'correct';
                        else
                            results_control_questions{2,s} = 'incorrect';
                        end
                        break;
                        
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
            end
        elseif t == 3 || t == 4
            for s = 7:11
                quest = [cell2mat(ctrl_questions{s,3}) '\n\n'...
                    '1) ' cell2mat(ctrl_questions{s,4}) '\n'...
                    '2) ' cell2mat(ctrl_questions{s,5}) '\n'...
                    '3) ' cell2mat(ctrl_questions{s,6}) '\n\n'...
                    'Bitte drücken Sie die entsprechende Nummer auf dem Nummern-Pad.'];
                
                DrawFormattedText(window, quest, par.x, par.y, par.colorText,[],[],[],3);
                Screen('Flip', window, [],[],1);
                
                if par.recordEEG,  NetStation('Event', num2str(par.trigger.control_question)); end
                if par.useEL
                    Eyelink('Message',['TR',num2str(par.trigger.control_question)]);
                    Eyelink('command', 'record_status_message "Control Question"');
                end
                
                while true
                    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                    timeSecs = firstPress(find(firstPress));
                    
                    if pressed == 1 && KbName(find(firstPress,1)) == string('1')
                        results_control_questions{1,s} = 1;
                        if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                            results_control_questions{2,s} = 'correct';
                        else
                            results_control_questions{2,s} = 'incorrect';
                        end
                        
                        break;
                    elseif pressed == 1 && KbName(find(firstPress,1)) == string('2')
                        results_control_questions{1,s} = 2;
                        if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                            results_control_questions{2,s} = 'correct';
                        else
                            results_control_questions{2,s} = 'incorrect';
                        end
                        break;
                    elseif pressed == 1 && KbName(find(firstPress,1)) == string('3')
                        results_control_questions{1,s} = 3;
                        if isequal(results_control_questions{1,s}, ctrl_questions.correct_answer(s))==1
                            results_control_questions{2,s} = 'correct';
                        else
                            results_control_questions{2,s} = 'incorrect';
                        end
                        break;
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
            end
        end
        
        %% Übersetzen/Abschreiben
        
        disp(['Uebersetzen / Abschreiben ',num2str(t)])
        sentence_count = 2;
        
        for l = 1:2
            
            next_task = false;
            
            % Instructions & Start Trigger
            
            DrawFormattedText(window, instructions.task.t_c{par.order_task(task_count)}, par.x, par.y, par.colorText,[],[],[],2);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            KbQueueStart(deviceIndex);
            
            while 1 % Wait for VP to finish instructions
                [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                timeSecs = firstPress(find(firstPress));
                
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
                
                if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                    break;
                end
            end
            
            if par.order_task(task_count) == 1
                if par.recordEEG
                    NetStation('Event', num2str(par.trigger.uebersetzen_start(t))); end
                if par.useEL
                    Eyelink('Message',['TR',num2str(par.trigger.uebersetzen_start(t))]);
                    Eyelink('command', 'record_status_message "Uebersetzen_start"');
                end
            elseif par.order_task(task_count) == 2
                if par.recordEEG
                    NetStation('Event', num2str(par.trigger.abschreiben_start(t))); end
                if par.useEL
                    Eyelink('Message',['TR',num2str(par.trigger.abschreiben_start(t))]);
                    Eyelink('command', 'record_status_message "Abschreiben_start"');
                end
            end
            
            WaitSecs(0.5);
            
            task_start = GetSecs;
            
            % Satz präsentieren und Task
            while true
                
                if  sentence_count >= length(sentences_ue{t})
                    break
                end
                
                DrawFormattedText(window, sentences_ue{t}{sentence_count}, par.x, par.y, par.colorText,[],[],[],2);
                Screen('TextSize', window, par.textSize);
                Screen('Flip', window, [],[],1);
                
                timing_task_sentence_start = GetSecs;
                
                if par.order_task(task_count) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.uebersetzen_sentence_start(t))); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.uebersetzen_sentence_start(t))]);
                        Eyelink('command', 'record_status_message "Uebersetzen_sentence_start"');
                    end
                elseif par.order_task(task_count) == 2
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.abschreiben_sentence_start(t))); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.abschreiben_sentence_start(t))]);
                        Eyelink('command', 'record_status_message "Abschreiben_sentence_start"');
                    end
                end
                
                % Keyboard
                Text = [];
                text_presented = 0;
                Timestamp = [NaN];
                Output = [NaN];
                maxChars = 81;
                zeilen=1;
                
                KbQueueStart(deviceIndex);
                
                while 1 % Keyboard Input
                    
                    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                    timeSecs = firstPress(find(firstPress));
                    
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
                    if pressed
                        
                        actual_letter = KbName(find(firstPress,1));
                        Output = [Output, string(actual_letter)];
                        
                        if actual_letter == string('LeftShift') || actual_letter == string('RightShift') || actual_letter == string('BackSpace') || actual_letter == string('space') || actual_letter == string('udiaeresis') || actual_letter == string('odiaeresis') || actual_letter == string('adiaeresis') || actual_letter == string('Return') || actual_letter == string(',<') || actual_letter == string('.>') || actual_letter == string('-_') || actual_letter == string('8*') || actual_letter == string('9(') || actual_letter == string('2@') || actual_letter == string('LeftArrow') || actual_letter == string('RightArrow')
                            actual_letter = [];
                        end
                        
                        if isequal(Output(end), string('BackSpace')) == 1
                            Text = Text(1:length(Text)-1);
                        elseif isequal(Output(end-1), string('LeftShift')) == 1 && length(Output) > 1
                            actual_letter = upper(actual_letter);
                        elseif isequal(Output(end-1), string('RightShift')) == 1 && length(Output) > 1
                            actual_letter = upper(actual_letter);
                        elseif isequal(Output(end), string('space')) == 1
                            Text = [Text,' '];
                        elseif isequal(Output(end), string('udiaeresis')) == 1
                            Text = [Text,'ü'];
                        elseif isequal(Output(end), string('odiaeresis')) == 1
                            Text = [Text,'ö'];
                        elseif isequal(Output(end), string('adiaeresis')) == 1
                            Text = [Text,'ä'];
                        elseif isequal(Output(end), string('-_')) == 1
                            Text = [Text,'-'];
                        end
                        
                        if isequal(Output(end-1), string('LeftShift')) == 1 && isequal(Output(end), string('8*')) == 1
                            Text = [Text,'('];
                        elseif isequal(Output(end-1), string('LeftShift')) == 1 && isequal(Output(end), string('9(')) == 1
                            Text = [Text,')'];
                        elseif isequal(Output(end-1), string('LeftShift')) == 1 && isequal(Output(end), string('2@')) == 1
                            Text = [Text,'"'];
                        elseif isequal(Output(end), string(',<')) == 1 && ~isequal(Output(end-1), string('LeftShift')) == 1 && ~isequal(Output(end-1), string('RightShift')) == 1
                            Text = [Text,','];
                        elseif isequal(Output(end), string(',<')) == 1 && isequal(Output(end-1), string('LeftShift')) == 1 && ~isequal(Output(end-1), string('RightShift')) == 1
                            Text = [Text,';'];
                        elseif isequal(Output(end), string('.>')) == 1 && ~isequal(Output(end-1), string('LeftShift')) == 1 && ~isequal(Output(end-1), string('RightShift')) == 1
                            Text = [Text,'.'];
                        elseif isequal(Output(end), string('.>')) == 1 && isequal(Output(end-1), string('LeftShift')) == 1 && ~isequal(Output(end-1), string('RightShift')) == 1
                            Text = [Text,':'];
                        end
                        
                        if isequal(Output(end-1), string('RightShift')) == 1 && isequal(Output(end), string('8*')) == 1
                            Text = [Text,'('];
                        elseif isequal(Output(end-1), string('RightShift')) == 1 && isequal(Output(end), string('9(')) == 1
                            Text = [Text,')'];
                        elseif isequal(Output(end-1), string('RightShift')) == 1 && isequal(Output(end), string('2@')) == 1
                            Text = [Text,'"'];
                        elseif isequal(Output(end), string(',<')) == 1 && isequal(Output(end-1), string('RightShift')) == 1 && ~isequal(Output(end-1), string('LeftShift')) == 1
                            Text = [Text,';'];
                        elseif isequal(Output(end), string('.>')) == 1 && isequal(Output(end-1), string('RightShift')) == 1 && ~isequal(Output(end-1), string('LeftShift')) == 1
                            Text = [Text,':'];
                        end
                        
                        Text = [Text, actual_letter];
                        Timestamp = [Timestamp, timeSecs - startSecs];
                        
                        text_presented = char(Text);
                        
                        text_presented = strrep(text_presented,' ','  ');
                        s = text_presented;
                        
                        if length(text_presented)>maxChars+1
                            text_presented = [];
                            while true
                                j = maxChars;
                                if strcmp(s(j+1),' ')
                                else
                                    while ~ strcmp(s(j),' ')
                                        j=j-1;
                                    end
                                end
                                
                                if ~strcmp(s(j),' ') && strcmp(s(j+1),' ')
                                    text_presented=[text_presented,s(1:j),'\n'];
                                    s=[s(j+3:end)];
                                elseif strcmp(s(j),' ') && strcmp(s(j+1),' ')
                                    text_presented=[text_presented,s(1:j-1),'\n'];
                                    s=[s(j+2:end)];
                                    
                                elseif strcmp(s(j),' ') && ~strcmp(s(j+1),' ')
                                    text_presented=[text_presented,s(1:j-2) '\n'];
                                    s=[s(j+1:end)];
                                end
                                
                                if length(s) <= maxChars
                                    text_presented=[text_presented,s];
                                    break
                                end
                            end
                        end
                        
                    end
                    
                    [nx, ny, textbounds_sentences_ue, wordbounds_sentences_ue] = DrawFormattedText(window, sentences_ue{t}{sentence_count}, par.x, par.x, par.colorText,[],[],[],3);
                    [nx, ny, textbounds_text_presented, wordbounds_text_presented] = DrawFormattedText(window, text_presented, 0.08*screenXpixels, yCenter * 1.15, par.colorText,[],[],[],3);
                    Screen('TextSize', window, par.textSize);
                    Screen('Flip', window, [],[],1);
                    
            
                    textbounds_task_sentences{t}{sentence_count} = textbounds_sentences_ue;
                    wordbounds_task_sentences{t}{sentence_count} = wordbounds_sentences_ue;
                    
                    textbounds_task_text_presented{t}{sentence_count} = textbounds_text_presented;
                    wordbounds_task_text_presented{t}{sentence_count} = wordbounds_text_presented;                    
                    
                    if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                        KbQueueStop(deviceIndex);
                        if par.order_task(task_count) == 1
                            results_text_uebersetzen{t,sentence_count} = Text;
                            results_output_uebersetzen{t,sentence_count} = Output;
                            results_timestamp_uebersetzen{t,sentence_count} = Timestamp;
                            
                            timing_task_sentence_end = GetSecs;
                            timing_task_sentences_translation{t,sentence_count} = timing_task_sentence_end -timing_task_sentence_start; 
                            break
                            
                        elseif par.order_task(task_count) == 2
                            results_text_abschreiben{t,sentence_count} = Text;
                            results_output_abschreiben{t,sentence_count} = Output;
                            results_timestamp_abschreiben{t,sentence_count} = Timestamp;

                            timing_task_sentence_end = GetSecs;
                            timing_task_sentences_transcription{t,sentence_count} = timing_task_sentence_end -timing_task_sentence_start; 

                            break
                            
                        end
                    end
                    
                    task_timing = GetSecs;
                    
                    if task_timing-task_start >= par.time_for_task
                        KbQueueStop(deviceIndex);
                        
                        if par.order_task(task_count) == 1
                            if par.recordEEG
                                NetStation('Event', num2str(par.trigger.uebersetzen_end(t))); end
                            if par.useEL
                                Eyelink('Message',['TR',num2str(par.trigger.uebersetzen_end(t))]);
                                Eyelink('command', 'record_status_message "Uebersetzen_end"');
                            end
                            
                            timing_task_sentence_end = GetSecs;
                            timing_task_sentences_translation{t,sentence_count} = timing_task_sentence_end -timing_task_sentence_start; 
 
                            
                            results_text_uebersetzen{t,sentence_count} = Text;
                            results_output_uebersetzen{t,sentence_count} = Output;
                            results_timestamp_uebersetzen{t,sentence_count} = Timestamp;
                            
                        elseif par.order_task(task_count) == 2
                            
                            if par.recordEEG
                                NetStation('Event', num2str(par.trigger.abschreiben_end(t))); end
                            if par.useEL
                                Eyelink('Message',['TR',num2str(par.trigger.abschreiben_end(t))]);
                                Eyelink('command', 'record_status_message "Abschreiben_end"');
                            end

                            timing_task_sentence_end = GetSecs;
                            timing_task_sentences_transcription{t,sentence_count} = timing_task_sentence_end -timing_task_sentence_start; 

                            
                            results_text_abschreiben{t,sentence_count} = Text;
                            results_output_abschreiben{t,sentence_count} = Output;
                            results_timestamp_abschreiben{t,sentence_count} = Timestamp;
                        end
                        
                        if par.order_task(task_count) == 1
                            
                            % Subjektiv empfundene Schwierigkeit
                            WaitSecs(0.5);
                            if par.recordEEG
                                NetStation('Event', num2str(par.trigger.subempfschwierigkeit_uebersetzen(t))); end
                            if par.useEL
                                Eyelink('Message',['TR',num2str(par.trigger.subempfschwierigkeit_uebersetzen(t))]);
                                Eyelink('command', 'record_status_message "SubjempfSchwierigkeit_uebersetzen"');
                            end
                            
                            Screen('DrawLine', window, [0,0,0], xCenter-5*px2cm, yCenter, xCenter+5*px2cm, yCenter, 5);
                            DrawFormattedText(window, 'Wie schwierig fanden Sie diese Aufgabe?\n\nBitte klicken Sie mit der linken Maustaste\nam entsprechenden Ort auf die Linie.', 'center', par.y, par.colorText,[],[],[],1);
                            DrawFormattedText(window, 'Leicht', xCenter-(21*px2cm)/2, yCenter, par.colorText,[],[],[],3);
                            DrawFormattedText(window, 'Schwierig', xCenter+(14*px2cm)/2, yCenter, par.colorText,[],[],[],3);
                            Screen('Flip', window);
                            
                            ShowCursor('CrossHair', screenNumber);
                            
                            SetMouse(xCenter, 100, window);
                            
                            while 1
                                
                                % Get the current position of the mouse
                                [x, y, buttons] = GetMouse(window);
                                
                                x = min(x, screenXpixels);
                                x = max(0, x);
                                y = max(0, y);
                                y = min(y, screenYpixels);
                                
                                % Button press
                                if buttons(1) == 1 && x > xCenter-5*px2cm && x < xCenter+5*px2cm && y < yCenter+10 && y >  yCenter-10
                                    Schwierigkeit = x;
                                    Schwierigkeit_cm = ((x-xCenter)/px2cm)+5;
                                    break
                                end
                                
                            end
                            
                            HideCursor(screenNumber);
                            sub_empf_schwierigkeit_uebersetzen(t) = Schwierigkeit_cm;
                            
                        end
                        
                        %                         task_count = task_count+1;
                        next_task = true;
                        break
                        
                    end
                end
                
                sentence_count = sentence_count+1;
                
                last_sentence_task(task_count) = sentence_count;
                
                if next_task == true
                    break
                end
            end
            
            if task_count == 1 || task_count == 3
                DrawFormattedText(window, instructions.task.t_c{3}, par.x, par.y, par.colorText,[],[],[],2);
                Screen('TextSize', window, par.textSize);
                Screen('Flip', window, [],[],1);
                
                KbQueueStart(deviceIndex);
                
                while 1 % Wait for VP to finish instructions
                    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                    timeSecs = firstPress(find(firstPress));
                    
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
                    
                    if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                        break;
                    end
                end
            end
            
            task_count = task_count+1;
            
        end
        
        KbQueueRelease(deviceIndex)
        KbQueueCreate(deviceIndex,keyList);
        KbQueueStart(deviceIndex);
        
        
        if text_two == false
            actSecs = GetSecs;
            Timing = [Timing, actSecs-startSecs];
            
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.exp_1_stop)); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.exp_1_stop)]);
                Eyelink('command', 'record_status_message "Exp_1_stop"');
            end
            
        else
            actSecs = GetSecs;
            Timing = [Timing, actSecs-startSecs];
            
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.exp_2_stop)); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.exp_2_stop)]);
                Eyelink('command', 'record_status_message "Exp_2_stop"');
            end

        end
        
        text_two = true;
        
        DrawFormattedText(window, 'Vielen Dank für Ihren Effort.\n\nNun folgt eine kurze Pause und\ndie Versuchsleitung wird zu Ihnen kommen.', par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        
        %% Stop EEG/ET for Recalibration 2/3
        WaitSecs(2);
        
        if par.useEL && par.useEL_Calib
            if par.recordEEG,  NetStation('Event', num2str(par.trigger.recalibration_start)); end
            if par.recordEEG, pause(2); NetStation('StopRecording'); end;
            Screen('Flip', window, [],[],1);
            
            fprintf('Stop Recording Track\n');
            %send trigger for start of calibration
            Eyelink('StopRecording'); %Stop Recording
            Eyelink('CloseFile');
            edfFile= edfFileCell{end};
            EL_DownloadDataFile
            
            
            % ----- EL_Cleanup:
            Eyelink('Command', 'clear_screen 0');
            
            % Shutdown Eyelink:
            Eyelink('StopRecording');
            Eyelink('CloseFile');
            Eyelink('Shutdown'); %DN: commented out for now. Uncomment later
            fprintf('Stopped the Eyetracker\n');
            % ----- end EL_Cleanup
            
            DrawFormattedText(window, 'Vielen Dank.\n\nNun folgt eine kurze Pause und\ndie Versuchsleitung wird zu Ihnen kommen.', par.x, par.y, par.colorText,[],[],[],2);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            KbQueueStart(deviceIndex);
            
            while 1 % Wait for VP to finish instructions
                
                [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                timeSecs = firstPress(find(firstPress));
                
                if pressed == 1 && KbName(find(firstPress,1)) == string('w')
                    break;
                end
            end
            
            KbQueueStop(deviceIndex);
            
            EL_Connect;
            
            try % open file to record data to
                disp('creating edf file');
                edfFileCell{end+1}=[par.subjectID '_ELF' num2str(length(edfFileCell)+1) '.edf']; %edfFileCell{end+1}=[num2str(par.subjectID),'_NR' (num2str(length(edfFileCell))+1) '.edf'];
                Eyelink('Openfile', edfFileCell{end});
            catch
                disp('Error creating the file on Tracker');
            end;
            
            EL_Calibrate
            
            Eyelink('StartRecording');
            Eyelink('command', 'record_status_message "RECALIBRATED"');
%             Eyelink('Message',['TR',num2str(par.trigger.recalibration_end)]);
            Eyelink('command', 'record_status_message "Calibration END"');
            if par.recordEEG, NetStation('StartRecording'); end;
            pause(2);
            
%             if par.recordEEG,  NetStation('Event', num2str(par.trigger.recalibration_end)); end
            HideCursor(screenNumber);
            disp('DID THE EEG START RECORDING DATA? IF NOT, PRESS THE RECORD BUTTON!');
            
        else
            
            KbQueueStart(deviceIndex);
            
            while 1 % Wait for VL to press W
                
                [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                timeSecs = firstPress(find(firstPress));
                
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
                
                if pressed == 1 && KbName(find(firstPress,1)) == string('w')
                    break;
                end
            end
        end
        actSecs = GetSecs;
        Timing = [Timing, actSecs-startSecs];
    end
end

disp('ELF fertig')

WaitSecs(0.5);


if par.recordLDT
    
    %% Lexical Decision Task
    % Settings LDT
    
    rng('shuffle');
    

    % Trigger
    % Triggers Task 1:
    par.trigger.task1_taskStart=190;
    par.trigger.task1_taskEnd=195;
    
    par.trigger.task1_word_start_lf=150;
    par.trigger.task1_word_start_hf=151;
    par.trigger.task1_word_start_pseudoword=152;
    
    par.trigger.task1_word_start=[par.trigger.task1_word_start_lf,par.trigger.task1_word_start_hf,par.trigger.task1_word_start_pseudoword];
    
    par.trigger.task1_lf_answer_correct=160;
    par.trigger.task1_hf_answer_correct=161;
    par.trigger.task1_pseudoword_answer_correct=162;
    
    par.trigger.task1_answer_correct=[par.trigger.task1_lf_answer_correct,par.trigger.task1_hf_answer_correct,par.trigger.task1_pseudoword_answer_correct];
    
    par.trigger.task1_lf_answer_incorrect=165;
    par.trigger.task1_hf_answer_incorrect=166;
    par.trigger.task1_pseudoword_answer_incorrect=167;
    
    par.trigger.task1_answer_incorrect=[par.trigger.task1_lf_answer_incorrect,par.trigger.task1_hf_answer_incorrect,par.trigger.task1_pseudoword_answer_incorrect];
    
    % Trigger Task 2
    par.trigger.task2_taskStart=290;
    par.trigger.task2_taskEnd=295;
    
    par.trigger.task2_word_start_lf=250;
    par.trigger.task2_word_start_hf=251;
    par.trigger.task2_word_start_pseudoword=252;
    
    par.trigger.task2_word_start=[par.trigger.task2_word_start_lf,par.trigger.task2_word_start_hf,par.trigger.task2_word_start_pseudoword];
    
    par.trigger.task2_lf_answer_correct=260;
    par.trigger.task2_hf_answer_correct=261;
    par.trigger.task2_pseudoword_answer_correct=262;
    
    par.trigger.task2_answer_correct=[par.trigger.task2_lf_answer_correct,par.trigger.task2_hf_answer_correct,par.trigger.task2_pseudoword_answer_correct];
    
    par.trigger.task2_lf_answer_incorrect=265;
    par.trigger.task2_hf_answer_incorrect=266;
    par.trigger.task2_pseudoword_answer_incorrect=267;
    
    par.trigger.task2_answer_incorrect=[par.trigger.task2_lf_answer_incorrect,par.trigger.task2_hf_answer_incorrect,par.trigger.task2_pseudoword_answer_incorrect];
    
    % Trigger Task 3
    par.trigger.task3_taskStart=390;
    par.trigger.task3_taskEnd=395;
    
    par.trigger.task3_word_start_d_d=301;
    par.trigger.task3_word_start_d_e=302;
    par.trigger.task3_word_start_d_p=303;
    par.trigger.task3_word_start_e_d=304;
    par.trigger.task3_word_start_e_e=305;
    par.trigger.task3_word_start_e_p=306;
    par.trigger.task3_word_start_p_d=307;
    par.trigger.task3_word_start_p_e=308;
    par.trigger.task3_word_start_p_p=309;
    
    
    par.trigger.task3_d_d_answer_correct=311;
    par.trigger.task3_d_e_answer_correct=312;
    par.trigger.task3_d_p_answer_correct=313;
    par.trigger.task3_e_d_answer_correct=314;
    par.trigger.task3_e_e_answer_correct=315;
    par.trigger.task3_e_p_answer_correct=316;
    par.trigger.task3_p_d_answer_correct=317;
    par.trigger.task3_p_e_answer_correct=318;
    par.trigger.task3_p_p_answer_correct=319;
    
    
    par.trigger.task3_d_d_answer_incorrect=321;
    par.trigger.task3_d_e_answer_incorrect=322;
    par.trigger.task3_d_p_answer_incorrect=323;
    par.trigger.task3_e_d_answer_incorrect=324;
    par.trigger.task3_e_e_answer_incorrect=325;
    par.trigger.task3_e_p_answer_incorrect=326;
    par.trigger.task3_p_d_answer_incorrect=327;
    par.trigger.task3_p_e_answer_incorrect=328;
    par.trigger.task3_p_p_answer_incorrect=329;
    
    
    % Wörter einlesen Task 1/2
    words_file = 'Stimuli_CLINT.csv';
    words_raw=readtable(words_file,'FileEncoding', 'UTF-8');
    
    for s = 1:length(words_raw.Stimulus)
        if words_raw.Task(s) == 1 && words_raw.Test(s) == 1
            task_1.trialwords{s} = words_raw.Stimulus{s};
        elseif words_raw.Task(s) == 1 && words_raw.Test(s) == 2
            for i = s-length(task_1.trialwords)
                task_1.word{i} = words_raw.Stimulus{s};
                task_1.if_word(i) = words_raw.Word(s);
                task_1.wordfrequency(i) = words_raw.Wordfrequency(s);
                task_1.language(i) = words_raw.Language(s);
                task_1.test(i) = words_raw.Test(s);
            end
        elseif words_raw.Task(s) == 2 && words_raw.Test(s) == 1
            for i = s-length(task_1.word)-length(task_1.trialwords)
                task_2.trialwords{i} = words_raw.Stimulus{s};
            end
        elseif words_raw.Task(s) == 2 && words_raw.Test(s) == 2
            for i = s-length(task_1.word)-length(task_1.trialwords)-length(task_2.trialwords)
                task_2.word{i} = words_raw.Stimulus{s};
                task_2.if_word(i) = words_raw.Word(s);
                task_2.wordfrequency(i) = words_raw.Wordfrequency(s);
                task_2.language(i) = words_raw.Language(s);
                task_2.test(i) = words_raw.Test(s);
            end
            
        end
    end
    
    % Read in words Task 3
    words_file_switch_trials = 'Stimuli_CLINT_switching_trials.csv';
    words_file_switch = 'Stimuli_CLINT_switching.csv';
    words_raw_switch_trials = readtable(words_file_switch_trials,'FileEncoding', 'UTF-8');
    words_raw_switch = readtable(words_file_switch,'FileEncoding', 'UTF-8');
    
    
    for s = 1:length(words_raw_switch_trials.Stimulus)
        task_3.trialwords{s} = words_raw_switch_trials.Stimulus{s};
    end
    
    % Preallocating
    task_3.d_d_sw = zeros(1,length(words_raw_switch.Sequenz));
    task_3.d_e_sw = zeros(1,length(words_raw_switch.Sequenz));
    task_3.d_p_sw = zeros(1,length(words_raw_switch.Sequenz));
    task_3.e_e_sw = zeros(1,length(words_raw_switch.Sequenz));
    task_3.e_d_sw = zeros(1,length(words_raw_switch.Sequenz));
    task_3.e_p_sw = zeros(1,length(words_raw_switch.Sequenz));
    task_3.p_d_sw = zeros(1,length(words_raw_switch.Sequenz));
    task_3.p_e_sw = zeros(1,length(words_raw_switch.Sequenz));
    task_3.p_p_sw = zeros(1,length(words_raw_switch.Sequenz));
    
    for s = 1:length(words_raw_switch.Sequenz)
        task_3.sequenz{s} = words_raw_switch.Sequenz{s};
        task_3.word{s} = words_raw_switch.Stimulus{s};
        task_3.if_word(s) = words_raw_switch.Word(s);
        task_3.language(s) = words_raw_switch.Language(s);
        task_3.test(s) = words_raw_switch.Test(s);
        task_3.d_e_sw(s) = words_raw_switch.d_e_sw(s);
        task_3.e_d_sw(s) = words_raw_switch.e_d_sw(s);
        
        if task_3.sequenz{s} == 'D' || task_3.sequenz{s} == 'E'
            task_3.if_word(s) = 1;
        else
            task_3.if_word(s) = 2;
        end
        
        if task_3.sequenz{s} == 'D'
            task_3.language(s) = 1;
        elseif task_3.sequenz{s} == 'E'
            task_3.language(s) = 2;
        else
            task_3.language(s) = 3;
        end
        
        
        
        if s > 1 && task_3.sequenz{s} == 'E' && task_3.sequenz{s-1} == 'D'
            task_3.d_e_sw(s) = 1;
        elseif s > 1 && task_3.sequenz{s} == 'D' && task_3.sequenz{s-1} == 'E'
            task_3.e_d_sw(s) = 1;
        elseif s > 1 && task_3.sequenz{s} == 'D' && task_3.sequenz{s-1} == 'D'
            task_3.d_d_sw(s) = 1;
        elseif s > 1 && task_3.sequenz{s} == 'P' && task_3.sequenz{s-1} == 'D'
            task_3.d_p_sw(s) = 1;
        elseif s > 1 && task_3.sequenz{s} == 'E' && task_3.sequenz{s-1} == 'E'
            task_3.e_e_sw(s) = 1;
        elseif s > 1 && task_3.sequenz{s} == 'P' && task_3.sequenz{s-1} == 'E'
            task_3.e_p_sw(s) = 1;
        elseif s > 1 && task_3.sequenz{s} == 'D' && task_3.sequenz{s-1} == 'P'
            task_3.p_d_sw(s) = 1;
        elseif s > 1 && task_3.sequenz{s} == 'E' && task_3.sequenz{s-1} == 'P'
            task_3.p_e_sw(s) = 1;
        elseif s > 1 && task_3.sequenz{s} == 'P' && task_3.sequenz{s-1} == 'P'
            task_3.p_p_sw(s) = 1;
        elseif s == 1
            task_3.p_p_sw(s) = 1;
        end
    end
    
    % Instruction
    gen_Instruction_trial= 'Bitte lesen Sie die folgenden Wörter in englischer oder\ndeutscher Sprache.\n\nEntscheiden Sie danach so schnell und so präzis als möglich,\nob es sich um ein Wort oder ein Pseudowort handelt.\n\nDrücken Sie bei einem Wort die linke Pfeiltaste\nund die rechte Pfeiltaste bei einem Pseudowort.\nEs wird drei Aufgaben mit kurzen Pausen dazwischen geben.\n\nDrücken Sie ENTER, um den Probedurchgang zu starten.';
    gen_Instruction_task= 'Nun beginnt die Aufgabe.\n\nBitte versuchen Sie, die Aufgabe so schnell und\nso präzis als möglich zu bearbeiten.\n\nDrücken Sie ENTER, um zu beginnen.';
    gen_Instruction_end= 'Dieser Teil der Aufgabe ist nun beendet.\n\nEs folgt eine kurze Pause,\nbevor es weitergeht.';
    
    
    %% LDT
    actSecs = GetSecs;
    Timing = [Timing, actSecs-startSecs];
    
    if par.recordEEG
        NetStation('Event', num2str(par.trigger.ldt_start)); end
    if par.useEL
        Eyelink('Message',['TR',num2str(par.trigger.ldt_start)]);
        Eyelink('command', 'record_status_message "LDT_start"');
    end
    
    % Trial
    
    DrawFormattedText(window, gen_Instruction_trial, par.x, par.y, par.colorText,[],[],[],2);
    Screen('TextSize', window, par.textSize);
    Screen('Flip', window, [],[],1);
    
    disp('THE SUBJECT IS READING THE INSTRUCTIONS');
    disp('DID THE EEG START RECORDING DATA? IF NOT, PRESS THE RECORD BUTTON!');
    
    KbQueueStart(deviceIndex);
    
    while 1 % Wait for VP to finish instructions
        [ pressed, firstPress]=KbQueueCheck(deviceIndex);
        timeSecs = firstPress(find(firstPress));
        
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
        
        if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
            break;
        end
    end
    
    KbQueueStop(deviceIndex);
    
    Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
    Screen('Flip', window,[],[],1);
    
    WaitSecs(1);
    disp('Starting Trial Task');
    
    % Trial Task
    trial = 0;
    par.textSize = 30;
    
    for s = 1:length(task_3.trialwords)
        
        trial = trial+1;
        
        DrawFormattedText(window, task_3.trialwords{s}, 'center', 'center', par.colorText,[],[],[],3);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window,[],[],1);
        
        
        KbQueueStart(deviceIndex);
        
        while 1
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            
            % Get response, send trigger accordingly
            if firstPress(KbName('LeftArrow'))
                disp('LeftArrow')
                break
            elseif firstPress(KbName('RightArrow'))
                disp('RightArrow')
                break
            end
        end
        
        KbQueueStop(deviceIndex);
        
        Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
        Screen('Flip', window,[],[],1);
        
        % ISI
        rng('shuffle')
        isi(trial)=0.5+0.2*rand;
        wakeup(trial) = WaitSecs(isi(trial));
        
    end
    
%     par.textSize = 20;
    
    for i = par.order_LDT
        if i == 1
            % LDT 1
            
            which_task = 'german';
            % Building Timing and Answer Matrix
            timing_task_1 = zeros(length(task_1.word),10);
            answers_task_1 = cell(length(task_1.word),13);
            
            % Preallocating
            RT = zeros(length(task_1.word),1);
            correct = zeros(length(task_1.word),1);
            type = cell(length(task_1.word),1);
            trigger_sent = zeros(length(task_1.word),1);
            before_word_secs = zeros(length(task_1.word),1);
            after_word_secs = zeros(length(task_1.word),1);
            after_trigger_wordstart_secs = zeros(length(task_1.word),1);
            answer_trigger_secs = zeros(length(task_1.word),1);
            before_isi_secs = zeros(length(task_1.word),1);
            after_isi_secs = zeros(length(task_1.word),1);
            isi = zeros(length(task_1.word),1);
            wakeup = zeros(length(task_1.word),1);
            
            % Shuffling
            rng('shuffle')
            order_task_1 = randperm(length(task_1.word));
            
            
            % Real Task Instructions
            
            DrawFormattedText(window, gen_Instruction_task, par.x, par.y, par.colorText,[],[],[],3);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            
            KbQueueStart(deviceIndex);
            
            while 1 % Wait for VP to finish instructions
                [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                timeSecs = firstPress(find(firstPress));
                
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
                
                if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                    break;
                end
            end
            
            KbQueueStop(deviceIndex);
            
            Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
            Screen('Flip', window,[],[],1);
            
            % Send Start-Trigger
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.task1_taskStart));
            end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.task1_taskStart)]);
                Eyelink('command', 'record_status_message "Task1_Start"');
            end
            
            WaitSecs(1);
            
            disp('Starting Task_1');
            before_task_secs = GetSecs;
            
            % Wortpr�sentation
            trial=0;
            fliptimestamp = [];
%             par.textSize = 30;
            
          for s = order_task_1

                 
                trial = trial+1;
                disp([which_task,' trial = ',num2str(trial)])
                
                before_word_secs(trial) = GetSecs;
                
                DrawFormattedText(window, task_1.word{s}, 'center', 'center', par.colorText,[],[],[],3);
                Screen('TextSize', window, par.textSize);    
                [vbl(trial), stonstime(trial), fliptimestamp(trial)]=Screen('Flip', window,[],[],1);
                
                after_word_secs(trial)  = GetSecs;
                
                % Send Trigger for word_beginning
                if par.recordEEG,  NetStation('Event', num2str(par.trigger.task1_word_start(task_1.wordfrequency(s))),fliptimestamp(trial)); end
                if par.useEL
                    Eyelink('Message',['TR',num2str(par.trigger.task1_word_start(task_1.wordfrequency(s)))]);
                    Eyelink('command', 'record_status_message "Word START"');
                end
                
                after_trigger_wordstart_secs(trial) = GetSecs;
                
                
                KbQueueStart(deviceIndex);
                
                while 1
                    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                    timeSecs = firstPress(find(firstPress));
                    
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
                    
                    % Get response, send trigger accordingly
                    if task_1.if_word(s) == 1 && firstPress(KbName('LeftArrow'))
                        correct(trial) = 1; type(trial) = {'Hit'};
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task1_answer_correct(task_1.wordfrequency(s))),timeSecs);
                        end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task1_answer_correct(task_1.wordfrequency(s)))]);
                            Eyelink('command', 'record_status_message "Hit"');
                        end
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task1_answer_correct(task_1.wordfrequency(s));
                        break
                        
                    elseif task_1.if_word(s) == 1 && firstPress(KbName('RightArrow'))
                        correct(trial) = 0; type(trial) = {'Missing'};
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task1_answer_incorrect(task_1.wordfrequency(s))),timeSecs);
                        end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task1_answer_incorrect(task_1.wordfrequency(s)))]);
                            Eyelink('command', 'record_status_message "Missing"');
                        end
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task1_answer_incorrect(task_1.wordfrequency(s));
                        break
                        
                    elseif task_1.if_word(s) == 2 && firstPress(KbName('LeftArrow'))
                        correct(trial) = 0; type(trial) = {'FalseAlarm'};
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task1_answer_incorrect(task_1.wordfrequency(s))),timeSecs);
                        end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task1_answer_incorrect(task_1.wordfrequency(s)))]);
                            Eyelink('command', 'record_status_message "FalseAlarm"');
                        end
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task1_answer_incorrect(task_1.wordfrequency(s));
                        break
                        
                    elseif task_1.if_word(s) == 2 && firstPress(KbName('RightArrow'))
                        correct(trial) = 1; type(trial) = {'CorrRej'};
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task1_answer_correct(task_1.wordfrequency(s))),timeSecs);
                        end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task1_answer_correct(task_1.wordfrequency(s)))]);
                            Eyelink('command', 'record_status_message "CorrRej"');
                        end
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task1_answer_correct(task_1.wordfrequency(s));
                        break
                    end
                end
                
                KbQueueStop(deviceIndex);
                
                Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
                Screen('Flip', window,[],[],1);
                
                before_isi_secs(trial) = GetSecs;
                
                % ISI
                rng('shuffle')
                isi(trial)=0.5+0.2*rand;
                wakeup(trial) = WaitSecs(isi(trial));
                
                after_isi_secs(trial) = GetSecs;
                
                % Write Timing Matrix
                RT(trial) = timeSecs - after_word_secs(trial);
                timing_task_1(trial,:) = [before_task_secs, before_word_secs(trial)-before_task_secs, after_word_secs(trial)-before_task_secs, after_trigger_wordstart_secs(trial)-before_task_secs, answer_trigger_secs(trial)-before_task_secs, before_isi_secs(trial)-before_task_secs, after_isi_secs(trial)-before_task_secs, isi(trial), wakeup(trial)-before_task_secs, RT(trial)];
                
                % Write Answer Matrix
                answers_task_1(trial,:)=[par.subjectID which_task s task_1.word(s) KbName(firstPress) RT(trial) correct(trial) type(trial) trigger_sent(trial) task_1.if_word(s) task_1.wordfrequency(s) task_1.language(s) task_1.test(s)];
            end
            
            %send last triggers
            if par.recordEEG,  NetStation('Event', num2str(par.trigger.task1_taskEnd)); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.task1_taskEnd)]);
                Eyelink('command', 'record_status_message "Task FINISHED"');
            end %Send Eytracker Trigger
            
            
            % timing_task_1_as_table = table(timing_task_1,...
            %     'VariableNames',{'Before_Task' 'Before_Word' 'After_Word' 'After_Trigger_Wordstart' 'Answer_Trigger' 'Before_isi' 'After_Isi' 'ISI' 'Wakeup' 'RT'});
            
            answers_task_1 = cell2table(answers_task_1,...
                'VariableNames',{'SubjectID' 'WhichTask' 'Order_Index' 'Word' 'KeyName' 'RT' 'Correct' 'AnswerType' 'Trigger_Sent' 'Word_Pseudoword' 'Wordfrequency' 'Language' 'Test'});
            
            disp('End of Task 1');
%             par.textSize = 20;
            
            DrawFormattedText(window, gen_Instruction_end, par.x, par.y, par.colorText,[],[],[],3);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            WaitSecs(10);
            
        elseif i == 2
            which_task = 'english';
            
            % Building Timing and Answer Matrix
            timing_task_2 = zeros(length(task_2.word),10);
            answers_task_2 = cell(length(task_2.word),13);
            
            % Preallocating
            RT = zeros(length(task_2.word),1);
            correct = zeros(length(task_2.word),1);
            type = cell(length(task_2.word),1);
            trigger_sent = zeros(length(task_2.word),1);
            before_word_secs = zeros(length(task_2.word),1);
            after_word_secs = zeros(length(task_2.word),1);
            after_trigger_wordstart_secs = zeros(length(task_2.word),1);
            answer_trigger_secs = zeros(length(task_2.word),1);
            before_isi_secs = zeros(length(task_2.word),1);
            after_isi_secs = zeros(length(task_2.word),1);
            isi = zeros(length(task_2.word),1);
            wakeup = zeros(length(task_2.word),1);
            
            % Shuffling
            rng('shuffle')
            order_task_2 = randperm(length(task_2.word));
            trial=0;
            
            % Real Task Instructions
            
            DrawFormattedText(window, gen_Instruction_task, par.x, par.y, par.colorText,[],[],[],3);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            
            KbQueueStart(deviceIndex);
            
            while 1 % Wait for VP to finish instructions
                [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                timeSecs = firstPress(find(firstPress));
                
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
                
                if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                    break;
                end
            end
            
            KbQueueStop(deviceIndex);
            
            Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
            Screen('Flip', window,[],[],1);
            
            % Send Start-Trigger
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.task2_taskStart));
            end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.task2_taskStart)]);
                Eyelink('command', 'record_status_message "Task2_Start"');
            end
            
            WaitSecs(1);
            
            disp('Starting Task_2');
            before_task_secs = GetSecs;
            
            
            % Wortpräsentation
            trial=0;
            fliptimestamp = [];
            
%             par.textSize = 30;
            
            for s = order_task_2

                  
                trial = trial+1;
                disp([which_task,' trial = ',num2str(trial)])
                
                before_word_secs(trial) = GetSecs;
                
                DrawFormattedText(window, task_2.word{s}, 'center', 'center', par.colorText,[],[],[],3);
                Screen('TextSize', window, par.textSize);
                [vbl(trial), stonstime(trial), fliptimestamp(trial)]=Screen('Flip', window,[],[],1);
                
                after_word_secs(trial)  = GetSecs;
                
                % Send Trigger for word_beginning
                if par.recordEEG,  NetStation('Event', num2str(par.trigger.task2_word_start(task_2.wordfrequency(s))),fliptimestamp(trial)); end
                if par.useEL
                    Eyelink('Message',['TR',num2str(par.trigger.task2_word_start(task_2.wordfrequency(s)))]);
                    Eyelink('command', 'record_status_message "Word START"');
                end
                
                after_trigger_wordstart_secs(trial) = GetSecs;
                
                
                KbQueueStart(deviceIndex);
                
                while 1
                    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                    timeSecs = firstPress(find(firstPress));
                    
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
                    
                    % Get response, send trigger accordingly
                    if task_2.if_word(s) == 1 && firstPress(KbName('LeftArrow'))
                        correct(trial) = 1; type(trial) = {'Hit'};
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task2_answer_correct(task_2.wordfrequency(s))),timeSecs);
                        end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task2_answer_correct(task_2.wordfrequency(s)))]);
                            Eyelink('command', 'record_status_message "Hit"');
                        end
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task2_answer_correct(task_2.wordfrequency(s));
                        break
                        
                    elseif task_2.if_word(s) == 1 && firstPress(KbName('RightArrow'))
                        correct(trial) = 0; type(trial) = {'Missing'};
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task2_answer_incorrect(task_2.wordfrequency(s))),timeSecs);
                        end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task2_answer_incorrect(task_2.wordfrequency(s)))]);
                            Eyelink('command', 'record_status_message "Missing"');
                        end
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task2_answer_incorrect(task_2.wordfrequency(s));
                        break
                        
                    elseif task_2.if_word(s) == 2 && firstPress(KbName('LeftArrow'))
                        correct(trial) = 0; type(trial) = {'FalseAlarm'};
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task2_answer_incorrect(task_2.wordfrequency(s))),timeSecs);
                        end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task2_answer_incorrect(task_2.wordfrequency(s)))]);
                            Eyelink('command', 'record_status_message "FalseAlarm"');
                        end
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task2_answer_incorrect(task_2.wordfrequency(s));
                        break
                        
                    elseif task_2.if_word(s) == 2 && firstPress(KbName('RightArrow'))
                        correct(trial) = 1; type(trial) = {'CorrRej'};
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task2_answer_correct(task_2.wordfrequency(s))),timeSecs);
                        end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task2_answer_correct(task_2.wordfrequency(s)))]);
                            Eyelink('command', 'record_status_message "CorrRej"');
                        end
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task2_answer_correct(task_2.wordfrequency(s));
                        break
                    end
                end
                
                KbQueueStop(deviceIndex);
                
                Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
                Screen('Flip', window,[],[],1);
                
                before_isi_secs(trial) = GetSecs;
                
                % ISI
                rng('shuffle')
                isi(trial)=0.5+0.2*rand;
                wakeup(trial) = WaitSecs(isi(trial));
                
                after_isi_secs(trial) = GetSecs;
                
                % Write Timing Matrix
                RT(trial) = timeSecs - after_word_secs(trial);
                timing_task_2(trial,:) = [before_task_secs, before_word_secs(trial)-before_task_secs, after_word_secs(trial)-before_task_secs, after_trigger_wordstart_secs(trial)-before_task_secs, answer_trigger_secs(trial)-before_task_secs, before_isi_secs(trial)-before_task_secs, after_isi_secs(trial)-before_task_secs, isi(trial), wakeup(trial)-before_task_secs, RT(trial)];
                
                % Write Answer Matrix
                answers_task_2(trial,:)=[par.subjectID which_task s task_2.word(s) KbName(firstPress) RT(trial) correct(trial) type(trial) trigger_sent(trial) task_2.if_word(s) task_2.wordfrequency(s) task_2.language(s) task_2.test(s)];
            end
            
            %send last triggers
            if par.recordEEG,  NetStation('Event', num2str(par.trigger.task2_taskEnd)); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.task2_taskEnd)]);
                Eyelink('command', 'record_status_message "Task FINISHED"');
            end %Send Eytracker Trigger
            
            
            % timing_task_2_as_table = table(timing_task_2,...
            %     'VariableNames',{'Before_Task' 'Before_Word' 'After_Word' 'After_Trigger_Wordstart' 'Answer_Trigger' 'Before_isi' 'After_Isi' 'ISI' 'Wakeup' 'RT'});
            
            answers_task_2 = cell2table(answers_task_2,...
                'VariableNames',{'SubjectID' 'WhichTask' 'Order_Index' 'Word' 'KeyName' 'RT' 'Correct' 'AnswerType' 'Trigger_Sent' 'Word_Pseudoword' 'Wordfrequency' 'Language' 'Test'});
            
            disp('End Task 2');
            
%             par.textSize = 20;
            
            DrawFormattedText(window, gen_Instruction_end, par.x, par.y, par.colorText,[],[],[],3);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            WaitSecs(10);
            
        elseif i == 3
            which_task = 'switch';
            
            % Building Timing and Answer Matrix
            timing_task_3 = zeros(length(task_3.word),10);
            answers_task_3 = cell(length(task_3.word),15);
            
            % Preallocating
            RT = zeros(length(task_3.word),1);
            correct = zeros(length(task_3.word),1);
            condition = cell(length(task_3.word),1);
            type = cell(length(task_3.word),1);
            trigger_sent = zeros(length(task_3.word),1);
            before_word_secs = zeros(length(task_3.word),1);
            after_word_secs = zeros(length(task_3.word),1);
            after_trigger_wordstart_secs = zeros(length(task_3.word),1);
            answer_trigger_secs = zeros(length(task_3.word),1);
            before_isi_secs = zeros(length(task_3.word),1);
            after_isi_secs = zeros(length(task_3.word),1);
            isi = zeros(length(task_3.word),1);
            wakeup = zeros(length(task_3.word),1);
            
            % Shuffling
            % rng('shuffle')
            % order_task_1 = randperm(length(task_1.word));
            trial=0;
            
            
            % Real Task Instructions
            
            DrawFormattedText(window, gen_Instruction_task, par.x, par.y, par.colorText,[],[],[],3);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            
            KbQueueStart(deviceIndex);
            
            while 1 % Wait for VP to finish instructions
                [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                timeSecs = firstPress(find(firstPress));
                
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
                
                if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                    break;
                end
            end
            
            KbQueueStop(deviceIndex);
            
            Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
            Screen('Flip', window,[],[],1);
            
            % Send Start-Trigger
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.task3_taskStart));
            end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.task3_taskStart)]);
                Eyelink('command', 'record_status_message "Task3_Start"');
            end
            
            WaitSecs(1);
            
            disp('Starting Task_3');
            before_task_secs = GetSecs;
            
            % Wortpräsentation
            trial=0;
            fliptimestamp = [];
            
 %           par.textSize = 30;
            
            for s = 1:480
                
                trial = trial+1;
                disp([which_task,' trial = ',num2str(trial)])
                
                before_word_secs(trial) = GetSecs;
                
                DrawFormattedText(window, task_3.word{s}, 'center', 'center', par.colorText,[],[],[],3);
                Screen('TextSize', window, par.textSize);
                [vbl(trial), stonstime(trial), fliptimestamp(trial)]=Screen('Flip', window,[],[],0);
                after_word_secs(trial)  = GetSecs;
                
                % Send Trigger for word_beginning
                if task_3.e_d_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_e_d),fliptimestamp(trial)); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_e_d)]);
                        Eyelink('command', 'record_status_message "Word_START_e_d"');
                    end
                elseif task_3.d_e_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_d_e),fliptimestamp(trial)); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_d_e)]);
                        Eyelink('command', 'record_status_message "Word_START_d_e"');
                    end
                elseif task_3.d_d_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_d_d),fliptimestamp(trial)); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_d_d)]);
                        Eyelink('command', 'record_status_message "Word_START_d_d"');
                    end
                elseif task_3.d_p_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_d_p),fliptimestamp(trial));  end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_d_p)]);
                        Eyelink('command', 'record_status_message "Word_START_d_p"');
                    end
                elseif task_3.e_e_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_e_e),fliptimestamp(trial)); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_e_e)]);
                        Eyelink('command', 'record_status_message "Word_START_e_e"');
                    end
                elseif task_3.e_p_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_e_p),fliptimestamp(trial)); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_e_p)]);
                        Eyelink('command', 'record_status_message "Word_START_e_p"');
                    end
                elseif task_3.p_d_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_p_d),fliptimestamp(trial)); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_p_d)]);
                        Eyelink('command', 'record_status_message "Word_START_p_d"');
                    end
                elseif task_3.p_p_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_p_p),fliptimestamp(trial)); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_p_p)]);
                        Eyelink('command', 'record_status_message "Word_START_p_p"');
                    end
                elseif task_3.p_e_sw(s) == 1
                    if par.recordEEG
                        NetStation('Event', num2str(par.trigger.task3_word_start_p_e),fliptimestamp(trial)); end
                    if par.useEL
                        Eyelink('Message',['TR',num2str(par.trigger.task3_word_start_p_e)]);
                        Eyelink('command', 'record_status_message "Word_START_p_e"');
                    end
                end
                
                
                after_trigger_wordstart_secs(trial) = GetSecs;
                
                
                KbQueueStart(deviceIndex);
                
                while 1
                    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                    timeSecs = firstPress(find(firstPress));
                    
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
                    
                    % Get response, send trigger accordingly
                    if task_3.e_d_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_e_d_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_e_d_answer_correct)]);
                            Eyelink('command', 'record_status_message "e_d_hit"');
                        end
                        correct(trial) = 1; type(trial) = {'e_d_hit'};
                        condition{trial} = 'sw_e_d';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_e_d_answer_correct;
                        break
                        
                    elseif task_3.e_d_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_e_d_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_e_d_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "e_d_miss"');
                        end
                        correct(trial) = 0; type(trial) = {'e_d_miss'};
                        condition{trial} = 'sw_e_d';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_e_d_answer_incorrect;
                        break
                        
                    elseif task_3.d_e_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_d_e_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_d_e_answer_correct)]);
                            Eyelink('command', 'record_status_message "d_e_hit"');
                        end
                        correct(trial) = 1; type(trial) = {'d_e_hit'};
                        condition{trial} = 'sw_d_e';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_d_e_answer_correct;
                        break
                        
                    elseif task_3.d_e_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_d_e_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_d_e_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "d_e_miss"');
                        end
                        correct(trial) = 0; type(trial) = {'d_e_miss'};
                        condition{trial} = 'sw_d_e';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_d_e_answer_incorrect;
                        break
                        
                    elseif task_3.d_d_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_d_d_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_d_d_answer_correct)]);
                            Eyelink('command', 'record_status_message "d_d_hit"');
                        end
                        correct(trial) = 1; type(trial) = {'d_d_hit'};
                        condition{trial} = 'nsw_d_d';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_d_d_answer_correct;
                        break
                        
                    elseif task_3.d_d_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_d_d_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_d_d_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "d_d_miss"');
                        end
                        correct(trial) = 0; type(trial) = {'d_d_miss'};
                        condition{trial} = 'nsw_d_d';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_d_d_answer_incorrect;
                        break
                        
                    elseif task_3.e_e_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_e_e_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_e_e_answer_correct)]);
                            Eyelink('command', 'record_status_message "e_e_hit"');
                        end
                        correct(trial) = 1; type(trial) = {'e_e_hit'};
                        condition{trial} = 'nsw_e_e';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_e_e_answer_correct;
                        break
                        
                    elseif task_3.e_e_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_e_e_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_e_e_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "e_e_miss"');
                        end
                        correct(trial) = 0; type(trial) = {'e_e_miss'};
                        condition{trial} = 'nsw_e_e';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_e_e_answer_incorrect;
                        break
                        
                    elseif task_3.d_p_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_d_p_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_d_p_answer_correct)]);
                            Eyelink('command', 'record_status_message "d_p_crj"');
                        end
                        correct(trial) = 1; type(trial) = {'d_p_crj'};
                        condition{trial} = 'nsw_d_p';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_d_p_answer_correct;
                        break
                        
                    elseif task_3.d_p_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_d_p_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_d_p_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "d_p_fa"');
                        end
                        correct(trial) = 0; type(trial) = {'d_p_fa'};
                        condition{trial} = 'nsw_d_p';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_d_p_answer_incorrect;
                        break
                        
                    elseif task_3.p_d_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_p_d_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_p_d_answer_correct)]);
                            Eyelink('command', 'record_status_message "p_d_hit"');
                        end
                        correct(trial) = 1; type(trial) = {'p_d_hit'};
                        condition{trial} = 'nsw_p_d';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_p_d_answer_correct;
                        break
                        
                    elseif task_3.p_d_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_p_d_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_p_d_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "p_d_miss"');
                        end
                        correct(trial) = 0; type(trial) = {'p_d_miss'};
                        condition{trial} = 'nsw_p_d';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_p_d_answer_incorrect;
                        break
                        
                    elseif task_3.p_e_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_p_e_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_p_e_answer_correct)]);
                            Eyelink('command', 'record_status_message "p_e_hit"');
                        end
                        correct(trial) = 1; type(trial) = {'p_e_hit'};
                        condition{trial} = 'nsw_p_e';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_p_e_answer_correct;
                        break
                        
                    elseif task_3.p_e_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_p_e_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_p_e_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "p_e_miss"');
                        end
                        correct(trial) = 0; type(trial) = {'p_e_miss'};
                        condition{trial} = 'nsw_p_e';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_p_e_answer_incorrect;
                        break
                        
                    elseif task_3.e_p_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_e_p_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_e_p_answer_correct)]);
                            Eyelink('command', 'record_status_message "e_p_crj"');
                        end
                        correct(trial) = 1; type(trial) = {'e_p_crj'};
                        condition{trial} = 'nsw_e_p';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_e_p_answer_correct;
                        break
                        
                    elseif task_3.e_p_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_e_p_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_e_p_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "e_p_fa"');
                        end
                        correct(trial) = 0; type(trial) = {'e_p_fa'};
                        condition{trial} = 'nsw_e_p';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_e_p_answer_incorrect;
                        break
                        
                    elseif task_3.p_p_sw(s) == 1 && firstPress(KbName('RightArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_p_p_answer_correct),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_p_p_answer_correct)]);
                            Eyelink('command', 'record_status_message "p_p_crj"');
                        end
                        correct(trial) = 1; type(trial) = {'p_p_crj'};
                        condition{trial} = 'nsw_p_p';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_p_p_answer_correct;
                        break
                        
                    elseif task_3.p_p_sw(s) == 1 && firstPress(KbName('LeftArrow'))
                        if par.recordEEG
                            NetStation('Event', num2str(par.trigger.task3_p_p_answer_incorrect),timeSecs); end
                        if par.useEL
                            Eyelink('Message',['TR',num2str(par.trigger.task3_p_p_answer_incorrect)]);
                            Eyelink('command', 'record_status_message "p_p_fa"');
                        end
                        correct(trial) = 0; type(trial) = {'p_p_fa'};
                        condition{trial} = 'nsw_p_p';
                        answer_trigger_secs(trial) = GetSecs;
                        trigger_sent(trial) = par.trigger.task3_p_p_answer_incorrect;
                        break
                    end
                end
                
                KbQueueStop(deviceIndex);
                
                Screen('DrawLines', window, allCoords, lineWidthPix, par.colorText, [xCenter yCenter]);
                Screen('Flip', window,[],[],1);
                
                before_isi_secs(trial) = GetSecs;
                
                % ISI
                rng('shuffle')
                isi(trial)=0.5+0.2*rand;
                wakeup(trial) = WaitSecs(isi(trial));
                
                after_isi_secs(trial) = GetSecs;
                
                % Write Timing Matrix
                RT(trial) = timeSecs - after_word_secs(trial);
                timing_task_3(trial,:) = [before_task_secs, before_word_secs(trial)-before_task_secs, after_word_secs(trial)-before_task_secs, after_trigger_wordstart_secs(trial)-before_task_secs, answer_trigger_secs(trial)-before_task_secs, before_isi_secs(trial)-before_task_secs, after_isi_secs(trial)-before_task_secs, isi(trial), wakeup(trial)-before_task_secs, RT(trial)];
                
                % Write Answer Matrix
                answers_task_3(trial,:)=[par.subjectID which_task task_3.sequenz(s) task_3.word(s) KbName(firstPress) RT(trial) condition{trial} correct(trial) type(trial) task_3.d_e_sw(trial) task_3.e_d_sw(trial) trigger_sent(trial) task_3.if_word(s) task_3.language(s) task_3.test(s)];
            end
            
            %send last triggers
            if par.recordEEG,  NetStation('Event', num2str(par.trigger.task3_taskEnd)); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.task3_taskEnd)]);
                Eyelink('command', 'record_status_message "Task FINISHED"');
            end %Send Eytracker Trigger
            
            
            % timing_task_1_as_table = table(timing_task_1,...
            %     'VariableNames',{'Before_Task' 'Before_Word' 'After_Word' 'After_Trigger_Wordstart' 'Answer_Trigger' 'Before_isi' 'After_Isi' 'ISI' 'Wakeup' 'RT'});
            
            answers_task_3 = cell2table(answers_task_3,...
                'VariableNames',{'SubjectID' 'WhichTask' 'Sequenz' 'Word' 'KeyName' 'RT' 'Condition' 'Correct' 'AnswerType' 'd_e_sw' 'e_d_sw' 'Trigger_Sent' 'Word_Pseudoword' 'Language' 'Test'});
            
            disp('End of Task 3');
            
%             par.textSize = 20;
            
            DrawFormattedText(window, gen_Instruction_end, par.x, par.y, par.colorText,[],[],[],3);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            WaitSecs(10);
        end
    end
    
    actSecs = GetSecs;
    Timing = [Timing, actSecs-startSecs];
    
    if par.recordEEG
        NetStation('Event', num2str(par.trigger.ldt_stop)); end
    if par.useEL
        Eyelink('Message',['TR',num2str(par.trigger.ldt_stop)]);
        Eyelink('command', 'record_status_message "LDT_stop"');
    end
    
    par.textSize = 20;
    
    DrawFormattedText(window, 'Vielen Dank für Ihren Effort.\n\nNun folgt eine kurze Pause und\ndie Versuchsleitung wird zu Ihnen kommen.', par.x, par.y, par.colorText,[],[],[],2);
    Screen('TextSize', window, par.textSize);
    Screen('Flip', window, [],[],1);
    
    %% Stop EEG/ET for Recalibration 4
    if par.useEL && par.useEL_Calib
        if par.recordEEG,  NetStation('Event', num2str(par.trigger.recalibration_start)); end
        if par.recordEEG, pause(2); NetStation('StopRecording'); end;
        Screen('Flip', window, [],[],1);
        %window=Screen('OpenWindow', whichScreen, par.BGcolor);
        fprintf('Stop Recording Track\n');
        %send trigger for start of calibration
        Eyelink('StopRecording'); %Stop Recording
        Eyelink('CloseFile');
        edfFile= edfFileCell{end};
        EL_DownloadDataFile
        %    save([savePath, 'results_ELF_' par.subjectID '_' num2str(length(edfFileCell)) '.mat'],'par')
        
        
        % ----- EL_Cleanup:
        Eyelink('Command', 'clear_screen 0');
        
        
        % Shutdown Eyelink:
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        Eyelink('Shutdown'); %DN: commented out for now. Uncomment later
        fprintf('Stopped the Eyetracker\n');
        % ----- end EL_Cleanup
        
        DrawFormattedText(window, 'Vielen Dank für Ihren Effort.\n\nNun folgt eine kurze Pause und\ndie Versuchsleitung wird zu Ihnen kommen.', par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        
        KbQueueStart(deviceIndex);
        
        while 1 % Wait for VP to finish instructions
            
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            
            if pressed == 1 && KbName(find(firstPress,1)) == string('w')
                break;
            end
        end
        KbQueueStop(deviceIndex);
        
        EL_Connect;
        %Eyelink('CloseFile');
        %Eyelink('Message',['TR',num2str(par.trigger_recalibration_start)]);
        %Eyelink('command', 'record_status_message "Calibration START"');
        try % open file to record data to
            disp('creating edf file');
            edfFileCell{end+1}=[par.subjectID '_ELF' num2str(length(edfFileCell)+1) '.edf']; %edfFileCell{end+1}=[num2str(par.subjectID),'_NR' (num2str(length(edfFileCell))+1) '.edf'];
            Eyelink('Openfile', edfFileCell{end});
        catch
            disp('Error creating the file on Tracker');
        end;
        EL_Calibrate
        Eyelink('StartRecording');
        Eyelink('command', 'record_status_message "RECALIBRATED"');
%         Eyelink('Message',['TR',num2str(par.trigger.recalibration_end)]);
        Eyelink('command', 'record_status_message "Calibration END"');
        if par.recordEEG, NetStation('StartRecording'); end;
        pause(2);
        
        %     if par.recordEEG,  NetStation('Event', num2str(par.trigger_taskStart(cntTaskRuns))); end
%         if par.recordEEG,  NetStation('Event', num2str(par.trigger.recalibration_end)); end
        HideCursor(screenNumber);
        disp('DID THE EEG START RECORDING DATA? IF NOT, PRESS THE RECORD BUTTON!');
    else
        
        KbQueueStart(deviceIndex);
        
        while 1 % Wait for VP to finish instructions
            
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            
            if pressed == 1 && KbName(find(firstPress,1)) == string('w')
                break;
            end
        end
    end

end



WaitSecs(1)

if par.recordReading_Post
    if par.recordEEG
        NetStation('Event', num2str(par.trigger.exp_post_start)); end
    if par.useEL
        Eyelink('Message',['TR',num2str(par.trigger.exp_post_start)]);
        Eyelink('command', 'record_status_message "LDT_start"');
    end
    
    %% Lesen Post
    
    for t = par.order(3:4)
        KbQueueStart(deviceIndex);
        
        % Instruktion Lesen
        DrawFormattedText(window, instructions.task.reading{1}, par.x, par.y, par.colorText,[],[],[],2);
        Screen('TextSize', window, par.textSize);
        Screen('Flip', window, [],[],1);
        
        while 1 % Wait for VP to finish instruction
            [ pressed, firstPress]=KbQueueCheck(deviceIndex);
            timeSecs = firstPress(find(firstPress));
            
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
            
            if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                break;
            end
        end
        
        WaitSecs(0.5);
        
        if par.recordEEG
            NetStation('Event', num2str(par.trigger.lesen_post_start(t))); end
        if par.useEL
            Eyelink('Message',['TR',num2str(par.trigger.lesen_post_start(t))]);
            Eyelink('command', 'record_status_message "Lesen_post_start"');
        end
        
        start_reading_post{t} = GetSecs;
        
        for s = 2:length(sentences_ue{t})
            
            timing_reading_post = GetSecs;
            
            [nx, ny, textbounds, wordbounds] = DrawFormattedText(window, sentences_ue{t}{s}, par.x_lesen, par.y_lesen, par.colorText,[],[],[],4);
            Screen('TextSize', window, par.textSize);
            Screen('Flip', window, [],[],1);
            
            textbounds_reading_post{t}{s} = textbounds;
            wordbounds_reading_post{t}{s} = wordbounds;
            
            if par.recordEEG
                NetStation('Event', num2str(par.trigger.lesen_sentence_post_start(t))); end
            if par.useEL
                Eyelink('Message',['TR',num2str(par.trigger.lesen_sentence_post_start(t))]);
                Eyelink('command', 'record_status_message "Lesen_post_zeile"');
            end
            
            while 1
                [ pressed, firstPress]=KbQueueCheck(deviceIndex);
                timeSecs = firstPress(find(firstPress));
                
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
                if pressed == 1 && KbName(find(firstPress,1)) == string('Return')
                    
                    break;
                end
            end
            
            timeSecs = GetSecs;
            timing_reading_sentence_post{t}(s) = timeSecs - timing_reading_post;
        end
        
        WaitSecs(0.3);
        
        if par.recordEEG
            NetStation('Event', num2str(par.trigger.lesen_post_end(t))); end
        if par.useEL
            Eyelink('Message',['TR',num2str(par.trigger.lesen_post_end(t))]);
            Eyelink('command', 'record_status_message "Lesen_post_ende"');
        end
        
        
    end 
     
    actSecs = GetSecs;
    Timing = [Timing, actSecs-startSecs];
    
    DrawFormattedText(window, 'Vielen Dank für Ihren Effort.\n\nDas Experiment ist nun vorbei und\ndie Versuchsleitung wird zu Ihnen kommen.', par.x, par.y, par.colorText,[],[],[],2);
    Screen('TextSize', window, par.textSize);
    Screen('Flip', window, [],[],1);
    
    
    
    if par.recordEEG
        NetStation('Event', num2str(par.trigger.exp_post_stop)); end
    if par.useEL
        Eyelink('Message',['TR',num2str(par.trigger.exp_post_stop)]);
        Eyelink('command', 'record_status_message "Exp_post_stop"');
    end
    
end

actSecs = GetSecs;
Timing = [Timing, actSecs-startSecs];

WaitSecs(3)

%% Stop recordings and download ET Files
if par.recordEEG
    fprintf('Stop Recording EEG\n');
    NetStation('StopRecording'); %Stop Recording
    %NetStation('Disconnect');
end

if par.useEL
    fprintf('Stop Recording Track\n');
    Eyelink('StopRecording'); %Stop Recording
    Eyelink('CloseFile');
    edfFile=edfFileCell{end};
    EL_DownloadDataFile
    EL_Cleanup %Shutdown Eyetracker and close all Screens
end
if ~userExit
    Screen('CloseAll');
end

% Saving Results



var_save_full = {'Timing','par', 'instructions', 'ctrl_questions', 'sentences_ue',...
    'task_1','answers_task_1', 'timing_task_1','task_2','answers_task_2', 'timing_task_2','task_3','answers_task_3', 'timing_task_3',...
    'timing_reading_sentence', 'start_reading','textbounds_reading', 'wordbounds_reading', 'sub_empf_schwierigkeit_lesen',...
    'timing_task_sentences_translation', 'timing_task_sentences_transcription',...
    'results_control_questions', 'results_output_abschreiben', 'results_output_uebersetzen', 'results_text_abschreiben', 'results_text_uebersetzen', 'results_timestamp_abschreiben', 'results_timestamp_uebersetzen','sub_empf_schwierigkeit_uebersetzen'...
    'timing_reading_sentence_post', 'start_reading_post','textbounds_reading_post', 'wordbounds_reading_post'};

var_save_LDT = {'Timing','par', 'instructions', 'ctrl_questions', 'sentences_ue',...
    'task_1','answers_task_1', 'timing_task_1','task_2','answers_task_2', 'timing_task_2','task_3','answers_task_3', 'timing_task_3'};

var_save_ELF_Exp = {'Timing','par', 'instructions', 'ctrl_questions', 'sentences_ue',...
    'timing_reading_sentence', 'start_reading','textbounds_reading', 'wordbounds_reading', 'sub_empf_schwierigkeit_lesen',...
    'timing_task_sentences_translation', 'timing_task_sentences_transcription',...
    'results_control_questions', 'results_output_abschreiben', 'results_output_uebersetzen', 'results_text_abschreiben', 'results_text_uebersetzen', 'results_timestamp_abschreiben', 'results_timestamp_uebersetzen','sub_empf_schwierigkeit_uebersetzen'};

var_save_Reading_Post = {'Timing','par', 'instructions', 'ctrl_questions', 'sentences_ue',...
    'timing_reading_sentence_post', 'start_reading_post','textbounds_reading_post', 'wordbounds_reading_post'};

if par.recordFullEXP
    save([savePath, 'Fullresults_ELF_' par.subjectID '.mat'],var_save_full{:});
end

if par.recordLDT && ~ par.recordFullEXP
    save([savePath, 'Results_LDT_' par.subjectID '.mat'],var_save_LDT{:});
end
if par.recordELF_Exp && ~ par.recordFullEXP
    save([savePath, 'Results_ELF_Exp_' par.subjectID '.mat'],var_save_ELF_Exp{:});
end
if par.recordReading_Post && ~ par.recordFullEXP
    save([savePath, 'Results_Reading_Post' par.subjectID '.mat'],var_save_Reading_Post{:});
end

save([savePath, 'Allvariables_' par.subjectID '.mat']);

% if par.recordFullEXP
%     save([savePath, 'Fullresults_ELF_' par.subjectID '.mat'],'Timing','par', 'task_1','answers_task_1', 'timing_task_1','task_2','answers_task_2', 'timing_task_2','task_3','answers_task_3', 'timing_task_3', 'timing_reading', 'timing_reading_all', 'results_control_questions', 'results_output_abschreiben', 'results_output_uebersetzen', 'results_text_abschreiben', 'results_text_uebersetzen', 'results_timestamp_abschreiben', 'results_timestamp_uebersetzen', 'timing_reading_post')
% end
% 
% if par.recordLDT && ~ par.recordFullEXP
%     save([savePath, 'Results_LDT_' par.subjectID '.mat'], 'Timing','par', 'task_1','answers_task_1', 'timing_task_1','task_2','answers_task_2', 'timing_task_2','task_3','answers_task_3', 'timing_task_3')
% end
% if par.recordELF_Exp && ~ par.recordFullEXP
%     save([savePath, 'Results_ELF_' par.subjectID '.mat'],'Timing','par', 'timing_reading', 'timing_reading_all', 'results_control_questions', 'results_output_abschreiben', 'results_output_uebersetzen', 'results_text_abschreiben', 'results_text_uebersetzen', 'results_timestamp_abschreiben', 'results_timestamp_uebersetzen')
% end
% if par.recordReading_Post && ~ par.recordFullEXP
%     save([savePath, 'Results_RP_' par.subjectID '.mat'],'Timing','par', 'timing_reading_post')
% end


addpath(genpath('/home/stimuluspc/Tools/Tooboxes/eeglab'))
pathEdf2Asc = '/home/stimuluspc/Tools/Tools/edf2asc';
if par.useEL
    for i=1:length(edfFileCell)
        system([pathEdf2Asc ' "' [savePath, par.subjectID '_ELF' num2str(i)] '" -y'])
        parseeyelink(strrep([savePath, par.subjectID '_ELF' num2str(i) '.edf' ],'.edf','.asc'),[strrep([savePath, par.subjectID '_ELF' num2str(i)],'.edf','') '_ET.mat'],'TR');
    end
end

ListenChar(1);

sca;