%% Configuration file 
% Screen parameters 

function [screen,stim] = config_stimuli(settings, stimuli_wksp)

experiment_settings = settings;
stim = stimuli_wksp;
sca;

%% Inputting desired screen refresh rate

screen.des.hz = experiment_settings.target_framerate; 
screen.des.framerate = 1/screen.des.hz;

%% prepare screen parameters and display screen
screen.all = Screen('Screens');
screen.number = max(screen.all);
screen.white = WhiteIndex(screen.number);
screen.black = BlackIndex(screen.number);
screen.grey = screen.white*0.34;
screen.background_colour = screen.(experiment_settings.display_background);
screen.txt_size = 50;
screen.txt_colour = screen.white;
screen.font = 'courier new';

%% psychtoolbox synctests 

% inf infinite
% screen.synctest = Screen('Preference', 'SkipSyncTests', 1);
screen.synctest = Screen('Preference','SyncTestSettings', 0.01, 50, 0.25);
%%

screen.frame_duration = 1/(Screen('FrameRate',screen.number));
screen.hz = 1/(screen.frame_duration);

[screen.sizeX, screen.sizeY] = Screen('WindowSize', screen.number); %pixels
[screen.disp_sizeX, screen.disp_sizeY] = Screen('DisplaySize', screen.number); %mm
screen.sizePixel = Screen('PixelSize', screen.number); %bpp

screen.centerX = screen.sizeX/2;
screen.centerY = screen.sizeY/2;

%ScreenTest
[screen.testwindow, screen.rect] = Screen('OpenWindow',screen.number);
screen.frame_duration_mfitest = Screen('GetFlipInterval', screen.testwindow);
screen.hz_mfitest = 1/screen.frame_duration_mfitest; 

Screen('CloseAll');

disp(['Recorded refresh rate: ' num2str(screen.hz_mfitest) ''])

%% Checking for screen refresh errors 

if exist('subject_MRI', 'var')
    
    if subject_MRI == 1
        
        if round(screen.hz_mfitest) ~= screen.des.hz            
            error_screenrefresh = ({(['screen refresh rate not as desired, got: ' num2str(screen.hz_mfitest) ' need to change something'])})
            %return           
        else
            %OK 
        end
        
    else
        % only running as test mode, probably OK to continue, just post error
        if round(screen.hz) ~= screen.des.hz            
            warning_screenrefresh = ({(['screen refresh rate not as desired, got:' num2str(screen.hz_mfitest) 'continued anyway..'])})           
        else
            %OK 
        end
        
    end   
    
else
    % running from other mode e.g., config for design, post errors 

    if screen.des.framerate == screen.frame_duration_mfitest
        %OK 
    else
        error1_screenrefresh = str2mat({(['measured framerate not good? Got: ' num2str(screen.frame_duration_mfitest) ', Want: ' num2str(screen.des.framerate) ''])})
    end

    if screen.des.hz == screen.hz
        %OK 
    else
        error2_screenrefresh = str2mat({(['measured Hz not good? Got: ' num2str(screen.hz_mfitest) ', Want: ' num2str(screen.des.hz) ''])})
    end
    
end

%% Calculating stimulus locations and sizes depending if laptop or MRI
scr = scr_calculations(experiment_settings, stim);

screen.scaling_factor = scr.scaling_factor;
screen.offset_x = scr.desired_pix_x;
screen.va_x = scr.desired_va_x;
screen.va_y = scr.desired_va_y;
screen.cm_x = scr.desired_cm_x;
screen.cm_y = scr.desired_cm_y;
screen.pix_x = scr.desired_pix_x;
screen.pix_y = scr.desired_pix_y;
screen.dist = scr.dist;

%% Setting up fixation cross values 

