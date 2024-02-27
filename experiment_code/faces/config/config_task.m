%% Configuration file 
% Task design
function [task, stim] = config_task(settings, experiment_structure, control_structure, stim_wksp)

experiment_settings = settings
task_design = experiment_structure 
control_design = control_structure 
stim = stim_wksp

%% Loading and checking run/block trial number
task.runs = experiment_settings.design_runs; 
task.blocksprun = experiment_settings.design_blocksperrun;

% Min trials per run calculated in experiment_design function 
task.trialsprun = length(task_design);
task.control_trialsprun = length(control_design);

% Checking is trials per block integer
if mod(task.trialsprun, task.blocksprun)
    error_runs = ('trials in a run not easily divided into desired no of blocks, change settings blocks per run to one of :')
    divisors = find_divisors(task.trialsprun)
    return
else
    task.trialspblock = task.trialsprun / task.blocksprun; 
    
    if mod(task.control_trialsprun, task.blocksprun)
        error_runs = ('control trials in a run not easily divided into desired no of blocks, change settings blocks per run to one of :')
        divisors = find_divisors(task.control_trialsprun)
        return
    else
        task.control_trialspblock = task.control_trialsprun / task.blocksprun;
        task.control_ratio = task.control_trialsprun / task.trialsprun;
    end
end

%% Giving eta for run / experiment 

task.trial_time_est_secs = (experiment_settings.jitter_max_ms - experiment_settings.jitter_min_ms)/2/1000 ...
    + experiment_settings.mask_ms/1000 + experiment_settings.response_ms/1000 ...
    + (mean(experiment_settings.target_soa_values_fr)/experiment_settings.target_framerate)/1000

task.total_trialsprun = task.trialsprun + task.control_trialsprun

task.total_timeprun_mins = (task.total_trialsprun * task.trial_time_est_secs)/60

task.total_timeall_mins = task.total_timeprun_mins * task.runs

%% Calculate trials per age/sex/emo category vs. available stimuli 

% Calculate number of categories used 
task.category_number = length(experiment_settings.target_age_choices) * length(experiment_settings.target_sex_choices) * length(experiment_settings.target_emotion_choices);
% ... how many trials for each category in a run
task.category_trialsprun = task.trialsprun / task.category_number;

fn = fieldnames(stim.images);
 % Finding minimum number of images across all set used 
for i = 1:length(fieldnames(stim.images))    
    minimages(i) = length(stim.images.(fn{i}));
end 
stim.images_category_min = min(minimages);

if stim.images_category_min < task.category_trialsprun
    warning_images1 = ('not enough images per emo categories for no of trials, reducing number and forcing repeated images') 

    %first setting number of images used per category as the category min 
    stim.images_category_number = stim.images_category_min;

    %then reducing until divisible by an integer..
    while round(task.category_trialsprun/stim.images_category_number) ~= (task.category_trialsprun/stim.images_category_number)
        stim.images_category_number = stim.images_category_number - 1;
    end
    stim.images_category_reps = task.category_trialsprun / stim.images_category_number;
else 
    % no problem with number of available images
    stim.images_category_reps = 1; 
end
 
end 