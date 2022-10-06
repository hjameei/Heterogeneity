
%read in Mental Health Questionnaire and extract diagnoses for each subject
clear all
close all

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
    case 2
        In_private = In_private_Ye;
        In_open = In_open_Ye;
        path_old_dx = path_old_dx_Ye;
    case 3
        In_private = In_private_Hadis;
        In_open = In_open_Hadis;
        path_old_dx = path_old_dx_Hadis;
    otherwise
        In_private = In_private_Other;
        In_open = In_open_Other;
        path_old_dx = path_old_dx_Other;
end

%contains med_num (variable data) and med_txt (variable names)
load ([In_private,'med_instance0.mat']);
mhq_data_id=med_num(:,1);

%contains data field 20400-0.0, whcih identifies 
%whether a UKBB participant completed the questionnaire and when.
opts = detectImportOptions([In_private,'mb1958_MHQ_completed.xlsx']);
data = readtable([In_private,'mb1958_MHQ_completed.xlsx'],opts);
date_mhq_completed = data(:,2);
date_mhq_completed_id = data(:,1);

[ID, ind_date_mhq_completed_id, ind_data_id] = intersect (date_mhq_completed_id{:,1}, mhq_data_id);
date_mhq_completed=date_mhq_completed(ind_date_mhq_completed_id,1);
date_mhq_completed_id=date_mhq_completed_id{ind_date_mhq_completed_id,1};
mhq_data_id=mhq_data_id(ind_data_id,1);
data_num=med_num(ind_data_id,:);

%find variables of interest
%fields containing 20544 relate to the MHQ
ind_MHQ=find(contains(med_txt(1,:),'20544')==1);


%Define individuals who completed the questionaire
%field 20400-0.0 identifies whether a UKBB participant completed the questionnaire and when.
ind_completed=find(contains(med_txt(1,:),'20544-0.1')==1);
MHQ_completed=find(~isnan(med_num(:,ind_completed)));

