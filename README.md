This project aims to map diagnosis heterogeneity in [UK Biobank dataset](https://bbams.ndph.ox.ac.uk/ams/).

# Diagnostic codes

## Preliminary information 
The diagnosis information of individuals are reported in formats of four different sources:
- GP Clinical data (readv2/readv3)
- Self-reported diagnosis (Cancer/Noncancer)
- ICD codes relating inpatients (ICD9/ICD10)
- Self-reported Mental Health Questionnaire (MHQ)

The  (available under name gp_clinical, informations about how to obtain this table can be found in [UBK Primary care Documentation](https://biobank.ndph.ox.ac.uk/showcase/showcase/docs/primary_care_data.pdf)).

## Steps 1: code_diagnosis/Find_daignostic_codes.m

This code goes through the diseases of interest provided in a file named "Diseases_of_interest.xlsx", and finds all the diagnostic codes and descriptions of theses diseases, including ICD9/10, read v2, MHQ codes. 

 ### Input:
 - **Diseases_of_interest.xlsx**
    The main sheet is the list of diseases of interest, detailed by their exact labels, the organ they are related to, they body system they involve, and the keywords to find the diseases by in the code/description of diagnostic codes.
    Each disease of interest has its own include and exclude criteria to match the exact description of the diagnostic codes, which are detailed in the remaining 8 sheets of the excel file.
 - **all_lkps_maps_v3.xlsx**: detailing the code and description of the IC9/10, read_v2/v3, as well as lookup tables for pair-wise mappings between these codes. This table is available to download on [page 17 of UKB instructions](https://biobank.ndph.ox.ac.uk/showcase/showcase/auxdata/primarycare_codings.zip).
 - **mhq_code.xlsx**: available [here](https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=1401).
 - **self_report_medical_cancer_codes.xlsx**: self-reported cancer codes, available [here](https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=3).
 - **self_report_medical_noncancer_codes.xlsx**: self-reported non-cancer codes, available [here](https://biobank.ndph.ox.ac.uk/showcase/coding.cgi?id=3).

### Output: 

- **disease_codes.mat**
    This file contains label, organ, system, codes, and description of the diseases of interest, as searched through diagnostic codes. The exact feilds are:
    - code_icd9/description_icd9 
    - code_icd10/description_icd10
    - code_mhq/description_mhq
    - code_self_v2/description_self
    - dx_labels
    - dx_organ
    - dx_system
- **vars_to_crosscheck.mat**:all variables in the code, only needed for Step 2.

## Steps 1.2: code_diagnosis/Crosscheck_codes.m (superseded)

This code finds the similarities and discrepancies between the older version of the program and the this new version. The aim is to update the diseases of interest file, and this step doesn't need to be repeated, and is just documented.

### Input: 
- **vars_to_crosscheck.mat**
- **self_report_medical_cancer_codes.xlsx**
- **self_report_medical_noncancer_codes.xlsx**

### Output: 
- **description_codes_v1_v2.xlsx**: contains missing and overlaps between ICD9, ICD10, and self codes for the previous version of this program.

## Step 2: code_diagnosis/Create_excel_files.m
Creates an Excel file for each diagnosis status separately for each diagnosis code, split by sheets

### Input: 
- **vars_to_crosscheck.mat**: generated in Step 1 

### Output: 
- **description_codes_<DATE>.xlsx**: contains the excel file for descriptions and codes for traits of interest.


## Steps 3: code_diagnosis/Map_icd_read2_read3.m

This file will find a mapping between codes from ICD9/10, and read_v2 and read_v3, and stores read_v2 and read_v3 codes of the diseases of interest.

### Input:

- **disease_codes.mat**, generated during the previsous step.

- **all_lkps_maps_v3.xlsx**

### Output:

- **icd_diseaseCode_mapped.mat**
    The generated file contains the following fields:
    - code_self_v2
    - code_icd9
    - code_icd10
    - readv2
    - readv3
    - dx_labels
    - dx_organ
    - dx_organ
    
## Steps 4: code_diagnosis/Identify_subIDs_icd_self.m

This code will identify subject IDs with any one of the diagnoses, mapped by ICD9/ICD10 and self-reports. 

### Input:

- **Diseases_of_interest.xlsx**
- **icd_diseaseCode_mapped.mat**, generated in Step 3.
- **medical_data.csv**: containing datafields as specified in 'medical condition' ([spreadsheet](https://biobank.ndph.ox.ac.uk/showcase/codown.cgi)).
- **data_fields_53_52_34_dates.csv**: contains dates at baseline, first, and second MRI visists.

### Output:

- **subID_icd_self.mat**
    The generated file contains the following fields:
    - subID_healthy_icd9
    - subID_healthy_icd10
    - subID_healthy_self
    - subID_dx_icd9
    - subID_dx_icd10
    - subID_dx_self
    - date_completed_icd9
    - date_completed_icd10
    - age_diag_self
    - age_diag_icd9
    - age_diag_icd10
    - dx_labels
    - dx_organ
    - dx_organ

## Steps 5: code_diagnosis/Identify_subIDs_mhq.m

Similar to Step 3, this code will identify subject IDs with any one of the diagnoses, but mapped by MHQ.
read in Mental Health Questionnaire and extract diagnoses for each subject

- **med_instance0.mat**, this file contains variable data and variable names for MHQ diagnostic codes (similar to all_lkps_maps_v3.xlsx for other diagnostic codes).
- **mb1958_MHQ_completed.xlsx**: ontains data field 20400-0.0, whcih identifies whether a UKBB participant completed the questionnaire and when.
- **disease_codes.mat**: generated in Step 1.
### Output:

- **subID_mhq.mat**
    The generated file contains the following fields:
    - subID_completed_mhq
    - subID_PNA_or_missing_mhq
    - subID_healthy_mhq
    - subID_dx_mhq
    - date_completed_mhq
    - date_dx_mhq
    - dx_labels
    - dx_organ
    - dx_organ


## Steps 6: code_diagnosis/Identify_subIDs_gp_clinical.m

This code will identify subject IDs with any one of the diagnoses, according to GP clinical. 

### Input:

- **data_fields_53_52_34_dates.csv**
- **icd_diseaseCode_mapped.mat**, generated in Step 3.
- **gp_clinical_06_10_22.txt**: which is primary care data. These fields are updated regularly and can be redownloaded if we have an updated .enc file. Instructions to download primary care data are shown in [primary_care_data.pdf](https://biobank.ndph.ox.ac.uk/showcase/showcase/auxdata/primarycare_codings.zip).

### Output:
- Blocks of data with prefix **subID_GPClinical**, containing the following ifnormation:
    - subID_readv2
    - subID_readv3
    - subID_completed_gp
    - date_completed_readv2
    - date_completed_readv3


## Steps 7: code_diagnosis/Combine_blocks_gp_clinical.m

This code will combine .mat files (containing clinical GP data) from Step 5 (Identify_subIDs_gp_clinical.m).

### Input:

- **subID_GPClinical**, blocks

### Output:

- **GPdata_all.mat**
    The generated file contains the following fields:
    - subID_readv2
    - subID_readv3
    - subID_completed_gp
    - date_completed_readv2
    - date_completed_readv3

## Steps 8: code_diagnosis/Identify_subIDs_from_all_sources.m

This code will combine subject IDs and dates from clinical GP data with other data (from self report, icd9, icd10 and MHQ).

### Input:

- **GPdata_all.mat**, generated in Step 7.
- **subID_icd_self.mat** generated in Step 4.
- **subID_mhq.mat** generated in Step 5.
- **data_fields_53_52_34_dates.csv**

### Output:

- **DiseaseGroupSubID.mat**
    The generated file contains the following fields:
    - subID_self
    - subID_icd
    - subID_icd9
    - subID_icd10
    - subID_mhq
    - subID_all
    - age_diag_self
    - age_diag_icd9
    - age_diag_icd10
    - age_diag_mhq
    - age_diag_all
    - date_diag_icd9
    - date_diag_icd10
    - subID_healthy
    - dx_labels
    - dx_organ
    - dx_system

## Steps 9: code_find_imaging_genetics_subs/Identify_subIDs_with_imaging_genetics.m (superseded)

This code will identify the subjects IDs with imaging data, genetics data, and both imaging and genetics data..

### Input:
- **DiseaseGroupSubID.mat**: generated in Step 8.
- **data_fields_53_52_34_dates.csv**
- **w60698_20210809_subjects_to_remove_consent.mat**: subjects that withdrew their consent.
- **chr_id_sex.csv**: participants with genetic data available.
- **variable_selection.xlsx**
- **mb1958_MRI_freesurfer_DK.csv**
- **demographics.mat**

### Output:

- **plot_data.mat**
    The generated file contains the following fields:
    - subID_genetics
    - subID_imaging
    - subID_imaging_genetics
    - Number_data
    - demographic_matrix
    - labels
    - organs
    - systems

## Step 10: code_find_imaging_genetics_subs/Identify_subIDs_with_imaging_genetics_biochem.m

This code will identify the subject IDs with imaging data, genetics data, imaging and genetic data, biochemical data, and biochemical and genetics data.

### Input:
- **DiseaseGroupSubID.mat**: generated in Step 8.
- **data_fields_53_52_34_dates.csv**
- **w60698_20210809_subjects_to_remove_consent.mat**: subjects that withdrew their consent.
- **chr_id_sex.csv**: participants with genetic data avialable. This file should be placed in In_private folder.
- **variable_selection.xlsx**
- **mb1958_MRI_freesurfer_DK.csv**
- **demographics.mat**

### Output:

- **plot_data.mat**
    The generated file contains the following fields:
    - subID_genetics
    - subID_imaging
    - subID_imaging_genetics
    - subID_biochemical
    - subID_biochemical_genetics
    - eid_with_MRI_freesurfer_DK
    - eid_genetics
    - eid_with_MRI_freesurfer_DK_genetics
    - eid_with_biochemical
    - eid_with_biochemical_genetics
    - Number_data
    - demographic_matrix
    - labels
    - organs
    - systems
    
## Step 11: code_diagnosis/SplitHealthyControlsForGWAS.m

This code splits the data into several control groups for further analysis.

### Input:
- **plot_data.mat**: generated in Step 10.
- **QC_passed_samples.csv**: the samples who pass both sample and SNP QC. This file should be placed in In_private folder.
- **DiseaseGroupSubID.mat**: generated in Step 8.
- **chr_id_sex.csv**: participants with genetic data available. This file should be placed in In_private folder.


### Output:

- **SplitControlGroups.mat**
    The generated file contains the following fields:
    - control_groups_labels: label for each control group.
    - control_groups: a cell array containing 21 cells, each corresponding to ID/sex/age of controls groups.
    
The generated controls group discription of each lable is as follows:
- **Control_1_subID_GWAS**: GWAS control group, randomly selecting 25k individuals who have biochemcial data but do not have neuroimaging data - to be used to **perform GWAS**. This contains 3 cell arrays of length 62, which is the number of biochemical traits data availabe in UKB.
- **Control_2_subID_imaging**: Imaging control group encompassing all individuals who are classified as controls who also have imaging data – to be used for **normative modeling of brain data**
- **Control_3_subID_genetic**: Genetics control group encompassing all individuals not in the GWAS control group - to be used for **PRS clustering analysis**
- **Control_4_subID_imaging_genetics**: Imaging/genetics control group who also have both imaging and genetics data – to be used for **combined imaging/prs analysis**
- **Control_5_subID_biochemical**: Biochemical control groups excluding those in the GWAS analysis – to be used for **normative modeling** (3 cell arrays of length 62).
- **Control_6_subID_biochemical_genetics**: Biochemical/genetics control group excluding those in the GWAS analysis – to be used for **GWAS validation** (3 cell arrays of length 62).
- **Control_7_subID_biochemical_genetics_imaging**: Biochemical/genetics/imaging control group excluding those in the GWAS analysis – to be used for **p-integration** (3 cell arrays of length 62).
Each control group as its respective age and sex variables saved as well in format of Control_<control_num>_age_<group> and Control_<control_num>_sex_<group> respectively. Please refer to **control_groups_labels** variable for the description of each respective field in **control_groups** file.

## Step 12: code_find_imaging_genetics_subs/Identify_subIDs_for_split_data.m

This code will aggregate demographics data for each control group.

### Input:
- **SplitControlGroups.mat**: generated in Step 11.
- **demographics.mat**
- **data_fields_53_52_34_dates.csv**


### Output:
- **plot_data_congrol_groups.mat** with the field demographic_matrix.

## Steps 13: Generate_figures/demographic figures.R

This code will generate demographic figures for data.

### Input:
- **plot_data.mat**: generated in Step 10.
- **plot_data_congrol_groups.mat**: generated in Step 12.
- **DiseaseGroupSubID.mat**: generated in Step 8.
- **QC_passed_samples.csv**: list of individual IDs who passed sample and genetic QC. This file should be placed in In_private folder.

### Output:

- **Count_<DATA>.pdf**: frequency of each diagnostic label for each imaging, genetics, and imaging_genetics, biochemical, and biochemical_genetics data plotted by gender.
- **data_frequency.csv**: frequency of each diagnostic label for each imaging, genetics, imaging_genetics, biochemical, and biochemical_genetics data.
- **data_demographics.csv**: the data demographics (N, age, sex, ethnicity) average/SD for each imaging, genetics, and imaging_genetics, biochemical, and biochemical_genetics data.
- **data_demographics_control_groups.csv**: the data demographics (N, age, sex, ethnicity) average/SD for each control group data.
 
 
 # Biochem codes
 
 ## Step 1: code_biochemical/read_in_biochemical_data.m
 
 This code will read in biochemical data and prepare inputs for GAM modelling
 
 ### Input:
 
 ### Output:
 
 - **.mat files for each trait: e.g., GAMLSSinput_Biochem_Alanine_aminotransferase_ALT.mat
 
 ## Step 2: Run GAMLSS modelling in R (best to use a cluster to run each trait in parralel)
 
 This code will run GAMLSS on a portion of healthy controls **Control_5_subID_biochemical** generated in diagnostic code
 - It will select the most appropriate family distribution for each trait considered 
 
  ### Input:
  -**.mat files for each trait: e.g., GAMLSSinput_Biochem_Alanine_aminotransferase_ALT.mat
 
  ### Output (for each trait):
 -**GAMLSSout_FIT_eval_famDist_Platelet_count_Healthy.mat contains fit information evaluated for each family distribution
 -**GAMLSSout_FIT_main_Alanine_aminotransferase_ALT_Healthy.mat contains: 
        - fit information for main distribution (KS statistics)
        - deviation scores for healthy individuals on which GAMs was run
 -**GAMLSSout_main_OPTAlanine_aminotransferase_ALT__Healthy_predicted_sex0.mat contains:
        - z_scores_unseen_subs
        - z_scores_unseen_subs_BCT
        - predicted_quantiles
      Also repeated for sex1 (males)
 
 ## Step 3a: code_biochemical/Deviations_biochemical/check_and_plot_std_of_deviations.m
 
 This code is used to check the fit statistics from GAMLSS modelling and to generate inputs for Figure 1
 
 ### Input:
 
-**GAMLSSinput_Biochem_Alanine_aminotransferase_ALT.mat generated in Step 1
-**GAMLSSout_FIT_eval_famDist_Platelet_count_Healthy.mat generated in Step 2
-**GAMLSSout_main_OPTAlanine_aminotransferase_ALT__Healthy_predicted_sex0.mat generated in Step 2
-**GAMLSSout_main_OPTAlanine_aminotransferase_ALT__Healthy_predicted_sex0.mat generated in Step 2

 ### Output:
 
 -**output_from_check_and_plot_std_of_deviations.m (used to generate main heterogeneity figure)
 
 ## Step 3b: code_biochemical/Deviations_biochemical/COMORBIDITY_check_and_plot_std_of_deviations.m
 
 This code is used to determine whether main results from Step 3a are consistent with those obtained after removing individuals with comorbodities from each diagnostic group. 
 
  ### Input:
 
  ### Output:
 
 ## Step 3c code_biochemical/Deviations_biochemical/SAMPLE_SIZE_check_and_plot_std_of_deviations.m
 
 This code is used to determine whether ain results from Step 3a are consistent with those obtained after using the sample number of individuals per diagnostic group to compute the SD
 
 ## Step 3d: Figure
 
 
 ## Step 4b: code_biochemical/Deviations_biochemical/Heirarchy_check_and_plot_std_of_deviations.m
 
 This code is used to estimate heterogeneity in specific diagnostic subtypes. Note that resampling with replacement is used to yeild confidence intervals for SD. 
 
 Need to define num_resamples (number of samples)
 
  ### Input:
 
  ### Output:
 
 ## Step 4b: Generate_figures/figure_heterogeneity_biochem_Diagnosticheirarchy_BRANCHING.m
 
 
