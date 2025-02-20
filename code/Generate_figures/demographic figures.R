user<- readline(prompt="Enter user: 1 for Maria, 2 for Hadis, 3 for others\n")

if (user == "1") {
  In_private = '/Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/HETEROGENEITY2/Private_data/'
  Out_private ='/Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/HETEROGENEITY2/Private_data/Private_data_out'
} else if(user == "2") {
  In_private = '/Users/hadisjameei/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/PhD research/UK Biobank/Medical data/'
  Out_private = '/Users/hadisjameei/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/PhD research/UK Biobank/Medical data'
} else {
  In_private = ''
  Out_private = ''
}

eid_qc_passed=read.csv(paste0(In_private, 'QC_passed_samples.csv'), header = FALSE)

data_path = paste0(Out_private, '/plot_data.mat')
path_control_group = paste0(Out_private, '/plot_data_congrol_groups.mat')
disease_path = paste0(Out_private, '/DiseaseGroupSubID.mat')
output_dir <- file.path(Out_private, 'Plots')

if (!dir.exists(output_dir)){
  dir.create(output_dir)
} 

library(R.matlab)
library(stargazer)
library(plyr)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(stringr)

cross_dsads <- readMat(data_path)
control_group <- readMat(path_control_group)


dx_labels = do.call(rbind.data.frame, cross_dsads$labels)
dx_organs = do.call(rbind.data.frame, cross_dsads$organs )
systems = c()
for (i in 1:nrow(dx_organs)){
  if (length(cross_dsads$system[[i]][[1]]) ==0){
    systems = c(systems, NA)
  }
  else{
    systems = c(systems, cross_dsads$system[[i]][[1]])
  }
}
dx_systems = as.data.frame(systems)
colnames(dx_systems) <- colnames(dx_labels)

for(i in seq(1, nrow(dx_organs))){
  if (grepl("blood", dx_organs[i,1], fixed = TRUE)){
    dx_organs[i,1] <- "Blood-forming organs"
  }
}

ind_healthy = str_detect(dx_organs[,1], "Healthy")
ind_psychiatry = str_detect(dx_organs[,1], "Psychiatric")
ind_brain_alone = (dx_organs[,1] == fixed("Brain"))

dx_organs_factors = as.factor(unique(c(dx_organs[ind_healthy,1], 
                            dx_organs[ind_psychiatry,1],
                            dx_organs[ind_brain_alone,1], 
                            dx_organs[-c(ind_healthy, ind_psychiatry,ind_brain_alone),1])
                          ))
                              

df_numbers = cbind(dx_labels, dx_organs, dx_systems, cross_dsads$Number.data)
colnames(df_numbers)[1] = "Diagnosis"
colnames(df_numbers)[2] = "Organ"
colnames(df_numbers)[3] = "System"
colnames(df_numbers)[4] = "Imaging"
colnames(df_numbers)[5] = "Genetics"
colnames(df_numbers)[6] = "Imagning_Genetics"
colnames(df_numbers)[7] = "Biochemical"
colnames(df_numbers)[8] = "Biochemical_Genetics"


df_demo = as.data.frame(cross_dsads$demographic.matrix);

names(df_demo)[1] = "Imaging data"
names(df_demo)[2] = "Genetics data"
names(df_demo)[3] = "Imaging+Genetics data"
names(df_demo)[4] = "Biochemical data"
names(df_demo)[5] = "Biochemical+Genetics data"

row_names = c("N", "Age Mean(SD)", " Sex (M %)", "Ethnicity",
              "White N(%)", "Non-white N(%)")
