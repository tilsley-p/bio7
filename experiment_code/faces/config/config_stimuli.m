%% Configuration file 
% Image stimuli 

function stim = config_stimuli(settings)

experiment_settings = settings

%% Finding stimuli location 

if isfolder('stimuli') == 1
    s = what('stimuli');stim.path = s.path;clear s
else
    error_path = sprintf('check execution folder / presence of stimuli folder')
end

%% Inputting FACES database structure / design elements   
%Defining the categories in the database and corresponding naming codes
%emotion
stim.catelog.emotions = {'sad' 'fear' 'happy' 'angry', 'disgust', 'neutral'};
stim.catelog.emotions_id = {'s' 'f' 'h' 'a', 'd', 'n'};
stim.catelog.emotions_tot = length(stim.catelog.emotions); 
%sex
stim.catelog.sexs = {'male' 'female'};
stim.catelog.sexs_id = {'m' 'f'};
stim.catelog.sexs_tot = length(stim.catelog.sexs); 
%age
stim.catelog.ages = {'old' 'middle' 'young'};
stim.catelog.ages_id = {'o' 'm' 'y'};
stim.catelog.ages_tot = length(stim.catelog.ages);
%list
stim.list = '_a.jpg';
stim.listb = '_b.jpg';

%% Setting desired image shortlist for particular experiment 

%emotion
stim.emotions_contrast = experiment_settings.target_emotion_choices';
stim.emotions_contrast_no = length(stim.emotions_contrast);
match_emotion = 0;
for idx = 1:stim.emotions_contrast_no
    search_emotion = string(char(stim.emotions_contrast(idx)));
    idx_match = find(stim.catelog.emotions(:) == search_emotion);
    match_emotion = match_emotion + 1; 
    stim.emotions_contrast_id(match_emotion) = stim.catelog.emotions_id(idx_match);
end
clear idx idx_match search_emotion match_emotion match_count

%mask
stim.emotions_mask = experiment_settings.mask_emotion_choice';
stim.emotions_mask_no = length(stim.emotions_mask);
match_emotion = 0;

%emotion plus mask 
stim.emotions = stim.emotions_contrast;
stim.emotions(length(stim.emotions)+1) = stim.emotions_mask;
stim.emotions_no = length(stim.emotions);

for idx = 1:stim.emotions_no
    search_emotion = string(char(stim.emotions(idx)));
    if search_emotion == "neutral"
        id = ('n');
        match_emotion = match_emotion + 1;
        stim.emotions_id(match_emotion) = cellstr(id);
        stim.emotions_mask_id = cellstr(id);
    else
        idx_match = find(stim.catelog.emotions(:) == search_emotion);
        match_emotion = match_emotion + 1; 
        stim.emotions_id(match_emotion) = stim.catelog.emotions_id(idx_match);
    end
end
clear idx idx_match search_emotion match_emotion match_count

%sex
stim.sexs = experiment_settings.target_sex_choices';
stim.sexs_no = length(stim.sexs);
match_sex = 0;
for idx = 1:stim.sexs_no
    search_sex = string(char(stim.sexs(idx)));
    idx_match = find(stim.catelog.sexs(:) == search_sex);
    match_sex = match_sex + 1; 
    stim.sexs_id(match_sex) = stim.catelog.sexs_id(idx_match);
end
clear idx idx_match search_sex match_sex match_count    

%age
stim.ages = experiment_settings.target_age_choices';
stim.ages_no = length(stim.ages);
match_age = 0;
for idx = 1:stim.ages_no
    search_age = string(char(stim.ages(idx)));
    idx_match = find(stim.catelog.ages(:) == search_age);
    match_age = match_age + 1; 
    stim.ages_id(match_age) = stim.catelog.ages_id(idx_match);
end
clear idx idx_match search_age match_age match_count

%age
stim.locations = experiment_settings.target_location_choices';
stim.locations_no = length(stim.locations);
match_locations = 0;
for idx = 1:stim.locations_no
    search_locations = char(stim.locations(idx));
    search_locations_1 = string(search_locations(1));
    match_locations = match_locations + 1; 
    stim.locations_id(match_locations) = cellstr(search_locations_1);
end
clear idx idx_match search_locations match_locations match_count


%% Creating categorised complete image directory

disp('Loading desired shortlist of images for experiment...')

%loading all emotion images by group age/sex

[emo,sex,age] = ndgrid(1:stim.emotions_no,1:stim.sexs_no,1:stim.ages_no);
stim.combi_id = strcat(stim.ages_id(age(:)),'_',stim.sexs_id(sex(:)),'_',stim.emotions_id(emo(:)));

stim.combi = strcat(stim.ages(age(:)),'_',stim.sexs(sex(:)),'_',stim.emotions(emo(:)));

clear emo sex age

for i = 1:length(stim.combi_id)
    
    temp_filename = strcat(stim.combi_id{i}, stim.list);
    
stim.images.(stim.combi_id{i}) = dir(fullfile(stim.path,['*' temp_filename '']));
stim.images.(stim.combi_id{i}) = stim.images.(stim.combi_id{i})(~startsWith({stim.images.(stim.combi_id{i}).name}, '.'));

clear temp_filename

end

clear i

%loading all emotion images by group age/sex for images contrasted, control
%neutral condition not present

[emo,sex,age] = ndgrid(1:stim.emotions_contrast_no,1:stim.sexs_no,1:stim.ages_no);
stim.combi_contrast_id = strcat(stim.ages_id(age(:)),'_',stim.sexs_id(sex(:)),'_',stim.emotions_contrast_id(emo(:)));

stim.combi_contrast = strcat(stim.ages(age(:)),'_',stim.sexs(sex(:)),'_',stim.emotions_contrast(emo(:)));

clear emo sex age

[emo,sex,age] = ndgrid(max(stim.emotions_no),1:stim.sexs_no,1:stim.ages_no);
stim.combi_control_id = strcat(stim.ages_id(age(:)),'_',stim.sexs_id(sex(:)),'_',stim.emotions_id(emo(:)));

stim.combi_control = strcat(stim.ages(age(:)),'_',stim.sexs(sex(:)),'_',stim.emotions(emo(:)));

stim.combi_control_id = repelem(stim.combi_control_id,stim.emotions_contrast_no);
stim.combi_control = repelem(stim.combi_control,stim.emotions_contrast_no);

clear emo sex age
%loading the last control neutral condition 

% loading an additional b list neutral condition for the resting task 

for i = 1:length(stim.combi_id)
    
    temp_filename = strcat(stim.combi_id{i}, stim.listb);
    
stim.images_blist.(stim.combi_id{i}) = dir(fullfile(stim.path,['*' temp_filename '']));
stim.images_blist.(stim.combi_id{i}) = stim.images_blist.(stim.combi_id{i})(~startsWith({stim.images_blist.(stim.combi_id{i}).name}, '.'));

clear temp_filename

end

clear i

fn = fieldnames(stim.images);

 % Finding minimum number of images across all set used 
 for i = 1:length(fieldnames(stim.images))
     
 minimages(i) = length(stim.images.(fn{i}));
 
 end
 
 stim.images_maxpemocat = min(minimages);
 
 clear fn
 clear i
 clear minimages
 
end
