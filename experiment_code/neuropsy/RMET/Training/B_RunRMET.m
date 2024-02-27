%% EKMANN Faces Task - Run Experiment
% Presentation of all 36 Eye

% Trials run as follows: 
% Emotion image presentation without labels (5s)
% Image remains and labels pop up, participant clicks on choice (max 12s)
% Next screen then appears, participant clicks on next (max 7s) 
% (or instead of clicking next, the x button can be used to cancel the run)

% Coded by: Penelope Tilsley, tilsley.penelope@gmail.com
% Last updated: 10.01.2024

%% Setting up data

time = datestr(now,'HH:MM');
time(3) = 'h';

setup.data_mat_name = ['sub-' setup.subject_type '' int2str(setup.subject_no) '_acq-test_task-ekmann_' date '_' time '.mat']; 
setup.data_csv_name = ['sub-' setup.subject_type '' int2str(setup.subject_no) '_acq-test_task-ekmann_data_' date '_' time '.csv'];
setup.results_csv_name = ['sub-' setup.subject_type '' int2str(setup.subject_no) '_acq-test_task-ekmann_results_' date '_' time '.csv'];

data.subject_number(1:length(image_names),1) = repelem(setup.subject_no, length(1:length(image_names))); 
data.subject_type(1:length(image_names),1) = repelem(cellstr(setup.subject_type), length(1:length(image_names))); 
data.subject_date(1:length(image_names),1) = repelem(cellstr(date), length(1:length(image_names)));
data.subject_time(1:length(image_names),1) = repelem(cellstr(time), length(1:length(image_names)));
data.subject_lang(1:length(image_names),1) = repelem(setup.subject_lang, length(1:length(image_names)));

if setup.subject_lang == 0
    data.subject_lang_id(1:length(image_names),1) = repelem(cellstr('french'), length(1:length(image_names)));
else
    data.subject_lang_id(1:length(image_names),1) = repelem(cellstr('english'), length(1:length(image_names)));
end

data.trial = (1:length(image_names))';
data.image_name = imagelist_eng(2:end,1);
data.image_emotion = imagelist(2:end,2);
data.image_emotion_eng = imagelist_eng(2:end,2);
data.image_emotion_fr = imagelist_fr(2:end,2);
data.image_label_1 = imagelist(2:end,3);
data.image_label_1_eng = imagelist_eng(2:end,3);
data.image_label_1_fr = imagelist_fr(2:end,3);
data.image_label_2 = imagelist(2:end,4);
data.image_label_2_eng = imagelist_eng(2:end,4);
data.image_label_2_fr = imagelist_fr(2:end,4);
data.image_label_3 = imagelist(2:end,5);
data.image_label_3_eng = imagelist_eng(2:end,5);
data.image_label_3_fr = imagelist_fr(2:end,5);
data.image_label_4 = imagelist(2:end,6);
data.image_label_4_eng = imagelist_eng(2:end,6);
data.image_label_4_fr = imagelist_fr(2:end,6);

data.onset_trial = NaN(length(image_names), 1);
data.onset_response = NaN(length(image_names), 1);
data.onset_pause = NaN(length(image_names), 1);
data.offset_trial = NaN(length(image_names), 1);
data.reaction_time = NaN(length(image_names), 1);
data.label_clicked = NaN(length(image_names), 1);
data.label_clicked_name = cell(length(image_names), 1);

data.correct_check = cell(length(image_names), 1);
data.correct_check_no = NaN(length(image_names), 1);
data.correct_letter_check = cell(length(image_names), 1);

data.response_check = cell(length(image_names), 1); 
data.response_check_no = NaN(length(image_names), 1);
data.response_letter_check = cell(length(image_names), 1);

data.response_correct = NaN(length(image_names), 1);
data.response_correct_id = cell(length(image_names), 1);

%% Running Task

