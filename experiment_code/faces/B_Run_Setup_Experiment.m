%% Task execution setup file

clear;
sca; 
 
addpath('archive','config','conversion','data', 'execution','stimuli');

setup.subject_no = input('Subject number?: ');
setup.subject_type = lower(input('Patient (p) or control (c)?: ','s'));

%setup.subject_run = input('Run number?: '); %had multiple runs before. no
%longer the case so just inputting directly as 1. 
setup.subject_run = 1;
%instead, allowing saving of data with run number for longitudinal data 
setup.subject_rep = input('Run/repitition number (longitudinal)?: ');

setup.subject_mode = input('test(0) or MRI(1)?: ');
setup.subject_lang = input('Run in french(0) or english(1): ');
setup.subject_counterbalance = input('Counterbalance version1 (1) or version2 (2): ');

%% Format inputs 

if setup.subject_no < 10
    setup.subject_no_string = strcat("00",string(setup.subject_no)); 
else
    if setup.subject_no < 100
        setup.subject_no_string = strcat("0",string(setup.subject_no)); 
    else
        setup.subject_no_string = string(setup.subject_no);
    end
end

if setup.subject_rep < 10
    setup.subject_rep_string = strcat("0",string(setup.subject_rep)); 
else
    setup.subject_rep_string = string(setup.subject_rep);
end

%% Load experiment workspace
if setup.subject_mode == 1
    load('task-faces_acq-MRI_design.mat');  
    setup.subject_MRI = 1;
elseif setup.subject_mode == 0
    load('task-faces_acq-test_design.mat')
    setup.subject_MRI = 0;
else
    disp('non-valid input for MRI options')
    return
end
%% Setup saving info 
if setup.subject_MRI == 1
    setup.design_csv_name = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-MRI_task-faces_run-' char(setup.subject_rep_string) '_design.csv']); 
    setup.data_mat_name = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-MRI_task-faces_run-' char(setup.subject_rep_string) '.mat']); 
    setup.data_csv_name = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-MRI_task-faces_run-' char(setup.subject_rep_string) '_data.csv']);
    setup.save_setup = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-MRI_task-faces_run-' char(setup.subject_rep_string) '_setup.txt']);
    setup.save_settings = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-MRI_task-faces_run-' char(setup.subject_rep_string) '_settings.json']);
elseif setup.subject_MRI == 0
    setup.design_csv_name = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-test_task-faces_run-' char(setup.subject_rep_string) '_design.csv']);
    setup.data_mat_name = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-test_task-faces_run-' char(setup.subject_rep_string) '.mat']);
    setup.data_csv_name = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-test_task-faces_run-' char(setup.subject_rep_string) '_data.csv']);
    setup.save_setup = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-test_task-faces_run-' char(setup.subject_rep_string) '_setup.txt']);
    setup.save_settings = string(['sub-' char(setup.subject_type) '' char(setup.subject_no_string) '_acq-test_task-faces_run-' char(setup.subject_rep_string) '_settings.json']);
else
    disp('non-valid input for file options, try again')
    return
end
%% Check if there is already a matlab datafile corresponding to inputs
% if not file will be created at end of run
if exist((fullfile('data',setup.data_mat_name)),'file')
    warning_input = ('data matrix with specified paramaters already exists');
    exp_overwrite = input('stop, (0) or overwrite (1) data?: ');
    if exp_overwrite == 0
         disp('experiment stopped, check existing data files or redefine inputs');
         return
    elseif exp_overwrite == 1
    else
        disp('non-valid input for file options, try again')
        return 
    end
    else
    disp('no existing data mat for input subject parameters')
end  
%% Checking if there is already an existing csv datafile from previous runs 
if exist((fullfile('data',setup.data_csv_name)),'file')
    if setup.subject_run == 1 
        disp('data csv with specified paramaters already exists')
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
        disp('Starting a run > run 1 but no previous data with these parameters exists?')
        create = input('Continue anyway despite no run 1 data? No - Stop (0), Yes (1): ');           
        if create == 0
            disp('check data files before continuing or change inputs');
            return 
        else
            disp('no existing data csv for input subject parameters')
            data = data; 
        end
        clear create
    else
        disp('no existing data csv for input subject parameters')
        data = data; 
    end
