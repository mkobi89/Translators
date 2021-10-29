clear all
clc

eeglabpath='C:\Users\rebec\OneDrive - uzh.ch\Master\FS20\Umsetzung und Auswertung neurophysiologischer Experimente\eeglab_current'
eeglab;
load('\Users\rebec\OneDrive - uzh.ch\Master\FS20\Umsetzung und Auswertung neurophysiologischer Experimente\Daten für Praxis\Sub02.mat')

%eeglab redraw

%% Band Pass Filtering and HIlbert Transformation for each Frequency band
%Zeitfrequenz Analyse, für Fouriertransformation, Zeitinformation, über die
%gesamte Zeit hat man die Info, welche Frequenz dominant ist, Wavelet,
%Hilbert, Multiple short time Fourier Transformation.
%here HIlbert Transform, Bandpass DAta to the DAta you're interested in -->
%dann haben wir nur die Aktivität in der Zeit (hier zwischen 1 und 3.5) wie
%viel von delta, Theta etc. ist in dieser Zeitfenster.
%delta
EEG_delta=EEG;
delta_HPF=1;
delta_LPF=3.5;
EEG_delta=pop_eegfiltnew(EEG_delta, delta_HPF,delta_LPF);
EEG_delta.hilbert=hilbert(EEG_delta.data')';
EEG_delta.amplitude=abs(EEG_delta.hilbert);
EEG_delta.phase=angle(EEG_delta.hilbert); %phase in radian

%theta
EEG_theta=EEG;
theta_HPF=4;
theta_LPF=7.5;
EEG_theta=pop_eegfiltnew(EEG_theta, theta_HPF,theta_LPF);
EEG_theta.hilbert=hilbert(EEG_theta.data')';
EEG_theta.amplitude=abs(EEG_theta.hilbert);
EEG_theta.phase=angle(EEG_theta.hilbert); %phase in radian

%alpha1: working memory
EEG_alpha1=EEG;
alpha1_HPF=8;
alpha1_LPF=10;
EEG_alpha1=pop_eegfiltnew(EEG_alpha1, alpha1_HPF,alpha1_LPF);
EEG_alpha1.hilbert=hilbert(EEG_alpha1.data')';
EEG_alpha1.amplitude=abs(EEG_alpha1.hilbert);
EEG_alpha1.phase=angle(EEG_alpha1.hilbert); %phase in radian

%alpha2: mehr Aufmerksamkeit
EEG_alpha2=EEG;
alpha2_HPF=10.5;
alpha2_LPF=12.5;
EEG_alpha2=pop_eegfiltnew(EEG_alpha2, alpha2_HPF,alpha2_LPF);
EEG_alpha2.hilbert=hilbert(EEG_alpha2.data')';
EEG_alpha2.amplitude=abs(EEG_alpha2.hilbert);
EEG_alpha2.phase=angle(EEG_alpha2.hilbert); %phase in radian

%beta
EEG_beta=EEG;
beta_HPF=13;
beta_LPF=21;
EEG_beta=pop_eegfiltnew(EEG_beta, beta_HPF,beta_LPF);
EEG_beta.hilbert=hilbert(EEG_beta.data')';
EEG_beta.amplitude=abs(EEG_beta.hilbert);
EEG_beta.phase=angle(EEG_beta.hilbert); %phase in radian

%gamma
EEG_gamma=EEG;
gamma_HPF=30;
gamma_LPF=49.5;
EEG_gamma=pop_eegfiltnew(EEG_gamma, gamma_HPF,gamma_LPF);
EEG_gamma.hilbert=hilbert(EEG_gamma.data')';
EEG_gamma.amplitude=abs(EEG_gamma.hilbert);
EEG_gamma.phase=angle(EEG_gamma.hilbert); %phase in radian

%% Segmentation, BAseline removal and ERP for each Frequency Band
%wir haben die BAseline verschoben (removed), die FRequenzen wurden
%sepeariert
%delta
EEG_delta.data=EEG_delta.amplitude;
EEG_delta=pop_epoch(EEG_delta,{13,14,15},[-0.2 0.8])
EEG_delta=pop_rmbase(EEG_delta,[-200 0]);
EKP_delta = mean(EEG_delta.data,3);

%theta
EEG_theta.data=EEG_theta.amplitude;
EEG_theta=pop_epoch(EEG_theta,{13,14,15},[-0.2 0.8])
EEG_theta=pop_rmbase(EEG_theta,[-200 0]);
EKP_theta= mean(EEG_theta.data,3);

%alpha1
EEG_alpha1.data=EEG_alpha1.amplitude;
EEG_alpha1=pop_epoch(EEG_alpha1,{13,14,15},[-0.2 0.8])
EEG_alpha1=pop_rmbase(EEG_alpha1,[-200 0]);
EKP_alpha1 = mean(EEG_alpha1.data,3);

%alpha2
EEG_alpha2.data=EEG_alpha2.amplitude;
EEG_alpha2=pop_epoch(EEG_alpha2,{13,14,15},[-0.2 0.8])
EEG_alpha2=pop_rmbase(EEG_alpha2,[-200 0]);
EKP_alpha2 = mean(EEG_alpha2.data,3);

%beta
EEG_beta.data=EEG_beta.amplitude;
EEG_beta=pop_epoch(EEG_beta,{13,14,15},[-0.2 0.8])
EEG_beta=pop_rmbase(EEG_beta,[-200 0]);
EKP_beta= mean(EEG_beta.data,3);

%gamma
EEG_gamma.data=EEG_gamma.amplitude;
EEG_gamma=pop_epoch(EEG_gamma,{13,14,15},[-0.2 0.8])
EEG_gamma=pop_rmbase(EEG_gamma,[-200 0]);
EKP_gamma = mean(EEG_gamma.data,3);

%% Merge all Files together
%wir nehmen alle Zeitpunkte, aber nur 61 Elektroden
EKP_fr =[EKP_gamma(61,:);EKP_beta(61,:);EKP_alpha2(61,:);EKP_alpha1(61,:);EKP_theta(61,:);EKP_delta(61,:)];
  
%% Plotting Version 1
figure
imagesc(EKP_fr)%gca allow us to see different frequencies
set(gca,'XTick',[0 51 94 250],'XTickLabel',{'-200','0','170', '800'})
set(gca,'YTickLabel',{'gamma','beta','alpha2','alpha1','theta','delta'})
colormap('jet')
caxis([min(min(EKP_fr)) max(max(EKP_fr))])
xlabel('Time(ms)')
ylabel('Frequency')
c=colorbar
ylabel(c,'Power/FRequency(dB/Hz)')
set(gcf,'color','w');

%% Plotting Version 2
%labels in die Mitte tun
