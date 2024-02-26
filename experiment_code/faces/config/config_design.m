%% Configuration file 
% Complete design 

function [experiment_design_struct, experiment_design, task_design, control_design] = config_design(settings, task_wksp, stim_wksp, time_wksp)

experiment_settings = settings;
task = task_wksp;
stim = stim_wksp;
time = time_wksp;
 
for idx = 1:task.runs
    
    %% Create new randomised run structures for task and control  
    [experiment_structure, control_structure] = create_experiment_structure(experiment_settings);
    
    structures = {experiment_structure, control_structure};
    structures_ref = {"experiment_structure", "control_structure"};
    
    for iter = 1:length(structures)
    
        %% Loop over experiment structures and add task, stim, time info
        input_structure = structures{1,iter};
        
        % Creating output naming scheme accordingly
        input_structure_ref = structures_ref(iter);
        input_structure_ref_cut = extractBefore(string(input_structure_ref), '_');
        
        clear input_structure_output_run input_structure_output
        input_structure_output_run = cell2table(input_structure, 'VariableNames',["task_stim_location" "task_stim_age" "task_stim_sex" "task_target_emotion" "task_soa_reference" "stim_target_id" "stim_target_type" "stim_mask_id" "stim_mask_type"]);

%%%%%%%%% GETTING task info (run, block, trial) %%%%%%%%%%%%
        
        if input_structure_ref_cut == "experiment"
            trialsprun = task.trialsprun;
            task_trial_type = repelem('T',trialsprun)';
        elseif input_structure_ref_cut == "control"
            trialsprun = task.control_trialsprun;
            task_trial_type = repelem('C',trialsprun)';
        end 
        % Adding run index to datatable
        run_column = num2cell(repelem(idx, trialsprun))';
        % Adding block index to datatable
        block_column = num2cell(repelem(1:task.blocksprun,trialsprun/task.blocksprun))';
        % Adding trial index to datatable 
        trial_column = (1:trialsprun)'; 
        
%%%%%%%%% GETTING time info (soa, jitter, mask) %%%%%%%%%%%%
        
        % empty cell arrays to be filled trial by trial 
        soa_secs = cell(length(trial_column),1);
        soa_fr = cell(length(trial_column),1);
        soa_reference_num = cell(length(trial_column),1);
        jitter_fr = cell(length(trial_column),1);
        jitter_secs = cell(length(trial_column),1);
        mask_fr = cell(length(trial_column),1);
        mask_secs = cell(length(trial_column),1);
        response_fr = cell(length(trial_column),1);
        response_secs = cell(length(trial_column),1);

        %%% soas %%%
        %Taking soa types levels in structure
        soa_types = unique(input_structure_output_run.task_soa_reference);
        % Reformating soa types to order numerically
        soa_refs = erase(soa_types, 't');
        soa_refs = sort(str2double(soa_refs));
        soa_types_sorted = strcat('t',string(soa_refs));
        % Getting associated list of soa framerates and secs 
        soa_values_fr = time.soa_frames; 
        soa_values_secs = time.soa_secs;
        
        % Looping each trial in structure and adding corresponding soa time info
        for trial = 1:length(trial_column)
            %Finding soa index from soa list
            trial_soa = input_structure_output_run.task_soa_reference(trial);
            pos = strcmp(trial_soa, soa_types_sorted);
            categ = find(pos);
            %Assigning corresponding values
            soa_secs{trial,:} = soa_values_secs(categ);
            soa_fr{trial,:} = soa_values_fr(categ);
            soa_reference_num{trial,:} = soa_refs(categ);
        end
        
        %%% jitters, mask, response times %%%
        jitter_fr = Shuffle(repelem(time.jitters_frames, trialsprun/length(time.jitters_frames)))';
        jitter_secs = jitter_fr * time.poss.framerate;
        mask_fr = Shuffle(repelem(time.mask_frames, trialsprun))';
        mask_secs = mask_fr * time.poss.framerate;
        response_fr = Shuffle(repelem(time.response_frames, trialsprun))';
        response_secs =  response_fr * time.poss.framerate;
        
        % Calculating relative trial times 
        trial_time_fr = cell2mat(soa_fr) + mask_fr + jitter_fr + response_fr;
        trial_time_secs = trial_time_fr * time.poss.framerate; 

