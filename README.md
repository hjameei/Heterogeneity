# Heterogeneity
This project aims to map diagnosis heterogeneity in [UK Biobank dataset](https://bbams.ndph.ox.ac.uk/ams/).

## Preliminary information 
### Diagnostic codes
The diagnosis information of individuals are reported in formats of four different sources:
- GP Clinical data (readv2/readv3)
- Self reported diagnosis (Cancer/Noncancer)
- ICD codes relating inpatients (ICD9/ICD10)
- Self reported Mental Health Questionnaire (MHQ)

The  (available under name gp_clinical, informations about how to obtain this table can be found in [UBK Primary care Documentation](https://biobank.ndph.ox.ac.uk/showcase/showcase/docs/primary_care_data.pdf)).

## Steps 1: code_diagnosis/Find_daignostic_codes.m

This code goes through the diseases of interest provided in a file named "Diseases_of_interest.xlsx", and finds all the diagnostic codes and descriptions of theses diseases, including ICD9/10, read v2, MHQ codes. 

 ### Input:
 - **Diseases_of_interest.xlsx**
    The main sheet is the list of diseases of interest, detailed by their exact labels, the organ they are related to, they body system they involve, and the keywords to find the diseases by in the code/description of diagnostic codes.
    Each disease of interest has its own include and exclude criteria to match the exact description of the diagnostic codes, which are detailed in the remaining 8 sheets of the excel file.

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

This file will find a mapping between codes from ICD9/10, and read_v2 and read_v3.

### Input:

- **disease_codes.mat**, generated during the previsous step.

- **all_lkps_maps_v3.xlsx**: a lookup table for . This table is available to download ([page 17 of UKB instructions](https://biobank.ndph.ox.ac.uk/showcase/showcase/auxdata/primarycare_codings.zip)).

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
    



