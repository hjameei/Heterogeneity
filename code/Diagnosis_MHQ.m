
%read in Mental Health Questionnaire and extract diagnoses for each subject
clear all
close all

load med_instance0.mat
%contains med_num (variable data) and med_txt (variable names)

%find variables of interest
%fields containing 20544 relate to the MHQ
ind_MHQ=find(contains(med_txt(1,:),'20544')==1);


%Define individuals who completed the questionaire
%field 20400-0.0 identifies whether a UKBB participant completed the questionnaire and when.
ind_completed=find(contains(med_txt(1,:),'20544-0.1')==1);
MHQ_completed=find(~isnan(med_num(:,ind_completed)));