%%%%%%%%% GETTING reference-name info (emotion, sex, age, location) %%%%%%%%%%%%

        location_id = cell(length(trial_column),1);
        location_x = NaN(length(trial_column),1);
        location_y = NaN(length(trial_column),1);
        location_ref = NaN(length(trial_column),1);
        age_ref = NaN(length(trial_column),1);
        age_id = cell(length(trial_column),1);
        emotion_ref = NaN(length(trial_column),1);
        emotion_id = cell(length(trial_column),1);
        sex_ref = NaN(length(trial_column),1);
        sex_id = cell(length(trial_column),1);

        for trial = 1:length(trial_column)
            %Finding location index from stim locations
            trial_location = input_structure_output_run.task_stim_location(trial);
            pos = strcmp(trial_location, stim.locations);
            categ = find(pos);
            %Assigning corresponding values
            location_id{trial,:} = stim.locations_id(categ);
            location_x(trial,:) = stim.location_coord(categ,1);
            location_y(trial,:) = stim.location_coord(categ,2);
            location_ref(trial,:) = categ;
            
            %Finding sex index from stim sex
            trial_sex = input_structure_output_run.task_stim_sex(trial);
            pos = strcmp(trial_sex, stim.sexs);
            categ = find(pos);
            sex_ref(trial,:) = categ;
            sex_id{trial,:} = stim.sexs_id(categ);
            
            %Finding age index from stim age
            trial_age = input_structure_output_run.task_stim_age(trial);
            pos = strcmp(trial_age, stim.ages);
            categ = find(pos);
            age_ref(trial,:) = categ;
            age_id{trial,:} = stim.ages_id(categ);
            
            %Finding age index from stim age
            trial_emotion = input_structure_output_run.task_target_emotion(trial);
            pos = strcmp(trial_emotion, stim.emotions);
            categ = find(pos);
            emotion_ref(trial,:) = categ;
            emotion_id{trial,:} = stim.emotions_id(categ);
        end
                      
%%%%%%%%% GETTING stim info (category, image, path) %%%%%%%%%%%%

        % empty cell arrays to be filled trial by trial 
        target_photoname = cell(length(trial_column),1);
        target_photonumber = cell(length(trial_column),1);
        target_photoref = NaN(length(trial_column),1);
        target_photocat = cell(length(trial_column),1);
        mask_photoname = cell(length(trial_column),1);
        mask_photonumber = cell(length(trial_column),1);
        mask_photoref = NaN(length(trial_column),1);
        mask_photocat = cell(length(trial_column),1);
        
        %Loop over categories of stimuli
        for catidx = 1:length(stim.combi_contrast_id)
            
            if input_structure_ref_cut == "experiment"
                % Find how many time it appears
                trial_target_id = stim.combi_contrast_id(catidx);
            elseif input_structure_ref_cut == "control"
                % Find how many time it appears
                trial_target_id = stim.combi_control_id(catidx);
            end
                
                trial_target_id_idx = find(strcmp(input_structure_output_run.stim_target_id, trial_target_id));
                % Make a randomised repeated incremental list to associate
                % image numbers randomly to each corresponding row
                target_refs = repelem((1:(length(trial_target_id_idx)/stim.images_category_reps)),stim.images_category_reps);
                target_refs_shuffled = Shuffle(target_refs); 

                %For every matching row, give corresponding id and incrementing image references 
                for matchidx = 1:length(trial_target_id_idx) 
                    
                    trial_no = trial_target_id_idx(matchidx);
                    
                    % In rows containing the target category, give random image index 
                    target_photoref(trial_no,:) = target_refs_shuffled(matchidx);   
                    
                    % Assign stimuli images corresponding to the random image index  
                    if input_structure_ref_cut == "experiment"
                        photoname_target = stim.images.(char(stim.combi_contrast_id(catidx)))(target_photoref(trial_no,:)).name;
                        photonumber_target = stim.images.(char(stim.combi_contrast_id(catidx)))(target_photoref(trial_no,:)).name(1:3);
                    elseif input_structure_ref_cut == "control"
                        photoname_target = stim.images.(char(stim.combi_control_id(catidx)))(target_photoref(trial_no,:)).name;
                        photonumber_target = stim.images.(char(stim.combi_control_id(catidx)))(target_photoref(trial_no,:)).name(1:3);
                    end 
                    photoname_mask = stim.images_blist.(char(stim.combi_control_id(catidx)))(target_photoref(trial_no,:)).name;
                    photonumber_mask = stim.images_blist.(char(stim.combi_control_id(catidx)))(target_photoref(trial_no,:)).name(1:3);
                     
                    target_photoname{trial_target_id_idx(matchidx),:} = string(photoname_target);
                    target_photonumber{trial_target_id_idx(matchidx),:} = string(photonumber_target); 
                    mask_photoname{trial_target_id_idx(matchidx),:} = string(photoname_mask);
                    mask_photonumber{trial_target_id_idx(matchidx),:} = string(photonumber_mask); 
                    target_photocat{trial_target_id_idx(matchidx),:} = catidx;
                
                end
    
        end
        mask_photocat = target_photocat;
        mask_photoref = target_photoref;

