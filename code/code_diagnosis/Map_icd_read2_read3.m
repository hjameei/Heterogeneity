

%This code will find a mapping between codes from icd9, icd10 and self
%report

%inputs:
%disease_codes.mat (from Find_diagnostic_codes.m
%all_lkps_maps_v3.xlsx - The lookup table can be downloaded. see page 17
%for download instructions:
%https://biobank.ndph.ox.ac.uk/showcase/showcase/auxdata/primarycare_codings.zip

%outputs:
%icd_diseaseCode_mapped.mat


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


filename = [Out_open 'disease_codes.mat'];
load(filename,'code_self_v2','code_icd9','code_icd10','dx_labels','dx_organ','dx_system');
dGrp=dx_labels;


%load DiseaseCode.mat code_icd10 code_icd9 code_self

% Find corresponding Read v2 and Read ctv3 code
filename=[In_private,'primarycare_codings/all_lkps_maps_v3.xlsx'];
readv2_icd9=cell(length(dGrp),1);
% read v2 to icd 9
[~,txt,raw]=xlsread(filename,'read_v2_icd9');
for i=1:length(dx_labels)
    icdtmp=code_icd9{i};
    ind=[];
    for j=1:length(icdtmp)
        tmptxt=num2str(icdtmp(j));
        ind=[ind;find(strcmp(tmptxt,txt(:,2)))];
    end
    
    % Check code signifies (only include one-to-one mapping)
    code_def=cell2mat(raw(ind,3));
    ind_single=find(code_def==1);
    
    readv2_icd9{i}=txt(ind(ind_single),1);
end


% read v3 to icd9
readv3_icd9=cell(length(dGrp),1);
[~,txt]=xlsread(filename,'read_ctv3_icd9');
for i=1:length(code_icd9)
    icdtmp=code_icd9{i};
    ind=[];
    for j=1:length(icdtmp)
        tmptxt=num2str(icdtmp(j));
        ind=[ind;find(strcmp(tmptxt,txt(:,2)))];
    end
    % check the mapping status (only include E:exact one-to-one or G: accurate but general) 
    map_status=txt(ind,3);
    ind_e=find(strcmp('E',map_status));
    ind_g=find(strcmp('G',map_status));
    
    % Check refine flag(only C,completed refined)
    flag=txt(ind,4);
    ind_c=find(strcmp('C',flag));
    
    % Satisfy both
    ind_selec=intersect(ind_c,union(ind_e,ind_g));
    readv3_icd9{i}=txt(ind(ind_selec),1);
end


% read v2 to icd 10
readv2_icd10=cell(length(dGrp),1);
[~,txt,raw]=xlsread(filename,'read_v2_icd10');
for i=1:length(code_icd10)
    icdtmp=code_icd10{i};
    ind=[];
    for j=1:length(icdtmp)
        tmptxt=icdtmp{j};
        ind=[ind;find(contains(txt(:,2),tmptxt))];
    end
    
    % Check code signifies (only include one-to-one mapping)
    code_def=cell2mat(raw(ind,3));
    ind_single=find(code_def==1);
    
    readv2_icd10{i}=txt(ind(ind_single),1);
end
return
% read v3 to icd 10
readv3_icd10=cell(length(dGrp),1);
[~,txt]=xlsread(filename,'read_ctv3_icd10');
for i=1:length(code_icd10)
    icdtmp=code_icd10{i};
    ind=[];
    for j=1:length(icdtmp)
        tmptxt=icdtmp{j};
        ind=[ind;find(contains(txt(:,2),tmptxt))];
    end
    % check the mapping status (only include E:exact one-to-one or G: accurate but general) 
    map_status=txt(ind,3);
    ind_e=find(strcmp('E',map_status));
    ind_g=find(strcmp('G',map_status));
    
    % Check refine flag(only C,completed refined)
    flag=txt(ind,4);
    ind_c=find(strcmp('C',flag));
    
    % satisfy both
    ind_selec=intersect(ind_c,union(ind_e,ind_g));
    readv3_icd10{i}=txt(ind(ind_selec),1);
end

% combine readv2_icd9 and readv3_icd10
readv2=cell(length(dGrp),1);
readv3=cell(length(dGrp),1);
for i=1:length(dGrp)
    
    %readv2_icd9
    tmp9=readv2_icd9{i};
    tmp10=readv2_icd10{i};
    tmp=unique([tmp9;tmp10]);
    readv2{i,1}=tmp;
    clear tmp9 tmp10
    
    %readv2_icd10
    tmp9=readv3_icd9{i};
    tmp10=readv3_icd10{i};
    tmp=unique([tmp9;tmp10]);
    readv3{i,1}=tmp;
    clear tmp9 tmp10
end


save([Out_open,'icd_diseaseCode_mapped.mat'],...
    'code_self_v2', 'code_icd9' ,'code_icd10', 'readv2' ,'readv3' ,...
    'dx_labels','dx_organ','dx_system');








