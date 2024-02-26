%% EKMANN Faces Task - Load Experiment
% Loads all 60 Faces, across 6 emotion choices:
% 'surprise 'fear 'disgust 'joy 'anger 'sadness 

% Gets inputs of subject for saving details
% FYI: be careful to input correctly (no spaces etc.) else there will be
% problems with saving correctly
% Tests screen and presents choice labels in their positions (5s) 

% Coded by: Penelope Tilsley, tilsley.penelope@gmail.com
% Last updated: 10.01.2024

%% Load images from Excel file and setup screen 

clear;
sca; 

addpath('stimuli','data','config','archive');

image_order = 'image_order_Ekmann.xlsx';
[num, imagelist, ] = xlsread(image_order);
image_names = strcat(imagelist(2:end), '.jpg');


%% Getting inputs and setup
setup.subject_no = input('Subject number?: ');
setup.subject_type = lower(input('Patient (p) or control (c)?: ','s'));
setup.subject_lang = input('Run in french(0) or english(1): ');

% Initialize Psychtoolbox
%% prepare screen parameters and display screen
screen.all = Screen('Screens');
screen.number = max(screen.all);
screen.white = WhiteIndex(screen.number);
screen.black = BlackIndex(screen.number);
screen.grey = screen.white*0.34;
screen.txt_size = 35;
screen.txt_colour = screen.black;
screen.font = 'courier new';
screen.frame_duration = 1/(Screen('FrameRate',screen.number));
screen.hz = 1/(screen.frame_duration);
[screen.sizeX, screen.sizeY] = Screen('WindowSize', screen.number); %pixels
[screen.disp_sizeX, screen.disp_sizeY] = Screen('DisplaySize', screen.number); %mm
screen.sizePixel = Screen('PixelSize', screen.number); %bpp
screen.synctest = Screen('Preference','SyncTestSettings', 0.01, 50, 0.25);

[screen.main, screen.rect] = Screen(screen.number,'OpenWindow',screen.white,[]); %coords for test mode
[~] = Screen('BlendFunction', screen.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
screen.centerX = screen.rect(3)/2;
screen.centerY = screen.rect(4)/2;
Screen('TextSize', screen.main, screen.txt_size); %Reuter used 36.. 
Screen('TextFont', screen.main, screen.font);


%% Setup target images 

for t = 1:length(image_names)
    tic;
    target_image_name = string(image_names(t));
    target_image{t} = imread(target_image_name);
    toc;
end

target_image = target_image'; 

stim.image_size_original = size(target_image{t}); 
stim.image_size_X = round(stim.image_size_original(2)) * 2; 
stim.image_size_Y = round(stim.image_size_original(1)) * 2;


%% Setup labels 

labels_fr = ["surprise", "peur", "dégoût", "joie", "colère", "tristesse"]; 
labels_eng = ["surprise", "fear", "disgust", "joy", "anger", "sadness"]; 

if setup.subject_lang == 0 %french
    labels = labels_fr; 
    next_label = ["suivant"];
    stop_label = ["x"];
else % setup.subject_lang == 1; %english
    labels = labels_eng; 
    next_label = ["next"];
    stop_label = ["x"];
end

labels_width = 250;
labels_height = 50;
labels_gap = 50;

labels_pos = cell(1, length(labels));

label_start_x = (screen.rect(3)/length(labels))/4;
label_end_x = label_start_x + labels_width; 
label_start_y = 1000;
label_end_y = 1100;


for j = 1:length(labels)
    %labels_pos_rect{j} = [labels_start_x + (j - 1) * (labels_width + labels_gap), -300, labels_start_x + j * labels_width + (j - 1) * labels_width, -300];
    labels_pos_txt{j} = [label_start_x + ((j - 1) * (labels_width + labels_gap)), label_start_y, label_end_x + ((j - 1) * (labels_width + labels_gap)), label_end_y];
    labels_pos_rect{j} = labels_pos_txt{j} + [(-labels_gap/4), -labels_height, (+labels_gap/4), -labels_height];
end    

%rectangle = [label_start_x, (label_start_y -labels_height), label_end_x, (label_end_y - labels_height)];


for j = 1:length(labels)
    
    Screen('FillRect',screen.main, screen.white, labels_pos_rect{j});
    Screen('FrameRect',screen.main, screen.txt_colour, labels_pos_rect{j}, 4);
    DrawFormattedText(screen.main, labels{j}, 'center', labels_pos_txt{j}(2)+10, screen.txt_colour, [], [], [], [], [], labels_pos_txt{j});
end    

% Screen('Flip', screen.main);
% WaitSecs(5)



next_label_start_x = screen.centerX - (labels_width/2);
next_label_end_x = next_label_start_x + labels_width; 
next_label_start_y = screen.centerY - labels_height;
next_label_end_y = screen.centerY + labels_height;

next_label_pos_txt{1} = [next_label_start_x, next_label_start_y, next_label_end_x, next_label_end_y];
next_label_pos_rect{1} = next_label_pos_txt{1} + [(-labels_gap/4), -labels_height, (+labels_gap/4), -labels_height];

Screen('FillRect',screen.main, screen.white, next_label_pos_rect{1});
Screen('FrameRect',screen.main, screen.txt_colour, next_label_pos_rect{1}, 4);
DrawFormattedText(screen.main, next_label{1}, 'center', next_label_pos_txt{1}(2)+10, screen.txt_colour, [], [], [], [], [], next_label_pos_txt{1});

% Screen('Flip', screen.main);
% WaitSecs(5)


stop_label_start_x = screen.rect(3) - labels_gap;
stop_label_end_x = stop_label_start_x + (labels_gap/2); 
stop_label_start_y = screen.rect(2) + (labels_height/2);
stop_label_end_y = screen.rect(2) + labels_height;

stop_label_pos_txt{1} = [stop_label_start_x, stop_label_start_y, stop_label_end_x, stop_label_end_y];
stop_label_pos_rect{1} = stop_label_pos_txt{1} + [(-labels_gap/4), (-labels_height/4), (+labels_gap/4), (+labels_height/4)];

Screen('FillRect',screen.main, screen.white, stop_label_pos_rect{1});
Screen('FrameRect',screen.main, screen.txt_colour, stop_label_pos_rect{1}, 4);
DrawFormattedText(screen.main, stop_label{1}, 'center', stop_label_pos_txt{1}(2)+((stop_label_end_y - stop_label_start_y)*0.75), screen.txt_colour, [], [], [], [], [], stop_label_pos_txt{1});

Screen('Flip', screen.main);
WaitSecs(5)

Screen('CloseAll')
