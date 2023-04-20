clear all 
close all
 
asrb=0;

%This code will combine subject IDs and dates from clinical GP data with
%other data (from self report, icd9, icd10 and MHQ)
 
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
        In_private = In_private_Spartan;
        In_open = In_open_Spartan;
        Out_open = Out_open_Spartan;
        Out_private = Out_open_Spartan;
    case 3
        In_private = In_private_Hadis;
        In_open = In_open_Hadis;
        path_old_dx = path_old_dx_Hadis;
        ut_open = Out_open_Hadis;
        Out_private = Out_private_Hadis;
    otherwise
        In_private = In_private_Other;
        In_open = In_open_Other;
        path_old_dx = path_old_dx_Other;
end
 

load([Out_private,'GPdata_all.mat']);

grp_num=158;
%remove duplicate IDs and retain earliest diagnosis
%read v2
for g=1:grp_num
    A = subID_readv2{g};
    [n, bin] = histc(A, unique(A));
    multiple = find(n > 1);
    index    = find(ismember(bin, multiple));
    
    if ~isempty(index)
        
        for ii=1:length(index)
            a=split(date_completed_readv2{g}{index(ii)},"/");
            b(ii)=str2double(a(3));
        end
        
        ind1=find(min(b));
        ind=find(b~=b(ind1));
        clear b
        
        date_completed_readv2{g}(index(ind))=[];
        subID_readv2{g}(index(ind))=[];
    end
end
 

%remove duplicate IDs and retain earliest diagnosis
%read v3
for g=1:grp_num
    A = subID_readv3{g};
    [n, bin] = histc(A, unique(A));
    multiple = find(n > 1);
    index    = find(ismember(bin, multiple));
    
    if ~isempty(index)
        
        for ii=1:length(index)
            a=split(date_completed_readv3{g}{index(ii)},"/");
            b(ii)=str2double(a(3));
        end
        
        ind1=find(min(b));
        ind=find(b~=b(ind1));
        clear b
        
        date_completed_readv3{g}(index(ind))=[];
        subID_readv3{g}(index(ind))=[];
    end
end
 
 
dateFile=[In_private,'data_fields_53_52_34_dates.csv'];
 
%age of BP diagnosis - readv2
ttds = datastore(dateFile,...
    'DatetimeType','text','ReadVariableNames',0);
fprintf('Read datastore\n');
dates=readall(ttds);
eid_dates=str2double(dates{2:end,1});
dates_header=dates(1,:);
dates=dates(2:end,:);
 
%date of birth
birth_year=str2double(dates{:,2});
birth_month=str2double(dates{:,3});
birth_day=15*ones(length(birth_month),1);
formatOut='dd/MM/yyyy';
date_birth=datetime(birth_year,birth_month,birth_day,'Format',formatOut);
 
 
for i=1:grp_num
    [a, b, c]=intersect(eid_dates,subID_readv2{i});
    date_birth_cmp_readv2{i}=date_birth(b);
    
    [a, b, c]=intersect(eid_dates,subID_readv3{i});
    date_birth_cmp_readv3{i}=date_birth(b);
end
 
%age at diagnosis GP data
 
for g=1:grp_num
    
    %readv2
    if ~isempty(date_completed_readv2{g})
        date_completed_readv2_con=datetime(date_completed_readv2{g},'InputFormat',formatOut);
        [rx, cx]=find(~isnat(date_completed_readv2_con));
        numdays=zeros(size(date_completed_readv2_con));
        for ii=1:length(rx)
            numdays(rx(ii),cx(ii))=datenum(date_completed_readv2_con(rx(ii),cx(ii)))-datenum(date_birth(rx(ii)));
        end
        age_readv2{g}=numdays./365; clear numdays
        
        %remove ages that don't make sense
        ind=find(age_readv2{g}<0);
        age_readv2{g}(ind)=NaN;
    end
    
    %readv3
    if ~isempty(date_completed_readv3{g})
        date_completed_readv3_con=datetime(date_completed_readv3{g},'InputFormat',formatOut);
        [rx, cx]=find(~isnat(date_completed_readv3_con));
        numdays=zeros(size(date_completed_readv3_con));
        for ii=1:length(rx)
            numdays(rx(ii),cx(ii))=datenum(date_completed_readv3_con(rx(ii),cx(ii)))-datenum(date_birth(rx(ii)));
        end
        age_readv3{g}=numdays./365; clear numdays
        
        %remove ages that don't make sense
        ind=find(age_readv3{g}<0);
        age_readv3{g}(ind)=NaN;
    end
end
 
 
%NEED TO COMBINE WITH MHQ, ICD9,10 and self
 
filename = [Out_private, 'subID_icd_self'];
load(filename);

filename = [Out_private, 'subID_mhq.mat'];
load(filename);
date_dx_mhq = date_dx_mhq';


subID_self = subID_dx_self;
subID_icd9 = subID_dx_icd9;
subID_icd10 = subID_dx_icd10;
subID_mhq = subID_dx_mhq';
date_diag_icd9 = date_completed_icd9;
date_diag_icd10 = date_completed_icd10;
date_diag_mhq = date_completed_mhq;

date_birth=datetime(birth_year,birth_month,birth_day,'Format',formatOut);

