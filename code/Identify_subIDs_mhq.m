
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
        Out_private = Out_private_Maria;
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
date_completed_mhq = data(:,2);
date_mhq_completed_id = data(:,1);

[ID, ind_date_mhq_completed_id, ind_data_id] = intersect (date_mhq_completed_id{:,1}, mhq_data_id);
date_completed_mhq=date_completed_mhq(ind_date_mhq_completed_id,1);
date_mhq_completed_id=date_mhq_completed_id{ind_date_mhq_completed_id,1};
mhq_data_id=mhq_data_id(ind_data_id,1);
data_num=med_num(ind_data_id,:);

%find variables of interest
%fields containing 20544 relate to the MHQ
ind_MHQ=find(contains(med_txt(1,:),'20544')==1);


%add subID to diagnostic categories
filename = [Out_open 'disease_codes.mat'];
load(filename,'code_mhq','dx_labels','dx_organ','dx_system');


subID_dx_mhq=cell(length(dx_labels),1);
for i=1:length(dx_labels)
   dx_codes=code_mhq{i};
  if   ~isempty(dx_codes)
     
      for code_1=1:length(dx_codes)
            [ind_subID_row, ind_var_col] = find(data_num(:,ind_MHQ)==dx_codes(code_1));
            subID_dx_mhq{i} = [subID_dx_mhq{i}; mhq_data_id(ind_subID_row)];
      end
  end
  
    %index duplicated codes
    [~, dup]=unique(subID_dx_mhq{i});
    
    %remove duplicated codes
    subID_dx_mhq{i}=subID_dx_mhq{i}(dup);
    
end

%Define individuals who completed the questionaire
%field 20400-0.0 identifies whether a UKBB participant completed the questionnaire and when.
find_subID_with_mhq=find(~isnat(date_completed_mhq{:,1}));
n_completed_mhq=length(find_subID_with_mhq);
subID_completed_mhq=mhq_data_id(find_subID_with_mhq,1);

%find subID who are missing mhq data 
subID_missing_mhq = mhq_data_id(isnat(date_completed_mhq{:,1}));

%find subID with either missing data or who prefer not to answer (PNA) or who
find_total = sum(data_num(:,ind_MHQ),2,'omitnan');
subID_PNA_or_missing_mhq = mhq_data_id(find_total<=0);

%find subID who completed mhq and who did not endorse any mental health issues
subID_with_zero_total = mhq_data_id(find_total==0);
[subID_healthy_mhq, ~,~] = intersect(subID_completed_mhq, subID_with_zero_total);

filename = [Out_private, 'subID_mhq.mat'];
save(filename,'dx_labels','dx_organ','dx_system',...
    'subID_completed_mhq','subID_PNA_or_missing_mhq','subID_healthy_mhq',...
    'subID_dx_mhq','date_completed_mhq');






