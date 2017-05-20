function subslice_eeg(varargin)

%Slice EEG trials further into fixation-related potentials

global data_root;

opts=struct('subidx',[],...
    'time_win',[-0.2 0.5],... %time window around fixation onset
    'save',1);
opts=parseOpts(opts,varargin);

%get info
[expt, subjects] = get_exp_info;
if ~isempty(opts.subidx); subjects = subjects(opts.subidx); end %keep only requested subject(s)

for si = 1:numel(subjects)
    subj = subjects{si};
    
    %load data
    fprintf('Loading preprocessed EEG and fixation data of subject %s...\n',subj);
    try
        load(fullfile(data_root,expt,subj,'prep',[subj '_prep']));
        load(fullfile(data_root,expt,subj,'prep','Fixation_data.mat'));
    catch
        fprintf('No data found for subj %s \n',subj);
        continue;
    end
    
     %HACK discard first trial of subj s01 (interrupted trial)
    if strcmp(subj,'s01')
        z = jf_reject(z,'dim',3,'idx',1);
    end
    
    %check if trials have same marker number
    eeg_trials = [z.di(3).extra.trial];
    fix_trials = [fixations(find(diff(fixations(:,1))~=0),1)' fixations(end,1)];
    test = isequal(eeg_trials,fix_trials);
    if ~test
        disp('Marker numbers of EEG and fixation data do not match!');
        keyboard
    end
    
    %make list with trial index (1:number of trials) for each fixation
    trial_idx = nan(1,size(fixations,1));
    tmp = fixations;
    for ti = 1:size(z.X,3); %for every trial
        fix_idx = find(tmp(:,1)==z.di(3).extra(ti).trial);
        if any(diff(fix_idx)>1);
            fix_idx = fix_idx(1:find(diff(fix_idx)>1));
        end
        trial_idx(fix_idx) = repmat(ti,1,numel(fix_idx));
        tmp(fix_idx,:) = nan(numel(fix_idx),size(tmp,2));
    end
    
    %get FRP window in samples
    fs = z.di(n2d(z,'time')).info.fs;
    win_samp = round(opts.time_win*fs);
    
    %make new X
    fprintf('Subslicing into %d FRPs...\n',size(fixations,1));
    X = nan(size(z.X,1),diff(win_samp)+1,size(fixations,1)); %ch x time x fixation
    keep = true(1,size(fixations,1));
    
    for fi=1:size(fixations,1) %for every fixation
        fix_on_samp = find(abs(z.di(2).vals/1000-fixations(fi,2)) == min(abs(z.di(2).vals/1000-fixations(fi,2)))); %find time index corresponding to fixation onset
        fix_samp = fix_on_samp+win_samp(1):fix_on_samp+win_samp(2);
        
        if fix_samp(1)>0 && fix_samp(end)<size(z.X,2) %if whole FRP window falls inside trial
            X(:,:,fi) = z.X(:,fix_samp,fixations(fi,1));
        else
            keep(fi)=false;
        end
    end

    if ~all(keep)
        fprintf('Discarding %d FRPs with timepoints outside trial...\n',sum(~keep));
        X = X(:,:,keep);
        fixations = fixations(keep,:);
    end
    
    %put new X in z
    z.X = X;
    z.di(n2d(z,'time')).vals = [opts.time_win(1):1/fs:opts.time_win(2)]*1000;
    
    %make new dim info for 3rd dimension ('fixation')
    di=mkDimInfo(size(X,3),'fixation',[],[]); di=di(1);
    trials = num2cell(fixations(:,1)); [di.extra.trial] = deal(trials{:});
    targets = num2cell(fixations(:,6));[di.extra.target] = deal(targets{:});
    times_fixated = num2cell(fixations(:,7)); [di.extra.times_fixated] = deal(times_fixated{:});
    fixation_length = num2cell(fixations(:,8)); [di.extra.fix_len] = deal(fixation_length{:});
    z.di(3) = di;
    z = jf_addprep(z,'subslice',sprintf('subsliced trials into FRPs %1.0f-%1.0f ms',opts.time_win*1000),struct('time_win',opts.time_win));
    
    %detrend FRPs again to remove slow variations
    z=jf_detrend(z,'dim','time');
    
    %add labels for classification
    Yl = single([z.di(3).extra.target]);
%     Yl = single([z.di(3).extra.times_fixated])==2;
%     Yl=single(Yl);
    [z.Y,z.Ydi] = addClassInfo(Yl,'zeroLab',1,'spType','1v1','Ydi','fixation','markerdict',struct('marker',[1 0],'label',{{'target','non-target'}}));
    
   
    %save
    if opts.save
        fprintf('Saving...\n');
        filedir = fullfile(z.rootdir,'prep');
        if ~isdir(filedir); mkdir(filedir); end
        filename = fullfile(filedir,[subj '_subsliced']);
        save(filename,'z');
    end
    fprintf('Done!\n');
end