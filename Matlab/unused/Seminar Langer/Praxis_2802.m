%% alles löschen
clear all
clc

%% Pfad zu EEG LAB
cd('/Users/ninaraduner/Downloads/eeglab2019_1/');
eeglab
close();

%% Pfad zu Daten & Daten laden
%cd('/Users/ninaraduner/Downloads/7_Experiment/Daten/Daten für Hausaufgabe/');

load('/Users/ninaraduner/Downloads/7_Experiment/Daten/Daten für Hausaufgabe/Sub01.mat')

%% Pfad zum aktuellen File
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

%% Bedingungen
% 13, 14, 15 -> Bedingung A
% 17, 18, 19 -> Bedingung B
% 5, 6, 7 -> Bedingung C


% event: wann fängt etwas an, wann hört es auf, Markern; einige sagen, dass
% Gesichter gezeigt wurden. bekannte, unbekannte gesichter, und scramble:
% farbmuster, ählich wie gesicht, aber kein Gesicht -> unterschied
% visueller verarbeitung und Gesichtverarbeitung

%% Epochen
EEGC1 = pop_epoch(EEG, {13, 14, 15}, [-0.2, 0.8]);
EEGC2 = pop_epoch(EEG, {17, 18, 19}, [-0.2, 0.8]);
EEGC3 = pop_epoch(EEG, {5, 6, 7}, [-0.2, 0.8]);

% Epochen zu den Bedinungen, 200ms davor und 800ms danach; bei der 13.
% wurde ein Gesicht gezeigt, wir wollen aber die 200 ms davor noch nehmen:
% vorher die Baseline, die wir auch wollen. es passiert nicht viel.
% Aktivität ist nicht verbunden mit Gesicht. Innerhalb 800ms danach ein
% Signal messbar. Danach nicht mehr sinnvoll zu dem Gesicht.

% 1. Stelle: Signal
% 2. Stelle: Events/Marker
% 3. Stelle: Dauer der Epochen

% EEGC1: 70x250x295: 70 -> channels/Elektroden X 250 Zeitpunkte (1 Sekunde
% pro Event * 250 srat) X 295 Trials (Bedingung 1)

%% Baseline removen
EEGC1reb = pop_rmbase(EEGC1, [-200,0]);
EEGC2reb = pop_rmbase(EEGC2, [-200,0]);
EEGC3reb = pop_rmbase(EEGC3, [-200,0]);

% muss zum Baseline rausrechnen die Zeit hier in Milisekunden eingeben, bei
% Epochen in Sekunden

% beide Kurven übereinander plotten
figure(1)
hold on
plot(EEGC1reb.data(13, :, 1), 'g')
plot(EEGC1.data(13, :,1), 'k')


%% ERP's berechnene: über die 3. Dimension mitteln
EKP1Eany = mean(EEGC1reb.data(:,:,:), 3);
EKP2Eany = mean(EEGC2reb.data(:,:,:), 3);
EKP3Eany = mean(EEGC3reb.data(:,:,:), 3);

% über die Trials mitteln, Epochen mitteln über die 3. Dimension
% letzt Zahl gibt die Dimension an über die gemittelt wird
% nur den Datenteil rausgenommen und gemittelt -> kein struct mehr

figure;
hold on
relElectrode = 61;
plot(EEGC1reb.times, EKP1Eany(relElectrode, :), 'g', 'LineWidth', 2)
plot(EEGC2reb.times, EKP2Eany(relElectrode, :), 'r', 'LineWidth', 2)
plot(EEGC3reb.times, EKP3Eany(relElectrode, :), 'b', 'LineWidth', 2)
xlabel('time in ms after stimiulus onset')
ylabel('potential diffrences avereaged over all elextrodes')
titel('Channel E 65(EEG)')

% N170 sehr typisch für visuelle Inputs
% erwartet nicht, dass beim Zeitpunkt 0 passiert, weil es vom Auge zuerst
% in den Kortex muss und dann erst die Reaktion

% rot vermutlich scrambled face
% Unterschied zwischen blau und grün nicht von Auge ersichtbar
% (signifikanz)


%% Für alle 8 Probanden
EKP1E65 = nan(8, 250);
EKP2E65 = nan(8, 250);
EKP3E65 = nan(8, 250);

relElectrode = 61;

