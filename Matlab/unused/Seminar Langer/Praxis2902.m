clear
clc
cd('C:\Users\rebec\OneDrive - uzh.ch\Master\FS20\Umsetzung und Auswertung neurophysiologischer Experimente\eeglab_current\eeglab2019_1')
mypath=pwd;
eeglabpath='C:\Users\rebec\OneDrive - uzh.ch\Master\FS20\Umsetzung und Auswertung neurophysiologischer Experimente\eeglab_current\eeglab2019_1'
cd(eeglabpath)

%open and close once so all paths are set correctly
eeglab; 
close;
cd(mypath);

addpath ('C:\Users\rebec\OneDrive - uzh.ch\Master\FS20\Umsetzung und Auswertung neurophysiologischer Experimente\Daten für Praxis')
%which shadedErrorBar --> um zu schauen, ob es die Datei findet und ob der
%Path geladen ist

%% 
for i=1:8 %(Probanden, bis 8 Probanden)
    load(['C:\Users\rebec\OneDrive - uzh.ch\Master\FS20\Umsetzung und Auswertung neurophysiologischer Experimente\Daten für Praxis\Sub0' num2str(i) '.mat'])%iterieren, immer wieder von neu etwas machen immer weider über eine variable drüber gehen
    
    %condition 1
    EEGC1 = pop_epoch(EEG, {13, 14, 15}, [-0.2, 0.8]); %in seconds
    EEGC1=pop_rmbase(EEGC1, [-200,0]);   %remove baseline mit rmbase
    ERPC1(i,:)=mean(EEGC1.data(61,:,:),3);
    ERP1(i,:,:)=mean(EEGC1.data(:,:,:),3);
    ERPC1front(i,:)=mean(EEGC1.data(6,:,:),3);
    
    %condition 2
    EEGC2 = pop_epoch(EEG, {5, 6, 7}, [-0.2, 0.8]); %in seconds
    EEGC2=pop_rmbase(EEGC2, [-200,0]);   %remove baseline mit rmbase
    ERPC2(i,:)=mean(EEGC2.data(61,:,:),3);
    ERP2(i,:,:)=mean(EEGC2.data(:,:,:),3);
    ERPC2front(i,:)=mean(EEGC2.data(6,:,:),3); %Frontale Elektrode wird gemessen um wie zu zeigen, dass Frontal (Elektrode 6) keine Messung zeigt, und die hinten beim visuellen Kortex schon (61)
    
    %condition 3
    EEGC3 = pop_epoch(EEG, {17, 18, 19}, [-0.2, 0.8]); %in seconds
    EEGC3=pop_rmbase(EEGC3, [-200,0]);   %remove baseline mit rmbase
    ERPC3(i,:)=mean(EEGC3.data(61,:,:),3);
    ERP3(i,:,:)=mean(EEGC3.data(:,:,:),3);
    ERPC3front(i,:)=mean(EEGC3.data(6,:,:),3);
end   
    
%% Mittelwert über alle Versuchspersonen (alle Elektroden jedoch noch vorhanden)
GM1=squeeze(mean(ERP1,1)); %squeeze ist eine Dimensionsreduktion, die 1 row ist nun die Elektrode, deswegen steht nicht mehr 8x70x250 sondern nur noch 70x250
GM2=squeeze(mean(ERP2,1));
GM3=squeeze(mean(ERP3,1));

%% Plotten der EKP auf Elektrode EEG065 (visuell)
figure;
plot(mean(ERPC1),'LineWidth',2)
hold on
plot(mean(ERPC2),'LineWidth',2)
hold on
plot(mean(ERPC3),'LineWidth',2)

%% Plotten der EKP auf Elektrode EEG006 (frontal)

%%findpeaks
findpeaks(ERPC1(1,:),'Annotate','extents')
close all
figure

%% findpeaks
findpeaks(double(-1*ERPC1(1,:)),'Annotate','extents') %we do the findpeaks on the *-1 data

[PKS,LOCS]=findpeaks(double(-ERPC1(1,76:100)),'NPeak',1);

%we want not just the peak but 5 timepoints before and after
start=75+LOCS-5;
stop=75+LOCS+5;

