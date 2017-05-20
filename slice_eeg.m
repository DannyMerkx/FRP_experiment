function slice_eeg(varargin)

% This is the function for slicing the FRP recancellation experiment.
%
% Optional input:
%   subidx: indices of subjects to include (default all)
%   fs: output sampling rate (default 256)

global data_root;
opts=struct('subidx',[],'fs',256);
opts=parseOpts(opts,varargin);

[expt, subjects, eeg_filenames, ~, marker_info] = get_exp_info;
if ~isempty(opts.subidx); 
    subjects = subjects(opts.subidx); 
    eeg_filenames = eeg_filenames(opts.subidx);
end %keep only requested subject(s)
bdfmarker=bitshift(marker_info.trialstart,8);

for si=1:numel(subjects); % subjects
    subj = subjects{si};
    
    %slice
    rootdir = fullfile(data_root,expt,subj);
    try
        if strcmp(subj,'s01') || strcmp(subj,'Kristel') || strcmp (subj,'Alysha');
            %HACK: for some subjects, EEG recording was interrupted so we have 2 bdf files
            %We need to specify a fixed trial length to be able to merge both files into 1 z structure
            if strcmp(subj,'s01') %longest trial is 915365 samples (= 447 sec)
                trlen_ms = 447*10^3;
            elseif strcmp(subj, 'Kristel') %longest trial is 761009 samples (= 372 sec)
                trlen_ms = 372*10^3;
            elseif strcmp(subj,'Alysha') %longest trial is 1178630 samples (= 576 sec)
                trlen_ms = 576*10^3;
            end
            z  = raw2jf(fullfile(rootdir,'raw_data',eeg_filenames{si}),...
                'rootdir',rootdir,...
                'subsample',struct('fs',512),... %do not downsample yet
                'RecPhaseLimits',bdfmarker,...
                'trlen_ms',trlen_ms,...
                'prune_equal',0);
        else
            z  = raw2jf(fullfile(rootdir,'raw_data',eeg_filenames{si}{1}),...
                'rootdir',rootdir,...
                'subsample',struct('fs',512),... %do not downsample yet
                'startSet',bdfmarker,...
                'endSet',bdfmarker,...
                'autoPrune',0,...
                'prune_equal',0);
        end
    catch
        fprintf('Unable to read file %s, skipped\n',fullfile(rootdir,'raw_data',eeg_filenames{si}{1}))
        continue;
    end
    
    if( isempty(z) ) continue; end;
    
    %downsample now
    fprintf('Downsampling to %d Hz...\n',opts.fs);
    z = jf_subsample(z,'fs',opts.fs);
    
    % add subject info
    disp('Updating subject and channel info...');
    z.subj=subj;
    z.label=[];
    z.expt = expt;
     
    % setup the channel info more nicely
    if strcmp(z.di(n2d(z.di,'ch')).vals{1},'STATUS')
        z.X = circshift(z.X,-1); %move status channel to end
        z.di(n2d(z.di,'ch')).vals = circshift(z.di(n2d(z.di,'ch')).vals,[0,-1]);
    end
    z.di(n2d(z.di,'ch'))=addPosInfo(z.di(n2d(z.di,'ch')),'cap32',0);
    iseeg=false(size(z.X,n2d(z.di,'ch')),1); iseeg(1:32)=true;
    [z.di(1).extra.iseeg]=num2csl(iseeg);
    
    % relabel EXGs
    z.di(n2d(z.di,'ch')).vals{strcmp('EXG1',z.di(n2d(z.di,'ch')).vals)}='EOG_LEFT';
    z.di(n2d(z.di,'ch')).vals{strcmp('EXG2',z.di(n2d(z.di,'ch')).vals)}='EOG_RIGHT';
    z.di(n2d(z.di,'ch')).vals{strcmp('EXG3',z.di(n2d(z.di,'ch')).vals)}='EOG_TOP';
    z.di(n2d(z.di,'ch')).vals{strcmp('EXG4',z.di(n2d(z.di,'ch')).vals)}='EOG_BOTTOM';
    
    %remove inter trial intervals
    disp('Removing inter trial intervals...');
    epochD = n2d(z,'epoch');
    markers = [z.di(epochD).extra.marker];
    z = jf_retain(z,'dim',epochD,'idx',diff(markers)==0,'summary','removed inter trial intervals');
    
    % save original trial number
    for ti=1:size(z.X,epochD); %for all trials
        z.di(epochD).extra(ti).trial = bitshift(z.di(epochD).extra(ti).marker,-8);
    end
    
    % save
    disp('Saving...');
    filedir = fullfile(z.rootdir,'prep');
    if ~isdir(filedir); mkdir(filedir); end
    filename = fullfile(filedir,[subj '_raw']);
    save(filename,'z');
end;
end