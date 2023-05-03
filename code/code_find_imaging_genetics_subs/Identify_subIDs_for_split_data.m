clear all
close all


varname='biochemical'; %can be biochemical or physical 

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


%load control group data
load([Out_private, 'SplitControlGroups.mat']);

%demographic_data
load([In_private 'demographics.mat']);

dateFile=[In_private,'data_fields_53_52_34_dates.csv'];
 
ttds = datastore(dateFile,...
    'DatetimeType','text','ReadVariableNames',0);
fprintf('Read datastore\n');
dates=readall(ttds);
dates_header=dates(1,:);
dates=dates(2:end,:);
eids=str2num(cell2mat(table2array(dates(:, 1))));

Num = zeros(1,7);
age_mean = zeros(1,7);
age_std = zeros(1,7);
sex_ratio_male = zeros(1,7);
n_ethnicity_white = zeros(1,7);
ratio_ethnicity_white = zeros(1,7);
n_ethnicity_nonwhite = zeros(1,7);
ratio_ethnicity_nonwhite = zeros(1,7);

for i=1:7
    [~,ind,~] = intersect(eids, control_groups{(i-1)*3+1});
    Num(i) = size(control_groups{(i-1)*3+2},1);
    age_mean(i) = mean(control_groups{(i-1)*3+2});
    age_std(i) = std(control_groups{(i-1)*3+2});
    sex_ratio_male(i) = sum(control_groups{(i-1)*3+3})/size(control_groups{(i-1)*3+3},1);
    n_ethnicity_white(i) = sum(genetic_grouping(ind));
    ratio_ethnicity_white(i) = sum(genetic_grouping(ind))/size(genetic_grouping(ind),1);
    n_ethnicity_nonwhite(i) = size(genetic_grouping(ind),1)-sum(genetic_grouping(ind));
    ratio_ethnicity_nonwhite(i) = n_ethnicity_nonwhite(i) /size(genetic_grouping(ind),1);
end


demographic_matrix = [ Num; age_mean; age_std; sex_ratio_male; n_ethnicity_white; ratio_ethnicity_white; n_ethnicity_nonwhite; ratio_ethnicity_nonwhite];

save([Out_private 'plot_data_congrol_groups.mat'], 'demographic_matrix');
