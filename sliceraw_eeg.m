function sliceraw_eeg(varargin)

% This is the function for slicing the FRP recancellation experiment.
%
% Optional input:
%   subidx: indices of subjects to include (default all)
%   fs: output sampling rate (default 256)

global bciroot; if isempty(bciroot); set_bciroot; end
opts=struct('subidx',[],'fs',256);
opts=parseOpts(opts,varargin);

[expt, subjects, eeg_filenames, ~, marker_info] = get_exp_info;
if ~isempty(opts.subidx); subjects = subjects(opts.subidx); end %keep only requested subject(s)

for si=1:numel(subjects); % subjects
    subj = subjects{si};
    
    %slice
    rootdir = fullfile(bciroot{1},expt,subj);
    try
        z = raw2jf(fullfile(rootdir,'raw_data',eeg_filenames{si}),...
            'rootdir',rootdir,...
            'subsample',struct('fs',opts.fs),...
            'startSet',marker_info.trialstart,...
            'endSet',marker_info.trialend,...
            'autoPrune',0,...
            'prune_equal',0);
    catch
        fprintf('Unable to read file %s, skipped\n',fullfile(rootdir,eeg_filenames{si}))
        continue;
    end
    
    if( isempty(z) ) continue; end;
   
    % setup the channel info more nicely
    if strcmp(z.di(n2d(z.di,'ch')).vals{1},'STATUS')
        z.X = circshift(z.X,-1); %move status channel to end
        z.di(n2d(z.di,'ch')).vals = circshift(z.di(n2d(z.di,'ch')).vals,[0,-1]);
    end
    z.di(n2d(z.di,'ch'))=addPosInfo(z.di(n2d(z.di,'ch')),'cap64',0);
    iseeg=false(size(z.X,n2d(z.di,'ch')),1); iseeg(1:64)=true;
    [z.di(1).extra.iseeg]=num2csl(iseeg);
    
    % save original trial number
    epochD = n2d(z,'epoch');
    for ti=1:size(z.X,epochD); %for all trials 
        z.di(epochD).extra(ti).trial = ti;
    end

    % save
    jf_save(z,'raw',1,fullfile(rootdir,'jf_prep'));
end;
end