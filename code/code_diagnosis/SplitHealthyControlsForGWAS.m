
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
        Out_private = Out_private_Maria;
    case 2
        In_private = In_private_Ye;
        In_open = In_open_Ye;
        path_old_dx = path_old_dx_Ye;
    case 3
        In_private = In_private_Hadis;
        In_open = In_open_Hadis;
        Out_private = Out_private_Hadis;
    otherwise
        In_private = In_private_Other;
        Out_private = Out_private_Other;
end


%load EIDs of subjects with both genetics and biochemical data
load([Out_private 'plot_data.mat']);

%load EIDs of subjects that meet genetic QC
eid_qc_passed=readtable([In_private, 'QC_passed_samples.csv']);
eid_qc_passed=eid_qc_passed{:,1};

%find intersect
eid_qc_passed_biochemical_genetics = intersect(eid_qc_passed, eid_with_biochemical_genetics);

%load demographic data 
load([Out_private, 'DiseaseGroupSubID.mat']);

%find age and sex of subjects that meet 3 conditions (i.e., those with genetics and
%biochem and that passed genetic QC)

%sex 

dateFile=[In_private,'mb1958_Sample-QC.csv'];
 
ttds = datastore(dateFile,...
    'DatetimeType','text','ReadVariableNames',0);
fprintf('Read datastore\n');
dates=readall(ttds);
dates_header=dates(1,:);
dates=dates(2:end,:);
subID_qc_table=str2num(cell2mat(table2array(dates(:, 1))));
A=string(table2array(dates(:, 3)));
A(A=="") = "-1";
sex_qc_table =str2double(A);



% age
dateFile=[In_private,'data_fields_53_52_34_dates.csv'];
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
assessment_date_baseline=datetime(dates{:,4},'Format',formatOut); %date at assessment

age_qc_table = calyears(between(date_birth, assessment_date_baseline));


control_groups = {};
control_groups_labels = [{'Control_1_subID_GWAS'; 'Control_1_age_GWAS'; 'Control_1_sex_GWAS';...
                          'Control_2_subID_imaging'; 'Control_2_age_imaging'; 'Control_2_sex_imaging';...
                          'Control_3_subID_genetic'; 'Control_3_age_genetic'; 'Control_3_sex_genetic';...
                          'Control_4_subID_imaging_genetics'; 'Control_4_age_imaging_genetics'; 'Control_4_sex_imaging_genetics';...
                          'Control_5_subID_biochemical'; 'Control_5_age_biochemical'; 'Control_5_sex_biochemical';...
                          'Control_6_subID_biochemical_genetics'; 'Control_6_age_biochemical_genetics'; 'Control_6_sex_biochemical_genetics';...
                          'Control_7_subID__biochemical_genetics_imaging'; 'Control_7_age_biochemical_genetics_imaging'; 'Control_7_sex_biochemical_genetics_imaging'}];


% define control group 1

subID_healthy_qc_passed = intersect(subID_healthy_maria, eid_qc_passed);

for i=1:size(eid_with_biochemical,2)
    subID_healthy_biochemical = intersect(subID_healthy_qc_passed, eid_with_biochemical{i});
    ID = setdiff(subID_healthy_biochemical, eid_with_MRI_freesurfer_DK);
    
    random_indexes = randperm(length(ID));
    ID_group1 = ID(random_indexes(1:40000));
    [~, ind, ~] = intersect(eid_with_genetics, ID_group1);

    control_groups{1,i} = ID_group1;
    control_groups{2,i} = age_with_genetics(ind);
    control_groups{3,i} = sex_with_genetics(ind);
end

control_group1 = control_groups{1,1};
for i=2:size(eid_with_biochemical,2)
    control_group1 = union(control_group1, control_groups{1,i});
end

% define control group 2

[ID_healthy_imaging, ~, ind] = intersect(subID_healthy_maria, eid_with_MRI_freesurfer_DK);
control_groups{4,1} = ID_healthy_imaging;
control_groups{5,1} = age_with_MRI_freesurfer_DK(ind);
control_groups{6,1} = sex_with_MRI_freesurfer_DK(ind);


% define control group 3

ID_group3 = setdiff(subID_healthy_qc_passed,control_group1);
[~, ind, ~] = intersect(eid_with_genetics, ID_group3);
control_groups{7,1} = ID_group3;
control_groups{8,1} = age_with_genetics(ind);
control_groups{9,1} = sex_with_genetics(ind);

