%Find codes for each diagnosis

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
        Out_open = Out_open_Hadis;
    otherwise
        In_private = In_private_Other;
        In_open = In_open_Other;
        path_old_dx = path_old_dx_Other;
end

%read in diseases of interest (this should be modified to ensure that
%diseases are captured by keywords
[num,txt,raw]=xlsread([In_open,'Diseases_of_interest.xlsx']);
dx_labels=txt(2:end,1);
dx_key_words=txt(2:end,4:18);
dx_organ=txt(2:end,2);
dx_system=txt(2:end,3);

%additional inclusion and exclusion critera for diagnoses
[~,~,raw]=xlsread([In_open,'Diseases_of_interest.xlsx'],'Exclude_code_icd9');
dx_code_exc_icd9=raw(2:end,2:8);

[~,~,raw]=xlsread([In_open,'Diseases_of_interest.xlsx'],'Include_code_icd9');
dx_code_inc_icd9=raw(2:end,2:15);

[~,~,raw]=xlsread([In_open,'Diseases_of_interest.xlsx'],'Exclude_code_icd10');
dx_code_exc_icd10=raw(2:end,2:47);

[~,~,raw]=xlsread([In_open,'Diseases_of_interest.xlsx'],'Include_code_icd10');
dx_code_inc_icd10=raw(2:end,2:45);

[~,~,raw]=xlsread([In_open,'Diseases_of_interest.xlsx'],'Exclude_code_mhq');
dx_code_exc_mhq=raw(2:end,2:8);

[~,~,raw]=xlsread([In_open,'Diseases_of_interest.xlsx'],'Include_code_mhq');
dx_code_inc_mhq=raw(2:end,2:8);

%initialise code variable
code_self_v2=cell(length(dx_labels),1);
code_icd9=cell(length(dx_labels),1);
code_icd10=cell(length(dx_labels),1);
code_mhq=cell(length(dx_labels),1);

description_self=cell(length(dx_labels),1);
description_icd9=cell(length(dx_labels),1);
description_icd10=cell(length(dx_labels),1);
description_mhq=cell(length(dx_labels),1);

%SELF REPORT
%downloaded from https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=3
%cancer codes
[num_self,txt_self,raw_self]=xlsread([In_open,'self_report/self_report_medical_cancer_codes.xlsx']);

%include all cancer codes in self report spreadsheet
ind_cancer=find(contains(dx_labels,'Cancer')==1);
code_self_v2{ind_cancer}=num_self(:,1);
description_self{ind_cancer}=txt_self(:,2); 

%noncancer codes
%downloaded from https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=3
[num,txt,raw]=xlsread([In_open,'self_report/self_report_medical_noncancer_codes.xlsx']);

for i=1:length(dx_labels)
    for key=1:size(dx_key_words,2)
        dx=dx_key_words{i,key};
        if ~isempty(dx)
            newpat = caseInsensitivePattern(dx);
            ind=find(contains(txt(:,2),newpat)==1);
            code_self_v2{i}=[code_self_v2{i}; num(ind,1)];
            description_self{i}=[description_self{i}; txt(ind,2)];
        end
    end
    
    %index duplicated codes
    [~, dup]=unique(code_self_v2{i});
    
    %remove duplicated codes
    code_self_v2{i}=code_self_v2{i}(dup);
    description_self{i}=description_self{i}(dup);
end


%ICD9
[num_icd9,txt_icd9,raw_icd9]=xlsread([In_open,'primarycare_codings/all_lkps_maps_v3.xlsx'],'icd9_lkp');

for i=1:length(dx_labels)

    for key=1:size(dx_key_words,2)
        dx=dx_key_words{i,key};
        if ~isempty(dx)
            newpat = caseInsensitivePattern(dx); %make keyword case insensitive
            ind=find(contains(txt_icd9(:,2),newpat)==1); %index all codes with keyword
            
            code_icd9{i}=[code_icd9{i}; convertCharsToStrings(txt_icd9(ind,1))];
            description_icd9{i}=[description_icd9{i}; txt_icd9(ind,2)];
            
        end
    end
    
    
    %manually include specific codes
    Include=rmmissing(string(dx_code_inc_icd9(i,:)));
    if ~isempty(Include)
        for criteria=1:size(Include,2)
            [code, ind, ~]=intersect(code_icd9{i},Include(criteria));
            if isempty(ind)
                code_icd9{i}=[code_icd9{i}; Include(criteria)];
                ind_code_orig=find(strcmp(txt_icd9(:,1),Include(criteria))==1);
                description_icd9{i}=[description_icd9{i}; txt_icd9(ind_code_orig,2)];
            end
        end
    end
    
    %index duplicated codes
    [~, dup]=unique(code_icd9{i});
    
    %remove duplicated codes
    code_icd9{i}=code_icd9{i}(dup);
    description_icd9{i}=description_icd9{i}(dup);
    
    %manually exclude specific codes
    Exclude=rmmissing(string(dx_code_exc_icd9(i,:)));
    if ~isempty(Exclude)
        for criteria=1:size(Exclude,2)
            [~, ind, ~]=intersect(code_icd9{i},Exclude(criteria)); %find code to exclude
            
            if ~isempty(ind)
                code_icd9{i}(ind)=[];
                description_icd9{i}(ind)=[];
            end
            
        end
    end
    

end

%ICD10
[num_icd10,txt_icd10,raw_icd10]=xlsread([In_open,'primarycare_codings/all_lkps_maps_v3.xlsx'],'icd10_lkp');

for i=1:length(dx_labels)
    for key=1:size(dx_key_words,2)
        dx=dx_key_words{i,key};
        if ~isempty(dx)
            newpat = caseInsensitivePattern(dx); %make variable name case insensitive 
            ind=find(contains(txt_icd10(:,5),newpat)==1);
            code_icd10{i}=[code_icd10{i}; convertCharsToStrings(txt_icd10(ind,1))];
            description_icd10{i}=[description_icd10{i}; convertCharsToStrings(txt_icd10(ind,5))];
        end
    end
    
    %manually include specific codes
    Include=rmmissing(string(dx_code_inc_icd10(i,:)));
    if ~isempty(Include)
        for criteria=1:size(Include,2)
            [code, ind, ~]=intersect(code_icd10{i},Include(criteria));
            if isempty(ind)
                code_icd10{i}=[code_icd10{i}; Include(criteria)];
                ind_code_orig=find(strcmp(txt_icd10(:,1),Include(criteria))==1);
                description_icd10{i}=[description_icd10{i}; txt_icd10(ind_code_orig,5)];
            end
        end
    end
    
    %index duplicated codes
    [~, dup]=unique(code_icd10{i});
    
    %remove duplicated codes
    code_icd10{i}=code_icd10{i}(dup);
    description_icd10{i}=description_icd10{i}(dup);
    
    %manually exclude specific codes
    Exclude=rmmissing(string(dx_code_exc_icd10(i,:)));
    if ~isempty(Exclude)
        for criteria=1:size(Exclude,2)
            [~, ind, ~]=intersect(code_icd10{i},Exclude(criteria)); %find code to exclude
            
            if ~isempty(ind)
                code_icd10{i}(ind)=[];
                description_icd10{i}(ind)=[];
            end
            
        end
    end
    

    
    %adding alternative codes, which are available in ICD10
    code_alternative = [];
    desc_alternative = [];
    for c1=1:length(code_icd10{i})
        ind_code_alt=find(txt_icd10(:,1)==code_icd10{i}(c1));
        code_alternative=[code_alternative; txt_icd10(ind_code_alt,2)];
        desc_alternative=[desc_alternative; txt_icd10(ind_code_alt,5)];
    end
    code_icd10{i} = [code_icd10{i}; code_alternative];
    description_icd10{i}= [description_icd10{i}; desc_alternative];
    
    
    %index duplicated codes
    [~, dup]=unique(code_icd10{i});
    
    %remove duplicated codes
    code_icd10{i}=code_icd10{i}(dup);
    description_icd10{i}=description_icd10{i}(dup);
    
    
end

filename = [Out_open 'vars_to_crosscheck.mat'];
save(filename);


%MHQ
%downloaded from https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=1401
[num_mhq,txt_mhq,raw_mhq]=xlsread([In_open,'MHQ/mhq_code.xlsx']);
txt_mhq=txt_mhq(2:end,:);
for i=1:length(dx_labels)
    for key=1:size(dx_key_words,2)
        dx=dx_key_words{i,key};
        if ~isempty(dx)
            newpat = caseInsensitivePattern(dx);
            ind=find(contains(txt_mhq(:,2),newpat)==1);
            code_mhq{i}=[code_mhq{i}; num_mhq(ind,1)];
            description_mhq{i}=[description_mhq{i}; txt_mhq(ind,2)];
        end
    end
    
    %manually include specific codes
    Include=rmmissing(string(dx_code_inc_mhq(i,:)));
    if ~isempty(Include)
        for criteria=1:size(Include,2)
            [code, ind, ~]=intersect(code_mhq{i},str2double(Include(criteria)));
            if isempty(ind)
                code_mhq{i}=[code_mhq{i}; str2double(Include(criteria))];
                ind_code_orig=find(strcmp(string(num_mhq(:,1)),Include(criteria))==1);
                description_mhq{i}=[description_mhq{i}; txt_mhq(ind_code_orig,2)];
            end
        end
    end
    
    %index duplicated codes
    [~, dup]=unique(code_mhq{i});
    
    %remove duplicated codes
    code_mhq{i}=code_mhq{i}(dup);
    description_mhq{i}=description_mhq{i}(dup);
    
    %manually exclude specific codes
    Exclude=rmmissing(string(dx_code_exc_mhq(i,:)));
    if ~isempty(Exclude)
        for criteria=1:size(Exclude,2)
            [~, ind, ~]=intersect(code_mhq{i},str2double(Exclude(criteria))); %find code to exclude
            
            if ~isempty(ind)
                code_mhq{i}(ind)=[];
                description_mhq{i}(ind)=[];
            end
            
        end
    end
    
    
end


filename = [Out_open 'disease_codes.mat'];
save(filename,'dx_labels','dx_organ','dx_system',...
              'code_self_v2','code_icd9','code_icd10','code_mhq',...
              'description_self','description_icd9','description_icd10','description_mhq');





