clear all
close all

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


%subjects that withdrew consent
exclude=readtable([In_private 'w60698_20210809_subjects_to_remove_consent.csv']);
exclude=exclude{:,1};
 
%MRI_freesurfer_DK - Index subjects with both visits
MRI_freesurfer_DK_labs=readtable([In_private,'variable_selection.xlsx'], 'Sheet','freesurfer_dkt');
MRI_freesurfer_DK_table=readtable([In_private,'mb1958_MRI_freesurfer_DK']);
%selected subjects with available thickness data for a randomly selected
%brain region
ind_eid_with_MRI_freesurfer_DK_visit_1=find(~isnan(MRI_freesurfer_DK_table.x27267_2_0));
ind_eid_with_MRI_freesurfer_DK_visit_2=find(~isnan(MRI_freesurfer_DK_table.x27267_3_0));
ind_eid_with_MRI_freesurfer_DK_both_visits=intersect(ind_eid_with_MRI_freesurfer_DK_visit_1,ind_eid_with_MRI_freesurfer_DK_visit_2);
%select based on just the first visit
eid_with_MRI_freesurfer_DK=MRI_freesurfer_DK_table.eid(ind_eid_with_MRI_freesurfer_DK_visit_1);
[a, b, c]=intersect(eid_with_MRI_freesurfer_DK,exclude);
eid_with_MRI_freesurfer_DK(b)=[];
ind_eid_with_MRI_freesurfer_DK_visit_1(b)=[];



%load genetics data - participants with genetics data available
eid_genetics_table = readtable([In_private 'chr_id_sex.csv']);
eid_genetics = table2array(eid_genetics_table(:,1));
eid_sex = table2array(eid_genetics_table(:,2));
ind = find(eid_genetics > 0);
eid_genetics = eid_genetics(ind);
% eid_sex = eid_sex(ind);

eid_with_MRI_freesurfer_DK_genetics = intersect(eid_with_MRI_freesurfer_DK, eid_genetics);

%demographic_data
load([In_private 'demographics.mat']);

%diagnosis data
filename = [Out_private, 'DiseaseGroupSubID.mat'];
load(filename);
labels = ([{'Healthy'}; dx_labels]);
organs = ([{'Healthy'}; dx_organ]);
systems = ([{'Healthy'}; dx_system]);
Number_data = zeros(size(dx_labels,1)+1,3);

Number_data(1,1) = size(intersect(subID_healthy, eid_with_MRI_freesurfer_DK),1);
Number_data(1,2) = size(intersect(subID_healthy, eid_genetics),1);
Number_data(1,3) = size(intersect(subID_healthy, eid_with_MRI_freesurfer_DK_genetics),1);
for i=1:size(dx_labels,1)
    Number_data(i+1, 1)=size(intersect(subID_all{i}, eid_with_MRI_freesurfer_DK),1);
    Number_data(i+1, 2)=size(intersect(subID_all{i}, eid_genetics),1);
    Number_data(i+1, 3)=size(intersect(subID_all{i}, eid_with_MRI_freesurfer_DK_genetics),1);
end

% second plot

elements=intersect(subID_healthy, eid_genetics);
[~,ind,~]=intersect(ID,elements);
subID_genetics{1} =  [elements sex_all(ind)];

elements=intersect(subID_healthy, eid_with_MRI_freesurfer_DK);
[~,ind,~]=intersect(ID,elements);
subID_imaging{1} =  [elements sex_all(ind)];

elements=intersect(subID_healthy, eid_with_MRI_freesurfer_DK_genetics);
[~,ind,~]=intersect(ID,elements);
subID_imaging_genetics{1} =  [elements sex_all(ind)];

for i=1:size(dx_labels,1)
    elements=intersect(subID_all{i}, eid_genetics);
    [~,ind,~]=intersect(ID,elements);
    subID_genetics{i+1} =  [elements sex_all(ind)];

    elements=intersect(subID_all{i}, eid_with_MRI_freesurfer_DK);
    [~,ind,~]=intersect(ID,elements);
    subID_imaging{i+1} =  [elements sex_all(ind)];

    elements=intersect(subID_all{i}, eid_with_MRI_freesurfer_DK_genetics);
    [~,ind,~]=intersect(ID,elements);
    subID_imaging_genetics{i+1} =  [elements sex_all(ind)];
end



%age of diagnosis
dateFile=[In_private,'data_fields_53_52_34_dates.csv'];
 
ttds = datastore(dateFile,...
    'DatetimeType','text','ReadVariableNames',0);
fprintf('Read datastore\n');
dates=readall(ttds);
dates_header=dates(1,:);
dates=dates(2:end,:);
eids=str2num(cell2mat(table2array(dates(:, 1))));
 
formatOut='dd/MM/yyyy';
assessment_date_visit_0=datetime(dates{:,4},'Format',formatOut); %date at baseline visit
assessment_date_visit_1=datetime(dates{:,5},'Format',formatOut); %date at baseline visit
assessment_date_MRI_visit_1=datetime(dates{:,6},'Format',formatOut); %date at first MRI visit
assessment_date_MRI_visit_2=datetime(dates{:,7},'Format',formatOut); %date at first MRI visit
 
%date of birth
birth_year=str2double(dates{:,2});
birth_month=str2double(dates{:,3});
birth_day=15*ones(length(birth_month),1);
birthdate=datetime(birth_year,birth_month,birth_day,'Format',formatOut);
 
%age
age_at_visit_0_days=datenum(assessment_date_visit_0)-datenum(birthdate);
age_at_visit_0_years=age_at_visit_0_days/365.25;
 
