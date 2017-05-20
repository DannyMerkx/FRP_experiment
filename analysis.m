function analysis(varargin)

% Analyse the data of the FRP recancellation experiment
%
% Optional input:
%   subidx    = subjects to analyze (default all)
%   GA_subidx = subjects to include in grand average (default all)
addpath(genpath(('\\DISKSTATION\Danny\Documents\Studie\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation\analysis')));
addpath(genpath('C:\Users\Beheerder\Documents\MATLAB\Scriptie'))
opts = struct('subidx',[],'GA_subidx',[]);
opts = parseOpts(opts,varargin);

% 0) Initialize analysis: add necessary functions to path
init_analysis;

% 1) slice raw data into trials
slice_eeg('subidx',opts.subidx);
slice_eyedata('subidx',opts.subidx);

% process fixations
datapreparation;

% 2) preprocess EEG
preproc('subidx',opts.subidx); %preprocess EEG for FRP analysis
subslice_eeg('subidx',opts.subidx); %subslice EEG into FRPs

% 3) analyse FRPs
plotFRP('subidx',opts.subidx); %make and plot average FRPs per class
classifyFRP('subidx',opts.subidx); %classify FRPs

%%

% 5) plot classification results
number_of_trials('subidx',opts.subidx); %count number of trials (to determine chance level)
CR_Epoch('subidx',opts.subidx); %compute and plot single epoch accuracies for trials with left and right targets

% 6) Grand average 
GA_number_of_trials('subidx',opts.GA_subidx); %count number of trials (to determine chance level)
GA_CR_Epoch('subidx',opts.GA_subidx); %compute and plot single epoch accuracies for trials with left and right targets
GA_ERP('subidx',opts.GA_subidx); %ERP plots