N = as.character(round(df_demo[1,]))
age_mean = as.character(format(round(df_demo[2,],3),nsmall=2))
age_std = as.character(format(round(df_demo[3,],3),nsmall=2))
age= paste0(age_mean, " (" ,age_std, ")")
sex = as.character(format(round(df_demo[4,]*100,3),nsmall=2))
Ethnicity_white_n = as.character(round(df_demo[5,],3))
Ethnicity_white_freq = as.character(format(round(df_demo[6,]*100,3),nsmall=2))
Ethnicity_white = paste0(Ethnicity_white_n, " (" ,Ethnicity_white_freq, " %)")
Ethnicity_nonwhite_n = as.character(round(df_demo[7,],3))
Ethnicity_nonwhite_freq = as.character(format(round(df_demo[8,]*100,3),nsmall=2))
Ethnicity_nonwhite = paste0(Ethnicity_nonwhite_n, " (" ,Ethnicity_nonwhite_freq, " %)")
Ethnicity = c("", "", "")
demographic_dataframe = as.data.frame(rbind(N, age, sex, Ethnicity, Ethnicity_white, Ethnicity_nonwhite))
demographic_dataframe = cbind(row_names, demographic_dataframe)
names(demographic_dataframe)[1] = ""
names(demographic_dataframe)[2] = "Imaging data"
names(demographic_dataframe)[3] = "Genetics data"
names(demographic_dataframe)[4] = "Imaging+Genetics data"
names(demographic_dataframe)[5] = "Biochemical data"
names(demographic_dataframe)[6] = "Biochemical+Genetics data"


imagings = cross_dsads$subID.imaging
disease_labels = c()
disease_organs = c()
disease_systems = c()
for (i in seq(1, length(imagings))){
  disease_labels = c(disease_labels, rep(df_numbers[i,1], df_numbers[i,4]))
  disease_organs = c(disease_organs, rep(df_numbers[i,2], df_numbers[i,4]))
  disease_systems = c(disease_systems, rep(df_numbers[i,3], df_numbers[i,4]))
}
imagings = ldply(imagings, data.frame)
imagings = cbind(imagings, disease_labels, disease_organs, disease_systems)
imagings$X2 = as.factor(imagings$X2)
imagings$disease_organs = factor(imagings$disease_organs, 
                                 levels=dx_organs_factors)


genetics = cross_dsads$subID.genetics
disease_labels = c()
disease_organs = c()
disease_systems = c()
for (i in seq(1, length(genetics))){
  disease_labels = c(disease_labels, rep(df_numbers[i,1], df_numbers[i,5]))
  disease_organs = c(disease_organs, rep(df_numbers[i,2], df_numbers[i,5]))
  disease_systems = c(disease_systems, rep(df_numbers[i,3], df_numbers[i,5]))
}
genetics = ldply(genetics, data.frame)
genetics = cbind(genetics, disease_labels, disease_organs, disease_systems)
genetics$X2 = as.factor(genetics$X2)
genetics$disease_organs = factor(genetics$disease_organs, levels=dx_organs_factors)


imaging_genetics = cross_dsads$subID.imaging.genetics
disease_labels = c()
disease_organs = c()
disease_systems = c()
for (i in seq(1, length(imaging_genetics))){
  disease_labels = c(disease_labels, rep(df_numbers[i,1], df_numbers[i,6]))
  disease_organs = c(disease_organs, rep(df_numbers[i,2], df_numbers[i,6]))
  disease_systems = c(disease_systems, rep(df_numbers[i,3], df_numbers[i,6]))
}
imaging_genetics = ldply(imaging_genetics, data.frame)
imaging_genetics = cbind(imaging_genetics, disease_labels, disease_organs, disease_systems)
imaging_genetics$X2 = as.factor(imaging_genetics$X2)
imaging_genetics$disease_organs = factor(imaging_genetics$disease_organs, levels=dx_organs_factors)


biochemical = cross_dsads$subID.biochemical
disease_labels = c()
disease_organs = c()
disease_systems = c()
for (i in seq(1, length(biochemical))){
  disease_labels = c(disease_labels, rep(df_numbers[i,1], df_numbers[i,7]))
  disease_organs = c(disease_organs, rep(df_numbers[i,2], df_numbers[i,7]))
  disease_systems = c(disease_systems, rep(df_numbers[i,3], df_numbers[i,7]))
}
biochemical = ldply(biochemical, data.frame)
biochemical = cbind(biochemical, disease_labels, disease_organs, disease_systems)
biochemical$X2 = as.factor(biochemical$X2)
biochemical$disease_organs = factor(biochemical$disease_organs, levels=dx_organs_factors)


