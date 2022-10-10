
%This code will combine .mat files (containing clinical GP data) 
%from Identify_subIDs_gp_clinical.m

%This code was run on Spartan


clear all;
close all;

run('Set_data_path.m');

x = 2;


% change paths for the corresponding user
switch x
    case 1
        In_private = In_private_Maria;
        In_open = In_open_Maria;
        path_old_dx = path_old_dx_Maria;
        Out_open = Out_open_Maria;
        Out_private = Out_private_Maria;
    case 2
        In_private = In_private_Spartan;
        In_open = In_open_Spartan;
        Out_open = Out_open_Spartan;
        Out_private = Out_open_Spartan;
    case 3
        In_private = In_private_Hadis;
        In_open = In_open_Hadis;
        path_old_dx = path_old_dx_Hadis;
    otherwise
        In_private = In_private_Other;
        In_open = In_open_Other;
        path_old_dx = path_old_dx_Other;
end




% Get case ID list
d = dir([Out_open,'/GPdata/']);
case_list = {d.name};
ind = find(contains(case_list,'GPClinical'));
case_list_tmp =case_list(ind);
grp_num=45; %number of diagnoses

date_readv2_all={};
date_readv3_all={};
subs_readv2_all={};
subs_readv3_all={};
subID_completed_gp_all={};
for g=1:grp_num
    %case_list = replace( case_list_tmp , 'GPdataGrp1' , ['GPdataGrp',num2str(g)]) ;
    ind=find(contains(case_list_tmp,['GPClinical',num2str(g)])==1);
    case_list=case_list_tmp(ind);

    for i=1:length(case_list)
        x=case_list(i);
	x
        Y=strcat(Out_open,'/GPdata/',x);
        
        
        GPdata=load(Y{1});
        
        
        date_readv2_all{i}=GPdata.date_completed_readv2{:};
        date_readv3_all{i}=GPdata.date_completed_readv3{:};
        subs_readv2_all{i}=GPdata.subID_readv2{:};
        subs_readv3_all{i}=GPdata.subID_readv3{:};
        subID_completed_gp_all{i}=GPdata.subID_completed_gp{:};
    
    end
    
    date_completed_readv2{:,g}=cat(1,date_readv2_all{:});
    date_completed_readv3{:,g}=cat(1,date_readv3_all{:});
    subID_readv2{:,g}=cat(1,subs_readv2_all{:});
    subID_readv3{:,g}=cat(1,subs_readv3_all{:});
    subID_completed_gp{:,g}=cat(1,subID_completed_gp_all{:});
    clear date_readv2_all date_readv3_all subs_readv2_all subs_readv3_all subID_completed_gp_all


end

save([Out_open,'GPdata_all.mat'],'date_completed_readv2','date_completed_readv3','subID_readv2','subID_readv3','subID_completed_gp');