%%%%%%%%% COMPILING into output table %%%%%%%%%%%%        
        % Adding task info to output structure 
        input_structure_output_run = addvars(input_structure_output_run, cell2mat(run_column), 'NewVariableNames', 'task_order_run');
        input_structure_output_run = addvars(input_structure_output_run, cell2mat(block_column), 'NewVariableNames', 'task_order_block');
        input_structure_output_run = addvars(input_structure_output_run, trial_column, 'NewVariableNames', 'task_order_trial_sep');
        input_structure_output_run = addvars(input_structure_output_run, cellstr(task_trial_type), 'NewVariableNames', 'task_trial_type');
        % Adding stim info to output structure
        %target
        input_structure_output_run = addvars(input_structure_output_run, target_photoname, 'NewVariableNames', 'stim_target_photoname');
        input_structure_output_run = addvars(input_structure_output_run, target_photonumber, 'NewVariableNames', 'stim_target_photonumber');
        input_structure_output_run = addvars(input_structure_output_run, cell2mat(target_photocat), 'NewVariableNames', 'stim_target_cat');
        input_structure_output_run = addvars(input_structure_output_run, target_photoref, 'NewVariableNames', 'stim_target_photo_ref');
        %mask 
        input_structure_output_run = addvars(input_structure_output_run, mask_photoname, 'NewVariableNames', 'stim_mask_photoname');
        input_structure_output_run = addvars(input_structure_output_run, mask_photonumber, 'NewVariableNames', 'stim_mask_photonumber');
        input_structure_output_run = addvars(input_structure_output_run, cell2mat(mask_photocat), 'NewVariableNames', 'stim_mask_cat');
        input_structure_output_run = addvars(input_structure_output_run, mask_photoref, 'NewVariableNames', 'stim_mask_photo_ref');
        %location
        input_structure_output_run = addvars(input_structure_output_run, location_id, 'NewVariableNames', 'stim_location_id');
        input_structure_output_run = addvars(input_structure_output_run, location_x, 'NewVariableNames', 'stim_location_x');
        input_structure_output_run = addvars(input_structure_output_run, location_y, 'NewVariableNames', 'stim_location_y');
        input_structure_output_run = addvars(input_structure_output_run, location_ref, 'NewVariableNames', 'stim_location_ref');  
        % age, sex, emotion references
        input_structure_output_run = addvars(input_structure_output_run, age_ref, 'NewVariableNames', 'stim_age_ref');
        input_structure_output_run = addvars(input_structure_output_run, emotion_ref, 'NewVariableNames', 'stim_emotion_ref');
        input_structure_output_run = addvars(input_structure_output_run, sex_ref, 'NewVariableNames', 'stim_sex_ref');
        input_structure_output_run = addvars(input_structure_output_run, age_id, 'NewVariableNames', 'stim_age_id');
        input_structure_output_run = addvars(input_structure_output_run, emotion_id, 'NewVariableNames', 'stim_emotion_id');
        input_structure_output_run = addvars(input_structure_output_run, sex_id, 'NewVariableNames', 'stim_sex_id');
        % Adding time info to output structure 
        %soa
        input_structure_output_run = addvars(input_structure_output_run, cell2mat(soa_secs), 'NewVariableNames', 'time_soa_secs');
        input_structure_output_run = addvars(input_structure_output_run, cell2mat(soa_fr), 'NewVariableNames', 'time_soa_fr');
        input_structure_output_run = addvars(input_structure_output_run, cell2mat(soa_reference_num), 'NewVariableNames', 'time_soa_reference_num');    
        % jitter, mask, response  
        input_structure_output_run = addvars(input_structure_output_run, jitter_fr, 'NewVariableNames', 'time_jitter_fr');
        input_structure_output_run = addvars(input_structure_output_run, jitter_secs, 'NewVariableNames', 'time_jitter_secs');
        input_structure_output_run = addvars(input_structure_output_run, mask_fr, 'NewVariableNames', 'time_mask_fr');
        input_structure_output_run = addvars(input_structure_output_run, mask_secs, 'NewVariableNames', 'time_mask_secs');
        input_structure_output_run = addvars(input_structure_output_run, response_fr, 'NewVariableNames', 'time_response_fr');
        input_structure_output_run = addvars(input_structure_output_run, response_secs, 'NewVariableNames', 'time_response_secs');  
        % est trial times
        input_structure_output_run = addvars(input_structure_output_run, trial_time_fr, 'NewVariableNames', 'time_trial_fr');
        input_structure_output_run = addvars(input_structure_output_run, trial_time_secs, 'NewVariableNames', 'time_trial_secs');
        % Adding corresponding reference info 
        
        
        % Ordering columns manually 
        prefixes = {'task_', 'stim_', 'time_'};
        
        columnsper_prefix = cell(1, numel(prefixes));
        for i = 1:numel(prefixes)
            % Find column names starting with the current prefix
            prefix_select = prefixes{i};
            prefix_columns = input_structure_output_run.Properties.VariableNames(startsWith(input_structure_output_run.Properties.VariableNames,prefix_select));
            % Sort based on word after given prefix (after the underscore)
            [~, sortidx] = sort(extractAfter(prefix_columns, strlength(prefix_select(1))));
            % Store the sorted columns for the current prefix
            columnsper_prefix{i} = prefix_columns(sortidx);
        end
        % Concatenate all the sorted columns
        order_columns = [columnsper_prefix{:}, setdiff(input_structure_output_run.Properties.VariableNames, [columnsper_prefix{:}])];

        % Reorder the table columns
        input_structure_output_run = input_structure_output_run(:, order_columns);
        
        
        % Filtering into experiment or control table 
        if input_structure_ref_cut == "experiment"
            if idx == 1
                task_design = input_structure_output_run;
            else
                task_design = vertcat(task_design,input_structure_output_run);
            end    
        elseif input_structure_ref_cut == "control"
            if idx == 1
                control_design = input_structure_output_run;
            else
                control_design = vertcat(control_design,input_structure_output_run);
            end      
        end
    end
end

%Merging the output tables and sorting based on run and block number 
experiment_design = task_design;
experiment_design = [experiment_design; control_design];
experiment_design = sortrows(experiment_design, {'task_order_run','task_order_block'});

%Appending merged trial number 
task_merged_trials = (1:height(experiment_design))';
experiment_design = addvars(experiment_design, task_merged_trials, 'NewVariableNames', 'task_order_trial', 'After','task_order_trial_sep');

experiment_design_struct = table2struct(experiment_design);

end


