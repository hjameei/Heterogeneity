
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


%load EIDs of subjects with both genetics and biochemical data
subID_genetics_biochem

%load EIDs of subjects that meet genetic QC


%find intersect

%load demographic data 

%find age and sex of subjects that meet 3 conditions (i.e., those with genetics and
%biochem and that passed genetic QC)

% split the healthy controls into 2 groups:

% group1 = GWAS 
% group2 = PRS analyses

% Example data
ID = [1 2 3 4 5 6 7 8 9];
age = [25 33 20 28 30 24 26 29 27];
sex = [1 0 1 1 0 0 1 1 0];

% Split into two groups based on age and sex, with group1 having length of 50 thousand and group2 having the remaining data
group1 = [];
group2 = [];
while isempty(group1) || isempty(group2) || abs(mean(age(group1)) - mean(age(group2))) > 0.5 || abs(std(age(group1)) - std(age(group2))) > 0.5
    % Shuffle the ID vector
    ID_shuffle = ID(randperm(length(ID)));
    % Split the shuffled ID vector into two groups with equal number of sex==0 and sex==1
    group1 = ID_shuffle(sex(ID_shuffle)==1);
    group2 = ID_shuffle(sex(ID_shuffle)==0);
    % Truncate group1 to have length of 50 thousand for GWAS
    if length(group1) > 50000
        group1 = group1(1:50000);
    end
end
