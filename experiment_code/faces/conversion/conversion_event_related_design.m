experiment_design = struct2table(experiment_design_struct);
experiment_design.task_order_trial = shuffle_er;
experiment_design = sortrows(experiment_design, 'task_order_trial');
experiment_design.task_order_run = task_order_run;
experiment_design.task_order_block = task_order_block;
experiment_design.task_order_trial_sep = task_order_trialsep;