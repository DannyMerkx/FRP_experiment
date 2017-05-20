function preproc(varargin)

% Preprocess data for ERP analysis
%
% Optional input:
%   subidx: indices of subjects to include (default all)
%   save: save the results (default 1)
%   filtbands: bands for fft filter (default [.1 .5 12 15])
%   timewin: Nx2 time windows for analysis

global data_root;

opts=struct('subidx',[],'condidx',[],...
    'filtbands',[.1 .5 12 15],...
    'time_win',[0 16*10^3; 0 30*10^3],... %first window for fast conditions, second for slow conditions
    'save',1);
opts=parseOpts(opts,varargin);

%get info
[expt, subjects] = get_exp_info;
if ~isempty(opts.subidx); subjects = subjects(opts.subidx); end %keep only requested subject(s)

for si = 1:numel(subjects)
    close all
    subj = subjects{si};
    
    %load data
    fprintf('Loading data of subject %s...\n',subj);
    try
        load(fullfile(data_root,expt,subj,'prep',[subj '_raw']));
    catch
        fprintf('No data found for subj %s \n',subj);
        continue;
    end
    
    %remove 2 failed trails
    if strcmp(subj,'Ian_2')
      z.di(3).extra(1:2) = [];
      z.X(:,:,1:2)=[];
      z.di(3).vals(1:2)=[];
    end
    
    %remove 1 extra trial
    if strcmp(subj,'Alysha')
        z.di(3).extra(31) = [];
        z.X(:,:,31)=[];
        z.di(3).vals(31)=[];
    end
    
     biosemi = {'A1','A2','A3','A4','A5','A6','A7','A8',...
                'A9','A10','A11','A12','A13','A14','A15','A16',...
                'A17','A18','A19','A20','A21','A22','A23','A24',...
                'A25','A26','A27','A28','A29','A30','A31','A32'};

     biosemi2int = {'Fp1','AF3','F7','F3','FC1','FC5','T7','C3',...
                    'CP1','CP5','P7','P3','Pz','PO3','O1','Oz',...
                    'O2','PO4','P4','P8','CP6','CP2','C4','T8',...
                    'FC6','FC2','F4','F8','AF4','Fp2','Fz','Cz'};

           for chi = 1:sum([z.di(1).extra.iseeg]);
              z.di(1).vals(chi) = biosemi2int(strcmp(biosemi,z.di(1).vals{chi}));
           end
    
    %keep only EEG channels
    fprintf('Removing non-EEG channels...\n');
    eog_ch = strfind_cell('EOG',z.di(1).vals);
    eeg_ch = find([z.di(1).extra.iseeg]);
    
     %HACK: for subj Kristel, iseeg labels are not correct -> fix
    if strcmp(subj,'Kristel')
       eeg_ch = eeg_ch(1:32); 
    end
    z = jf_retain(z,'dim',n2d(z.di,'ch'),'idx',[eeg_ch eog_ch],'summary','keep EEG/EOG only');
    
    % CAR
    fprintf('Applying common average reference...\n');
    z = jf_reref(z,'dim','ch','summary','CAR');
    
    % remove outlying trials and channels
    %fprintf('Removing outliers...\n');
    z = jf_rmOutliers(z,'dim','epoch','thresh', 3.5);
    % z = jf_rmOutliers(z,'dim','ch','idx',eeg_ch,'thresh',3.5);
    z = jf_reref(z,'dim','ch','idx',[z.di(1).extra.iseeg],'summary','CAR');
    
    % remove slow drifts
    fprintf('Removing slow drifts...\n');
    z = jf_linDetrend(z,'dim','time');
    
    % spectrally filter
    fprintf('Applying filter %1.1f-%1.0fHz...\n',opts.filtbands(2),opts.filtbands(3));
    z = jf_fftfilter(z,'bands',opts.filtbands);
    
    % remove eye movement artefacts
    fprintf('Removing eye artefacts...\n')
    z = jf_artChRm(z,'vals',{'EOG_LEFT','EOG_RIGHT','EOG_TOP','EOG_BOTTOM'});
    
    % interpolate rejected channels
    %     fprintf('Interpolating rejected channels...\n');
    %     if strcmp (subjects{si},'s01')
    %       z = jf_spatdownsample(z,'capFile','cap32.txt', 'idx', 27, 'method', 'nearest');
    %     end
    
    % save
    if opts.save
        fprintf('Saving...\n');
        filedir = fullfile(z.rootdir,'prep');
        if ~isdir(filedir); mkdir(filedir); end
        filename = fullfile(filedir,[subj '_prep']);
        save(filename,'z');
    end
    fprintf('Done!\n');
end
end