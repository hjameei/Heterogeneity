user<- readline(prompt="Enter user: 1 for Maria, 2 for Hadis, 3 for others ")

if (user == "1") {
  Out_private ='/Users/mq669/Dropbox (Partners HealthCare)/DOCUMENTS/POSTDOC_MNC/NHMRC Investigator grant/DATA MANAGEMENT/HETEROGENEITY2/Private_data/Private_data_out'
} else if(user == "2") {
  Out_private = '/Users/hadisjameei/Library/CloudStorage/OneDrive-TheUniversityofMelbourne/PhD research/UK Biobank/Medical data'
} else {
  Out_private = ''
}

data_path = paste0(Out_private, '/plot_data.mat')

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


cross_dsads <- readMat(data_path)

df_numbers = do.call(rbind.data.frame, cross_dsads$labels)
df_numbers = cbind(df_numbers, cross_dsads$Number.data)
colnames(df_numbers)[1] = "Diagnosis"
colnames(df_numbers)[2] = "Imaging"
colnames(df_numbers)[3] = "Genetics"
colnames(df_numbers)[4] = "Both"


df_demo = as.data.frame(cross_dsads$demographic.matrix);

names(df_demo)[1] = "Imaging data"
names(df_demo)[2] = "Genetics data"
names(df_demo)[3] = "Imaging+Genetics data"

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

imagings = cross_dsads$subID.imaging
disease_labels = c()
for (i in seq(1, length(imagings))){
  disease_labels = c(disease_labels, rep(df_numbers[i,1], df_numbers[i,2]))
}
imagings = ldply(imagings, data.frame)
imagings = cbind(imagings, disease_labels)
imagings$X2 = as.factor(imagings$X2)

genetics = cross_dsads$subID.genetics
disease_labels = c()
for (i in seq(1, length(genetics))){
  disease_labels = c(disease_labels, rep(df_numbers[i,1], df_numbers[i,3]))
}
genetics = ldply(genetics, data.frame)
genetics = cbind(genetics, disease_labels)
genetics$X2 = as.factor(genetics$X2)

imaging_genetics = cross_dsads$subID.imaging.genetics
disease_labels = c()
for (i in seq(1, length(imaging_genetics))){
  disease_labels = c(disease_labels, rep(df_numbers[i,1], df_numbers[i,4]))
}
imaging_genetics = ldply(imaging_genetics, data.frame)
imaging_genetics = cbind(imaging_genetics, disease_labels)
imaging_genetics$X2 = as.factor(imaging_genetics$X2)

rownames(df_numbers) <- NULL
rownames(demographic_dataframe) <- NULL

stargazer(df_numbers,                 # Export txt
          summary = FALSE,
          type = "text",
          out = paste0(output_dir, "/data_requency.txt"))

stargazer(demographic_dataframe,                 # Export txt
          summary = FALSE,
          type = "text",
          out = paste0(output_dir, "/data_demographic_txt.txt"))


pdf(file=paste0(output_dir, "/Count_imaging.pdf"), height = 9 , width = 21)
count_imaging = ggplot(data=imagings, aes(x=disease_labels, fill=X2))+
  geom_bar(position="dodge", width = 0.7)+
  xlab("Diagnosis")+
  ylab("Number of participants")+
  scale_fill_discrete(name = "Sex",labels=c('Female', 'Male'))+# 0 is female
  theme(axis.text.x = element_text(angle = 45,hjust=1), 
        text = element_text(size=20))
grid.arrange(count_imaging)
dev.off()

pdf(file=paste0(output_dir, "/Count_genetics.pdf"), height = 9 , width = 21)
count_genetics = ggplot(data=genetics, aes(x=disease_labels, fill=X2))+
  geom_bar(position="dodge", width = 0.7)+
  xlab("Diagnosis")+
  ylab("Number of participants")+
  scale_fill_discrete(name = "Sex",labels=c('Female', 'Male'))+# 0 is female
  theme(axis.text.x = element_text(angle = 45,hjust=1), 
        text = element_text(size=20))
grid.arrange(count_genetics)
dev.off()

pdf(file=paste0(output_dir, "/Count_imaging_genetics.pdf"), height = 9 , width = 21)
count_imaging_genetics = ggplot(data=imaging_genetics, aes(x=disease_labels, fill=X2))+
  geom_bar(position="dodge", width = 0.7)+
  xlab("Diagnosis")+
  ylab("Number of participants")+
  scale_fill_discrete(name = "Sex",labels=c('Female', 'Male'))+# 0 is female
  theme(axis.text.x = element_text(angle = 45,hjust=1), 
        text = element_text(size=20))
grid.arrange(count_imaging_genetics)
dev.off()



