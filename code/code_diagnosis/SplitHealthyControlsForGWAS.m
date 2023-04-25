
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
eid_genetics_table = readtable([In_private 'chr_id_sex.csv']);
subID_qc_table = table2array(eid_genetics_table(:,1));
sex_qc_table = table2array(eid_genetics_table(:,2))-1;

sex_qc_passed_biochemical_genetics = zeros(size(eid_qc_passed_biochemical_genetics));
[~, ind, ~] = intersect(subID_qc_table,eid_qc_passed_biochemical_genetics);
sex_qc_passed_biochemical_genetics = sex_qc_table(ind);

%age
age_qc_passed_biochemical_genetics = zeros(size(eid_qc_passed_biochemical_genetics));
for i=1:length(age_diag_all)
    [x,a,b]=intersect(eid_qc_passed_biochemical_genetics, subID_all{i});
    age_qc_passed_biochemical_genetics(a) = age_diag_all{i}(b);
end

% split the healthy controls into 2 groups:

% group1 = GWAS 
% group2 = PRS analyses

% Example data
% ID = [1 2 3 4 5 6 7 8 9];
% age = [25 33 20 28 30 24 26 29 27];
% sex = [1 0 1 1 0 0 1 1 0];

[ID_healthy, ~,ind] = intersect(subID_healthy_maria, eid_qc_passed_biochemical_genetics);
age_healthy = age_qc_passed_biochemical_genetics(ind);
sex_healthy = sex_qc_passed_biochemical_genetics(ind);

ID = ID_healthy;
age = age_healthy;
sex = sex_healthy;


% Split into two groups based on age and sex, with group1 having length of 50 thousand and group2 having the remaining data
group1 = [];
group2 = [];
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

while isempty(group1) || isempty(group2) || std(age(group2)) < 5
    % Shuffle the ID vector
    indexes = randperm(length(ID));    
    % Split the shuffled ID vector into two groups with equal number of sex==0 and sex==1
    group1 = indexes(sex(indexes)==1);
    group2 = indexes(sex(indexes)==0);
    % Truncate group1 to have length of 50 thousand for GWAS
    if length(group1) > 30000
        group1 = group1(1:30000);
    end
end

group2 = setdiff(randperm(length(ID)),group1);
subID_GWAS = eid_qc_passed_biochemical_genetics(group1);
age_GWAS = age_qc_passed_biochemical_genetics(group1);
sex_GWAS = sex_qc_passed_biochemical_genetics(group1);

subID_PRS_analysis = eid_qc_passed_biochemical_genetics(group2);
age_PRS_analysis = age_qc_passed_biochemical_genetics(group2);
sex_PRS_analysis = sex_qc_passed_biochemical_genetics(group2);


save([Out_private 'Split_GWAS_biochemical.mat'], 'ID_healthy', 'age_healthy', 'sex_healthy', ...
    'subID_GWAS', 'subID_PRS_analysis', ...
    'age_GWAS', 'age_PRS_analysis', 'sex_GWAS', 'sex_PRS_analysis');