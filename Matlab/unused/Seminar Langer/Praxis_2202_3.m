%% Vorbereitungen:
clc
clear all

%% In den Ordner vom m. file wechseln
% per Maus oder so:
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));


%% Einrichtung EEGLAB
% EEGLAB sollte irgendwo erreichbar gespeichert sein
% EEGLAB Pfad erreichbar machen
cd('~/Downloads/eeglab2019_1/');
% relativer Pfad; absoluter Pfad aus Ordnerinformation, eigentlich besser

% testen ob EEGLAB im Pfad ist
eeglab
close()

cd(fileparts(tmp.Filename));

%% Ein EEG File einlesen
load('/Users/ninaraduner/Downloads/7_Experiment/Daten/Daten für Praxis 3/AA4_RES_EEG.mat');


%% ADd Reference Channel and chanlocs
EEG.data(end+1,:) = 0;
EEG.nbchan = EEG.nbchan + 1;

% chanlocs
% EEG = pop_chanedit(EEG, 'load',{'GSN-HydroCel-129.sfp', 'filetype', 'sfp'});
chanlocs = readlocs('GSN-HydroCel-129.sfp');
chanlocs = chanlocs(4:end);
EEG.chanlocs = chanlocs;

%% Plotting
%Plot the EEG Dat
eegplot(EEG.data);

figure;
plot(EEG.data(10,1:500));
% Werte sind viel zu hoch für EEG -> im EEGplot nicht angezeigt

eegplot(EEG.data, 'events',EEG.event);
% trigger Anzeigen

% Verwende nur die ersten 100 Sekunden, damit die Berechnungen nicht zu
% lange dauern
EEG = pop_select(EEG, 'time', [1, 100]);


%% Filtern
EEG = pop_eegfiltnew(EEG, 1, 0); % Highpass filter bei 1 Hz
% immer zuerst den Hochpassfilter machen -> Reihenfolge wichtig
EEG_filtLowpass = pop_eegfiltnew(EEG, 0, 30); % lowpass filter bei 30 Hz in neue Datei

eegplot(EEG.data)

figure;
plot(EEG.data(10,1:500));
hold on;
plot(EEG_filtLowpass.data(10,1:500));
legend({'highpass filtered', 'high and lowpass filtered'});

EEG=EEG_filtLowpass;



% all electrodes which should be kept (we remove the electrodes, which measueres only muscle activity)
chan128 = [2 3 4 5 6 7 9 10 11 12 13 15 16 18 19 20 22 23 24 26 27 ...
    28 29 30 31 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 50 51 ...
    52 53 54 55 57 58 59 60 61 62 64 65 66 67 69 70 71 72 74 75 76 ...
    77 78 79 80 82 83 84 85 86 87 89 90 91 92 93 95 96 97 98 100 ...
    101 102 103 104 105 106 108 109 110 111 112 114 115 116 117 ...
    118 120 121 122 123 124 129];

% define eye channels (EOG)
eog_channels = sort([1 32 8 14 17 21 25 125 126 127 128]);

% find electrodes, which measure brain activity
channels = setdiff(chan128, eog_channels);

% Create new structures for EEG and EOG
[EOG] = pop_select(EEG , 'channel', eog_channels);
[EEG] = pop_select(EEG , 'channel', channels);

%% Bad Channel Detection & Interpolation
% Define standard deviations. if electrode deviates more than X standard
% deviations
kurt_thresh = 3;
prob_thresh = 3;
spec_thresh = 3;

[~, indelec_kurt, measure]  = pop_rejchan( EEG, 'elec', [1:104], 'threshold', kurt_thresh, 'measure' , 'kurt',  'norm' , 'on')
[~, indelec_thresh, measure]  = pop_rejchan(EEG, 'elec', [1:104], 'threshold', prob_thresh, 'measure' , 'prob', 'norm' , 'on')
[~, indelec_spec, measure]  = pop_rejchan(EEG, 'elec', [1:104], 'threshold', spec_thresh, 'measure' , 'spec', 'norm' , 'on')

bad_electrodes = unique([indelec_kurt, indelec_thresh, indelec_spec]);
% nimmt die schlechten zusammen, aber jede nur 1x

% interpoliert die schlechten über eine Kugel
EEG = eeg_interp(EEG, bad_electrodes, 'spherical');

%% Rereference to average reference
EEG = pop_reref(EEG, []);
% nach Komma die Referenz, wenn leerer Vektor -> Average Reference

%% ICA

%run ICA

tic;
EEG = pop_runica(EEG, 'icatype', 'runica');
toc;
% runica infomax
% tic, toc misst die Zeit, die es braucht um die Funktion auszuführen:
% 36.17 Sekunden

% plot ICA results
pop_selectcomps(EEG, [1:20]);

%% projiziere nur gute Komponten zurück
EEG_ica = pop_subcomp(EEG, [1 2 3 18]);

FrontalElec = 12;
figure;plot(EEG.data(FrontalElec,:));ylim([-60 110]);
figure;plot(EEG_ica.data(FrontalElec,:));ylim([-60 110]);