[screen.main, screenrect] = Screen(screen.number,'OpenWindow',screen.white,[]); %coords for test mode
[~] = Screen('BlendFunction', screen.main, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
HideCursor;

% Load and display images with labels
for t = 1:length(image_names)
  
    target_texture = Screen('MakeTexture',screen.main,target_image{t}); 
    labels = string(imagelist((t+1),3:6));
    labels_log(t,:) = labels;
    
    image_tic = 0;
    data.onset_trial(t) = GetSecs;
    
    while image_tic < 5
        Screen('DrawTexture',screen.main, target_texture, [],...
                [screen.centerX - (stim.image_size_X/2)...
                screen.centerY - (stim.image_size_Y/2)...
                screen.centerX + (stim.image_size_X/2)...
                screen.centerY + (stim.image_size_Y/2)]);
            
        image_flip = Screen('Flip',screen.main); 
        image_tic = image_flip-data.onset_trial(t);
    end
    
    Screen('DrawTexture',screen.main, target_texture, [],...
        [screen.centerX - (stim.image_size_X/2)...
        screen.centerY - (stim.image_size_Y/2)...
        screen.centerX + (stim.image_size_X/2)...
        screen.centerY + (stim.image_size_Y/2)]);
        
    for j = 1:length(labels)
        Screen('FillRect',screen.main, screen.white, labels_pos_rect{j});
        Screen('FrameRect',screen.main, screen.txt_colour, labels_pos_rect{j}, 4);
        DrawFormattedText(screen.main, labels{j}, 'center', labels_pos_txt{j}(2)+10, screen.txt_colour, [], [], [], [], [], labels_pos_txt{j});
    end  
    
    image_label_flip = Screen('Flip',screen.main); 
    image_label_tic = image_label_flip;
    
    data.onset_response(t) = image_label_tic;
    
    SetMouse(screen.centerX, screen.centerY, screen.main);
    ShowCursor('Hand');
        
    while true
        [x, y, buttons] = GetMouse(screen.main);
        label_click = 0;

        for j = 1:length(labels)
            if IsInRect(x, y, labels_pos_rect{j})
                label_click = j;
                break;
            end
        end
        
        if any(buttons)
            if label_click > 0
                data.reaction_time(t) = GetSecs() - image_label_tic;
                data.label_clicked(t) = label_click; 
                data.label_clicked_name{t} = labels(data.label_clicked(t));
                break;
            else
            end
        elseif (GetSecs() - image_label_tic) > 12
            data.label_clicked_name{t} = NaN;
            break;
        end
    end
    
    data.onset_pause(t) = GetSecs();
    HideCursor;
    
    Screen('FillRect',screen.main, screen.white, next_label_pos_rect{1});
    Screen('FrameRect',screen.main, screen.txt_colour, next_label_pos_rect{1}, 4);
    DrawFormattedText(screen.main, next_label{1}, 'center', next_label_pos_txt{1}(2)+10, screen.txt_colour, [], [], [], [], [], next_label_pos_txt{1});
    Screen('FillRect',screen.main, screen.white, stop_label_pos_rect{1});
    Screen('FrameRect',screen.main, screen.txt_colour, stop_label_pos_rect{1}, 4);
    DrawFormattedText(screen.main, stop_label{1}, 'center', stop_label_pos_txt{1}(2)+((stop_label_end_y - stop_label_start_y)*0.75), screen.txt_colour, [], [], [], [], [], stop_label_pos_txt{1});

Screen('Flip', screen.main);
          
    ShowCursor('Hand');
        
    while true
        [x, y, button_next] = GetMouse(screen.main);
        next_click = 0;

        if IsInRect(x, y, next_label_pos_rect{1})
            if any(button_next)
                next_click = 1;
                break;
            elseif (GetSecs() - data.onset_pause(t)) > 7
                break;
            end
        elseif IsInRect(x, y, stop_label_pos_rect{1})
            
            if any(button_next)
                stop_click = 1;
                data.offset_trial(t) = GetSecs();
                
                % Saving aborted data anyway
                
                disp('Experiment aborted early, still saving raw data...');
                clear target_image mask_image
                
                if setup.subject_lang == 0
                    data.subject_lang_id(1:length(image_names),1) = repelem(cellstr('french'), length(1:length(image_names)));
                else
                    data.subject_lang_id(1:length(image_names),1) = repelem(cellstr('english'), length(1:length(image_names)));
                end
                
                % Checking if response correct
                for k = 1:t
                    data.response_check{k,1} = lower(char(data.label_clicked_name{k,1}));
                    data.response_letter_check{k,1} = data.response_check{k,1}(1:3);
                    data.response_check_no(k,1) = data.label_clicked(k,1);
                    
                    if setup.subject_lang == 0
                        data.correct_check{k,1} = lower(char(data.image_emotion_fr{k,1}));
                        data.correct_letter_check{k,1} = lower(char(data.image_emotion_fr{k,1}(1:3)));
                    else
                        data.correct_check{k,1} = lower(char(data.image_emotion_eng{k,1}));
                        data.correct_letter_check{k,1} = lower(char(data.image_emotion_eng{k,1}(1:3)));
                    end

                    if data.correct_letter_check{k,1} == data.response_letter_check{k,1}
                        data.response_correct(k,1) = 1;
                        data.response_correct_id{k,1} = 'yes';
                    else
                        data.response_correct(k,1) = 0;
                        data.response_correct_id{k,1} = 'no';
                    end
                    
                    for j = 1:length(labels)
                        if ismember(data.correct_check(k),labels_log(j))
                            data.correct_check_no(k,1) = j;
                        end
                    end
                    
                end
                
                % Transform into tables
                experiment_data = struct2table(data);

                % Save data and design
                setup.data_mat_name = [setup.data_mat_name(1:end-4), '_aborted.mat'];
                save(fullfile('data',setup.data_mat_name)); 
                setup.data_csv_name = [setup.data_csv_name(1:end-4), '_aborted.csv'];
                
                writetable(experiment_data,fullfile('data',setup.data_csv_name)); 
                
                disp('Raw data:');
                disp(setup.data_csv_name);

                Screen('CloseAll');
                return;
            end
        elseif (GetSecs() - data.onset_pause(t)) > 7
            break;
        end
    end
    
    data.offset_trial(t) = GetSecs(); 
    
    HideCursor;
    Screen('FillRect',screen.main, screen.white);
    Screen('Flip', screen.main);
    WaitSecs(0.5);
    
end

Screen('CloseAll');


%% Save data

disp('Experiment finished, saving data...');

% Saving all data - 
% + Checking if response correct
for k = 1:length(image_names)
                    
    data.response_check{k,1} = lower(char(data.label_clicked_name{k,1}));
    data.response_letter_check{k,1} = data.response_check{k,1}(1:3);
    data.response_check_no(k,1) = data.label_clicked(k,1);
    
    if setup.subject_lang == 0
        data.correct_check{k,1} = lower(char(data.image_emotion_fr{k,1}));
        data.correct_letter_check{k,1} = lower(char(data.image_emotion_fr{k,1}(1:3)));
    else
        data.correct_check{k,1} = lower(char(data.image_emotion_eng{k,1}));
        data.correct_letter_check{k,1} = lower(char(data.image_emotion_eng{k,1}(1:3)));
    end

    if data.correct_letter_check{k,1} == data.response_letter_check{k,1}
        data.response_correct(k,1) = 1;
        data.response_correct_id{k,1} = 'yes';
    else
        data.response_correct(k,1) = 0;
        data.response_correct_id{k,1} = 'no';
    end
    
    for j = 1:length(labels)
    if ismember(data.correct_check(k),labels_log(j))
        data.correct_check_no(k,1) = j;
    end
    end
    
end

% Creating score sheet - 
% + Calculating subcategory results

list = fieldnames(data);
for l = 1:6
    fname = string(list(l));
    score.(fname) = data.(fname)(1);
end

score.total_score_no = sum(data.response_correct,'omitnan');
score.total_score_percent = round(mean(data.response_correct,'omitnan')*100,1);
score.total_reactiontime = mean(data.reaction_time,'omitnan'); 
score.total_time_mins = round((data.offset_trial(t) - data.onset_trial(1))/60,2);
score.total_time_secs = round(data.offset_trial(t) - data.onset_trial(1),1);

secs = seconds(score.total_time_secs);
secs.Format = "mm:ss";
total_time_mins_format = string(secs);


% Transform into table
experiment_data = struct2table(data);
experiment_results = struct2table(score);

% Save data and results
writetable(experiment_data,fullfile('data',setup.data_csv_name)); 
writetable(experiment_results,fullfile('data',setup.results_csv_name)); 

disp('Raw data:');
disp(setup.data_csv_name);
disp('Results sheet:');
disp(setup.data_csv_name);
disp(['Total correct percentage: ' num2str(score.total_score_percent) '%']);
disp(['Average reaction time: ' num2str(round(score.total_reactiontime,2)) ' secs']);
disp(['Completion time: ' num2str(total_time_mins_format) ' mins/secs']);

%Save matlab workspace
clear target_image mask_image
clearvars -except data experiment* image_names imagelist label* score screen setup stim 
save(fullfile('data',setup.data_mat_name)); 