biochemical_genetics = cross_dsads$subID.biochemical.genetics
disease_labels = c()
disease_organs = c()
disease_systems = c()
for (i in seq(1, length(biochemical_genetics))){
  disease_labels = c(disease_labels, rep(df_numbers[i,1], df_numbers[i,8]))
  disease_organs = c(disease_organs, rep(df_numbers[i,2], df_numbers[i,8]))
  disease_systems = c(disease_systems, rep(df_numbers[i,3], df_numbers[i,8]))
}
biochemical_genetics = ldply(biochemical_genetics, data.frame)
biochemical_genetics = cbind(biochemical_genetics, disease_labels, disease_organs, disease_systems)
biochemical_genetics$X2 = as.factor(biochemical_genetics$X2)
biochemical_genetics$disease_organs = factor(biochemical_genetics$disease_organs, levels=dx_organs_factors)


biochemical_genetics2 = biochemical_genetics[biochemical_genetics$X1 %in% eid_qc_passed$V1,]
biochemical_genetics2 = biochemical_genetics2[biochemical_genetics2$disease_labels %in% dx_labels[1:56,],]

disease_groups <- readMat(disease_path)
included_diagnosis = do.call(rbind.data.frame, disease_groups$included.diagnosis.maria )
biochemical_genetics2 = biochemical_genetics2[biochemical_genetics2$disease_labels %in% included_diagnosis[,1],]


pdf(file=paste0(output_dir, "/Count_imaging.pdf"), height = 30 , width = 30)
count_imaging = ggplot(data=imagings, aes(x=disease_labels, fill=X2))+
  geom_bar(position=position_dodge2(width = 0.7, preserve = "single", 
                                    reverse=TRUE))+
  scale_fill_discrete(name = "Sex",labels=c('Female', 'Male'))+# 0 is female
  facet_grid(.~disease_organs, scales = "free", space = "free")+
  xlab("Diagnosis")+
  ylab("Number of participants")+
  theme(axis.text.x = element_text(angle = 45,hjust=1),
        text = element_text(size=20),
        strip.text.x = element_text(angle = 90, size=12, face = "bold"))
grid.arrange(count_imaging)
dev.off()

pdf(file=paste0(output_dir, "/Count_genetics.pdf"), height = 30 , width = 30)
count_genetics = ggplot(data=genetics, aes(x=disease_labels, fill=X2))+
  geom_bar(position=position_dodge2(width = 0.7, preserve = "single", 
                                    reverse=TRUE))+
  scale_fill_discrete(name = "Sex",labels=c('Female', 'Male'))+# 0 is female
  facet_grid(.~disease_organs, scales = "free", space = "free")+
  xlab("Diagnosis")+
  ylab("Number of participants")+
  theme(axis.text.x = element_text(angle = 45,hjust=1),
        text = element_text(size=20),
        strip.text.x = element_text(angle = 90, size=12, face = "bold"))
grid.arrange(count_genetics)
dev.off()

pdf(file=paste0(output_dir, "/Count_imaging_genetics.pdf"), height = 30 , width = 30)
count_imaging_genetics = ggplot(data=imaging_genetics, aes(x=disease_labels, fill=X2))+
  geom_bar(position=position_dodge2(width = 0.7, preserve = "single", 
                                    reverse=TRUE))+
  scale_fill_discrete(name = "Sex",labels=c('Female', 'Male'))+# 0 is female
  facet_grid(.~disease_organs, scales = "free", space = "free")+
  xlab("Diagnosis")+
  ylab("Number of participants")+
  theme(axis.text.x = element_text(angle = 45,hjust=1),
        text = element_text(size=20),
        strip.text.x = element_text(angle = 90, size=12, face = "bold"))
grid.arrange(count_imaging_genetics)
dev.off()

pdf(file=paste0(output_dir, "/Count_biochemical.pdf"), height = 30 , width = 30)
count_imaging_genetics = ggplot(data=biochemical, aes(x=disease_labels, fill=X2))+
  geom_bar(position=position_dodge2(width = 0.7, preserve = "single", 
                                    reverse=TRUE))+
  scale_fill_discrete(name = "Sex",labels=c('Female', 'Male'))+# 0 is female
  facet_grid(.~disease_organs, scales = "free", space = "free")+
  xlab("Diagnosis")+
  ylab("Number of participants")+
  theme(axis.text.x = element_text(angle = 45,hjust=1),
        text = element_text(size=20),
        strip.text.x = element_text(angle = 90, size=12, face = "bold"))
