
clear all 
close all

%Examine the prescence of comorbidities
only_include_main_dx=1;

%set paths
asrb=0;
run('/Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/HETEROGENEITY2/Heterogeneity/code/code_diagnosis/Set_data_path.m');
PATH='/Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/UKBIOBANK/BiologicalData/';
PATH_OUT='/Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/HETEROGENEITY2/Private_data/Private_data_out/biochemical_out/GAMLSS_input_biochem/';
 
% change paths for the corresponding user
prompt = "Please specify user for path definition purposes\nFor Maria press 1\nFor others press 4\n";
x = input(prompt);
switch x
    case 1
        In_private = In_private_Maria;
        In_open = In_open_Maria_MRI;
        path_old_dx = path_old_dx_Maria;
        Out_open = Out_open_Maria;
        Out_private = Out_private_Maria;
    case 2
        In_private = In_private_Spartan;
        In_open = In_open_Spartan;
        Out_open = Out_open_Spartan;
        Out_private = Out_open_Spartan;
end


%load demographic data
load([dem_path,'demographics.mat']);


%read in eids for each diagnosis
load([Out_private, 'DiseaseGroupSubID.mat']);


%% test
% comorbid_healthy=zeros(length(subID_healthy),length(dx_labels));
% for i=1:length(subID_healthy)
%     
%     id=subID_healthy(i);
%     
%     for j=1:length(dx_labels)
%         
%         ind=find(subID_all{j}==id);
%         
%         if ~isempty(ind)
%             comorbid_healthy(i,j)=1;
%         end
%     
%     end
%     
% end
% 
% not_healthy=find(sum(comorbid_healthy(:,1:45),2)>=1);


%make diagnostic matrix
    n_dx=nan(length(dx_labels),1);
    original_matrix=zeros(size(ID,1),size(dx_labels,1));
    for dx=1:length(dx_labels)
        [eid,ind_subs_dx{dx},ind_dx]=intersect(subID_all{dx},ID);
        n_dx(dx)=length(eid);
        
        %generate binary matrix of diagnoses
        original_matrix(ind_dx,dx)=1;
    end
    

%remove diagnostic subtypes
DX_N=n_dx(1:54); tmp=age_diag_all;
original_matrix(:,46:end)=[];

%DX_LABELS=['Healthy'; dx_labels];
DX_LABELS=dx_labels(1:54);
% %%%%%%%%%%%%%%%%%%%%%%%%%
% %sort diagnoses by organ
% 
% [aIdx,DX_LABELS,organ_dx,~,~]=sort_diagnoses(DX_LABELS,only_include_main_dx);
% 
% %remove healthy control group 
% aIdx=aIdx(2:end)-1;
% organ_dx=organ_dx(2:end);
% DX_LABELS=DX_LABELS(2:end);
% original_matrix=original_matrix(:,aIdx);
% DX_N=DX_N(aIdx);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%

%remove diagnoses<1000 individuals
ind_rm_diagnosis=[];
for dx=1:length(DX_LABELS)
    
    if DX_N(dx)<1000
    
    ind_rm_diagnosis=[ind_rm_diagnosis; dx];
    
    end
end

DX_LABELS(ind_rm_diagnosis)=[];
original_matrix(:,ind_rm_diagnosis)=[];
DX_N(ind_rm_diagnosis)=[];

%fix DX labels
DX_LABELS = strrep(DX_LABELS, 'Bipolar, mania, hypomania, bipolar or manic-depression', 'Bipolar disorder');
DX_LABELS = strrep(DX_LABELS, 'Gastro-oesophageal reflux disease (GORD)', 'GORD');
DX_LABELS = strrep(DX_LABELS, 'CKD, Chronic kidney disease', 'Chronic kidney disease');
DX_LABELS = strrep(DX_LABELS, 'Anxiety or GAD (not inc. social anxiety)', 'Generalized anxiety');
DX_LABELS = strrep(DX_LABELS, 'Anxiety or GAD (not inc. social anxiety)', 'Anxiety or GAD');
DX_LABELS = strrep(DX_LABELS, 'or', '&'); DX_LABELS = strrep(DX_LABELS, 'and', '&');
DX_LABELS = strrep(DX_LABELS, '&d', 'or'); DX_LABELS = strrep(DX_LABELS, '&s', 'or'); DX_LABELS = strrep(DX_LABELS, '&e', 'or');
DX_LABELS = strrep(DX_LABELS, '&o', 'or');
DX_LABELS = strrep(DX_LABELS, 'Social anxiety & social phobia', 'Social anxiety');
DX_LABELS = strrep(DX_LABELS, 'psychosis & psychotic illness', 'Psychosis');
DX_LABELS = strrep(DX_LABELS, 'Autism, Aspergers & autistic spectrum disorer', 'ASD');

% get the number of diagnoses
num_diagnoses = size(original_matrix, 2);

% calculate the probability matrix
prob_matrix = zeros(num_diagnoses);

for i = 1:num_diagnoses
    for j = 1:num_diagnoses
        prob_matrix(i,j) = sum(original_matrix(:,i) & original_matrix(:,j)) / sum(original_matrix(:,i));
    end
end


%calculate number of subjects with comorbidity
abs_matrix = zeros(num_diagnoses);
for i = 1:num_diagnoses
    for j = 1:num_diagnoses
        abs_matrix(i,j) = sum(original_matrix(:,i) & original_matrix(:,j));
    end
end

% create a mask to display only the lower triangle
mask = tril(true(size(prob_matrix )), -1);

% set the diagonal and upper triangle to NaN
prob_matrix(~mask) = NaN;


% set up a grey color scheme using cbrewer
cmap = cbrewer('seq', 'Greys', 256);

% plot the matrix with a colorbar
hf=figure; hf.Color='w'; hf.Position=[50,50,800,800];
imagesc(prob_matrix);
colormap(cmap);
colorbar;

% Loop through each cell of the matrix
for i = 1:num_diagnoses
    for j = 1:num_diagnoses
        % Add the value of the matrix as text to the cell
        text(j, i, sprintf('%d', round(abs_matrix(i, j))), 'HorizontalAlignment', 'center');
    end
end


% add x and y axis labels
xticks(1:length(DX_LABELS))
yticks(1:length(DX_LABELS))
xticklabels(DX_LABELS)
xtickangle(90)
yticklabels(DX_LABELS)

%add n
for idx_dx=1:length(DX_LABELS)
    str = strcat('n=',string(DX_N(idx_dx))); 
    t=text(idx_dx,idx_dx+1,str);
    t.Rotation=90;
end

% display the plot
title('Comorbidities: Probability Matrix');
set(gca,'TickLength',[0 0],'FontSize',15)


