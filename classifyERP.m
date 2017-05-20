function classifyERP(varargin)

% Classify ERP responses
%
% Optional input:
%   subidx: indices of subjects to include (default all)
%   condidx: indices of conditions to include (default all)
%   fs = sampling rate to use for classification (default 32)
%   save = save the classified data (default 1)

global bciroot; if isempty(bciroot); set_bciroot; end

opts = struct('subidx',[],'condidx',[],'fs',32,'save',1);
opts = parseOpts(opts,varargin);

%get info
[expt, subjects, eeg_filenames, eye_filedirs, marker_info] = get_exp_info;
if ~isempty(opts.subidx); %keep only requested subject(s)
    subjects = subjects(opts.subidx); 
    gaze.use_offline = gaze.use_offline(opts.subidx);
end 


%make folder for saving figures
figdir=fullfile(bciroot{1},expt,'figs','ERP','jf_plots');
if ~exist(figdir,'dir'); mkdir(figdir); end;

for si = 1:numel(subjects);
    subj = subjects{si};

        try
            z= load(fullfile(bciroot{1},expt,subj,[subj '_prep_erp']));
        catch
            fprintf('Could not load data for subj %s condition %s \n',subj,label);
            continue
        end
 z= z.z;             
        % downsample and subslice
        fprintf('Downsampling to %d Hz \n',opts.fs)
        z = jf_subsample(z,'dim',n2d(z,'time'),'fs',opts.fs); %downsample
        z.fs = opts.fs;
        numepochs = numel(z.di(3).extra(1).erp_on_ms);
        z = subslice(z,'epoch_idx',2:numepochs-1); %subslice
        
        % store target and codebook of each trial (for sequence decoding)
        targets = [z.di(n2d(z,'epoch')).extra.targetmarker] - 19;
        z.LvsR.Y = targets; % 1=left, 2=right
        z.LvsR.Y(z.LvsR.Y==2) = -1; % +1 = left, -1 = right 
        
        codebook = zeros(2,size(z.X,3),size(z.X,4));
        for ti = 1:size(z.X,4)
            codebook(:,:,ti) = cell2num(z.di(n2d(z,'epoch')).extra(ti).stimMarkers)';
            codebook(:,:,ti) = ismember(codebook(:,:,ti),[111 121]); %row 1 = left, row 2 = right
        end
        z.codebook = codebook;

        % setup the labels
        Yl = single(cat(2,z.di(n2d(z.di,'epoch')).extra.trgterp)); % [nStim x nSeq]
        fmarkerdict=struct('label',{{'1' '0'}},'marker',[1 0]);
        oYdi=z.Ydi; % [Seq x subProb x lab]
        [z.Y,z.Ydi]=addClassInfo(Yl,'markerdict',fmarkerdict,'zeroLab',1,'spType','1vR','Ydi',z.di(n2d(z.di,{'erp','epoch'}))); % z.Y=[nStim x nSeq], z.Ydi=[stim x seq x subProb x lab]
        z.Ydi(n2d(z.Ydi,'epoch')).info=oYdi(n2d(oYdi,'subProb')).info; % rec left vs right decoding info
        
        % plot
        clf;jf_plotERP(z,'disptype','plot');
        saveaspdf(gcf,fullfile(figdir,[subj '_jf_ERP_' label]));
        clf;jf_plotAUC(z);
        saveaspdf(gcf,fullfile(figdir,[subj '_jf_AUC_ERP_' label]));
   
        % setup the folding - 10 folds
        z.foldIdxs=gennFold(ones(1,size(z.Y,2)),10,'dim',n2d(z.Ydi,'subProb')); % [nSeq x 10]
        
        % balance data, use only attended and unattended target stimuli
        foldIdxs = zeros(size(z.X,n2d(z,'erp')),size(z.X,n2d(z,'epoch')),1,size(z.foldIdxs,3));
        for fi = 1:size(foldIdxs,4) % for every fold
            foldIdxs(:,z.foldIdxs(:,:,fi)==1,:,fi) = squeeze(any(z.codebook(:,:,z.foldIdxs(:,:,fi)==1)));   %seqs in test set: codebook = 1 -> foldIdx = 1
            foldIdxs(:,z.foldIdxs(:,:,fi)==-1,:,fi)= -squeeze(any(z.codebook(:,:,z.foldIdxs(:,:,fi)==-1))); %seqs in train set: codebook = 1 -> foldIdx = -1
            if sum(z.Y(foldIdxs(:,:,:,fi)~=0)) ~= 0; warning(sprintf('Fold %d not balanced)',fi)); end %check if number of targets and non-targets is equal
        end
        z.foldIdxs = foldIdxs; % [nStim x nSeq x 1 x nFolds]
        
        %for subjects with offline gaze analysis, exclude epochs with wrong
        %eye gaze now
        if gaze.use_offline(si);
            load(fullfile(bciroot{1},expt,'eyedata_reanalyzed',[subj '_' label '_gaze_correct_erp.mat']));
            gaze_correct = gaze_correct';
            for fi=1:size(foldIdxs,4); %for every fold
                fld = foldIdxs(:,:,fi);
                fld(gaze_correct<1) = 0;
                %balance Y's
                Yfld = z.Y(fld~=0); %labels in this fold
                trgt_ratio = sum(Yfld);
                if trgt_ratio > 0 %more targets than non-targets
                    Y_idx = find(Yfld==1); %find indices of targets in Y
                    rm_Y = Y_idx(randperm(numel(Y_idx))); 
                    rm_Y = rm_Y(1:trgt_ratio); %pick random targets
                    rm_F = find(fld~=0); rm_F = rm_F(rm_Y); %find indices of removed targets in fold
                    fld(rm_F) = 0;
                elseif trgt_ratio < 0 %more non-targets than targets
                    Y_idx = find(Yfld==-1); %find indices of non-targets in Y
                    rm_Y = Y_idx(randperm(numel(Y_idx))); 
                    rm_Y = rm_Y(1:-trgt_ratio); %pick random non-targets
                    rm_F = find(fld~=0); rm_F = rm_F(rm_Y); %find indices of removed targets in fold
                    fld(rm_F) = 0;
                end
                if sum(z.Y(fld~=0)) ~= 0; warning(sprintf('Fold %d not balanced)',fi)); end %check if balancing was done correctly
                z.foldIdxs(:,:,:,fi) = fld;
            end
        end
        
        % whiten
        z  = jf_whiten(z,'dim','ch');

        % target vs non-target classification
        if( 0 ) % Kernel method (old)
            z  = jf_compKernel(z);
            z  = jf_cvtrain(z,'verb',0,'outerSoln',0);
        else
            z  = jf_cvtrain(z,'verb',0,'outerSoln',0,'objFn','lr_cg');
        end
      
        % left vs right decoding
        z = decodeERP(z);
        fprintf('Left vs Right classification accuracy: %1.2f \n',z.LvsR.CR);
        
        %save
        if opts.save
            jf_save(z,[label '_ERPclass'],1);
        end
    end
end

