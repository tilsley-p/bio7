%% General experimenter launcher
%  =============================
% By :      Martin SZINTE
% Projet :  pRFexp7T
% With :    Penelope TILSLEY, Jan Patrick STELLMANN

% Version description
% ===================
% Experiment in which we use a square full screen 4 directions (left/right/up/down) 
% bar pass stimuli with an attention task to the bar in order to obtain pRF retinotopy of 
% the occipital, parietal, frontal and subcortical structures.
% Adapted for 7T scanner CRMBM
% Use circular apperture
% Add full screen cross

% Settings
% For training:
% -------------
% - keep unplug hdmi, and put monitor at 60 Hz
% - insist on button, timing of response, fixation, stimuli orientation
% For main task: 
% --------------
% - plug Boldscreen to box (blue cable to back of box)
% - plug HDMI cable, select extend mode (fn + F11), boldscreen at 120 hz
% - flip the screen pressing leftmost front button on BoldScreen box
% - plug USB of button box from top part left (green dot) to laptop
% - plug the trigger cable to the trigger box
% - turn on power of button box (top and bottom part)
% - go to options USB mode, change from Serial to HID (change back to serial at the end) 
% - put trigger volume to 1
% - go to back menu and save as default
% - go to choose mode and pick synchronisation ON EACH RUN
% - Start session
% - Launch code, pass instructions, it will wait for first TR

% To do:
% -----
% - change phase direction of record in sequence

% First settings
% --------------
Screen('CloseAll');clear all;clear mex;clear functions;close all;home;AssertOpenGL;

% General settings
% ----------------
const.expStart          =   1;              % Start of a recording exp                          0 = NO  , 1 = YES
const.checkTrial        =   0;              % Print trial conditions (for debugging)            0 = NO  , 1 = YES
const.genStimuli        =   0;              % Generate the stimuli                              0 = NO  , 1 = YES
const.drawStimuli       =   0;              % Draw stimuli generated                            0 = NO  , 1 = YES
const.mkVideo           =   0;              % Make a video of a run                             0 = NO  , 1 = YES

% External controls
% -----------------
const.scanner           =   1;              % run in MRI scanner                                0 = NO  , 1 = YES
const.scannerTest       =   0;              % run with T returned at TR time                    0 = NO  , 1 = YES
const.room              =   1;              % run in MRI or eye-tracking room                   1 = MRI , 2 = eye-tracking
const.training          =   0;              % training session                                  0 = NO  , 1 = YES

% Run order and number per condition
% ----------------------------------
const.cond_run_order    =   [01;01];
const.cond_run_num      =   [01;02];

% Desired screen setting
% ----------------------
if const.training
    const.desiredFD     =   60;             % Desired refresh rate for training on laptop
else
    const.desiredFD     =   120;            % Desired refresh rate on bold screen
end
%fprintf(1,'\n\n\tDon''t forget to change before testing\n');
const.desiredRes        =   [1920,1080];    % Desired resolution

% Path
% ----
dir                     =   (which('expLauncher'));
cd(dir(1:end-18));

% Add Matlab path
% ---------------
addpath('config','main','conversion','instructions','trials','stim','stats');

% Subject configuration
% ---------------------
[const]                 =   sbjConfig(const);
                        
% Main run
% --------
main(const);
