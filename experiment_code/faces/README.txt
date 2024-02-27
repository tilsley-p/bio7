*README

Backwards Masking Faces Task (Fear/Happy)

----------------------

## Task Description 
Backwards masking task of emotive faces (happy or fear) masked by neutral faces of the same subject, with a control condition presenting neutral faces masked by a different version of a neutral face of the same subject. Mixed event-related design with 1x 14-minute run, separated into blocks of: emotive task (emotion choice) and neutral control (sex choice). Each block is preceded by a change in cue and brief pause. 

------------------------

## Acquisition Notes 
BOLD Screen must be placed 30cm from the back of the 7T bore. As of 13.10.2022 for first pilot: distance of 30cm. 
Button response system must be put on HID, triggering of task occurs on only 1st volume. 


-------------- ## How to: ------------------

## How to: Running the task: 

0. Go to folder Experiments/faces 

1. Run B_Run_Setup_Experiment.m

- input demanded parameters (follow what is in brackets) 

e.g., for subject 27, who is a control, using version 1 counterbalanced (changes index-thumb assignment for the neutral control task), on their first run, in english. 

Subject number?: 27
Patient (p) or control (c)?: c
Run/repetition number (longitudinal)?: 1
test(0) or MRI(1)?: 1
Run in french(0) or english(1): 1
'Counterbalance version1 (1) or version2 (2): 1

... wait a minute for images to be loaded + explain to participant the task  

2. Run C_Run_Experiment 

- respond again to subject_mode question to setup screen parameters  

3. Start running the NeuroLabs sync box (if in MRI mode)

4. Run fMRI on MRI console 

- "experiment triggered" should appear on matlab command window once triggered (and images on BOLD screen) [if in test mode, manually trigger by pressing 's' on keyboard]


NB: Response buttons are 'q', 'b', 'c', 'd'. 
NB: Cancel button if want to stop task ever 'x' - only possible when responses being recorded (no dot in centre fixation/no faces).

NB: When giving inputs the code will automatically check if existing data with the input parameters exist or if a previous run has been done. If previous data with the same inputs already exists in data/ prompts will be sent to ask whether to continue and overwrite data or stop. Manually copy and deplace data if necessary. 


------------------------

## Version Notes 
Version changes 10.01.2024.
Demonstration video added to other/vid/. 
Removed lines on screen and just kept fixation point (C_Run_Experiment.m). 
Fixation point appears and disappears in line with task response time (C_Run_Experiment.m). 
Changed data to be automatically saved in BIDS format with c for controls and p for patients added (C_Run_Experiment.m). 
Previous data transformed to new BIDS format (X_Transform_data.m). Data back-ups found in archive/.
Changing input to allow distinguishing between patients/controls (B_Run_Setup_Experiment.m). 
Allowing input run number to be assigned (file naming uses this number)(B_Run_Setup_Experiment.m). 
Added an input counterbalance choice which switched whether index-thumb is assigned to male or female in the control task. See notes in other/ (B_Run_Setup_Experiment.m). 

Version changes 06.08.2023.
Gross update of codes as functions with settings.json for experiment inputs 
Extra script B for loading setup and images before running experiment 
Flashing fixation cross for responses as in Retinotopy tasks
Choice of languages for cues etc. to be set in settings.json 
Possibility to reset settings in the json and rerun all/parts of A_Design to create new experiment
Choice - event related of block event related design.. 
Locations fully randomised, 50% left-right - controlled according to sex, age, emo etc.
Text cues presented on screen at all times 
Emotion block and neutral block both require button box choices (between fear/happy or male/female)

Version changes 13.10.2022. 
Fixation cross made to match Retinotopy task and resting state. 
FACES images used so that models mask themselves i.e., model-1 fear masked by model-1 neutral. 
Pseudo-randomised control of sex, age, emotion, number of soas across task. 
Locations fully randomised, 50% left-right - left vs right not controlled according to sex, age, emo etc. 
Text cues presented for 10 seconds before emotive and neutral tasks. 
took run start time as trigger time 
changed keyboard button box left from a to q
modified rest experiment file to integrate different mask and target images


-------------- ## How to: ------------------

## Caution ! How to: Creating the task: 

1. Navigate to folder Experiments/faces 

2. Run A_Design_Experiment and respond to input questions accordingly 

(design is saved in execution/ folder) 
** only needs to be done 1ce for all participants... 

** Don't run A_Design_Experiment unless want to create a new task design
- If you do, there will be a prompt anyway asking if want to save and/or saying that there is already an existing design, do you want to not save the new one or not, do you want to archive the last design (with date stamp). Of note, can only archive the old design once a day as this uses a datestamp, if want to archive more than one copy a day will have to do that manually. 