age_at_visit_1_days=datenum(assessment_date_visit_1)-datenum(birthdate);
age_at_visit_1_years=age_at_visit_1_days/365.25;
 
age_at_MRI_visit_1_days=datenum(assessment_date_MRI_visit_1)-datenum(birthdate);
age_at_MRI_visit_1_years=age_at_MRI_visit_1_days/365.25;
 
age_at_MRI_visit_2_days=datenum(assessment_date_MRI_visit_2)-datenum(birthdate);
age_at_MRI_visit_2_years=age_at_MRI_visit_2_days/365.25;
 
age_all_timepoints=[age_at_visit_0_years age_at_visit_1_years age_at_MRI_visit_1_years age_at_MRI_visit_2_years];


[~, ind, ~] = intersect(eids,eid_with_MRI_freesurfer_DK);
age_mean_with_MRI_freesurfer_DK = mean(age_at_MRI_visit_1_years(ind));
age_sd_with_MRI_freesurfer_DK = std(age_at_MRI_visit_1_years(ind));
sex_ratio_age_sd_with_MRI_freesurfer_DK = sum(sex_all(ind))/size(sex_all(ind),1);
n_ethnicity_white_with_MRI_freesurfer_DK = sum(genetic_grouping(ind));
ratio_ethnicity_white_with_MRI_freesurfer_DK = sum(genetic_grouping(ind))/size(genetic_grouping(ind),1);
n_ethnicity_nonwhite_with_MRI_freesurfer_DK = size(genetic_grouping(ind),1)-sum(genetic_grouping(ind));
ratio_ethnicity_nonwhite_with_MRI_freesurfer_DK = n_ethnicity_nonwhite_with_MRI_freesurfer_DK /size(genetic_grouping(ind),1);

[~, ind, ~] = intersect(eids,eid_genetics);
age_mean_with_genetics = mean(age_at_visit_0_years(ind));
age_sd_with_genetics = std(age_at_visit_0_years(ind));
sex_ratio_age_sd_with_genetics = sum(sex_all(ind))/size(sex_all(ind),1);
n_ethnicity_white_with_genetics = sum(genetic_grouping(ind));
ratio_ethnicity_white_with_genetics = sum(genetic_grouping(ind))/size(genetic_grouping(ind),1);
n_ethnicity_nonwhite_with_genetics = size(genetic_grouping(ind),1)-sum(genetic_grouping(ind));
ratio_ethnicity_nonwhite_with_genetics = n_ethnicity_nonwhite_with_genetics /size(genetic_grouping(ind),1);

[~, ind, ~] = intersect(eids,eid_with_MRI_freesurfer_DK_genetics);
age_mean_with_MRI_freesurfer_DK_genetics = mean(age_at_MRI_visit_1_years(ind));
age_sd_with_MRI_freesurfer_DK_genetics = std(age_at_MRI_visit_1_years(ind));
sex_ratio_age_sd_with_MRI_freesurfer_DK_genetics = sum(sex_all(ind))/size(sex_all(ind),1);
n_ethnicity_white_with_MRI_freesurfer_DK_genetics = sum(genetic_grouping(ind));
ratio_ethnicity_white_with_MRI_freesurfer_DK_genetics = sum(genetic_grouping(ind))/size(genetic_grouping(ind),1);
n_ethnicity_nonwhite_with_MRI_freesurfer_DK_genetics = size(genetic_grouping(ind),1)-sum(genetic_grouping(ind));
ratio_ethnicity_nonwhite_with_MRI_freesurfer_DK_genetics = n_ethnicity_nonwhite_with_MRI_freesurfer_DK_genetics /size(genetic_grouping(ind),1);


Num = [size(eid_with_MRI_freesurfer_DK,1) size(eid_genetics,1) size(eid_with_MRI_freesurfer_DK_genetics,1)];
age_mean = [age_mean_with_MRI_freesurfer_DK age_mean_with_genetics age_mean_with_MRI_freesurfer_DK_genetics];
age_sd = [age_sd_with_MRI_freesurfer_DK age_sd_with_genetics age_sd_with_MRI_freesurfer_DK_genetics];
sex_ratio_male = [sex_ratio_age_sd_with_MRI_freesurfer_DK sex_ratio_age_sd_with_genetics sex_ratio_age_sd_with_MRI_freesurfer_DK_genetics];
n_ethnicity_white = [n_ethnicity_white_with_MRI_freesurfer_DK n_ethnicity_white_with_genetics n_ethnicity_white_with_MRI_freesurfer_DK_genetics];
ratio_ethnicity_white = [ratio_ethnicity_white_with_MRI_freesurfer_DK ratio_ethnicity_white_with_genetics ratio_ethnicity_white_with_MRI_freesurfer_DK_genetics];
n_ethnicity_nonwhite =[n_ethnicity_nonwhite_with_MRI_freesurfer_DK n_ethnicity_nonwhite_with_genetics n_ethnicity_nonwhite_with_MRI_freesurfer_DK_genetics];
ratio_ethnicity_nonwhite = [ratio_ethnicity_nonwhite_with_MRI_freesurfer_DK ratio_ethnicity_nonwhite_with_genetics ratio_ethnicity_nonwhite_with_MRI_freesurfer_DK_genetics];


demographic_matrix = [ Num; age_mean; age_sd; sex_ratio_male; n_ethnicity_white; ratio_ethnicity_white; n_ethnicity_nonwhite; ratio_ethnicity_nonwhite];

save([Out_private 'plot_data.mat'], 'Number_data', 'labels', 'organs', 'systems', ...
    'subID_genetics', 'subID_imaging', 'subID_imaging_genetics', ...
    'demographic_matrix');
