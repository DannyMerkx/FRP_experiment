function [expt, subjects, eeg_filenames, eye_filedirs, marker_info] = get_exp_info(varargin)

% Get info about a specific experiment
%
% Output:
%       expt: location of data
%       labels: condition names
%       subjects: subjects' names
%       sessions: session numbers
%       markers: marker numbers necessary for slicing

    expt        = fullfile('own_experiments','visual','neglect_project','FRP_recancellation');
    subjects    = {'Alysha'}; 
    eeg_filenames   = {{'Alysha.edf'}}; 
    eye_filedirs    = {{'eye_data'}}; 
    
    %markers
    trialstart  = 1:30;                    % beginning of trial
    trialend    = 1:30;                    % end of trial
    marker_info = struct('trialstart',trialstart,'trialend',trialend);

    
