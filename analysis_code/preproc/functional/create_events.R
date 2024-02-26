#wd <- setwd("C:/Users/Tilsley/Desktop/faces/R")

#install.packages("InformationValue")
library("InformationValue")
library(ggplot2)
library(dplyr)
library(tidyverse)
library(data.table)


################# GETTING PYTHON COMMAND INPUTS ######################

args <- commandArgs(trailingOnly = TRUE)
subject_number = as.character(args[1])
session_number = as.character(args[2])
subject_type = as.character(args[3]) 
task_id = as.character(args[4])
wd = as.character(args[5])
rawsubsessdir = as.character(args[6])

## Uncomment for online testing 

#subject_number = "8761"
#session_number = "02"
#subject_type = "P"
#task_id = "faces"
#wd = "/Users/penny/disks/meso_shared/bio7/derivatives/R/beh/faces"
#rawsubsessdir = "/Users/penny/disks/meso_shared/bio7/sourcedata/beh/faces/sub-8761/ses-02"

setwd(wd)


######### DATA ORGANISATION #####################
data_raw_list <- list.files("rawsubsessdir")
#data_raw_list <- list.files("data_raw")

data_list <- subset(data_raw_list, endsWith(data_raw_list, 'data.csv'))
design_list <- subset(data_raw_list, endsWith(data_raw_list, 'design.csv'))
setup_list <- subset(data_raw_list, endsWith(data_raw_list, 'setup.txt'))

