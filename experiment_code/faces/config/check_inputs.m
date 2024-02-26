%% Task execution setup file
% Check input experiment parameters

%setup = setup_wksp;

if setup.subject_MRI == 1
    setup.data_mat_name = ['sub-' int2str(setup.subject_no) '_acq-MRI_task-faces_run-0' int2str(setup.subject_run) '.mat']; 
    setup.data_csv_name = ['sub-' int2str(setup.subject_no) '_acq-MRI_task-faces_data.csv'];
elseif setup.subject_MRI == 0
    setup.data_mat_name = ['sub-' int2str(setup.subject_no) '_acq-test_task-faces_run-0' int2str(setup.subject_run) '.mat'];
    setup.data_csv_name = ['sub-' int2str(setup.subject_no) '_acq-test_task-faces_data.csv'];
else
    error_input2 = ('non-valid input for file options, try again')
    return
end

%% Check if there is already a matlab datafile corresponding to inputs
% if not file will be created at end of run

if exist((fullfile('data',setup.data_mat_name)),'file')
    warning_input = ('data matrix with specified paramaters already exists')
    exp_overwrite = input('stop, (0) or overwrite (1) data?: ');
    if exp_overwrite == 0
         error_data = ('experiment stopped, check existing data files or redefine inputs')
         return
    elseif exp_overwrite == 1
    else
        error_input2 = ('non-valid input for file options, try again')
        return 
    end
else
    disp('no existing data mat for input subject parameters')
end
    
%% Checking if there is already an existing csv datafile from previous runs 

if exist((fullfile('data',setup.data_csv_name)),'file')
    if setup.subject_run == 1 
        warning_input = ('data csv with specified paramaters already exists')
        create = input('Load existing csv datafile and overwrite data? No - Stop (0), Yes (1): ');
        if create == 0
            disp('check data files before continuing or change inputs');
            return 
        else
            experiment_data = readtable(fullfile('data',setup.data_csv_name));
            data = table2struct(experiment_data,'ToScalar',true);
        end
        clear create
    else
        %ok to load previous datafile
        disp('loading previous csv')
        experiment_data = readtable(fullfile('data',setup.data_csv_name));
        data = table2struct(experiment_data,'ToScalar',true);
    end
else
    if setup.subject_run ~= 1
        warning_datafile = ('Starting a run > run 1 but no previous data with these parameters exists?')
        create = input('Continue anyway despite no run 1 data? No - Stop (0), Yes (1): ');           
        if create == 0
            disp('check data files before continuing or change inputs');
            return 
        else
            disp('no existing data csv for input subject parameters')
        end
        clear create
    else
        disp('no existing data csv for input subject parameters')
    end
end
 