%we calculate the mean of the 5 timepoints before and after the peak
peakC1=mean(ERPC1(1,start:stop),2);
    
%do the peak detection for all subjects and all consitions, wir schauen nur
%auf die subjects
for i=1:8
    [PKS,LOCS]=findpeaks(double(-ERPC1(i,76:100)),'NPeak',1);
    start=75+LOCS-5;
    stop=75+LOCS+5;
    peakC1(i)=mean(ERPC1(i,start:stop));
end

plot(EEGC1.times,ERPC1')%transport
plot(ERPC1')
findpeaks(double(-ERPC1(1,:)),'Annotate','extents')

plot(EEGC2.times,ERPC2')%transponieren, damit bekommt man die Verläufe von jeder Person
plot(ERPC2') %ohne findpeaks run, dann andere figure
findpeaks(double(-ERPC2(1,:)),'Annotate','extents')

for i=1:8
    [PKS,LOCS]=findpeaks(double(-ERPC2(i,76:100)),'NPeak',1);
    start=75+LOCS-5;
    stop=75+LOCS+5;
    peakC2(i)=mean(ERPC2(i,start:stop));
end


plot(EEGC3.times,ERPC3')%transport
plot(ERPC3')
findpeaks(double(-ERPC3(1,:)),'Annotate','extents')

for i=1:8 %egal ob es i oder iSub ist, muss nur immer dasselbe sein
    [PKS,LOCS]=findpeaks(double(-ERPC3(i,76:100)),'NPeak',1);
    start=75+LOCS-5;
    stop=75+LOCS+5;
    peakC3(i)=mean(ERPC3(i,start:stop));
end

%% Statistics

%ANOVA
[p,tbl]=anova1([peakC1;peakC2;peakC3]');
%anova1(y) performs one-way ANOVA for the sample data y and returns the
%p-value
%anova1 treats each volumn of y as a seperate group
%the function tests the hypothesis that the samples in the columns of y are
%with the same mean against the alternative hypothesis that the population
%mean

%scatter plot
figure;
scatter(ones(1,8),peakC1);
hold on
scatter(ones(1,8)+1,peakC2); %mit +1 gehen sie eine Kolonne daneben
hold on
scatter(ones(1,8)+2,peakC3);
xlim([0,4])%hiermit setzt man den Anfang und Endzeitpunkt der x Achse

%ttest
[h,p1,ci,stats]=ttest(peakC1,peakC2) %ttest2 wäre verbundene Stichproben (2 für unabhängig, ttest ist normale verbundene stichprobe)
[h,p2,ci,stats]=ttest(peakC1,peakC3)
[h,p3,ci,stats]=ttest(peakC2,peakC3)

%alternative ways of calculating and visualizing ERPs 
pop_timtopo(EEGC1)
pop_erpimage(EEGC1,1)

%%Plot the ERP with the errorbars/ generate continuous error bar area
%%aroung a line plot % die Visuelle Elektrode
figure 
hold on
shadedErrorBar(1:size(ERPC1,2),mean(ERPC1,1),std(ERPC1)/sqrt(size(ERPC1,1)),'lineprops','b');
shadedErrorBar(1:size(ERPC2,2),mean(ERPC2,1),std(ERPC2)/sqrt(size(ERPC2,1)),'lineprops','r');%1.Info=xAchse, 2. Y-Achse, 3. was um Mittelwert verteilt wird
shadedErrorBar(1:size(ERPC3,2),mean(ERPC3,1),std(ERPC3)/sqrt(size(ERPC3,1)),'lineprops','g');

%Elektrode für Nose Elektrode = front
figure 
hold on
shadedErrorBar(1:size(ERPC1front,2),mean(ERPC1front,1),std(ERPC1front)/sqrt(size(ERPC1front,1)),'lineprops','b');
shadedErrorBar(1:size(ERPC2front,2),mean(ERPC2front,1),std(ERPC2front)/sqrt(size(ERPC2front,1)),'lineprops','r');
shadedErrorBar(1:size(ERPC3front,2),mean(ERPC3front,1),std(ERPC3front)/sqrt(size(ERPC3front,1)),'lineprops','g');