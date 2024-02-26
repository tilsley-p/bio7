%% Task execution setup file

clear;
sca; 
 
addpath('archive','config','conversion','data', 'execution','stimuli');

setup.subject_mode = input('test(0) or MRI(1)?: ');
setup.subject_lang = input('Run in french(0) or english(1): ');

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

%% Loading language info and setting up cues 
setup.cue_offset_fr_centre = 300;
setup.cue_offset_linespace = 30;

if setup.subject_lang == 0
    setup.cue_position_one = char(experiment_settings.display_cue_pos(1));
    setup.cue_emotion_one = [char(experiment_settings.target_emotion_choices_french(1)) '?'];
    setup.cue_sex_one = [char(experiment_settings.target_sex_choices_french(1)) '?'];
    setup.cue_response_buttons_one = ['-' char(experiment_settings.response_buttons_french(1)) '-'];
    
    setup.cue_position_two = char(experiment_settings.display_cue_pos(2));
    setup.cue_emotion_two = [char(experiment_settings.target_emotion_choices_french(2)) '?'];
    setup.cue_sex_two = [char(experiment_settings.target_sex_choices_french(2)) '?'];
    setup.cue_response_buttons_two = ['-' char(experiment_settings.response_buttons_french(2)) '-'];
    
    setup.cue_end = char(experiment_settings.display_cue_end_french);
    setup.subject_language = 'french'; 
    
elseif setup.subject_lang == 1
    setup.cue_position_one = char(experiment_settings.display_cue_pos(1));
    setup.cue_emotion_one = [char(experiment_settings.target_emotion_choices(1)) '?'];
    setup.cue_sex_one = [char(experiment_settings.target_sex_choices(1)) '?'];
    setup.cue_response_buttons_one = ['-' char(experiment_settings.response_buttons(1)) '-'];
    
    setup.cue_position_two = char(experiment_settings.display_cue_pos(2));
    setup.cue_emotion_two = [char(experiment_settings.target_emotion_choices(2)) '?'];
    setup.cue_sex_two = [char(experiment_settings.target_sex_choices(2)) '?'];
    setup.cue_response_buttons_two = ['-' char(experiment_settings.response_buttons(2)) '-'];
    setup.cue_end = char(experiment_settings.display_cue_end);  
    
    setup.subject_language = 'english'; 
else
    disp('non-valid input for language options');
end

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