grid.arrange(count_imaging_genetics)
dev.off()


pdf(file=paste0(output_dir, "/Count_biochemical_genetics.pdf"), height = 30 , width = 45)
count_imaging_genetics = ggplot(data=biochemical_genetics, aes(x=disease_labels, fill=X2))+
  geom_bar(position=position_dodge2(width = 0.7, preserve = "single", 
                                    reverse=TRUE))+
  scale_fill_discrete(name = "Sex",labels=c('Female', 'Male'))+# 0 is female
  facet_grid(.~disease_organs, scales = "free", space = "free")+
  xlab("Diagnosis")+
  ylab("Number of participants")+
  theme(axis.text.x = element_text(angle = 45,hjust=1,size = 25, face = "bold"),
        axis.title = element_text(size = 40), 
        axis.text.y = element_text(size = 30),
        title = element_text(size = 30),
        text = element_text(size=25),
        strip.text.x = element_text(angle = 90, size=25, face = "bold"),
        legend.text = element_text(size=20))
grid.arrange(count_imaging_genetics)
dev.off()


df_numbers$Organ = factor(df_numbers$Organ, levels=dx_organs_factors)
df_numbers = df_numbers[order(df_numbers$Organ),]

rownames(df_numbers) <- NULL
rownames(demographic_dataframe) <- NULL


write.csv(df_numbers[,-c(3)], paste0(output_dir, "/data_frequency.csv"), row.names=TRUE)
write.csv(demographic_dataframe, paste0(output_dir, "/data_demographics.csv"), row.names=TRUE)


df_demo = as.data.frame(control_group$demographic.matrix)

names(df_demo)[1] = "Control 1"
names(df_demo)[2] = "Control 2"
names(df_demo)[3] = "Control 3"
names(df_demo)[4] = "Control 4"
names(df_demo)[5] = "Control 5"
names(df_demo)[6] = "Control 6"
names(df_demo)[7] = "Control 7"

row_names = c("N", "Age Mean(SD)", " Sex (M %)", "Ethnicity",
              "White N(%)", "Non-white N(%)")
N = as.character(round(df_demo[1,]))
age_mean = as.character(format(round(df_demo[2,],3),nsmall=2))
age_std = as.character(format(round(df_demo[3,],3),nsmall=2))
age= paste0(age_mean, " (" ,age_std, ")")
sex = as.character(format(round(df_demo[4,]*100,3),nsmall=2))
Ethnicity_white_n = as.character(round(df_demo[5,],3))
Ethnicity_white_freq = as.character(format(round(df_demo[6,]*100,3),nsmall=2))
Ethnicity_white = paste0(Ethnicity_white_n, " (" ,Ethnicity_white_freq, " %)")
Ethnicity_nonwhite_n = as.character(round(df_demo[7,],3))
Ethnicity_nonwhite_freq = as.character(format(round(df_demo[8,]*100,3),nsmall=2))
Ethnicity_nonwhite = paste0(Ethnicity_nonwhite_n, " (" ,Ethnicity_nonwhite_freq, " %)")
Ethnicity = rep("", length(N))
demographic_dataframe = as.data.frame(rbind(N, age, sex, Ethnicity, Ethnicity_white, Ethnicity_nonwhite))
demographic_dataframe = cbind(row_names, demographic_dataframe)

names(demographic_dataframe)[1] = ""
names(demographic_dataframe)[2] = "Control 1"
names(demographic_dataframe)[3] = "Control 2"
names(demographic_dataframe)[4] = "Control 3"
names(demographic_dataframe)[5] = "Control 4"
names(demographic_dataframe)[6] = "Control 5"
names(demographic_dataframe)[7] = "Control 6"
names(demographic_dataframe)[8] = "Control 7"
rownames(demographic_dataframe) <- NULL

write.csv(demographic_dataframe, paste0(output_dir, "/data_demographics_control_groups.csv"), row.names=TRUE)