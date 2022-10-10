path='/Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/UKBIOBANK/PRS PREDICT BRAIN STRUCTURE/process_IDPs/';
load([path,'IDPs_freesurfer_DK_data.mat']); %freesurfer
subID2=num2str(eid_with_MRI_freesurfer_DK); %freesurfer
subID2=str2num(subID2);
 
a=zeros(length(dGrp),14); %size of table a
tmp=table();
aa=zeros(length(dGrp),10); %size of table a
for i=1:length(dGrp)
    
    %subject id
    sub1=str2double(subID_all{i});
    sub2=subID_readv2{i};
    sub3=subID_readv3{i};
    
    %combine GP data (readv2 and readv3)
    subID_gp{i}=unique([sub2; sub3]);
    
    %combine three resources
    subID_all_with_GP{i}=unique([sub1;sub2;sub3]);
    
    ind1=zeros(length(sub1),1);
    for ii=1:length(sub1)
        ind1(ii)=find(sub1(ii)==subID_all_with_GP{i});
        %ind1(ii)=find(strcmp(sub1(ii),subID_all_with_GP{i}));
    end
    ind2=zeros(length(sub2),1);
    for ii=1:length(sub2)
        ind2(ii)=find(sub2(ii)==subID_all_with_GP{i});
        %ind2(ii)=find(strcmp(sub2(ii),subID_all_with_GP{i}));
    end
    ind3=zeros(length(sub3),1);
    for ii=1:length(sub3)
        ind3(ii)=find(sub3(ii)==subID_all_with_GP{i});
        %ind3(ii)=find(strcmp(sub3(ii),subID_all_with_GP{i}));
    end
    
    ss=zeros(length(subID_all_with_GP{i}),3);
    ss(ind1,1)=age_diag_all{i};
    ss(ind2,2)=age_readv2{i};
    ss(ind3,3)=age_readv3{i};
    ss(ss<=0)=nan;
    s_min=min(ss,[],2,'omitnan'); % earliest age of diagnosis
    age_diag_all{i}=s_min;
    
    %compare to self report
    subID_comm{i}=intersect(subID_gp{i},str2double(subID_all{i}));
    
    %subjects with brain imaging data
    subID_icd_img{i}=intersect(str2double(subID_icd{i}),subID2);
    subID_gp_img{i}=intersect(subID_gp{i},subID2);
    subID1_img{i}=intersect(str2double(subID_self{i}),subID2);
    subID_all_img{i}=intersect(str2double(subID_all{i}),subID2);
    subID_all_with_GP_img{i}=intersect(subID_all_with_GP{i},subID2);
    [~, img_idx, ~]=intersect(subID_all_with_GP{i},subID2);
    age_diag_all_img{i}=age_diag_all{i}(img_idx);
    subID_comm_img{i}=intersect(subID_comm{i},subID2);
 
    fprintf('\n%s\n',dGrp{i})
    fprintf('Hospital Inpatient (icd): n=%d; brainMRI: n=%d\n',length(subID_icd{i}),length(subID_icd_img{i}));
    fprintf('GP Clinical: n=%d; brainMRI: n=%d\n',length(subID_gp{i}),length(subID_gp_img{i}));
    fprintf('Self report: n=%d; brainMRI: n=%d\n',length(subID_self{i}),length(subID1_img{i}));
    fprintf('Hospital inpatient, gp and self report: n=%d; brainMRI: n=%d\n',length(subID_all_with_GP{i}),length(subID_all_with_GP_img{i}))
    fprintf('Consensus with GP and other sources: n=%d; brainMRI: n=%d\n',length(subID_comm{i}),length(subID_comm_img{i}))
    
    a(i,:)=[length(subID_icd{i}),length(subID_icd_img{i}),length(subID_self{i}),length(subID1_img{i}),...
        length(subID_all{i}),length(subID_all_img{i}),length(subID_comm{i}),length(subID_comm_img{i}),...
        length(subID_gp{i}),length(subID_gp_img{i}),length(subID_all_with_GP{i}),length(subID_all_with_GP_img{i}),length(subID_comm{i}),length(subID_comm_img{i})];
    
    %table for imaging data
    tmp.count(i,:)=[length(subID_icd_img{i}),length(subID1_img{i}),length(subID_gp_img{i}),length(subID_all_with_GP_img{i})];
    tmp.portion(i,:)=([length(subID_icd_img{i}),length(subID1_img{i}),length(subID_gp_img{i}),length(subID_all_with_GP_img{i})]/length(subID2))*100;
    tmp.age_mean(i,:)=nanmean(age_diag_all_img{i});
    tmp.age_std(i,:)=nanstd(age_diag_all_img{i});
    aa(i,:)=[tmp.count(i,1), tmp.portion(i,1), tmp.count(i,2), tmp.portion(i,2), tmp.count(i,3), tmp.portion(i,3), tmp.count(i,4), tmp.portion(i,4),...
       tmp.age_mean(i,:) tmp.age_std(i,:)];
 
end
T1=cell2table(dGrp','VariableNames',{'Disease group'});
T2=array2table(a,'VariableNames',{'Hospital inpatient','Brain MRI1','Self report','Brain MRI2',...
    'Hospital inpatient or self report','Brain MRI3','Hospital inpatient and self report','Brain MRI4',...
    'GP Clinical','Brain MRI5','diagnosis from any source','Brain MRI6','consensus between GP and other sources','Brain MRI7'});
%write out a table 
T=[T1,T2];
writetable(T,'DiseaseGroupSampleSize_freesurfer_includes_GP','FileType','spreadsheet');
 
T3=array2table(aa,'VariableNames',{'Hospital inpatient n','Hospital inpatient %','Self report n','Self report %',...
    'GP Clinical n','GP Clinical %','Diagnosis from any source n','Diagnosis from any source %','Age (mean)','Age (sd)'});
 
T_img=[T1,T3];
writetable(T_img,'DiseaseGroupSampleSize_freesurfer_img_cohort','FileType','spreadsheet');
 
% save DiseaseGroupSubID_06_08_21_Final.mat subID_self subID_icd subID_icd9 subID_icd10 ...
%     subID_comm dGrp age_diag_self age_diag_icd9 age_diag_icd10 ...
%     date_diag_icd9 date_diag_icd10 subID_all age_diag_all ...
%     subID_icd_img subID1_img subID_all_img subID_comm_img
 
save DiseaseGroupSubID_Final_09_08_21.mat age_diag_all subID_all_with_GP dGrp