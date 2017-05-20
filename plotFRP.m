function plotFRP(varargin)

% Make and plot FRPs with FieldTrip
%
% Optional input:
%   subidx = indices of subjects to include (default all)
%   mkFRP = compute FRPs (default 1)
%   plotFRP = plot the FRPs (default 1)
%   ch       = channel to plot in single electrode plots (default Cz)
%   topotime = time range for topoplot in seconds (default [.35 .45])
%   save   = save the results (default 1)
%
% Output:
%   fieldtrip structures with FRPs
%   figures with FRP plots
close all;

global data_root;

opts = struct('subidx',[],...
    'mkFRP',1,...
    'plotFRP',1,...
    'ch','Cz',...
    'topotime',[.35 .45],...
    'save',1);
opts = parseOpts(opts, varargin);

%get info
[expt, subjects] = get_exp_info;
if ~isempty(opts.subidx); subjects = subjects(opts.subidx); end %keep only requested subject(s)

%make directory for saving figures
if opts.plotFRP
    figdir = fullfile(data_root,expt,'figs','FRPs');
    if ~isdir(figdir); mkdir(figdir); end
end

for si = 1:numel(subjects);
    subj = subjects{si};
    
    if opts.mkFRP %make FRPs
        fprintf('Loading subsliced data of subject %s...\n',subj);
        try
            load(fullfile(data_root,expt,subj,'prep',[subj '_subsliced']));
        catch
            fprintf('No data found for subj %s \n',subj);
            continue;
        end
        
        %identify 1st target, 2nd target and non-target fixations
        trgt = [z.di(n2d(z,'fixation')).extra.target]; % 1=target, 0=non-target
        times_fixated = [z.di(n2d(z,'fixation')).extra.times_fixated]; % 1=first fixation, 2=second fixation
        fix_len = [z.di(n2d(z,'fixation')).extra.fix_len];
        trgts_first = trgt==1 & times_fixated==1 %& fix_len ==1;
        trgts_second = trgt==1 & times_fixated==2 %& fix_len ==1;
        ntgts = trgt==0 %& fix_len ==1;
        
        %separate z in first targets, second targets and non-targets
        ztrgt_first = jf_retain(z,'dim',3,'idx',trgts_first);
        ztrgt_second = jf_retain(z,'dim',3,'idx',trgts_second);
        zntgt = jf_retain(z,'dim',3,'idx',ntgts);
        
        %convert z-structs to FieldTrip data format
        trgtdata_first=jf2ft(ztrgt_first);
        trgtdata_second=jf2ft(ztrgt_second);
        ntgtdata=jf2ft(zntgt);
        
        %average over trials
        warning off
        disp('Computing FRPs...')
        cfg=[];
        trgtfrp_first=ft_timelockanalysis(cfg,trgtdata_first);
        trgtfrp_first.subj=subj; trgtfrp_first.class='attended target'; trgtfrp_first.dir = z.rootdir;
        trgtfrp_second=ft_timelockanalysis(cfg,trgtdata_second);
        trgtfrp_second.subj=subj; trgtfrp_second.class='unattended target'; trgtfrp_second.dir = z.rootdir;
        ntgtfrp=ft_timelockanalysis(cfg,ntgtdata);
        ntgtfrp.subj=subj; ntgtfrp.class='non-target'; ntgtfrp.dir = z.rootdir;
        warning on
        
        %baseline correction
         cfg.baseline=[-0.2 0];
         trgtfrp_first=ft_timelockbaseline(cfg,trgtfrp_first);
         trgtfrp_second=ft_timelockbaseline(cfg,trgtfrp_second);
         ntgtfrp=ft_timelockbaseline(cfg,ntgtfrp);
        
        %compute target - non-target and first - second fixation difference ERPs
        diff_TvsNT = trgtfrp_first;
        diff_TvsNT.class = 'target - nontarget';
        diff_TvsNT.dimord = 'chan_time';
        diff_TvsNT.avg = trgtfrp_first.avg-ntgtfrp.avg;
        
        diff_1vs2 = trgtfrp_first;
        diff_1vs2.class = 'first fixaton - second fixation';
        diff_1vs2.dimord = 'chan_time';
        diff_1vs2.avg = trgtfrp_first.avg-trgtfrp_second.avg;
        
        %save FRPs
        if opts.save
            disp('Saving FRPs...')
            filedir = fullfile(z.rootdir,'prep');
            if ~isdir(filedir); mkdir(filedir); end
            
            filename=fullfile(filedir,sprintf('%s_FRP_trgt_first.mat',subj));
            frp=trgtfrp_first; save(filename,'frp'); %saving as struct necessary for grand average function
            filename=fullfile(filedir,sprintf('%s_FRP_trgt_second.mat',subj));
            frp=trgtfrp_second; save(filename,'frp');
            filename=fullfile(filedir,sprintf('%s_FRP_ntgt.mat',subj));
            frp=ntgtfrp; save(filename,'frp');
            filename=fullfile(filedir,sprintf('%s_diff_TvsNT.mat',subj));
            frp=diff_TvsNT; save(filename,'frp');
            filename=fullfile(filedir,sprintf('%s_diff_1vs2.mat',subj));
            frp=diff_1vs2; save(filename,'frp');
        end
    else %try to load from file
        fprintf('Loading FRPs of subject %s...\n',subj);
        filedir = fullfile(data_root,expt,subj,'prep');
        try
            load(fullfile(filedir,sprintf('%s_FRP_trgt_first.mat',subj))); trgtfrp_first=frp;
            load(fullfile(filedir,sprintf('%s_FRP_trgt_second.mat',subj))); trgtfrp_second=frp;
            load(fullfile(filedir,sprintf('%s_FRP_ntgt.mat',subj))); ntgtfrp=frp;
            load(fullfile(filedir,sprintf('%s_diff_TvsNT.mat',subj))); diff_TvsNT=frp;
            load(fullfile(filedir,sprintf('%s_diff_1vs2.mat',subj))); diff_1vs2=frp;
        catch
            fprintf('No FRPs found for subj %s \n',subj);
            continue;
        end
    end
    
    %plot
    if opts.plotFRP
       %single channel plot
       clf; hold all
       LineStyleOrder = {'-','--'};
       Linewidth = 1;
       time = trgtfrp_first.time(:,52:180);
       ch = find(strcmp(trgtfrp_first.label,opts.ch));
       
       plot(time,trgtfrp_first.avg(ch,52:180),'color',[1 0 0],'LineStyle',LineStyleOrder{1},'LineWidth',Linewidth);
       plot(time,trgtfrp_second.avg(ch,52:180),'color',[0 0 1],'LineStyle',LineStyleOrder{1},'LineWidth',Linewidth);
       plot(time,ntgtfrp.avg(ch,52:180),'color',[0 0 0],'LineStyle',LineStyleOrder{2},'LineWidth',Linewidth);
       title(sprintf('FRPs of subj %s at %s',subj,opts.ch),'fontsize',14,'fontweight','bold');
       line([time(1) time(end)],[0 0],'color','k','LineWidth',1); %hor axis
       line([0 0],ylim,'color','k','LineWidth',1); %vert axis
       xlabel('time (s)'); ylabel('\muV');
       if opts.save
           saveaspdf(gcf,fullfile(figdir,['Single_FRP_' subj]));
       end
          
       %difference waves
       clf; 
       time = diff_TvsNT.time;
       ch = find(strcmp(diff_TvsNT.label,opts.ch));
       
       plotvals = [];
       plotvals = cat(1,plotvals,diff_TvsNT.avg(ch,:));
       plotvals = cat(1,plotvals,diff_1vs2.avg(ch,:));
       YLim = [floor(min(min(plotvals))*10)/10 ceil(max(max(plotvals))*10)/10]; %round to nearest decimal

       subplot(1,2,1);
       plot(time,diff_TvsNT.avg(ch,:),'color',[0 0 0]);
       line([time(1) time(end)],[0 0],'color','k','LineWidth',1); %hor axis
       line([0 0],YLim,'color','k','LineWidth',1); %vert axis
       xlabel('time (s)'); ylabel('\muV');
       title('Target vs Non-target contrast');
       set(gca,'xlim',[time(1) time(end)],'ylim',YLim);
       
       subplot(1,2,2);
       plot(time,diff_1vs2.avg(ch,:),'color',[0 0 0]);
       line([time(1) time(end)],[0 0],'color','k','LineWidth',1); %hor axis
       line([0 0],YLim,'color','k','LineWidth',1); %vert axis
       xlabel('time (s)'); ylabel('\muV');
       title('First vs Second fixation contrast');
       set(gca,'xlim',[time(1) time(end)],'ylim',YLim);
       
       set(gcf,'position',[5 650 850 350]);
       suptitle(sprintf('FRP difference waves for subj %s',subj));
       
       if opts.save
           saveaspdf(gcf,fullfile(figdir,['Diff_FRP_' subj]));
       end
       
       %topoplots
       close all;
       clf; colormap('default');
       
       time = opts.topotime;
       timeidx = nearest(diff_TvsNT.time,time(1)):nearest(diff_TvsNT.time,time(2));
       
       plotvals = [];
       plotvals = cat(1,plotvals,mean(diff_TvsNT.avg(:,timeidx),2));
       plotvals = cat(1,plotvals,mean(diff_1vs2.avg(:,timeidx),2));
       ZLim = [floor(min(plotvals(:))*10)/10 ceil(max(plotvals(:))*10)/10]; %round to nearest decimal
       
       cfg=[];
       cfg.channel       = 1:32;
       cfg.xlim          = opts.topotime;
       cfg.zlim          = ZLim;
       cfg.colorbar      = 'no';
       cfg.layout        = 'biosemi32.lay';
       cfg.comment       = 'no';
       
       subplot(1,2,1);
       ft_topoplotER(cfg,diff_TvsNT);
       title('Target vs Non-target contrast','FontWeight','bold','VerticalAlignment','top');
       subplot(1,2,2);
       ft_topoplotER(cfg,diff_1vs2);
       title('First vs Second fixation contrast','FontWeight','bold','VerticalAlignment','top');
       
       suptitle(sprintf('FRP differences for subj %s %1.2f-%1.2fs ',subj,opts.topotime));
       c=colorbar;
       
       %layout
       set(gcf,'position',[10 660 640 320])
       hh = get(gcf,'children');
       set(hh(4),'position',[0.05 -0.05 0.4 1]); set(get(hh(4),'title'),'position',[0 0.7 0.5])
       set(hh(2),'position',[0.45 -0.05 0.4 1]); set(get(hh(2),'title'),'position',[0 0.7 0.5])
       set(c,'position',[0.9 0.2 0.03 0.4])
       t=text(0.85,-0.1,'\muV','rotation',90);
       
       if opts.save
           saveaspdf(gcf,fullfile(figdir,['Topo_FRP_' subj]));
       end
 
    end
end