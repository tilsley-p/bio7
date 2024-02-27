%% Experiment execution file 
% task: emotion localiser, run experimental runs

%% Clearing anything in the workspace

clear;
sca; 

%% add paths to various folders for scripts, data 
addpath('config','conversion');

config_screen

config_keys

setup_calculations


%% Launching experiment Psychtoolbox
%%


%% Opening screen utting up fixation cross screen
[screen.main, screenrect] = Screen(screen.number,'OpenWindow',screen.grey,[]); %coords for test mode
[~] = Screen('BlendFunction', screen.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% screen.frame_duration_mfitest = Screen('GetFlipInterval', screen.main);
% screen.hz_mfitest = 1/screen.frame_duration_mfitest; 

screen.centerX = screen.rect(3)/2;
screen.centerY = screen.rect(4)/2;
Screen('TextSize', screen.main, screen.txt_size); %Reuter used 36.. 
Screen('TextFont', screen.main, screen.font);

Screen('DrawLines',screen.main, screen.line_fix_up_left, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_up_right, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_down_left, screen.line_width, screen.line_color, [], 1);
Screen('DrawLines',screen.main, screen.line_fix_down_right, screen.line_width, screen.line_color, [], 1);
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

commandwindow
HideCursor

disp('Waiting for stop key...')

% clear keyboard queue
while KbCheck 
end 

% wait for trigger
while ~KbCheck

DisableKeysForKbCheck([key.trigger,key.left1,key.left2,key.right1,key.right2]);

RestrictKeysForKbCheck([key.stop]);

[key_pressed, key_press_time, key_code] = KbCheck;

if key_code(key.stop)
    Screen('CloseAll');
    return
else
%continue
end 

end