for iSub = 1:8
    load(['/Users/ninaraduner/Downloads/7_Experiment/Daten/Daten für Hausaufgabe/Sub0' num2str(iSub) '.mat'])
    
    %Segment data for current subjetct
    EEGC1 = pop_epoch(EEG, {13, 14, 15}, [-0.2, 0.8]); % in seconds
    EEGC2 = pop_epoch(EEG, {17, 18, 19}, [-0.2, 0.8]);
    EEGC3 = pop_epoch(EEG, {5, 6, 7}, [-0.2, 0.8]);
    
    %remove baseline for each subject
    EEGC1reb = pop_rmbase(EEGC1, [-200,0]); % in milliseconds
    EEGC2reb = pop_rmbase(EEGC2, [-200,0]);
    EEGC3reb = pop_rmbase(EEGC3, [-200,0]);
    
    %calculate EKP for the subjects and save it in a new row
    EKP1E65(iSub, :) = mean(EEGC1reb.data(relElectrode,:,:), 3);
    EKP2E65(iSub, :) = mean(EEGC2reb.data(relElectrode,:,:), 3);
    EKP3E65(iSub, :) = mean(EEGC3reb.data(relElectrode,:,:), 3);
end

% average across subjects
GMEKP1E65 = mean(EKP1E65, 1);
GMEKP2E65 = mean(EKP2E65, 1);
GMEKP3E65 = mean(EKP3E65, 1);
    
    
figure;
hold on
plot(EEGC1reb.times, GMEKP1E65, 'g', 'lineWidth', 2)
plot(EEGC1reb.times, GMEKP2E65, 'r', 'lineWidth', 2)
plot(EEGC1reb.times, GMEKP3E65, 'b', 'lineWidth', 2)
xlabel('time in ms after stimulus onset')
ylabel('EKP')
legend('C1: unfamous faces', 'C2: scrambled faces', 'C3: famous faces', ...
    'location', 'NorthEastOutside')
% unfamous faces
% scrambled 
% famous faces

figure;
sgtitle('GMEKP Elektrode 65, alle drei Bedingungen')
subplot(3, 1, 1)
plot(EEGC1reb.times, GMEKP1E65, 'g', 'lineWidth', 2)
ylabel('EKP')
legend('Condition A')
subplot(3,1,2)
plot(EEGC1reb.times, GMEKP2E65, 'r', 'lineWidth', 2)
ylabel('EKP')
subplot(3,1,3)
plot(EEGC1reb.times, GMEKP3E65, 'b', 'lineWidth', 2)
xlabel('time in ms after stimulus onset')
ylabel('EKP') 


%% Graphen voneinader unterscheiden

% which findpeaks -> wenn was mit EEGlab steht, dann muss man den
% entfernen, weil wir das nicht wollen
% rmpath(...)

% find peaks in all Data
close all
%findpeaks(EKP1E65(1,:), 'Annotate', 'extents')
% negative peaks sind nicht angezeigt
%findpeaks(-EKP1E65(1,:), 'Annotate', 'extents')

% find all indices where time is within the interval of 100-200 ms as this
% will include N170, the time is the same for all conditions
indices = (EEGC1reb.times >= 100 & EEGC1reb.times <= 200);

% hold on
% plot(EKP1E65(1, :))
% plot(EKP1E65(1, indices))


firstIndex = find(indices, 1, 'first');

peakC1 = zeros(1, 8);
peakC2 = zeros(1, 8);
peakC3 = zeros(1, 8);

for iSub = 1:8
    %find peaks cutour around N170
    % PKS gives peak value
    % LOCS gives position (the start) of the peak
    [~, LOCSC1] = findpeaks(-EKP1E65(iSub, indices), 'NPeaks', 1);
    [~, LOCSC2] = findpeaks(-EKP2E65(iSub, indices), 'NPeaks', 1);
    [~, LOCSC3] = findpeaks(-EKP3E65(iSub, indices), 'NPeaks', 1);
    % double: wie viele Nachkommastellen, keine rundungsfehler
    % ~ unterdrückt 1. Output, bruachen wir nicht
    % Npeaks = macht den 1. Peak in dem Bereich
    
    
    % the index corresponding to that timepoint
    iN170C1 = firstIndex+LOCSC1;
    iN170C2 = firstIndex+LOCSC2;
    iN170C3 = firstIndex+LOCSC3;
    
    % definde an interval around which we want to calculate the magnitude
    % of the N170
    peakC1(iSub) = mean(EKP1E65(iSub, iN170C1-5:iN170C1+5), 2);
    peakC2(iSub) = mean(EKP1E65(iSub, iN170C2-5:iN170C2+5), 2);
    peakC3(iSub) = mean(EKP1E65(iSub, iN170C3-5:iN170C3+5), 2);
    
end



