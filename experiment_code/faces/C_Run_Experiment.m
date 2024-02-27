%% Experiment execution file 
% task: emotion, run experimental runs
commandwindow

if exist('setup','var')
    if exist('experiment_data', 'var')
        disp('data already exists for this setup, re-run same run? data may be overwritten..')
        disp('May need to run: B_Run_Setup_Experiment')
        rerun = input('continue anyway yes (1) or no (0)?: ');
        if rerun == 1
        else
            return
        end  
    else
    end
else
    disp('Please run: B_Run_Setup_Experiment, before this code to load subject info and images')
    return
end


keypressed = 0; 
HideCursor;
[screen, stim] = config_screen(experiment_settings, stim);

%% 


%%%%%%%%%%%%%%%%%%%% RUNNING EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%% 



%% Putting blank screen with fixation cross
[screen.main, screenrect] = Screen(screen.number,'OpenWindow',screen.background_colour,[]); %coords for test mode
[~] = Screen('BlendFunction', screen.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

screen.centerX = screen.rect(3)/2;
screen.centerY = screen.rect(4)/2;
Screen('TextSize', screen.main, screen.txt_size); %Reuter used 36.. 
Screen('TextFont', screen.main, screen.font);

%Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
%Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
%Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
%Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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
Screen('Flip',screen.main);

%% Waiting for trigger 

disp('Waiting for trigger...')

% clear keyboard queue
while KbCheck 
end 

% wait for trigger
while ~KbCheck

DisableKeysForKbCheck([key.left1,key.left2,key.right1,key.right2]);

RestrictKeysForKbCheck([key.trigger, key.stop]);

[key_pressed, key_press_time, key_code] = KbCheck;

if key_code(key.stop)
    Screen('CloseAll');
    return
else
    %key_trigger
    onset_trigger = key_press_time; 
end 

end

disp('experiment triggered')

RestrictKeysForKbCheck([]);
DisableKeysForKbCheck(key.trigger);

HideCursor;

%% Task - Making image texture and presenting images

for t = setup.trial_start:setup.trial_end
    
    if ismember(t, setup.block_starts)
        
        if t == setup.trial_start
            data.onset_trigger(t) = onset_trigger; 
            data.onset_run(t) = GetSecs; 
        else
        end
        % Saving timing onset blocks
        data.onset_block(t) = GetSecs;   
        

        %Preseting cue for choices
        if experiment_design_struct(t).task_trial_type == 'T'
            cue_one = setup.cue_emotion_one;
            cue_one_x = setup.cue_emotion_one_x;
            cue_one_y = setup.cue_emotion_one_y;
            cue_two = setup.cue_emotion_two;
            cue_two_x = setup.cue_emotion_two_x;
            cue_two_y = setup.cue_emotion_two_y;
            
            Screen('DrawText',screen.main, setup.cue_emotion_one,setup.cue_emotion_one_x,setup.cue_emotion_one_y,screen.black);
            Screen('DrawText',screen.main, setup.cue_emotion_two,setup.cue_emotion_two_x,setup.cue_emotion_two_y,screen.black);
            Screen('DrawText',screen.main, setup.cue_response_buttons_one,setup.cue_response_buttons_one_x,setup.cue_response_buttons_one_y,screen.black);
            Screen('DrawText',screen.main, setup.cue_response_buttons_two,setup.cue_response_buttons_two_x,setup.cue_response_buttons_two_y,screen.black);
            %Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
            %Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
            %Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
            %Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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
                screen.centerY+screen.fix_rad],...
                screen.line_width);
            Screen('Flip',screen.main);
            WaitSecs(experiment_settings.display_cue_secs);
        else
            % Putting cue on screen 
            
            cue_one = setup.cue_sex_one;
            cue_one_x = setup.cue_sex_one_x;
            cue_one_y = setup.cue_sex_one_y;
            cue_two = setup.cue_sex_two;
            cue_two_x = setup.cue_sex_two_x;
            cue_two_y = setup.cue_sex_two_y;
            
            Screen('DrawText',screen.main, setup.cue_sex_one,setup.cue_sex_one_x,setup.cue_sex_one_y,screen.black);
            Screen('DrawText',screen.main, setup.cue_sex_two,setup.cue_sex_two_x,setup.cue_sex_two_y,screen.black);
            Screen('DrawText',screen.main, setup.cue_response_buttons_one,setup.cue_response_buttons_one_x,setup.cue_response_buttons_one_y,screen.black);
            Screen('DrawText',screen.main, setup.cue_response_buttons_two,setup.cue_response_buttons_two_x,setup.cue_response_buttons_two_y,screen.black);
            %Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
            %Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
            %Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
            %Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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
                screen.centerY+screen.fix_rad],...
                screen.line_width);
            Screen('Flip',screen.main);
            WaitSecs(experiment_settings.display_cue_secs);
        end

        % Fixation cross for half the time
        %Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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
            screen.centerY+screen.fix_rad],...
            screen.line_width);
        Screen('Flip',screen.main);
        WaitSecs(experiment_settings.display_cue_secs); 

    else
    end

    %% Drawing image textures
    target_texture = Screen('MakeTexture',screen.main,target_image{t}); 
    mask_texture = Screen('MakeTexture',screen.main,mask_image{t});

    %% Presenting images 

    %% 1. Showing fixation cross for certain amount of jitter 
    data.onset_trial(t) = GetSecs;

    jitter_tic = 0;

    while jitter_tic < (experiment_design_struct(t).time_jitter_secs - screen.frame_duration_mfitest)

        Screen('DrawText',screen.main, cue_one,cue_one_x,cue_one_y,screen.txt_colour);
        Screen('DrawText',screen.main, cue_two,cue_two_x,cue_two_y,screen.txt_colour);
        Screen('DrawText',screen.main, setup.cue_response_buttons_one,setup.cue_response_buttons_one_x,setup.cue_response_buttons_one_y,screen.txt_colour);
        Screen('DrawText',screen.main, setup.cue_response_buttons_two,setup.cue_response_buttons_two_x,setup.cue_response_buttons_two_y,screen.txt_colour); 
        %Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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
            screen.centerY+screen.fix_rad],...
            screen.line_width);

        jitter_flip = Screen('Flip',screen.main);
        jitter_tic = jitter_flip-data.onset_trial(t);
    end

    %% 2. Showing target for different times (soa) 
    data.onset_target(t) = GetSecs; 

    soa_tic = 0;

    while soa_tic < (experiment_design_struct(t).time_soa_secs - screen.frame_duration_mfitest)

        Screen('DrawTexture',screen.main, target_texture, [],...
            [experiment_design_struct(t).stim_location_x - (stim.image_size_X/2)...
            experiment_design_struct(t).stim_location_y - (stim.image_size_Y/2)...
            experiment_design_struct(t).stim_location_x + (stim.image_size_X/2)...
            experiment_design_struct(t).stim_location_y + (stim.image_size_Y/2)]);
        Screen('DrawText',screen.main, cue_one,cue_one_x,cue_one_y,screen.txt_colour);
        Screen('DrawText',screen.main, cue_two,cue_two_x,cue_two_y,screen.txt_colour);
        Screen('DrawText',screen.main, setup.cue_response_buttons_one,setup.cue_response_buttons_one_x,setup.cue_response_buttons_one_y,screen.txt_colour);
        Screen('DrawText',screen.main, setup.cue_response_buttons_two,setup.cue_response_buttons_two_x,setup.cue_response_buttons_two_y,screen.txt_colour);
        %Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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
            screen.centerY+screen.fix_rad],...
            screen.line_width);

        soa_flip = Screen('Flip',screen.main); 
        soa_tic = soa_flip-data.onset_target(t);
    end

    %% 3. Showing mask for fixed amount of time 

    data.onset_mask(t) = GetSecs;

    mask_tic = 0; 

    while mask_tic < (experiment_design_struct(t).time_mask_secs - screen.frame_duration_mfitest)

        Screen('DrawTexture',screen.main, mask_texture, [],...
            [experiment_design_struct(t).stim_location_x - (stim.image_size_X/2)...
            experiment_design_struct(t).stim_location_y - (stim.image_size_Y/2)...
            experiment_design_struct(t).stim_location_x + (stim.image_size_X/2)...
            experiment_design_struct(t).stim_location_y + (stim.image_size_Y/2)]);
        Screen('DrawText',screen.main, cue_one,cue_one_x,cue_one_y,screen.txt_colour);
        Screen('DrawText',screen.main, cue_two,cue_two_x,cue_two_y,screen.txt_colour);
        Screen('DrawText',screen.main, setup.cue_response_buttons_one,setup.cue_response_buttons_one_x,setup.cue_response_buttons_one_y,screen.txt_colour);
        Screen('DrawText',screen.main, setup.cue_response_buttons_two,setup.cue_response_buttons_two_x,setup.cue_response_buttons_two_y,screen.txt_colour);
        %Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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
            screen.centerY+screen.fix_rad],...
            screen.line_width);

        mask_flip = Screen('Flip',screen.main);  
        mask_tic = mask_flip - data.onset_mask(t);
    end

    %% Clearing kb queue for checks 

    while KbCheck 
    end % clear keyboard queue
    FlushEvents('keyDown');
    key_code = [];
    key_pressed = 0;

    RestrictKeysForKbCheck([key.left1,key.left2,key.right1,key.right2, key.stop, key.pause]);
    DisableKeysForKbCheck(key.trigger);

    %% Showing fixation cross for fixed response time 

    data.onset_response(t) = GetSecs;
    response_tic = 0;

    while response_tic < (experiment_design_struct(t).time_response_secs - screen.frame_duration_mfitest)

        Screen('DrawText',screen.main, cue_one,cue_one_x,cue_one_y,screen.txt_colour);
        Screen('DrawText',screen.main, cue_two,cue_two_x,cue_two_y,screen.txt_colour);
        Screen('DrawText',screen.main, setup.cue_response_buttons_one,setup.cue_response_buttons_one_x,setup.cue_response_buttons_one_y,screen.txt_colour);
        Screen('DrawText',screen.main, setup.cue_response_buttons_two,setup.cue_response_buttons_two_x,setup.cue_response_buttons_two_y,screen.txt_colour);
        %Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
        %Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
        Screen('FrameOval',screen.main,screen.line_color,...
            [screen.centerX-screen.fix_out_rim_rad...
            screen.centerY-screen.fix_out_rim_rad...
            screen.centerX+screen.fix_out_rim_rad... 
            screen.centerY+screen.fix_out_rim_rad],...
            screen.line_width);

        response_flip = Screen('Flip',screen.main);    
        response_tic = response_flip-data.onset_response(t);

        [key_pressed, key_press_time, key_code] = KbCheck;

        FlushEvents('keyDown');   

        if key_pressed

            %only record the first key press, when data struct is still NaN
            if isnan(data.response_key(t))

                if key_code(key.left1)
                    data.response_time(t) = key_press_time;
                    data.reaction_time(t) = (key_press_time - data.onset_response(t));
                    %Define the response key side and assigned code
                    data.response_key(t) = key.left1;
                    data.response_key_name(t) = cellstr('left1');
                    data.response_key_id(t) = cellstr(key.left1_letter);
                    clear key_pressed key_press_time key_code

                elseif key_code(key.left2)
                    data.response_time(t) = key_press_time;
                    data.reaction_time(t) = (key_press_time - data.onset_response(t));
                    %Define the response key side and assigned code
                    data.response_key(t) = key.left2;
                    data.response_key_name(t) = cellstr('left2');
                    data.response_key_id(t) = cellstr(key.left2_letter);
                    clear key_pressed key_press_time key_code
                    
                elseif key_code(key.right1)
                    data.response_time(t) = key_press_time;
                    data.reaction_time(t) = (key_press_time - data.onset_response(t));
                    %Define the response key side and assigned code
                    data.response_key(t) = key.right1;
                    data.response_key_name(t) = cellstr('right1');
                    data.response_key_id(t) = cellstr(key.right1_letter);
                    clear key_pressed key_press_time key_code
                    
                elseif key_code(key.right2)
                    data.response_time(t) = key_press_time;
                    data.reaction_time(t) = (key_press_time - data.onset_response(t));
                    %Define the response key side and assigned code
                    data.response_key(t) = key.right2;
                    data.response_key_name(t) = cellstr('right2');
                    data.response_key_id(t) = cellstr(key.right2_letter);
                    clear key_pressed key_press_time key_code
                
                elseif key_code(key.stop)
                    data.response_time(t) = key_press_time;
                    data.reaction_time(t) = (key_press_time - data.onset_response(t));
                    %Define the response key code for stop, 999                       
                    data.response_key(t) = 999;
                    data.response_key_name(t) = cellstr('stop');
                    data.response_key_id(t) = cellstr(key.stop_letter);

                    Screen('CloseAll');
                    clear key_pressed key_press_time key_code
                    return
                else
                end

            else
                %button has already been pressed
                %can still stop the experiment even after first response given
                if key_code(key.stop)

                    data.response_time(t) = key_press_time;
                    data.reaction_time(t) = (data.response_time(t) - data.onset_response(t));

                    %Define the response key code for stop, 999                       
                    data.response_key(t) = 999;
                    data.response_key_name(t) = cellstr('stop');
                    data.response_key_id(t) = cellstr(key.stop_letter);
                    Screen('CloseAll');
                    clear key_pressed key_press_time key_code
                    return
                else
                clear key_pressed key_press_time key_code    
                end
            end
        else
            % no key pressed yet...
        end
    end
    % no more time to respond, end trial 

    data.offset_trial(t) = GetSecs;

    %% Calculate durations for events 
    data.duration_jitter(t) = jitter_flip - data.onset_trial(t);
    data.duration_target(t) = soa_flip - data.onset_target(t);
    data.duration_mask(t) = mask_flip - data.onset_mask(t);
    data.duration_response(t) = data.offset_trial(t) - data.onset_response(t);
    data.duration_trial(t) = data.offset_trial(t) - data.onset_trial(t);
    
    %Logging trial and image names
    data.trial_number_check(t) = t; 
    data.target_image_check{t} = setup.target_image_name{t}; 
    data.mask_image_check{t} = setup.mask_image_name{t};  
    
    %% Closing texture screens          
    Screen('Close', target_texture)
    Screen('Close', mask_texture)
    clear target_texture mask_texture
    
    if t == setup.trial_end
        data.offset_run(t) = GetSecs; 
    else
    end
