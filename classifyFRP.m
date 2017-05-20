function classifyFRP(varargin)

% Classify FRP responses
%
% Optional input:
%   subidx: indices of subjects to include (default all)
%   condidx: indices of conditions to include (default all)
%   fs = sampling rate to use for classification (default 32)
%   save = save the classified data (default 1)

global data_root;

opts = struct('subidx',[],'condidx',[],'fs',32,'save',1);
opts = parseOpts(opts,varargin);

%get info
[expt, subjects] = get_exp_info;
if ~isempty(opts.subidx); subjects = subjects(opts.subidx); end %keep only requested subject(s)

%make folder for saving figures
figdir=fullfile(data_root,expt,'figs','FRP_classification');
if ~exist(figdir,'dir'); mkdir(figdir); end;

for si = 1:numel(subjects);
    subj = subjects{si};
    
    fprintf('Loading subsliced data of subject %s...\n',subj);
    try
        load(fullfile(data_root,expt,subj,'prep',[subj '_subsliced']));
    catch
        fprintf('No data found for subj %s \n',subj);
        continue;
    end

    % downsample and subslice
    fprintf('Downsampling to %d Hz \n',opts.fs)
    z = jf_subsample(z,'dim',n2d(z,'time'),'fs',opts.fs); %downsample
    z.fs = opts.fs;
    
    %retain only longer fixations
    fix_len = [z.di(n2d(z,'fixation')).extra.fix_len];
    fix_len = fix_len == 1;
    z=jf_retain(z,'dim',3,'idx',fix_len);
    
    % plot
%     clf;jf_plotERP(z,'disptype','plot');
%     saveaspdf(gcf,fullfile(figdir,[subj '_jf_ERP']));
%     clf;jf_plotAUC(z);
%     saveaspdf(gcf,fullfile(figdir,[subj '_jf_AUC_ERP']));
    
    % setup the folding - 10 folds
    z.foldIdxs=gennFold(z.Y,5); 
    
    % balance data: equal number of targets and non-targets
    [z.foldIdxs]= balanceYs(z.Y,z.foldIdxs); % balance training sets -> [nStim x nSeq x 1 x nFolds]
        
    % whiten
    z  = jf_whiten(z,'dim','ch');
    
    % target vs non-target classification
    z  = jf_cvtrain(z,'verb',0,'outerSoln',0,'objFn','lr_cg');
    
    label =[]
    %save
    if opts.save
        jf_save(z,[label '_ERPclass'],1);
    end
end