% define group 4
ID_group4 = intersect(subID_healthy_qc_passed, eid_with_MRI_freesurfer_DK_genetics);
ID_group4 = setdiff(ID_group4, control_group1);
[~, ind, ~] = intersect(eid_with_MRI_freesurfer_DK_genetics, ID_group4);
control_groups{10,1} = ID_group4;
control_groups{11,1} = age_with_MRI_freesurfer_DK_genetics(ind);
control_groups{12,1} = sex_with_MRI_freesurfer_DK_genetics(ind);

% define group 5
for i=1:size(eid_with_biochemical,2)
    ID_group_pre = intersect(subID_healthy_maria, eid_with_biochemical{i});
    ID_group5 = setdiff(ID_group_pre, control_groups{1,i});
    [~, ind, ~] = intersect(ID_group5, subID_qc_table);
    control_groups{13,i} = ID_group5;
    control_groups{14,i} = age_qc_table(ind);
    control_groups{15,i} = sex_qc_table(ind);
end


% define group 6
for i=1:size(eid_with_biochemical,2)
    ID_group6 = intersect(subID_healthy_qc_passed, eid_with_biochemical{i});
    ID_group6 = setdiff(ID_group6, control_groups{1,i});

    [~, ind, ~] = intersect(ID_group6, subID_qc_table);
    control_groups{16,i} = ID_group6;
    control_groups{17,i} = age_qc_table(ind);
    control_groups{18,i} = sex_qc_table(ind);
end


control_group6 = control_groups{16,1};
for i=2:size(eid_with_biochemical,2)
    control_group6 = intersect(control_group6, control_groups{16,i});
end

% define group 7
subID_healthy_qc_passed_MRI_genetics = intersect(subID_healthy_qc_passed, eid_with_MRI_freesurfer_DK_genetics);
for i=1:size(eid_with_biochemical,2)
    ID_group7 = intersect(subID_healthy_qc_passed_MRI_genetics, eid_with_biochemical{i});
    ID_group7 = setdiff(ID_group7, control_groups{1,i});

    [~, ind, ~] = intersect(ID_group7, eid_with_MRI_freesurfer_DK_genetics);
    control_groups{19,i} = ID_group7;
    control_groups{20,i} = age_with_MRI_freesurfer_DK_genetics(ind);
    control_groups{21,i} = sex_with_MRI_freesurfer_DK_genetics(ind);
end

control_group7 = control_groups{19,1};
for i=2:size(eid_with_biochemical,2)
    control_group7 = intersect(control_group7, control_groups{19,i});
end


% split the healthy controls into 2 groups:

% group1 = GWAS 
% group2 = PRS analyses

% Example data
% ID = [1 2 3 4 5 6 7 8 9];
% age = [25 33 20 28 30 24 26 29 27];
% sex = [1 0 1 1 0 0 1 1 0];

% Split into two groups based on age and sex, with group1 having length of 50 thousand and group2 having the remaining data
% group1 = [];
% group2 = [];
% while isempty(group1) || isempty(group2) || abs(mean(age(group1)) - mean(age(group2))) > 0.5 || abs(std(age(group1)) - std(age(group2))) > 0.5
%     % Shuffle the ID vector
%     indexes = randperm(length(ID));    
%     % Split the shuffled ID vector into two groups with equal number of sex==0 and sex==1
%     group1 = indexes(sex(indexes)==1);
%     group2 = indexes(sex(indexes)==0);
%     % Truncate group1 to have length of 50 thousand for GWAS
%     if length(group1) > 20000
%         group1 = group1(1:20000);
%     end
% end

% while isempty(group1) || isempty(group2) || std(age(group2)) < 5
%     % Shuffle the ID vector
%     indexes = randperm(length(ID));    
%     % Split the shuffled ID vector into two groups with equal number of sex==0 and sex==1
%     group1 = indexes(sex(indexes)==1);
%     group2 = indexes(sex(indexes)==0);
%     % Truncate group1 to have length of 50 thousand for GWAS
%     if length(group1) > 40000
%         group1 = group1(1:40000);
%     end
% end
% 
% group2 = setdiff(randperm(length(ID)),group1);
% subID_GWAS = eid_qc_passed_biochemical_genetics(group1);
% age_GWAS = age_qc_passed_biochemical_genetics(group1);
% sex_GWAS = sex_qc_passed_biochemical_genetics(group1);
% 
% subID_PRS_analysis = eid_qc_passed_biochemical_genetics(group2);
% age_PRS_analysis = age_qc_passed_biochemical_genetics(group2);
% sex_PRS_analysis = sex_qc_passed_biochemical_genetics(group2);


save([Out_private 'SplitControlGroups.mat'], "control_groups", 'control_groups_labels', 'subID_qc_table', 'age_qc_table', 'sex_qc_table');