screen.fix_out_rim_radVal=   0.3;                                                                % radius of outer circle of fixation bull's eye
screen.fix_rim_radVal    =   0.75*screen.fix_out_rim_radVal;                                      % radius of intermediate circle of fixation bull's eye in degree
screen.fix_radVal        =   0.25*screen.fix_out_rim_radVal;                                      % radius of inner circle of fixation bull's eye in degrees
screen.fix_out_rim_rad   =   vaDeg2pix(screen.fix_out_rim_radVal,scr);                            % radius of outer circle of fixation bull's eye in pixels
screen.fix_rim_rad       =   vaDeg2pix(screen.fix_rim_radVal,scr);                                % radius of intermediate circle of fixation bull's eye in pixels
screen.fix_rad           =   vaDeg2pix(screen.fix_radVal,scr);                                    % radius of inner circle of fixation bull's eye in pixels


% Fixation lines
screen.line_width = screen.fix_rad;                                               % fixation line width
screen.line_color = screen.white;                                                 % fixation line color
screen.line_fix_up_left = [0,...                                                 % up left part of fix cross x start
                          scr.scr_sizeX/2 - screen.fix_out_rim_rad;....          % up left part of fix cross x end
                          -(scr.scr_sizeX-scr.scr_sizeY)/2,...                  % up left part of fix cross y start
                          scr.scr_sizeY/2 - screen.fix_out_rim_rad];             % up left part of fix cross y end
 
screen.line_fix_up_right = [scr.scr_sizeX/2 + screen.fix_out_rim_rad,...          % up right part of fix cross x start
                           scr.scr_sizeX;....                                   % up right part of fix cross x end
                           scr.scr_sizeY/2 - screen.fix_out_rim_rad,...          % up right part of fix cross y start
                           -(scr.scr_sizeX-scr.scr_sizeY)/2];                   % up right part of fix cross y end
                       
screen.line_fix_down_left = [0,...                                               % down left part of fix cross x start
                            scr.scr_sizeX/2 - screen.fix_out_rim_rad;....        % down left part of fix cross x end
                            scr.scr_sizeY+(scr.scr_sizeX-scr.scr_sizeY)/2,...   % down left part of fix cross y start
                            scr.scr_sizeY/2 + screen.fix_out_rim_rad];           % down left part of fix cross y end
 
screen.line_fix_down_right = [scr.scr_sizeX/2 + screen.fix_out_rim_rad,...        % down right part of fix cross x start
                             scr.scr_sizeX;....                                 % down right part of fix cross x end
                             scr.scr_sizeY/2 + screen.fix_out_rim_rad,...        % down right part of fix cross y start
                             scr.scr_sizeY+(scr.scr_sizeX-scr.scr_sizeY)/2];    % down right part of fix cross y end

%% Programming stimulus locations and size 

% %selecting number of image locations 

stim.location_coord = zeros(stim.locations_no,2);

for idx = 1:stim.locations_no
    
    if string(stim.locations_id(idx)) == 'c'
        stim.location_central = [(screen.centerX) (screen.centerY)];
        stim.location_coord(idx,:) = stim.location_central;
    elseif string(stim.locations_id(idx)) == 'l'
        stim.location_left = [(screen.centerX-screen.offset_x) (screen.centerY)];
        stim.location_coord(idx,:) = stim.location_left;
    elseif string(stim.locations_id(idx)) == 'r'
        stim.location_right = [(screen.centerX+screen.offset_x) (screen.centerY)];
        stim.location_coord(idx,:) = stim.location_right;
    elseif string(stim.locations_id(idx)) == 't'
        stim.location_top = [(screen.centerX) (screen.centerY-screen.offset_x)];
        stim.location_coord(idx,:) = stim.location_top;
    elseif string(stim.locations_id(idx)) == 'b'
        stim.location_bottom = [(screen.centerX) (screen.centerY+screen.offset_x)];
        stim.location_coord(idx,:) = stim.location_bottom;
    else
        error_stimloc = ('config_screen not setup for input stimuli locations in settings.json')
    end
    
end

