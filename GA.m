function GA
subj ={'s01','Kristel','Ian_2','Alysha'};
filedir = 'C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation\figs\GA'
    
a=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{1},'prep',[subj{1} '_FRP_trgt_first']));
b=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{2},'prep',[subj{2} '_FRP_trgt_first']));
c=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{3},'prep',[subj{3} '_FRP_trgt_first']));
d=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{4},'prep',[subj{4} '_FRP_trgt_first']));

e=a;
e.frp.avg= (a.frp.avg+b.frp.avg+c.frp.avg+d.frp.avg);
e=e.frp;
e.avg=e.avg/4;
trgtfrp_first=e;
 trgtfrp_first.avg(:,1:52)=[];
 trgtfrp_first.time(:,1:52)=[];
save ('trgt_first_GA','trgtfrp_first');

a=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{1},'prep',[subj{1} '_FRP_trgt_second']));
b=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{2},'prep',[subj{2} '_FRP_trgt_second']));
c=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{3},'prep',[subj{3} '_FRP_trgt_second']));
d=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{4},'prep',[subj{4} '_FRP_trgt_second']));

e=a;
e.frp.avg= (a.frp.avg+b.frp.avg+c.frp.avg+d.frp.avg);
e=e.frp;
e.avg=e.avg/4;
trgtfrp_second=e;
 trgtfrp_second.avg(:,1:52)=[];
 trgtfrp_second.time(:,1:52)=[];
save ('trgt_second_GA','trgtfrp_second');

a=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{1},'prep',[subj{1} '_FRP_ntgt']));
b=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{2},'prep',[subj{2} '_FRP_ntgt']));
c=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{3},'prep',[subj{3} '_FRP_ntgt']));
d=load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation',subj{4},'prep',[subj{4} '_FRP_ntgt']));

e=a;
e.frp.avg= (a.frp.avg+b.frp.avg+c.frp.avg+d.frp.avg);
e=e.frp;
e.avg=e.avg/4;
ntgtfrp=e;
 ntgtfrp.avg(:,1:52)=[];
 ntgtfrp.time(:,1:52)=[];
save ('ntgt_GA','ntgtfrp');

   
       %single channel plot
  for i=1:32
       clf; hold all
       LineStyleOrder = {'-','--'};
       Linewidth = 1;
       time = trgtfrp_first.time;
      

       plot(time,trgtfrp_first.avg(i,:),'color',[1 0 0],'LineStyle',LineStyleOrder{1},'LineWidth',Linewidth);
       plot(time,trgtfrp_second.avg(i,:),'color',[0 0 1],'LineStyle',LineStyleOrder{1},'LineWidth',Linewidth);
       plot(time,ntgtfrp.avg(i,:),'color',[0 0 0],'LineStyle',LineStyleOrder{2},'LineWidth',Linewidth);
       title(sprintf('FRPs grand average at %s',trgtfrp_first.label{i}),'fontsize',14,'fontweight','bold');
       line([time(1) time(end)],[0 0],'color','k','LineWidth',1); %hor axis
       line([0 0],ylim,'color','k','LineWidth',1); %vert axis
       xlabel('time (s)'); ylabel('\muV');
       saveas(gcf,fullfile(filedir,['GA%s',int2str(i),'.jpg']));
       clf
  end
   diff_TvsNT.avg = trgtfrp_first.avg-trgtfrp_second.avg;
   diff_2= trgtfrp_first.avg-ntgtfrp.avg;
   trgtfrp_first.avg =diff_TvsNT.avg;
   trgtfrp_second.avg=diff_2
  cfg=[];
       cfg.channel       = 1:32;
       cfg.colorbar      = 'no';
       cfg.layout        = 'biosemi32.lay';
       cfg.comment       = 'no';
       cfg.xlim          = [.35 .45];
       cfg.parameter     = 'avg';
       subplot(1,2,1);
       ft_topoplotER(cfg, trgtfrp_first);
       title('cancellation vs re-cancellation','FontWeight','bold','VerticalAlignment','top');
       subplot(1,2,2);
       ft_topoplotER(cfg,trgtfrp_second);
       title('target vs non-target','FontWeight','bold','VerticalAlignment','top');
%        if opts.save
%            saveaspdf(gcf,fullfile(figdir,['Single_FRP_' subj]));
%        end
