%STEP 4%

% RUN IN PARALLEL (on spartan)

%This code will identify subject IDs with any one of the diagnoses 
%Takes ~4h to run locally  
%modify line 26 to s=read(ttds) if just testing code (this will read 1
%block of data)

%inputs:
%icd_diseaseCode_mapped.mat from Map_icd_read2_read3.m
%medical_data.csv (containing datafields as specified in the 'medical
%condition' spreadsheet: https://biobank.ndph.ox.ac.uk/showcase/codown.cgi 

%outputs:
%spreadsheet containing DiseaseGroupSampleSize
%DiseaseGroupSubID_06_08_21.mat which contains subject IDs for each
%diagnosis

clear all
close all

asrb=0;
run('Set_data_path.m');

prompt = "Please specify user for path definition purposes\nFor Maria press 1\nFor Ye press 2\nFor Hadis press 3\nFor others press 4\n";
x = input(prompt);


% change paths for the corresponding user
switch x
    case 1
        In_private = In_private_Maria;
        In_open = In_open_Maria;
        path_old_dx = path_old_dx_Maria;
        Out_open = Out_open_Maria;
        Out_private = Out_private_Maria;
    case 2
        In_private = In_private_Ye;
        In_open = In_open_Ye;
        path_old_dx = path_old_dx_Ye;
    case 3
        In_private = In_private_Hadis;
        In_open = In_open_Hadis;
        path_old_dx = path_old_dx_Hadis;
        Out_open = Out_open_Hadis;
        Out_private = Out_private_Hadis;
    otherwise
        In_private = In_private_Other;
        In_open = In_open_Other;
        path_old_dx = path_old_dx_Other;
end

load([Out_open,'icd_diseaseCode_mapped.mat']);
dataFile=[In_private,'medical_data. csv'];
ttds = datastore(dataFile,...
    'DatetimeType','text','ReadVariableNames',0);
fprintf('Read datastore\n');


s=readall(ttds); %use s=read(ttds) if just testing;
% s=read(ttds);

% % subjects with self-report diagnoses - non-cancer
ind=find(contains(s{1,:},'20002-0.')==1);
subID=str2double(s{2:end,1});
num_self=s{2:end,ind};

ind=find(contains(s{1,:},'20009-0.')==1);
age_self=s{2:end,ind};

ind_healthy_self_noncancer = [];
for i=1:length(code_self_v2)
    code=code_self_v2{i};
    
    ind_sub=[];
    age_tmp=[];
    for j=1:size(num_self,1) % loop over subjects
        if i==1 && size(num_self{j},1) == 0
            ind_healthy_self_noncancer = [ind_healthy_self_noncancer; j];
        end
        x=num_self(j,:);
%         x=str2double(x);
        val=intersect(x,code);
        if ~isempty(val)
            ind_sub=[ind_sub,j];
            %find the index of val in x
            ind_x=zeros(length(val),1);
            for jj=1:length(ind_x)
                ind_x(jj)=find(val(jj)==x,1);
            end
            a=age_self(j,ind_x);% age of diagnosis of subject j
            a=str2double(a);
            a=min(a); %chose the earliest time
            age_tmp=[age_tmp;a];
        end
    end
    subID_dx_self{i}=subID(ind_sub);
    age_diag_self{i}=age_tmp;
    fprintf('%s: n=%d\n\n',dx_labels{i},length(subID_dx_self{i}));
end

%%%%%
% self-reported cancer
ind=find(contains(s{1,:},'20001-0.')==1);
num=s{2:end,ind};

%find the corresponding column for cancer in data
[num_labels,txt_labels,raw_labels]=xlsread([In_open,'Diseases_of_interest.xlsx']);
dx_labels=txt_labels(2:end,1);
dx_organ=txt_labels(2:end,2);
dx_system=txt_labels(2:end,3);
newpat = caseInsensitivePattern("Cancer");
ind_cancer_label=find(contains(dx_labels,newpat)==1);

%number of self-reported cancers
ind_cancer=find(contains(s{1,:},'134-0.')==1);
ind_cancer2=str2double(s{2:end,ind_cancer});
ind_cancer3=find(ind_cancer2>0);%number of self-reported cancer
ind_healthy_self_cancer = find(ind_cancer2<1);

subID_cancer=subID(ind_cancer3);
subID_dx_self{ind_cancer_label}=subID_cancer;

%age of cancer when first diagnosed
ind=find(contains(s{1,:},'20007-0.')==1);
num_age=s{2:end,ind};
num_age=str2double(num_age);


ind_healthy_self=intersect(ind_healthy_self_cancer, ind_healthy_self_noncancer);
subID_healthy_self=subID(ind_healthy_self);

age_cancer=min(num_age,[],2);
ind_nonan=find(~isnan(age_cancer));
age_cancer=age_cancer(ind_nonan);
age_completed_self{ind_cancer_label}=age_cancer; % -1=uncertain or unknown

clear num
%%%%%

%subjects with icd 9 coded diagnoses
fprintf('\nICD 9 diagnoses\n')
ind=find(contains(s{1,:},'41271')==1);
num=s{2:end,ind};
num_icd9=string(num);
header=s(1,ind);


%date of icd 9 diagnosis
ind=find(contains(s{1,:},'41281-0.')==1);
formatOut='dd/MM/yyyy';
%date_icd9=table2array(s(2:end,ind));
dates=s{2:end,ind};
date_icd9=datetime(dates,'Format',formatOut); 


%Date of assessment
dateFile=[In_private,'data_fields_53_52_34_dates.csv'];

ttds = datastore(dateFile,...
    'DatetimeType','text','ReadVariableNames',0);
fprintf('Read datastore\n');
dates=readall(ttds);
dates_header=dates(1,:);
dates=dates(2:end,:);
assessment_date_baseline=datetime(dates{:,4},'Format',formatOut); %date at first MRI visit
assessment_date_MRI_visit_1=datetime(dates{:,6},'Format',formatOut); %date at first MRI visit
assessment_date_MRI_visit_2=datetime(dates{:,7},'Format',formatOut); %date at first MRI visit

%date of birth
birth_year=str2double(dates{:,2});
birth_month=str2double(dates{:,3});
birth_day=15*ones(length(birth_month),1);
date_birth=datetime(birth_year,birth_month,birth_day,'Format',formatOut);

%age of icd 9 diagnosis
[rx, cx]=find(~isnat(date_icd9));
numdays=zeros(size(date_icd9));
for ii=1:length(rx)
    numdays(rx(ii),cx(ii))=datenum(date_icd9(rx(ii),cx(ii)))-datenum(date_birth(rx(ii)));
end
age_icd9=numdays./365; clear numdays
age_icd9(age_icd9==0)=nan;

% % age of diagnosis
for i=1:length(code_icd9) % loop over diseases
    code=code_icd9{i};
    
    ind_sub=[];
    age_tmp=[];
    date_icd9_tmp=[];
    for j=1:size(num_icd9,1) % loop over subjects
        x=num_icd9(j,:);
        val=intersect(x,code);
        if ~isempty(val)
            ind_sub=[ind_sub,j];
            
            %find the index of val in x
            ind_x=zeros(length(val),1);
            for jj=1:length(ind_x)
                ind_x(jj)=find(val(jj)==x);
            end
            
            % choose the earliest date
            numdays=datenum(date_icd9(j,ind_x))-datenum(assessment_date_baseline(j));
            [~,ind_min]=min(numdays);
            d=date_icd9(j,ind_x);
            d=d(ind_min);
            date_icd9_tmp=[date_icd9_tmp;d];
            
            % age of diagnosis of subject j
            a=age_icd9(j,ind_x);
            a=a(ind_min);%chose the earliest time
            age_tmp=[age_tmp;a];
        end
    end
    subID_dx_icd9{i}=subID(ind_sub);
    age_diag_icd9{i}=age_tmp;
    date_completed_icd9{i}=date_icd9_tmp;
    fprintf('%s: n=%d\n\n',dx_labels{i},length(subID_dx_icd9{i}));   
end

%subjects with icd 10 coded diagnoses
fprintf('\nICD 10 diagnoses\n')
ind=find(contains(s{1,:},'41270')==1);
txt_icd10=s{2:end,ind};
num_icd10 = string(txt_icd10);
header=s(1,ind);

%date of icd 10 diagnosis
ind=find(contains(s{1,:},'41280-0.')==1);
formatOut='dd/MM/yyyy';
dates=s{2:end,ind};
date_icd10=datetime(dates,'Format',formatOut); 


%age of icd 10 diagnosis
[rx, cx]=find(~isnat(date_icd10));
numdays=zeros(size(date_icd10));
for ii=1:length(rx)
    numdays(rx(ii),cx(ii))=datenum(date_icd10(rx(ii),cx(ii)))-datenum(date_birth(rx(ii)));
end
age_icd10=numdays./365; clear numdays
age_icd10(age_icd10==0)=nan;

for i=1:length(code_icd10)
    code=code_icd10{i};%disease code
    
    ind_sub=[];
    age_tmp=[];
    date_icd10_tmp=[];
    for j=1:size(txt_icd10,1)%loop over subjects
        x=txt_icd10(j,:);
        
        %compare each value in icd 10 code with subject's codes
        ind_x=[];
        for ii=1:length(code)
            ind_x=[ind_x,find(contains(x,code{ii}))];
        end
        if ~isempty(ind_x)
            ind_sub=[ind_sub,j];
            
            % choose the earliest date
            numdays=datenum(date_icd10(j,ind_x))-datenum(assessment_date_baseline(j));
            [~,ind_min]=min(numdays);
            d=date_icd10(j,ind_x);
            d=d(ind_min);
            date_icd10_tmp=[date_icd10_tmp;d];
            
            % age of diagnosis of subject j
            a=age_icd10(j,ind_x);
            a=a(ind_min); %chose the earliest time
            age_tmp=[age_tmp;a];
        end 
    end
    subID_dx_icd10{i}=subID(ind_sub);
    age_diag_icd10{i}=age_tmp;
    date_completed_icd10{i}=date_icd10_tmp;
    fprintf('%s: n=%d\n\n',dx_labels{i},length(subID_dx_icd10{i}));
end

% % Find consistent diagnoses between self report and hospital record
% % load subjects with brain imaging
% path='/Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/UKBIOBANK/PRS PREDICT BRAIN STRUCTURE/process_IDPs/';
% load([path,'IDPs_freesurfer_DK_data.mat']);
% subID2=num2str(eid_with_MRI_freesurfer_DK);
% % load([path,'IDPs_dMRI_data.mat'])
% % subID2=num2str(eid_with_MRI_DTI);
% 
% a=zeros(length(dx_labels),8);
% for i=1:length(dx_labels)
%     
%     %subject id
%     sub1=subID_dx_self{i};
%     sub2=subID_dx_icd9{i};
%     sub3=subID_dx_icd10{i};
%     
%     %combine icd9 and icd10
%     subs_icd{i}=unique([sub2;sub3]);
%     
%     %combine three resources
%     subs_all{i}=unique([sub1;sub2;sub3]);
%     
%     ind1=zeros(length(sub1),1);
%     for ii=1:length(sub1)
%         %ind1(ii)=find(sub1(ii)==subs_all{i});
%         ind1(ii)=find(strcmp(sub1(ii),subs_all{i}));
%     end
%     ind2=zeros(length(sub2),1);
%     for ii=1:length(sub2)
%         %ind2(ii)=find(sub2(ii)==subs_all{i});
%         ind2(ii)=find(strcmp(sub2(ii),subs_all{i}));
%     end
%     ind3=zeros(length(sub3),1);
%     for ii=1:length(sub3)
%         %ind3(ii)=find(sub3(ii)==subs_all{i});
%         ind3(ii)=find(strcmp(sub3(ii),subs_all{i}));
%     end
%     
%     ss=zeros(length(subs_all{i}),3);
%     ss(ind1,1)=age_diag_self{i};
%     ss(ind2,2)=age_diag_icd9{i};
%     ss(ind3,3)=age_diag_icd10{i};
%     ss(ss<=0)=nan;
%     s_min=min(ss,[],2,'omitnan'); % earliest age of diagnosis
%     age_diag_all{i}=s_min;
%     
%     %compare to self report
%     subs_comm{i}=intersect(subs_icd{i},sub1);
%     
%  end


%ICD9 and ICD10 healthy - subjects without any diagnoses
ind_healthy_icd9=find(all(num_icd9=='',2)); %index of subjects with empty codes
ind_healthy_icd10 = find(all(num_icd10=='',2)); %index of subjects with empty codes
subID_healthy_icd9=subID(ind_healthy_icd9);
subID_healthy_icd10=subID(ind_healthy_icd10);
ind_healthy_icd=intersect(ind_healthy_icd9,ind_healthy_icd10);
subID_healthy_icd=subID(ind_healthy_icd);


filename = [Out_private, 'subID_icd_self.mat'];
 save(filename,'dx_labels','dx_organ','dx_system',...
    'subID_healthy_icd9','subID_healthy_icd10','subID_healthy_self',...
    'subID_dx_icd9','subID_dx_icd10','subID_dx_self',...
    'date_completed_icd9','date_completed_icd10','age_diag_self', ...
    'age_diag_icd9', 'age_diag_icd10');
