%% Configuration file 
% MRI parameters and timing

function mri = calculate_MRI(settings, task_design, control_design, exp_design)

experiment_settings = settings; 
task_design = task_design;
control_design = control_design; 
experiment_design_merged = exp_design; 

designs = {task_design, control_design, experiment_design_merged};
design_names = {"task", "control", "complete_experiment"};

mri.TR = experiment_settings.mri_tr; %seconds 
mri.TE = experiment_settings.mri_te; %seconds  
mri.slicethickness = experiment_settings.mri_slicethickness; %mm
mri.slices = experiment_settings.mri_slices;

%% Calculate MRI time acquisition based on input parameters

cue = experiment_settings.display_cue_secs * 2; %seconds 
cues_prun_secs = cue*experiment_settings.design_blocksperrun; %10 seconds x 2 times 
cues_prun_vols = cues_prun_secs / mri.TR ;

for iter = 1:experiment_settings.design_runs
    
    for design = 1:length(designs)
        input_structure = designs{1,design};
        
        idx = find(input_structure.task_order_run == iter);
        %seconds
        time_TA_secs = accumarray(idx, input_structure.time_trial_secs(idx));
        mri.time_TA_secs(iter,design) = max(cumsum(time_TA_secs));
        %mins
        mri.time_TA_mins(iter,design) = mri.time_TA_secs(iter,design)/60;
        
        % adding cues to timings
        if string(design_names(design)) == "complete_experiment"
            add_cues_secs = cues_prun_secs*2; 
            add_cues_vol = cues_prun_vols*2;
        else
            add_cues_secs = cues_prun_secs;
            add_cues_vol = cues_prun_vols;
        end
        mri.time_cues_secs(iter,design) = add_cues_secs;   
        mri.time_cues_vol(iter,design) = add_cues_vol;    
        %seconds
        mri.time_TA_secs(iter,design) = mri.time_TA_secs(iter,design) + mri.time_cues_secs(iter,design);
        %mins
        mri.time_TA_mins(iter,design) = mri.time_TA_mins(iter,design) + (mri.time_cues_secs(iter,design)/60);
        % volumes
        mri.time_TA_vol(iter,design) = ceil(mri.time_TA_secs(iter,design)/mri.TR);
    end
    
    run_index(iter, 1) = iter; 
    
end

mri.run_index = run_index;
mri.design_index = design_names;


end

