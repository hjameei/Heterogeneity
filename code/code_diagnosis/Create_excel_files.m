clear all
close all
%STEP 2
%creat excel file containing disease codes alongside diagnostic labels 
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
    case 2
        In_private = In_private_Ye;
        In_open = In_open_Ye;
        path_old_dx = path_old_dx_Ye;
    case 3
        In_private = In_private_Hadis;
        In_open = In_open_Hadis;
        path_old_dx = path_old_dx_Hadis;
        Out_open = Out_open_Hadis;
    otherwise
        In_private = In_private_Other;
        In_open = In_open_Other;
        path_old_dx = path_old_dx_Other;
end

filename = [Out_open 'vars_to_crosscheck.mat'];
load(filename);


% ICD 9
code_new_icd9 = cell(0);
description_new_icd9=cell(0);
labels_new_icd9 = cell(0);

for i=1:length(dx_labels)
    for j=1:size(code_icd9{i},1)
        code_new_icd9 = [code_new_icd9; code_icd9{i}(j)];
        description_new_icd9 = [description_new_icd9; description_icd9{i}(j)];
        labels_new_icd9 = [labels_new_icd9; dx_labels{i}];
    end
end


% ICD 10
code_new_icd10 = cell(0);
description_new_icd10=cell(0);
labels_new_icd10 = cell(0);

for i=1:length(dx_labels)
    for j=1:size(code_icd10{i},1)
        code_new_icd10 = [code_new_icd10; code_icd10{i}(j)];
        description_new_icd10 = [description_new_icd10; description_icd10{i}(j)];
        labels_new_icd10 = [labels_new_icd10; dx_labels{i}];
    end
end


% self
code_new_self = cell(0);
description_new_self=cell(0);
labels_new_self = cell(0);

for i=1:length(code_icd9)
    for j=1:size(code_self_v2{i},1)
        code_new_self = [code_new_self; code_self_v2{i}(j)];
        description_new_self = [description_new_self; description_self{i}(j)];
        labels_new_self = [labels_new_self; dx_labels{i}];
    end
end


% MHQ
code_new_mhq = cell(0);
description_new_mhq=cell(0);
labels_new_mhq = cell(0);

for i=1:length(dx_labels)
    for j=1:size(code_mhq{i},1)
        code_new_mhq = [code_new_mhq; code_mhq{i}(j)];
        description_new_mhq = [description_new_mhq; description_mhq{i}(j)];
        labels_new_mhq = [labels_new_mhq; dx_labels{i}];
    end
end


          
T_icd9 = table(labels_new_icd9, description_new_icd9, code_new_icd9);
T_icd10 = table(labels_new_icd10, description_new_icd10, code_new_icd10);
T_self = table(labels_new_self, description_new_self, code_new_self);
T_mhq = table(labels_new_mhq, description_new_mhq, code_new_mhq);


filename_new = [Out_open 'description_codes_April10.xlsx'];

writetable(T_icd9, filename_new, 'Sheet', 'icd9','Range','A1');
writetable(T_icd10, filename_new, 'Sheet', 'icd10','Range','A1');
writetable(T_self, filename_new, 'Sheet', 'self','Range','A1');
writetable(T_mhq, filename_new, 'Sheet', 'mhq','Range','A1');