for i=1:size(date_diag_icd9,2)
    if ~isempty(date_diag_icd9{i})
        [rx, cx]=find(~isnat(date_diag_icd9{i}));
        numdays=zeros(size(date_diag_icd9{i}));
        for ii=1:length(rx)
            numdays(rx(ii),cx(ii))=datenum(date_diag_icd9{i}(rx(ii),cx(ii)))-datenum(date_birth(rx(ii)));
        end
        age_diag_icd9{i}=numdays./365; clear numdays
        age_diag_icd9{i}(age_diag_icd9{i}==0)=nan;
    end
end

for i=1:size(date_diag_icd10,2)
    if ~isempty(date_diag_icd10{i})
        [rx, cx]=find(~isnat(date_diag_icd10{i}));
        numdays=zeros(size(date_diag_icd10{i}));
        for ii=1:length(rx)
            numdays(rx(ii),cx(ii))=datenum(date_diag_icd10{i}(rx(ii),cx(ii)))-datenum(date_birth(rx(ii)));
        end
        age_diag_icd10{i}=numdays./365; clear numdays
        age_diag_icd10{i}(age_diag_icd10{i}==0)=nan;
    end
end


for i=1:size(date_dx_mhq,2)
    if ~isempty(date_dx_mhq{i})
        [rx, cx]=find(~isnat(date_dx_mhq{i}));
        numdays=zeros(size(date_dx_mhq{i}));
        for ii=1:length(rx)
            numdays(rx(ii),cx(ii))=datenum(date_dx_mhq{i}(rx(ii),cx(ii)))-datenum(date_birth(rx(ii)));
        end
        age_diag_mhq{i}=numdays./365; clear numdays
        age_diag_mhq{i}(age_diag_mhq{i}==0)=nan;
    else
        age_diag_mhq{i} = [];
    end

end


for i=1:size(subID_icd9,2) %looping over dx_labels 
    
    subID_icd{i}=[subID_icd9{i}; subID_icd10{i}];
    
    %index and removedduplicated codes
    [~, dup]=unique(subID_icd{i});
    subID_icd{i}=subID_icd{i}(dup);
    

    subID_all{i} = [subID_icd9{i}; subID_icd10{i}; subID_self{i}; subID_readv2{i}; subID_readv3{i}; subID_mhq{i}];
    age_readv2{i} = [];
    age_readv3{i} = [];
    if ~isempty(subID_readv2{i})
        age_readv2{i} = calyears(between(date_birth_cmp_readv2{i}, date_completed_readv2{i}));
        
    end
    if ~isempty(subID_readv3{i})
        age_readv3{i} = calyears(between(date_birth_cmp_readv3{i}, date_completed_readv3{i}));
    end

    age_diag_all{i} = [age_diag_icd9{i}; age_diag_icd10{i}; age_diag_self{i}; age_readv2{i}; age_readv3{i}; age_diag_mhq{i}];

    %index and removedduplicated codes
    [~, dup]=unique(subID_all{i});
    subID_all{i}=subID_all{i}(dup);
    age_diag_all{i}=age_diag_all{i}(dup);
    
end

subID_healthy_icd_self = intersect(intersect(subID_healthy_icd9, subID_healthy_icd10), subID_healthy_self);
subID_readv2_v3_vec=[];
subID_mhq_vec=[];
for i=1:size(subID_readv2,2)
    subID_readv2_v3_vec = [subID_readv2_v3_vec; subID_readv2{i}; subID_readv3{i}];
    subID_mhq_vec = [subID_mhq_vec; subID_mhq{i}];
end
%index and removedduplicated codes
[~, dup]=unique(subID_readv2_v3_vec);
subID_readv2_v3_vec=subID_readv2_v3_vec(dup);

%healthy ones wihtout anycodes
subID_healthy = setdiff(subID_healthy_icd_self, subID_mhq_vec); 
subID_healthy_icd_self_mhq = subID_healthy; 
subID_healthy = setdiff(subID_healthy, subID_readv2_v3_vec); 

% identify healthy individuals
[~,~,raw]=xlsread([In_open,'Diseases_of_interest.xlsx'],'Alt_label');
included_project_maria=raw(2:end, 2);
included_project_hadis=raw(2:end, 3);


unhealthy_maria = [];
unhealthy_hadis = [];
for i=1:length(dx_labels)
    if included_project_maria{i} ==1
        unhealthy_maria = [unhealthy_maria subID_all{i}];
    end
    if included_project_hadis{i}==1
        unhealthy_hadis = [unhealthy_hadis subID_all{i}];
    end
end

unhealthy_maria=unique(unhealthy_maria);
unhealthy_hadis=unique(unhealthy_hadis);
ind_unhealthy_maria=intersect(subID,unhealthy_maria);
ind_unhealthy_hadis=intersect(subID,unhealthy_hadis);
subID_healthy_maria = setdiff(subID, subID(ind_unhealthy_maria));
subID_healthy_hadis = setdiff(subID, subID(ind_unhealthy_hadis));


filename = [Out_private, 'DiseaseGroupSubID.mat'];
save(filename,  ...
    'subID_self', 'subID_icd', 'subID_icd9', 'subID_icd10', 'subID_mhq', 'subID_all', ...
    'age_diag_self', 'age_diag_icd9', 'age_diag_icd10', 'age_diag_mhq', 'age_diag_all', ...
    'date_diag_icd9', 'date_diag_icd10',   ...
    'subID_healthy', 'dx_labels', 'dx_organ', 'dx_system', 'subID_healthy_icd_self_mhq', ...
    'subID_healthy_maria', 'subID_healthy_hadis');
 
