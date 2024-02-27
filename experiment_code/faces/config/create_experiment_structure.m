function [task_structure, control_structure] = create_experiment_structure(settings)
    
    %settings_file = settings;
    %settings_str = fileread(settings_file);
    %experiment_settings = jsondecode(settings_str);

    experiment_settings = settings
    
    %Load choices from experiment settings file
    left_right_choices = experiment_settings.target_location_choices';
    sex_choices = experiment_settings.target_sex_choices';
    age_choices = experiment_settings.target_age_choices';
    emotion_choices = experiment_settings.target_emotion_choices';
    mask_emotion_choices = experiment_settings.mask_emotion_choice'; 
    soa_choices = experiment_settings.target_soa_choices';
    rep_choices = experiment_settings.choice_reps_run;
    
    %% Experiment Structure 
    % Generate all combinations of choices
    all_combinations_once = CombVec(left_right_choices, age_choices, sex_choices, emotion_choices, soa_choices)';
    
    % Duplicate combinations so they appear as many times as desired in a run
    all_combinations = repmat(all_combinations_once, rep_choices, 1);
    
    % Shuffle the rows to pseudorandomize the order
    num_combinations = size(all_combinations, 1);
    randomized_indices = randperm(num_combinations);
    pseudorand_structure = all_combinations(randomized_indices, :);
    
    % Create corresponding image category IDs for image stimuli ID matching
    image_categories_full = strcat(pseudorand_structure(:, 2), '_', pseudorand_structure(:, 3), '_', pseudorand_structure(:, 4));
    image_categories = cellfun(@(col) col(1), cellstr(pseudorand_structure(:, 2:4)));
    image_ids = strcat(image_categories(:, 1), '_', image_categories(:, 2), '_', image_categories(:, 3));
    image_ids = cellstr(image_ids);
    
    % Create the same image category IDs for the masks
    image_mask_full = strcat(pseudorand_structure(:, 2), '_', pseudorand_structure(:, 3), '_', mask_emotion_choices);
    image_mask_id_full = char(experiment_settings.mask_emotion_choice(1));
    image_mask_ids = strcat(image_categories(:, 1), '_', image_categories(:, 2), '_', image_mask_id_full(1));
    image_mask_ids = cellstr(image_mask_ids);
    
    pseudorand_structure(:,6) = image_ids
    pseudorand_structure(:,7) = image_categories_full
    pseudorand_structure(:,8) = image_mask_ids
    pseudorand_structure(:,9) = image_mask_full
    
    task_structure = pseudorand_structure
    
    %% Control Structure     
    % Generate all combinations of choices
    all_combinations_control_once = CombVec(left_right_choices, age_choices, sex_choices, mask_emotion_choices, soa_choices)';
    
    % Duplicate combinations so they appear as many times as desired in a run
    all_combinations_control = repmat(all_combinations_control_once, rep_choices, 1);
    
    % Shuffle the rows to pseudorandomize the order
    num_combinations_control = size(all_combinations_control, 1);
    randomized_indices = randperm(num_combinations_control);
    pseudorand_structure_control = all_combinations_control(randomized_indices, :);
    
    % Create corresponding image category IDs for image stimuli ID matching
    image_categories_full = strcat(pseudorand_structure_control(:, 2), '_', pseudorand_structure_control(:, 3), '_', pseudorand_structure_control(:, 4));
    image_categories = cellfun(@(col) col(1), cellstr(pseudorand_structure_control(:, 2:4)));
    image_ids = strcat(image_categories(:, 1), '_', image_categories(:, 2), '_', image_categories(:, 3));
    image_ids = cellstr(image_ids);
    
    % Create the same image category IDs for the masks
    image_mask_full = strcat(pseudorand_structure_control(:, 2), '_', pseudorand_structure_control(:, 3), '_', mask_emotion_choices);
    image_mask_id_full = char(experiment_settings.mask_emotion_choice(1));
    image_mask_ids = strcat(image_categories(:, 1), '_', image_categories(:, 2), '_', image_mask_id_full(1));
    image_mask_ids = cellstr(image_mask_ids);
    
    pseudorand_structure_control(:,6) = image_ids
    pseudorand_structure_control(:,7) = image_categories_full
    pseudorand_structure_control(:,8) = image_mask_ids
    pseudorand_structure_control(:,9) = image_mask_full
    
    control_structure = pseudorand_structure_control
    
end