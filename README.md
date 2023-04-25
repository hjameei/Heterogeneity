# Heterogeneity
This project aims to map diagnosis heterogeneity in [UK Biobank dataset](https://bbams.ndph.ox.ac.uk/ams/).

## Preliminary information 
### Diagnostic codes
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
- **chr_id_sex.csv**: participants with genetic data avialable.
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

This code splits the data into two groups, one for GWAS analysis and one for polygenic risk profiling.

### Input:
- **plot_data.mat**: generated in Step 10.
- **QC_passed_samples.csv**: the samples who pass both sample and SNP QC.
- **DiseaseGroupSubID.mat**: generated in Step 8.
- **chr_id_sex.csv**: participants with genetic data available.


### Output:

- **Split_GWAS_biochemical.mat**
    The generated file contains the following fields:
    - subID_GWAS
    - subID_PRS_analysis
    - age_GWAS
    - age_PRS_analysis
    - sex_GWAS
    - sex_PRS_analysis

## Steps 12: Generate_figures/demographic figures.R

This code will generate demographic figures for data.

### Input:
- **plot_data.mat**: generated in Step 9.

### Output:

- **Count_imaging_genetics.pdf**: frequency of each diagnostic label for each imaging, genetics, and imaging_genetics data plotted by gender.
- **data_requency.txt**: frequency of each diagnostic label for each imaging, genetics, and imaging_genetics data.
- **data_demographic_txt.txt**: the data demographics (N, age, sex, ethnicity) average/SD for each imaging, genetics, and imaging_genetics data.
