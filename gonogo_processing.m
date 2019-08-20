%% Processing of gonogo data for patient a54b12
clearvars; close all; clc

% Info
% ~11:30am start time
% ran one test run (9 trials)
% one left hand condition (25 trials)
% one right hand condition (25 trials)

%% load data
addpath('C:\Users\sunh20\Documents\SubjectData\a54b12_gonogo\mat_convert_updated')
load('2019-07-06_11-11-11.mat')
load('a54b12_1.mat')

%% pick data
clearvars -except chans chans_fs handedness NLX_data stim_inds subj_resp subjectID t_start 
%% visualization of BNC trigger + grid channels
% what channels are we interested in?

ch_BNC = 1;
ch_ECOG = 3;

fs_BNC = chans_fs(1);
fs_ECOG = chans_fs(3);

data_BNC = NLX_data{ch_BNC};
t_BNC = 1:1:length(data_BNC);
t_BNC = t_BNC./fs_BNC;

data_ECOG = NLX_data{ch_ECOG};
t_ECOG = 1:1:length(data_ECOG);
t_ECOG = t_ECOG./fs_ECOG;

figure;
plot(t_BNC,data_BNC)
xlabel('Time (s)')
ylabel('Voltage (uV)')
title('BNC21 - Button press information')

figure;
plot(t_ECOG,data_ECOG*1e6)
xlabel('Time (s)')
ylabel('Voltage (uV)')
title('Grid1 - ECoG Grid Ch 1')

%% check out trial information


%% filter ecog data (grid only for now)

filt_test = filt_neuro(data_ECOG,fs_ECOG);
figure
plot(t_ECOG,data_ECOG*1e6)
hold on
plot(t_ECOG,filt_test*1e6)
legend('pre filt','post filt')
xlabel('Time (s)')
ylabel('Voltage (uV)')


%% dividing data into epochs
% 200ms before stim onset + 200ms after button press