function [significances]=anova_testing
subj={'s01', 'Kristel','Ian_2', 'Alysha'};
for j=1:32
    data1=[];
    data2=[];
    data=[];
    for i=1:4;
        load(fullfile('C:\Users\Beheerder\School\KI\Scriptie\bci_code.git\own_experiments\visual\neglect_project\FRP_recancellation\',subj{i},'prep',[subj{i} '_subsliced']));
        z = jf_subsample(z,'fs',32);
        z.X(:,1:6,:)=[];
        a=z.X(j,:,:);
        a=reshape(a,size(a,2),size (a,3));
        b=z.di(3).extra;
        b=struct2cell(b);
        b=reshape(b,size(b,1),size(b,3));
        b=cell2mat(b);
        c=[a',b'];
        c(c(:,18)==0,:)=[];
        %c(c(:,20)==0,:)=[];
        x=c(:,1:16);
        y=c(:,19);
        data1= [data1;x];
        data2= [data2;y];
        data = [data;c];    
    end
    for ii=1:16
         sig(ii)=anova1(data1(:,ii)',data2,'off');
    end
    significances(:,j)=sig;
%     filename= strcat('channel ',int2str(j));
%     xlswrite(filename,data);
end

significant_samples=significances < 0.05;