end
%% Loading language info and setting up cues 
setup.cue_offset_fr_centre = 300;
setup.cue_offset_linespace = 30;

if setup.subject_lang == 0
    setup.cue_position_one = char(experiment_settings.display_cue_pos(1));
    setup.cue_emotion_one = [char(experiment_settings.target_emotion_choices_french(1)) '?'];
    if setup.subject_counterbalance == 1 %counterbalance version 1
        setup.cue_sex_one = [char(experiment_settings.target_sex_choices_french(1)) '?'];
    else
        setup.cue_sex_one = [char(experiment_settings.target_sex_choices_french(2)) '?'];
    end
    setup.cue_response_buttons_one = ['-' char(experiment_settings.response_buttons_french(1)) '-'];
    
    setup.cue_position_two = char(experiment_settings.display_cue_pos(2));
    setup.cue_emotion_two = [char(experiment_settings.target_emotion_choices_french(2)) '?'];
    if setup.subject_counterbalance == 1 %counterbalance version 1
        setup.cue_sex_two = [char(experiment_settings.target_sex_choices_french(2)) '?'];
    else
        setup.cue_sex_two = [char(experiment_settings.target_sex_choices_french(1)) '?'];
    end  
    setup.cue_response_buttons_two = ['-' char(experiment_settings.response_buttons_french(2)) '-'];
    
    setup.cue_end = char(experiment_settings.display_cue_end_french);
    setup.subject_language = 'french'; 
    
elseif setup.subject_lang == 1
    setup.cue_position_one = char(experiment_settings.display_cue_pos(1));
    setup.cue_emotion_one = [char(experiment_settings.target_emotion_choices(1)) '?'];
    if setup.subject_counterbalance == 1 %counterbalance version 1
        setup.cue_sex_one = [char(experiment_settings.target_sex_choices(1)) '?'];
    else
        setup.cue_sex_one = [char(experiment_settings.target_sex_choices(2)) '?'];
    end
    setup.cue_response_buttons_one = ['-' char(experiment_settings.response_buttons(1)) '-'];
    
    setup.cue_position_two = char(experiment_settings.display_cue_pos(2));
    setup.cue_emotion_two = [char(experiment_settings.target_emotion_choices(2)) '?'];
    if setup.subject_counterbalance == 1 %counterbalance version 1
        setup.cue_sex_two = [char(experiment_settings.target_sex_choices(2)) '?'];
    else
        setup.cue_sex_two = [char(experiment_settings.target_sex_choices(1)) '?'];
    end
    setup.cue_response_buttons_two = ['-' char(experiment_settings.response_buttons(2)) '-'];
    setup.cue_end = char(experiment_settings.display_cue_end);  
    
    setup.subject_language = 'english'; 
else
    disp('non-valid input for language options');
end

% Putting blank screen with fixation cross