end

%% 



%%%%%%%%%%%%%%% Experiment FINISHED  %%%%%%%%%%%%%%%



%
%% Present blank fixation screen end of experiment
%Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
%Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
%Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
%Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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
    screen.centerY+screen.fix_rad],...
    screen.line_width);
Screen('Flip', screen.main);
 
%% Save data

disp('Experiment finished, saving data...');

clear target_image mask_image

% Adding setup info 
data.subject_number(setup.trial_start:setup.trial_end) = repelem(setup.subject_no, length(setup.trial_start:setup.trial_end)); 
data.subject_type(setup.trial_start:setup.trial_end) = repelem(cellstr(setup.subject_type), length(setup.trial_start:setup.trial_end)); 
data.subject_mode(setup.trial_start:setup.trial_end) = repelem(setup.subject_mode, length(setup.trial_start:setup.trial_end)); 
data.subject_run(setup.trial_start:setup.trial_end) = repelem(setup.subject_run, length(setup.trial_start:setup.trial_end)); 
data.subject_rep(setup.trial_start:setup.trial_end) = repelem(setup.subject_rep, length(setup.trial_start:setup.trial_end));
data.subject_date(setup.trial_start:setup.trial_end) = repelem(cellstr(date), length(setup.trial_start:setup.trial_end));
data.subject_lang(setup.trial_start:setup.trial_end) = repelem(cellstr(setup.subject_language), length(setup.trial_start:setup.trial_end));
% Calculate frames 
data.duration_trial_frames = data.duration_trial / screen.frame_duration_mfitest;
data.duration_jitter_frames = data.duration_jitter / screen.frame_duration_mfitest;
data.duration_target_frames = data.duration_target / screen.frame_duration_mfitest;
data.duration_mask_frames = data.duration_mask / screen.frame_duration_mfitest;
data.duration_response_frames = data.duration_response / screen.frame_duration_mfitest;
% Calculate response correct

% Transform into table
experiment_data = struct2table(data);

% Save data and design
save(fullfile('data',setup.data_mat_name)); 
writetable(experiment_design,fullfile('data',setup.design_csv_name));   
writetable(experiment_data,fullfile('data',setup.data_csv_name)); 

% Save setup
writetable(setup_table,fullfile('data',setup.save_setup));
copyfile('settings.json', fullfile('data',setup.save_settings));

%% Removes screen when any keyboard press 

time_exp_secs = data.offset_run(t) - onset_trigger;
time_exp_mins = time_exp_secs/60;
time_exp_vols = time_exp_secs * mri.TR;

disp(['Experiment took: ' num2str(time_exp_mins) 'mins and : ' num2str(time_exp_vols) ' volumes']);
disp('Saving finished, waiting for stop key...');

RestrictKeysForKbCheck(key.stop);
DisableKeysForKbCheck(key.trigger);

while KbCheck 
    % clear keyboard queue
end 
while ~KbCheck 
    % wait for a stop key press
end

Screen('CloseAll');