for (s in data_list) {
  
  #### Opening relevant files for subject (data and design file)
  s_sub <- substr(s,1,(nchar(s)-8))  
  
  task_data <- read.csv2(paste0(wd,"/data_raw/",s),header=TRUE,sep=",",na.strings = "NaN")
  task_design <- read.csv2(paste0(wd,"/data_raw/",s_sub,"design.csv"),header=TRUE,sep=",",na.strings = "NaN")
  setup <- read.csv2(paste0(wd,"/data_raw/",s_sub,"setup.txt"),header=TRUE,sep=",",na.strings = "NaN")
  
  
  
  #### Binding both files (data and design file) and organising
  task <- cbind(task_design, task_data)
  
  task_colnames <- colnames(task)
  
  task <- task %>% mutate_at(c(1:4,12,14,16:18,21,23,29,31,33:39,41:45,51:52,55:79,82:83), as.character)
  
  task <- task %>% mutate_at(c(1:4,12,14,16:18,21,23,29,31,33:39,41:45,51:52,55:79,82:83), as.numeric)
  
  task <- task %>% mutate_at(c(5:11,13,15,19:20,22,24:28,30,32,40,46:50,53:54,80:81), as.factor)
  
  
  
  #### Mapping key responses/cues from setup.txt (translates --> english)
  
  #setup$cue_position_one = "top"
  #setup$cue_response_buttons_one = "-index-"
  #setup$cue_emotion_one = "joie?" | "happy?"
  #setup$cue_sex_one = "male?" | "male?" for cb version 1 or, if cb version 2 = "femelle?" | "female?"
  #task$response_key_name == "right1"
  
  setup$emo1_cut = substr(as.character(setup$cue_emotion_one[1]),1,(nchar(as.character(setup$cue_emotion_one[1]))-1))
  setup$emo1_check <- ifelse(setup$emo1_cut == "happy" | setup$emo1_cut == "joie","happy","fear")
  
  setup$sex1_cut = substr(as.character(setup$cue_sex_one[1]),1,(nchar(as.character(setup$cue_sex_one[1]))-1))
  setup$sex1_check <- ifelse(setup$sex1_cut == "male","male","female")                           
  
  #setup$cue_position_two = "bottom"
  #setup$cue_response_buttons_two = "-pouce-" 
  #setup$cue_emotion_two = "peur?" | "fear?"
  #setup$cue_sex_two = "femelle?" | "female?" for cb version 1 or, if cb version 2 = "male?" | "male?"
  #task$response_key_name == "right2"
  
  setup$emo2_cut = substr(as.character(setup$cue_emotion_two[1]),1,(nchar(as.character(setup$cue_emotion_two[1]))-1))
  setup$emo2_check <- ifelse(setup$emo2_cut == "happy" | setup$emo2_cut == "joie","happy","fear")
  
  setup$sex2_cut = substr(as.character(setup$cue_sex_two[1]),1,(nchar(as.character(setup$cue_sex_two[1]))-1))
  setup$sex2_check <- ifelse(setup$sex2_cut == "male","male","female")  
  

  
  #### Checking if response correct
  
  # 1. defining what participant chose
  # by using cue mapping above of 1:top/index or 2:bottom/thumb, to define the response chosen by 1:right1 or 2:right2
  task <- task %>%
    mutate(response_choice = case_when((task_trial_type == "T" & response_key_name == "right1") ~ setup$emo1_check,
                                       (task_trial_type == "T" & response_key_name == "right2") ~ setup$emo2_check,
                                       (task_trial_type == "C" & response_key_name == "right1") ~ setup$sex1_check,
                                       (task_trial_type == "C" & response_key_name == "right2") ~ setup$sex2_check))
  
  # 2. checking whether the response chosen matches the stimuli pressented
  task <- task %>%
    mutate(response_correct = case_when((task_trial_type == "T" & response_choice == task_target_emotion) ~ "correct",
                                        (task_trial_type == "T" & response_choice != task_target_emotion) ~ "incorrect",
                                        (task_trial_type == "C" & response_choice == task_stim_sex) ~ "correct",
                                        (task_trial_type == "C" & response_choice != task_stim_sex) ~ "incorrect"))
  
  # 3. transforming choice into binary 1 (correct) 0 (incorrect)
  task <- task %>%
    mutate(response_correct_ref = ifelse(response_correct == "correct",1,0))
  
  
  
  #### Creating new soa categories (mean split) 
  # 1. checking if conscious "Con" or non-conscious "Non-Con"
  task <- task %>%
    mutate(task_soa_categ = case_when((as.numeric(time_soa_reference_num) < mean(as.numeric(task$time_soa_reference_num))) ~ "noncon",
                                        (as.numeric(time_soa_reference_num) >= mean(as.numeric(task$time_soa_reference_num))) ~ "con"))
  
  # 2. transforming choice into binary 1 ("Con") 0 ("Non-Con")
  task <- task %>%
    mutate(task_soa_ref = ifelse(task_soa_categ == "con",1,0))
  
  
  
  #### Creating master soa/emotion category 
  task$task_trial_categ <- paste(task$task_soa_categ,task$task_target_emotion, sep = "_")
  task$task_trial_categ <- gsub("_","",task$task_trial_categ)
  
  
  
  ### Formatting new columns and removing gaps elsewhere
  replace(task$task_trial_categ, task$task_trial_categ=='', NA)
  
  task <- replace(task, task=='', NA)
  task$response_choice <- as.factor(task$response_choice)
  task$response_correct <- as.factor(task$response_correct)
  task$task_soa_categ <- as.factor(task$task_soa_categ)
  task$task_trial_categ <- as.factor(task$task_trial_categ)
  

  
  ### Creating df subset with task_T (emotion choice) and task_C (sex_choice)
  task_colnames <- colnames(task)
  task_T <- task[task$task_trial_type == "T",]
  task_C <- task[task$task_trial_type == "C",]
  
  
  
  #### Saving the new dataframes as .csvs 
  
  write.csv(task_T,paste0(wd,"/data_formatted/",s_sub,"df-T.csv"))
  write.csv(task_C,paste0(wd,"/data_formatted/",s_sub,"df-C.csv"))
  write.csv(task,paste0(wd,"/data_formatted/",s_sub,"df.csv"))
  write.csv(setup,paste0(wd,"/data_formatted/",s_sub,"setup.csv"))
  
  
  
  #### Creating onsets_tsvs

  onset_cols <- c("onset","duration","trial_type","reaction_time","response_time","response_correct","duration_isi", "stim_file", "trial_type_consc", "trial_type_emo")
  onsets_tsv <- data.frame(matrix(NA,ncol=length(onset_cols),nrow=nrow(task)))
  colnames(onsets_tsv) <- onset_cols
  
  # Essential Columns
  onsets_tsv$onset <- task$onset_target - task$onset_run[1]
  onsets_tsv$duration <- task$onset_mask - task$onset_target
  onsets_tsv$trial_type <- task$task_trial_categ
  
  # Extra columns 
  onsets_tsv$reaction_time <- task$reaction_time
  onsets_tsv$response_time <- task$duration_target + task$duration_mask + task$reaction_time
  onsets_tsv$response_correct <- task$response_correct
  onsets_tsv$stim_file <- task$stim_target_photoname
  onsets_tsv$trial_type_consc <- task$task_soa_categ
  onsets_tsv$trial_type_emo <- task$task_target_emotion
  
  for (j in 1:(nrow(task))) {
    if (j == 1) {
      onsets_tsv$duration_isi[j] <- task$duration_jitter[j]
      } else {
        onsets_tsv$duration_isi[j] <- task$duration_mask[j-1] + task$duration_response[j-1] + task$duration_jitter[j]
      }
  }
  
  write.table(onsets_tsv,paste0(wd,"/onsets/",s_sub,"onsets.tsv"),sep="\t",row.names = FALSE)
  #### End of subject data loop
  
  ###### TASK CALCULATIONS AND GRAPHS - RESPONSES AND SOA ##############
  
  task %>% 
    group_by(time_soa_secs, task_trial_type) %>% 
    summarise(mean = mean(response_correct_ref, na.rm = TRUE)) %>% 
    ggplot(.,aes(x=time_soa_secs,y=mean,col = factor(task_trial_type))) +
    geom_point() +
    geom_smooth(se=F) + 
    ylim(0,1)
  ggsave(paste0(wd,"/figures/combi_",s_sub,"soa_vs_responsecorrect_CvsT.tiff"),width = 4, height = 4)
  
  
  task %>% 
    group_by(task_soa_reference, task_trial_categ) %>% 
    summarise(mean = mean(response_correct_ref, na.rm = TRUE)) %>% 
    ggplot(.,aes(x=task_soa_reference,y=mean, col = factor(task_trial_categ))) +
    geom_point() +
    ylim(0,1)
  ggsave(paste0(wd,"/figures/combi_",s_sub,"soa_vs_responsecorrect_by_categ.tiff"),width = 4, height = 4)
  
  task_T %>% 
    group_by(time_soa_secs, task_target_emotion) %>% 
    summarise(mean = mean(response_correct_ref, na.rm = TRUE)) %>% 
    ggplot(.,aes(x=time_soa_secs,y=mean, col = task_target_emotion)) +
    geom_point() +
    geom_smooth(se=F) + 
    ylim(0,1)
  ggsave(paste0(wd,"/figures/T_",s_sub,"soa_vs_responsecorrect_by_emotion_point.tiff"),width = 6, height = 4)
  
  task_C %>% 
    group_by(time_soa_secs, task_target_emotion) %>% 
    summarise(mean = mean(response_correct_ref, na.rm = TRUE)) %>% 
    ggplot(.,aes(x=time_soa_secs,y=mean, col = task_target_emotion)) +
    geom_point() +
    geom_smooth(se=F) + 
    ylim(0,1)
  ggsave(paste0(wd,"/figures/C_",s_sub,"soa_vs_responsecorrect_by_emotion_point.tiff"),width = 6, height = 4)
  
  task_T %>% 
    group_by(time_soa_secs, stim_location_id) %>% 
    summarise(mean = mean(response_correct_ref, na.rm = TRUE)) %>% 
    ggplot(.,aes(x=time_soa_secs,y=mean, col = stim_location_id)) +
    geom_point() +
    geom_smooth(se=F) + 
    ylim(0,1)
  ggsave(paste0(wd,"/figures/T_",s_sub,"soa_vs_responsecorrect_by_location_point.tiff"),width = 6, height = 4)
  
  task_C %>% 
    group_by(time_soa_secs, stim_location_id) %>% 
    summarise(mean = mean(response_correct_ref, na.rm = TRUE)) %>% 
    ggplot(.,aes(x=time_soa_secs,y=mean, col = stim_location_id)) +
    geom_point() +
    geom_smooth(se=F) + 
    ylim(0,1)
  ggsave(paste0(wd,"/figures/C_",s_sub,"soa_vs_responsecorrect_by_location_point.tiff"),width = 6, height = 4)
  
  
  task %>% 
    group_by(task_trial_type) %>% 
    ggplot(aes(x=task_soa_reference, y=response_correct_ref)) + 
    geom_violin(aes(col = task_trial_type)) +
    ylim(-1,2)
  ggsave(paste0(wd,"/figures/combi_",s_sub,"soa_vs_responsecorrect_violin.tiff"),width = 6, height = 4)
  
  
  task_T %>% 
    ggplot(aes(x=task_soa_reference, y=response_correct_ref)) + 
    geom_violin() +
    geom_jitter(height = 0.1, na.rm = TRUE)
  ggsave(paste0(wd,"/figures/T_",s_sub,"soa_vs_responsecorrect_violin.tiff"),width = 6, height = 4)
  
  task_C %>% 
    ggplot(aes(x=task_soa_reference, y=response_correct_ref)) + 
    geom_violin() +
    geom_jitter(height = 0.1, na.rm = TRUE)
  ggsave(paste0(wd,"/figures/C_",s_sub,"soa_vs_responsecorrect_violin.tiff"),width = 6, height = 4)
  
  ggplot(task_C, aes(x=time_soa_secs, y=response_correct_ref)) + 
    geom_jitter(width = 0.001, height = 0.1, na.rm = TRUE)
  ggsave(paste0(wd,"/figures/C_",s_sub,"soa_vs_responsecorrect_scatter.tiff"),width = 6, height = 4)
  
  ggplot(task_T, aes(x=time_soa_secs, y=response_correct_ref)) + 
    geom_jitter(width = 0.001, height = 0.1, na.rm = TRUE)
  ggsave(paste0(wd,"/figures/T_",s_sub,"soa_vs_responsecorrect_scatter.tiff"),width = 6, height = 4)
  
  
  ggplot(task_T, aes(x=time_soa_secs, y=response_correct_ref, col=response_key_name)) + 
    geom_jitter(height = 0.1, na.rm = TRUE)
  ggsave(paste0(wd,"/figures/T_",s_sub,"soa_vs_responsecorrect_by_responsekey_scatter.tiff"),width = 6, height = 4)
  
  ggplot(task_C, aes(x=time_soa_secs, y=response_correct_ref, col=response_key_name)) + 
    geom_jitter(height = 0.1, na.rm = TRUE)
  ggsave(paste0(wd,"/figures/C_",s_sub,"soa_vs_responsecorrect_by_responsekey_scatter.tiff"),width = 6, height = 4)
  
  
  #### tables 
  table_responsecorrect <- aggregate(round(task_T$response_correct_ref,3), list(round(task_T$time_soa_secs,3)), FUN=mean, na.rm = TRUE)
  
  
  ggplot(task_T, aes(x=as.factor(round(time_soa_secs,3)), y=response_correct_ref, fill=response_key_name)) + 
    geom_bar(position="fill", stat="identity", na.rm = TRUE) +
    xlab("SOA (seconds)") +
    ylab("% Response Correct") + 
    labs(fill = "Response Key")
  ggsave(paste0(wd,"/figures/T_",s_sub,"soa_vs_responsecorrect_by_responsekey_barfreq.tiff"),width = 6, height = 4)
  
  
  ggplot(task_C, aes(x=as.factor(round(time_soa_secs,3)), y=response_correct_ref, fill=response_key_name)) + 
    geom_bar(position="fill", stat="identity", na.rm = TRUE) +
    xlab("SOA (seconds)") +
    ylab("% Response Correct") + 
    labs(fill = "Response Key")
  ggsave(paste0(wd,"/figures/C_",s_sub,"soa_vs_responsecorrect_by_responsekey_barfreq.tiff"),width = 6, height = 4)
  
  
  ggplot(task_C, aes(x=as.factor(round(time_soa_secs,3)), fill=response_key_name)) + 
    geom_bar(position="fill", na.rm = TRUE) +
    xlab("SOA (seconds)") +
    ylab("Frequency") + 
    labs(fill = "Response Key")
  ggsave(paste0(wd,"/figures/C_",s_sub,"soa_vs_responsekey_barfreq.tiff"),width = 6, height = 4)
  
  
  ggplot(task_T, aes(x=as.factor(round(time_soa_secs,3)), fill=response_key_name)) + 
    geom_bar(position="fill", na.rm = TRUE) +
    xlab("SOA (seconds)") +
    ylab("Frequency") + 
    labs(fill = "Response Key")
  ggsave(paste0(wd,"/figures/T_",s_sub,"soa_vs_responsekey_barfreq.tiff"),width = 6, height = 4)
  
  #sex
  ggplot(task, aes(x=as.factor(round(time_soa_secs,3)), fill=stim_sex_id)) + 
    geom_bar(position="fill",na.rm = TRUE) +
    xlab("SOA (seconds)") +
    ylab("% Frequency") + 
    labs(fill = "Target Location")
  ggsave(paste0(wd,"/figures/combi_check",s_sub,"soa_vs_sex_barfreq.tiff"),width = 6, height = 4)
  
  #emotion
  ggplot(task, aes(x=as.factor(round(time_soa_secs,3)), fill=task_target_emotion)) + 
    geom_bar(position="fill",na.rm = TRUE) +
    xlab("SOA (seconds)") +
    ylab("% Frequency") + 
    labs(fill = "Target Emotion")
  ggsave(paste0(wd,"/figures/combi_check",s_sub,"soa_vs_emotion_barfreq.tiff"),width = 6, height = 4)
  
  #location
  ggplot(task, aes(x=as.factor(round(time_soa_secs,3)), fill=stim_location_id)) + 
    geom_bar(position="fill",na.rm = TRUE) +
    xlab("SOA (seconds)") +
    ylab("% Frequency") + 
    labs(fill = "Target Location")
  ggsave(paste0(wd,"/figures/combi_check",s_sub,"soa_vs_location_barfreq.tiff"),width = 6, height = 4)
  
  #age
  ggplot(task, aes(x=as.factor(round(time_soa_secs,3)), fill=stim_age_id)) + 
    geom_bar(position="fill",na.rm = TRUE) +
    xlab("SOA (seconds)") +
    ylab("% Frequency") + 
    labs(fill = "Target Location")
  ggsave(paste0(wd,"/figures/combi_check",s_sub,"soa_vs_age_barfreq.tiff"),width = 6, height = 4)
  
  ggplot(task, aes(x=as.factor(round(time_soa_secs,3)), fill=as.factor(response_correct_ref))) + 
    geom_bar(position="fill",na.rm = TRUE) +
    scale_fill_discrete(labels=c("Incorrect", "Correct", "NA")) +
    xlab("SOA (seconds)") +
    ylab("% Frequency") + 
    labs(fill = "Response Correct")
  ggsave(paste0(wd,"/figures/combi_",s_sub,"soa_vs_responsecorrect_barfreq.tiff"),width = 6, height = 4)
  
  ggplot(task_T, aes(x=as.factor(round(time_soa_secs,3)), fill=as.factor(response_correct_ref))) + 
    geom_bar(position="fill",na.rm = TRUE) +
    scale_fill_discrete(labels=c("Incorrect", "Correct", "NA")) +
    xlab("SOA (seconds)") +
    ylab("% Frequency") + 
    labs(fill = "Response Correct")
  ggsave(paste0(wd,"/figures/T_",s_sub,"soa_vs_responsecorrect_barfreq.tiff"),width = 6, height = 4)
  
  ggplot(task_C, aes(x=as.factor(round(time_soa_secs,3)), fill=as.factor(response_correct_ref))) + 
    geom_bar(position="fill",na.rm = TRUE) +
    scale_fill_discrete(labels=c("Incorrect", "Correct", "NA")) +
    xlab("SOA (seconds)") +
    ylab("% Frequency") + 
    labs(fill = "Response Correct")
  ggsave(paste0(wd,"/figures/C_",s_sub,"soa_vs_responsecorrect_barfreq.tiff"),width = 6, height = 4)
  
  
  
}




#### soa modelling
soamodel <- glm(data=task_T,response_correct_ref~time_soa_secs, family = "binomial")
summary(soamodel)
pred.mod <- predict.glm(soamodel, task_T, type = "response")
task_T$pred.mod <- pred.mod

dfbis <- task_T[order(task_T$pred.mod),]
dfbis$RANGbis <- 1:length(task_T$pred.mod)

ggplot(dfbis, aes(x=RANGbis, y=RANGbis, col=response_correct)) + geom_point()

plotROC(task_T$response_correct_ref,task_T$pred.mod)

opti <- optimalCutoff(task_T$response_correct_ref,task_T$pred.mod)

sensitivity(task_T$response_correct_ref,task_T$pred.mod,threshold=opti)
specificity(task_T$response_correct_ref,task_T$pred.mod,threshold=opti)



