function Identify_subIDs_gp_clinical(grp_num)

%STEP 4 - can be run in parrallel to 'Identify_SUBIDs_icd_self.m'
%This code will find subject IDs with diagnosis according to GP clinical
%data
%Run this one spartan with case=1...length of disease labels

%inputs:
%icd_diseaseCode_mapped.mat (output from Map_icd_read2_read3.m)
    %to copy this file, open terminal and cd to: /Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/HETEROGENEITY2/Heterogeneity/outputs/Diagnosis
    % then: scp icd_diseaseCode_mapped.mat dibiasem@spartan.hpc.unimelb.edu.au:/home/dibiasem/punim0042/UKBIOBANK/diagnosis_outNew/
%gp_clinical_03_08_21.txt (which is primary care data). These fields are updated regularly
%and can be redownloaded if we have an updated .enc file. Instructions to
%download primary care data are shown in 'primary_care_data.pdf'

%outputs:
%GPdataGrp.mat containing subject IDs with diagnoses according to clinical
%GP data


run('Set_data_path.m');

prompt = "Please specify user for path definition purposes\nFor Maria press 1\nFor Spartan press 2\nFor Hadis press 3\nFor others press 4\n";
x = input(prompt);
%x = 2;

%grp_num=2;
% change paths for the corresponding user
switch x
    case 1
        In_private = In_private_Maria;
        In_open = In_open_Maria;
        path_old_dx = path_old_dx_Maria;
        Out_open = Out_open_Maria;
        Out_private = Out_private_Maria;
    case 2
        In_private = In_private_Spartan;
        In_open = In_open_Spartan;
        Out_open = Out_open_Spartan;
        Out_private = Out_open_Spartan;
    case 3
        In_private = In_private_Hadis;
        In_open = In_open_Hadis;
        path_old_dx = path_old_dx_Hadis;
    otherwise
        In_private = In_private_Other;
        In_open = In_open_Other;
        path_old_dx = path_old_dx_Other;
end


tic;


out=[Out_private,'GPdata/']; % where to save output

dateFile=[In_private,'/data_fields_53_52_34_dates.csv'];
dates=readtable(dateFile);
formatOut='dd/MM/yyyy';
assessment_date=datetime(dates{:,6},'Format',formatOut); %date at first MRI visit
date_MRI_all=assessment_date;
subID=dates{:,1};

%disease code
filename=[Out_open,'icd_diseaseCode_mapped.mat'];
load(filename);


% GP data
dataFile=[In_private,'GP_clinical/gp_clinical_06_10_22.txt'];
ttds = tabularTextDatastore(dataFile,...
    'DatetimeType','text','ReadVariableNames',0);
fprintf('Read datastore\n')
%s=readall(ttds);


% read a block of data at a time
ttds.ReadSize=10^9;
T=0;
while hasdata(ttds)
    s=read(ttds);
    if T==0
        s=s(2:end,[1,3,5,6]);
    else
        s=s(:,[1,3,5,6]);
    end
    data=table2array(s); clear s
    
    %loop over subjects and identify subjects with disease code
    subid=unique(data(:,1));
    
    % subjects of GP data into whole sample
    ind=zeros(length(subid),1);
    for i=1:length(ind)
        ind(i)=find(str2double(subid{i})==subID);
    end
    date_MRI=date_MRI_all(ind);
    
    %%%%%%
    fprintf('Loop over disease group\n')
    %i=str2double(grp_num); %1:length(dx_labels)
    i=grp_num;
    fprintf('%s\n',dx_labels{i});
    subv2=[];
    datev2=[];
    
    subv3=[];
    datev3=[];
    frst=0;
    for j=1:length(subid)
        
        %each subject has multiple records
        ind_sub=find(strcmp(subid{j},data(:,1)));
        date=data(ind_sub,2);
        
        %read v2
        v2=data(ind_sub,3);
        ind2=find(contains(v2,readv2{i}));
        if ~isempty(ind2)
            
            %date of diagnosis
            datev2tmp=date(ind2);
            
            %number of days between diagnosis and MRI measures
            datev2tmp=datev2tmp(~cellfun(@isempty,datev2tmp)); %delete potential empty entries
            
            if ~isempty(datev2tmp)
                numdays_v2=datenum(datev2tmp,formatOut)-datenum(date_MRI(j));
                
                %choose the earliest one
                [~,ind_min]=min(numdays_v2);
                
                datev2=[datev2;datev2tmp(ind_min)];
                
                %subid
                subv2=[subv2;str2double(subid{j})];
            else
                fprintf ('Read V2: Remove subject %d,ID:%s\n',j,subid{j})
            end
        end
        
        %read v3
        v3=data(ind_sub,4);
        ind3=find(contains(v3,readv3{i}));
        if ~isempty(ind3)
            
            %date of diagnosis
            datev3tmp=date(ind3);
            
            %number of days between diagnosis and MRI measures
            datev3tmp=datev3tmp(~cellfun(@isempty,datev3tmp)); %delete potential empty entries
            
            if ~isempty(datev3tmp)
                numdays_v3=datenum(datev3tmp,formatOut)-datenum(date_MRI(j));
                
                %choose the earliest one
                [~,ind_min]=min(numdays_v3);
                
                datev3=[datev3;datev3tmp(ind_min)];
                
                %subid
                subv3=[subv3;str2double(subid{j})];
            else
                fprintf ('Read v3: Remove subject %d,ID:%s\n',j,subid{j})
            end
        end
        show_progress(j,length(subid),frst);frst=1;
    end
    subID_readv2{i}=subv2;
    date_completed_readv2{i}=datev2;
    
    subID_readv3{i}=subv3;
    date_completed_readv3{i}=datev3;
    subID_completed_gp = subid;
 
    T=T+1;
    save([out,'subID_GPClinical',num2str(i),'_block',num2str(T),'.mat'],...
        'subID_readv2','date_completed_readv2','subID_readv3','date_completed_readv3','subID_completed_gp')
    fprintf('Complete data block %d, block size=%d\n\n',T,ttds.ReadSize)
    

    
end
toc;