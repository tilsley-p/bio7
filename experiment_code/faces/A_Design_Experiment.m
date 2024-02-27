
%% Cleanup 
clear;
sca;

%% add paths to various folders for scripts, data 
addpath('archive','config','conversion','data', 'execution','stimuli');

%% load settings file 
settings_file = 'settings.json';
experiment_settings = jsondecode(fileread(settings_file));

%% Configure keyboard
config_keys;

%% Configure stimuli and load images
stim = config_stimuli(experiment_settings);

%% test screen and prepare screen parameters
[screen, stim] = config_screen(experiment_settings, stim);

%% Create pseudorandomised conditions (for a run)
[experiment_structure, control_structure] = create_experiment_structure(experiment_settings);

%% Simulate across all runs 
[task, stim] = config_task(experiment_settings, experiment_structure, control_structure, stim);

%% Fixed timing parameters
time = config_trialtimes(experiment_settings, screen);

%% Create experiment tables for running experiments
[experiment_design_struct, experiment_design, task_design, control_design] = config_design(experiment_settings, task, stim, time);

%% MRI parameters
mri = calculate_MRI(experiment_settings, task_design, control_design, experiment_design);

%% Make tables for outputting experiment data
[data] = config_datafile(experiment_design);

%% Save design files to execution folder 
save_design;