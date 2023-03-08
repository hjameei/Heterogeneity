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

## Steps 2: code_diagnosis/Map_icd_read2_read3.m

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
    
## Steps 3: code_diagnosis/Identify_subIDs_icd_self.m

This code will identify subject IDs with any one of the diagnoses, mapped by ICD9/ICD10 and self-reports. 

### Input:

- **Diseases_of_interest.xlsx**
- **icd_diseaseCode_mapped.mat**, generated in Step 2.
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

## Steps 4: code_diagnosis/Identify_subIDs_mhq.m

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


## Steps 5: code_diagnosis/Identify_subIDs_gp_clinical.m

This code will identify subject IDs with any one of the diagnoses, according to GP clinical. 

### Input:

- **data_fields_53_52_34_dates.csv**
- **icd_diseaseCode_mapped.mat**, generated in Step 2.
- **gp_clinical_06_10_22.txt**: which is primary care data. These fields are updated regularly and can be redownloaded if we have an updated .enc file. Instructions to download primary care data are shown in [primary_care_data.pdf](https://biobank.ndph.ox.ac.uk/showcase/showcase/auxdata/primarycare_codings.zip).

### Output:
- Blocks of data with prefix **subID_GPClinical**, containing the following ifnormation:
    - subID_readv2
    - subID_readv3
    - subID_completed_gp
    - date_completed_readv2
    - date_completed_readv3
