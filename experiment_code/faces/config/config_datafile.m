%% Configuration file 
% Create experiment blank datatable 

function [data] = config_datafile(experiment_design)

experiment_design = experiment_design;

trials = height(experiment_design);

data.trial_number = (1:trials)';
data.trial_number_check = NaN(trials,1);
data.target_image_check = cell(trials,1); 
data.mask_image_check = cell(trials,1);

%empty columns for setup subject info
data.subject_number = NaN(trials,1);
data.subject_type = cell(trials,1);
data.subject_mode = NaN(trials,1);
data.subject_run = NaN(trials,1);
data.subject_rep = NaN(trials,1);
data.subject_date = cell(trials,1);
data.subject_lang = cell(trials,1);
%empty columns for timing onsets
data.onset_trigger = NaN(trials,1);
data.onset_run = NaN(trials,1);
data.onset_block = NaN(trials,1);
data.onset_trial = NaN(trials,1);
data.onset_target = NaN(trials,1);
data.onset_mask = NaN(trials,1);
data.onset_response = NaN(trials,1);
data.offset_trial = NaN(trials,1);
data.offset_run = NaN(trials,1);

%empty columns for recorded durations for each event 
data.duration_run = NaN(trials,1);
data.duration_run_frames = NaN(trials,1);
data.duration_block = NaN(trials,1);
data.duration_block_frames = NaN(trials,1);
data.duration_trial = NaN(trials,1);
data.duration_trial_frames = NaN(trials,1);
data.duration_jitter = NaN(trials,1);
data.duration_jitter_frames = NaN(trials,1);
data.duration_target = NaN(trials,1);
data.duration_target_frames = NaN(trials,1);
data.duration_mask = NaN(trials,1);
data.duration_mask_frames = NaN(trials,1);
data.duration_response = NaN(trials,1);
data.duration_response_frames = NaN(trials,1);

%empty columns for responses
data.response_time = NaN(trials,1);
data.response_key = NaN(trials,1);
data.response_key_name = cell(trials,1);
data.response_key_id = cell(trials,1);                   
data.reaction_time = NaN(trials,1);
data.response_correct = NaN(trials,1);

%experiment_data = struct2table(data);

end
