function slice_eyedata(varargin)

%Slice eyetracker data in the FRP_recancellation experiment
%
%Optional input:
%   subidx: indices of subjects to include (default all)
%
%Output:
%   file Fixation_data.mat: Nx5 matrix where N is number of fixations in the
%   experiment
%       column 1: trial number
%       column 2 & 3: start and end of each fixation
%       column 4 & 5: x and y-coordinates of gaze position in pixels

global code_root;
global data_root; data_root = '\\DISKSTATION\Danny\Documents\Studie\KI\Scriptie\bci_code.git';

opts=struct('subidx',[]);
opts=parseOpts(opts,varargin);

[expt, subjects, ~, eye_filedirs, marker_info] = get_exp_info;
if ~isempty(opts.subidx); subjects = subjects(opts.subidx); end %keep only requested subject(s)
opts.startSet = marker_info.trialstart;
opts.endSet = marker_info.trialend;

for si=1:numel(subjects); % subjects
    subj = subjects{si};
    
    %get location of files
    fdir = fullfile(data_root,expt,subj,'raw_data',eye_filedirs{si},'0004');
    fdir = fdir{1};
    hdrfname=fullfile(fdir,'header');
    eventfname=fullfile(fdir,'events');
    datafname =fullfile(fdir,'samples');
    
    % read the header and the events
    hdr=read_buffer_offline_header(hdrfname);
    events=read_buffer_offline_events(eventfname,hdr);
        
    % extract sample-rate from the header
    if ( isfield(hdr,'SampleRate') ) fs=hdr.SampleRate;
    elseif ( isfield(hdr,'Fs') ) fs=hdr.Fs;
    elseif ( isfield(hdr,'fSample') ) fs=hdr.fSample;
    else warning('Cant find sample rate, using fs=1'); fs=1;
    end
    
    % select the events we want to slice on from the stream
    vals = [events(1:end-2).value];
    uvals = unique(vals);
    eventidx = [];
    for vi=1:numel(uvals)
        eventidx = cat(2,eventidx,find(vals==uvals(vi),1)); %select only events where marker is inserted for the first time
    end
    devents=events(eventidx); % select the set of events for which we want data
    
        % Finally get the data segments we want
        data=repmat(struct('buf',[]),size(devents));
        fprintf('Slicing %d epochs:',numel(devents));
        keep=true(numel(devents),1);
        for ei=1:numel(devents);
          data(ei).buf=read_buffer_offline_data(datafname,hdr,devents(ei).sample+[offset_samp]);
            if ( size(data(ei).buf,2) < (offset_samp(2)-offset_samp(1)) ) keep(ei)=false; end;
            if ( subSampRatio>1 ) % sub-sample
                [data(ei).buf,idx] = subsample(data(ei).buf,size(data(ei).buf,2)./subSampRatio,2);
            end
            fprintf('.');
        end
        fprintf('done.\n');
        if ( ~all(keep) )
            fprintf('Discarding %d events with no data\n',sum(~keep));
            data=data(keep);
            devents=devents(keep);
        end
    
%     %Hack: get random piece of data to check if eyelink events are in there
%     time_win = [5*60 7*60];
%     sample_win = time_win .* fs;
%     trials(1).data=read_buffer_offline_data(datafname,hdr,sample_win);
%     trials(1).sample_win = sample_win;
%     %
    
    %find fixation events within each trial (onset time and gaze position)
    eye_hdr = load(fullfile(code_root,'own_experiments','visual','neglect_project','Common','files','eyelink_hdr.mat'));
    eye_hdr = eye_hdr.hdr;
    fixations = []; %prepare matrix for storing fixation info
    
    for ti=1:numel(data);
        eye_evts = read_eyelink_event(eye_hdr, trials(ti).data);
        types = {eye_evts.evt_type};
        fix_idx = find(strcmp('ENDFIX',types)); %find fixation events
        
        for fi=1:numel(fix_idx) %for all fixations
            fidx = fix_idx(fi);
            time = ([eye_evts(fidx).sttime eye_evts(fidx).entime]/fs); %fixation onset and offset in seconds
            pos = [eye_evts(fidx).gavx eye_evts(fidx).gavy]; %average gaze position during fixation
            fixations = cat(1,fixations,[ti time pos]);
        end
    end

    %save
    save(fullfile(data_root,expt,subj,'Fixation_data'),'fixations');
end

end