% Screen('Preference', 'VBLTimestampingMode', 1)
% [screen.main, screenrect] = Screen(screen.number,'OpenWindow',screen.background_colour,[]); %coords for test mode
% [~] = Screen('BlendFunction', screen.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% BeampositionTest(50,screen.main,[]);
Screen('Preference', 'SkipSyncTests', 1);
[screen.main, screenrect] = Screen(screen.number,'OpenWindow',screen.background_colour,[]); %coords for test mode
[~] = Screen('BlendFunction', screen.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

screen.centerX = screen.rect(3)/2;
screen.centerY = screen.rect(4)/2;
Screen('TextSize', screen.main, screen.txt_size); %Reuter used 36..  
Screen('TextFont', screen.main, screen.font);

setup.cue_emotion_one_bounds = TextBounds(screen.main,setup.cue_emotion_one,0);
setup.cue_sex_one_bounds = TextBounds(screen.main,setup.cue_sex_one,0);
setup.cue_response_buttons_one_bounds = TextBounds(screen.main,setup.cue_response_buttons_one,0);
setup.cue_emotion_two_bounds = TextBounds(screen.main,setup.cue_emotion_two,0);
setup.cue_sex_two_bounds = TextBounds(screen.main,setup.cue_sex_two,0);
setup.cue_response_buttons_two_bounds = TextBounds(screen.main,setup.cue_response_buttons_two,0);
setup.cue_end_bounds = TextBounds(screen.main,setup.cue_end,0);


if setup.cue_position_one == "top" 
    setup.cue_emotion_one_x = screen.centerX-(setup.cue_emotion_one_bounds(3)/2);
    setup.cue_emotion_one_y = screen.centerY-(setup.cue_offset_fr_centre)-(setup.cue_offset_linespace*2);
    setup.cue_sex_one_x = screen.centerX-(setup.cue_sex_one_bounds(3)/2);
    setup.cue_sex_one_y = screen.centerY-(setup.cue_offset_fr_centre)-(setup.cue_offset_linespace*2);
    setup.cue_response_buttons_one_x = screen.centerX-(setup.cue_response_buttons_one_bounds(3)/2);
    setup.cue_response_buttons_one_y = screen.centerY-(setup.cue_offset_fr_centre)+(setup.cue_offset_linespace);
elseif setup.cue_position_one == "bottom"
    setup.cue_emotion_one_x = screen.centerX-(setup.cue_emotion_one_bounds(3)/2);
    setup.cue_emotion_one_y = screen.centerY+(setup.cue_offset_fr_centre)-(setup.cue_offset_linespace*2);
    setup.cue_sex_one_x = screen.centerX-(setup.cue_sex_one_bounds(3)/2);
    setup.cue_sex_one_y = screen.centerY+setup.cue_offset_fr_centre-(setup.cue_offset_linespace*2); 
    setup.cue_response_buttons_one_x = screen.centerX-(setup.cue_response_buttons_one_bounds(3)/2);
    setup.cue_response_buttons_one_y = screen.centerY+(setup.cue_offset_fr_centre)+(setup.cue_offset_linespace); 
elseif setup.cue_position_one == "left"
    setup.cue_emotion_one_x = screen.centerX-setup.cue_offset_fr_centre-(setup.cue_emotion_one_bounds(3)/2);
    setup.cue_emotion_one_y = screen.centerY-(setup.cue_offset_linespace*2);
    setup.cue_sex_one_x = screen.centerX-setup.cue_offset_fr_centre-(setup.cue_sex_one_bounds(3)/2);
    setup.cue_sex_one_y = screen.centerY-(setup.cue_offset_linespace*2);
    setup.cue_response_buttons_one_x = screen.centerX-setup.cue_offset_fr_centre-(setup.cue_response_buttons_one_bounds(3)/2);
    setup.cue_response_buttons_one_y = screen.centerY+(setup.cue_offset_linespace);
elseif setup.cue_position_one == "right"
    setup.cue_emotion_one_x = screen.centerX+setup.cue_offset_fr_centre-(setup.cue_emotion_one_bounds(3)/2);
    setup.cue_emotion_one_y = screen.centerY-(setup.cue_offset_linespace*2); 
    setup.cue_sex_one_x = screen.centerX+setup.cue_offset_fr_centre-(setup.cue_sex_one_bounds(3)/2);
    setup.cue_sex_one_y = screen.centerY-(setup.cue_offset_linespace*2);
    setup.cue_response_buttons_one_x = screen.centerX+setup.cue_offset_fr_centre-(setup.cue_response_buttons_one_bounds(3)/2);
    setup.cue_response_buttons_one_y = screen.centerY+(setup.cue_offset_linespace); 
else
    disp('modify settings cue positions to be one of: top, bottom or left, right');
    return
end

if setup.cue_position_two == "top" 
    setup.cue_emotion_two_x = screen.centerX-(setup.cue_emotion_two_bounds(3)/2);
    setup.cue_emotion_two_y = screen.centerY-(setup.cue_offset_fr_centre)-(setup.cue_offset_linespace*2);
    setup.cue_sex_two_x = screen.centerX-(setup.cue_sex_two_bounds(3)/2);
    setup.cue_sex_two_y = screen.centerY-(setup.cue_offset_fr_centre)-(setup.cue_offset_linespace*2);
    setup.cue_response_buttons_two_x = screen.centerX-(setup.cue_response_buttons_two_bounds(3)/2);
    setup.cue_response_buttons_two_y = screen.centerY-(setup.cue_offset_fr_centre)+(setup.cue_offset_linespace);
elseif setup.cue_position_two == "bottom"
    setup.cue_emotion_two_x = screen.centerX-(setup.cue_emotion_two_bounds(3)/2);
    setup.cue_emotion_two_y = screen.centerY+(setup.cue_offset_fr_centre)-(setup.cue_offset_linespace*2);
    setup.cue_sex_two_x = screen.centerX-(setup.cue_sex_two_bounds(3)/2);
    setup.cue_sex_two_y = screen.centerY+(setup.cue_offset_fr_centre)-(setup.cue_offset_linespace*2); 
    setup.cue_response_buttons_two_x = screen.centerX-(setup.cue_response_buttons_two_bounds(3)/2);
    setup.cue_response_buttons_two_y = screen.centerY+(setup.cue_offset_fr_centre)+(setup.cue_offset_linespace); 
elseif setup.cue_position_two == "left"
    setup.cue_emotion_two_x = screen.centerX-setup.cue_offset_fr_centre-(setup.cue_emotion_two_bounds(3)/2);
    setup.cue_emotion_two_y = screen.centerY-(setup.cue_offset_linespace*2);
    setup.cue_sex_two_x = screen.centerX-setup.cue_offset_fr_centre-(setup.cue_sex_two_bounds(3)/2);
    setup.cue_sex_two_y = screen.centerY-(setup.cue_offset_linespace*2);
    setup.cue_response_buttons_two_x = screen.centerX-setup.cue_offset_fr_centre-(setup.cue_response_buttons_two_bounds(3)/2);
    setup.cue_response_buttons_two_y = screen.centerY+(setup.cue_offset_linespace);
elseif setup.cue_position_two == "right"
    setup.cue_emotion_two_x = screen.centerX+setup.cue_offset_fr_centre-(setup.cue_emotion_two_bounds(3)/2);
    setup.cue_emotion_two_y = screen.centerY-(setup.cue_offset_linespace*2); 
    setup.cue_sex_two_x = screen.centerX+setup.cue_offset_fr_centre-(setup.cue_sex_two_bounds(3)/2);
    setup.cue_sex_two_y = screen.centerY-(setup.cue_offset_linespace*2);
    setup.cue_response_buttons_two_x = screen.centerX+setup.cue_offset_fr_centre-(setup.cue_response_buttons_two_bounds(3)/2);
    setup.cue_response_buttons_two_y = screen.centerY+(setup.cue_offset_linespace); 
else
    disp('modify settings cue positions to be one of: top, bottom or left, right')
    return
end
    
Screen('DrawText',screen.main, setup.cue_emotion_one,setup.cue_emotion_one_x,setup.cue_emotion_one_y,screen.txt_colour);
Screen('DrawText',screen.main, setup.cue_emotion_two,setup.cue_emotion_two_x,setup.cue_emotion_two_y,screen.txt_colour);
Screen('DrawText',screen.main, setup.cue_response_buttons_one,setup.cue_response_buttons_one_x,setup.cue_response_buttons_one_y,screen.txt_colour);
Screen('DrawText',screen.main, setup.cue_response_buttons_two,setup.cue_response_buttons_two_x,setup.cue_response_buttons_two_y,screen.txt_colour);

Screen('FrameOval',screen.main,screen.line_color,...
    [screen.centerX-screen.fix_out_rim_rad...
    screen.centerY-screen.fix_out_rim_rad...
    screen.centerX+screen.fix_out_rim_rad...
    screen.centerY+screen.fix_out_rim_rad],...
    screen.line_width);
Screen('FrameOval',screen.main,screen.line_color,...
    [screen.centerX-screen.fix_rad ...
    screen.centerY-screen.fix_rad ...
    screen.centerX+screen.fix_rad ...
    screen.centerY+screen.fix_rad ],...
    screen.line_width);
Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
Screen('Flip',screen.main);
WaitSecs(4);

Screen('DrawText',screen.main, setup.cue_sex_one,setup.cue_sex_one_x,setup.cue_sex_one_y,screen.txt_colour);
Screen('DrawText',screen.main, setup.cue_sex_two,setup.cue_sex_two_x,setup.cue_sex_two_y,screen.txt_colour);
Screen('DrawText',screen.main, setup.cue_response_buttons_one,setup.cue_response_buttons_one_x,setup.cue_response_buttons_one_y,screen.txt_colour);
Screen('DrawText',screen.main, setup.cue_response_buttons_two,setup.cue_response_buttons_two_x,setup.cue_response_buttons_two_y,screen.txt_colour);

Screen('FrameOval',screen.main,screen.line_color,...
    [screen.centerX-screen.fix_out_rim_rad...
    screen.centerY-screen.fix_out_rim_rad...
    screen.centerX+screen.fix_out_rim_rad...
    screen.centerY+screen.fix_out_rim_rad],...
    screen.line_width);
Screen('FrameOval',screen.main,screen.line_color,...
    [screen.centerX-screen.fix_rad ...
    screen.centerY-screen.fix_rad ...
    screen.centerX+screen.fix_rad ...
    screen.centerY+screen.fix_rad ],...
    screen.line_width);
Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
Screen('Flip',screen.main);
WaitSecs(4);

Screen('DrawText',screen.main, setup.cue_end,screen.centerX-(setup.cue_end_bounds(3)/2),screen.centerY-(setup.cue_end_bounds(4)/2),screen.txt_colour);
Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
Screen('Flip',screen.main);
WaitSecs(4);
Screen('CloseAll');

%% Set trial and block loop values based on run number

setup.trial_start = find(experiment_design.task_order_run == setup.subject_run,1,'first');
setup.trial_end = find(experiment_design.task_order_run == setup.subject_run,1,'last');

block_transitions = find(diff(experiment_design.task_order_trial_sep)~=1);
setup.block_starts = [1; block_transitions + 1]; 

disp('Loading target and mask images into workspace, takes around ~2 mins...')

for t = setup.trial_start:setup.trial_end
    tic;
    target_image_name{t} = stim.images.(experiment_design_struct(t).stim_target_id)(experiment_design_struct(t).stim_target_photo_ref).name;
    target_image{t} = imread(target_image_name{t});
    mask_image_name{t} = stim.images_blist.(experiment_design_struct(t).stim_mask_id)(experiment_design_struct(t).stim_mask_photo_ref).name;
    mask_image{t} = imread(mask_image_name{t});
    toc;
end

setup.target_image_name = target_image_name';
target_image = target_image';
setup.mask_image_name = mask_image_name';
mask_image = mask_image';

stim.image_size_original = size(target_image{t}); 
stim.image_size_X = round(stim.image_size_original(2)*screen.scaling_factor); 
stim.image_size_Y = round(stim.image_size_original(1)*screen.scaling_factor);


%% Transform setup to table

clear t mask_image_name target_image_name block_transitions experiment_data
setup_table = removevars((struct2table(setup, 'AsArray', true)),...
    {'target_image_name','mask_image_name','block_starts','cue_end_bounds',...
    'cue_emotion_one_bounds','cue_sex_one_bounds', 'cue_response_buttons_one_bounds',...
    'cue_emotion_two_bounds','cue_sex_two_bounds', 'cue_response_buttons_two_bounds'});

