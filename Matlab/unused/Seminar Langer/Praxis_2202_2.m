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

%% Ein EEG File einlesen
load('/Users/ninaraduner/Downloads/7_Experiment/Daten/Daten für Hausaufgabe/Sub01.mat');


%% Influence of Reference
figure(1);
time = 1;
% reference avg
topoplot(EEG.data(:, time), EEG.chanlocs, 'electrodes', 'labels', 'style', 'map', 'maplimits', [-5, 5]);
colorbar;
title('Average References')

% reference left ear
figure(2);
chnlLeftEar = 18;
% 18er Elektrode ist hinter dem linken Ohr
leftEarRefData = pop_reref(EEG, chnlLeftEar);
% macht einen neuen Datensatz mit neuer Refernz, nicht EEG überschreiben
topoplot(leftEarRefData.data(:,time), EEG.chanlocs, 'electrodes', 'labels', 'style', 'map', 'maplimits', [-5, 5]);
colorbar;
title('linkes Ohr')
% 18 ist bei 2.5 im Wert (postivste Elektrode im ersten Bild), wenn dann
% dieser Wert von allen abgezogen wird, die sowieso schon weniger geladen
% sind, dann wird der ganze Kopf noch negativer
% Das muster auf dem Kopf bleibt sehr ähnlich, einfach anders skaliert. Die
% Verteilung bleibt gleich. 
% bei der 18 grün: ist 0, weil man sie von sich selbst abgezogen hat.
% Referenzierung wird verwendet, um Effekte deutlicher zu machen. Wenn im
% visuellen Kortex, dann keine Referenz im visuellen Kortex. oft wird
% average reference verwendet. manchmal mastoid, manchmal Nase
% (Muskelaktivität)

% in Masterarbeit: überall die gleichen Skalen, auch für Farben. Sonst sind
% die Grafiken nicht vergleichbar

