%% Configuration file 
% Task timings

function time = config_trialtimes(settings, screen_wksp)

experiment_settings = settings;
screen = screen_wksp;

%% Load inputs for experimental trial timings

%desired framerate - impacts most on soa timing inputs if wrong
time.des.Hz = experiment_settings.target_framerate;
time.des.framerate = 1/time.des.Hz;
time.poss.framerate = screen.frame_duration_mfitest; 
%mask timing
time.des.mask_secs = experiment_settings.mask_ms/1000; %mask time in s
time.des.mask_fr = round(time.des.mask_secs/time.des.framerate); %mask time in fr
%..
time.poss.mask_fr = round(time.des.mask_secs / screen.frame_duration_mfitest);
time.poss.mask_secs = time.poss.mask_fr * screen.frame_duration_mfitest;

%response timing
time.des.response_secs = experiment_settings.response_ms/1000; %response time in s
time.des.response_fr = round(time.des.response_secs/time.des.framerate); %response time in fr
%..
time.poss.response_fr = round(time.des.response_secs / screen.frame_duration_mfitest);
time.poss.response_secs = time.poss.response_fr * screen.frame_duration_mfitest;

%jitter timing
time.des.jitters_number = experiment_settings.jitter_number; %number of different jitters
time.des.jitters_min_secs = experiment_settings.jitter_min_ms/1000; %jitter min in s
time.des.jitters_max_secs = experiment_settings.jitter_max_ms/1000; %jitter max in s
%..
time.des.jitters_secs = linspace(time.des.jitters_min_secs,time.des.jitters_max_secs, time.des.jitters_number);
time.des.jitters_fr = round(time.des.jitters_secs / time.des.framerate); 
time.des.jitters_max_fr = round(time.des.jitters_max_secs/screen.frame_duration_mfitest);
time.des.jitters_min_fr = round(time.des.jitters_min_secs/screen.frame_duration_mfitest);
%..
time.poss.jitters_fr = round(time.des.jitters_secs / screen.frame_duration_mfitest);
time.poss.jitters_secs = time.poss.jitters_fr * screen.frame_duration_mfitest;

%soa timing
time.des.soa_number = length(experiment_settings.target_soa_choices);
time.des.soa_min_fr = experiment_settings.target_soa_values_fr(1);
time.des.soa_max_fr = experiment_settings.target_soa_values_fr(time.des.soa_number);
%..
time.des.soa_fr = experiment_settings.target_soa_values_fr;
time.des.soa_secs = time.des.soa_fr * time.des.framerate; 
%..
time.poss.soa_number = time.des.soa_number;
time.poss.soa_fr = round(time.des.soa_secs / screen.frame_duration_mfitest);
time.poss.soa_secs = time.poss.soa_fr * screen.frame_duration_mfitest;

%% Checking framerate input vs. actual
if screen.frame_duration_mfitest == time.des.framerate
    %framerate OK 
else 
    warning = ("screen framerate not correct, time values will have been modified, please check time.des and time.poss, ex:")
    time.des.soa_secs
    time.poss.soa_secs
end

%% Graph all the possible soas in the given range specified 
% soas in haz et al 2021 for reference 
% time.soa_haz_frames = [1, 2, 4, 6, 8, 10, 12, 18];
% time.soa_haz_secs = time.soa_haz_frames * screen.frame_duration; 

time.poss.soa_opts_fr = (1:time.poss.soa_fr(time.poss.soa_number));
time.poss.soa_opts_secs = time.poss.soa_opts_fr * screen.frame_duration_mfitest;

figure
scatter(time.poss.soa_opts_secs*1000, time.poss.soa_opts_fr)
hold on 
scatter(time.poss.soa_secs*1000, time.poss.soa_fr, 'b','filled','MarkerFaceAlpha', 0.8);

%% Saving values

time.jitters_frames = time.poss.jitters_fr;
time.jitters_secs = time.poss.jitters_secs;

time.mask_frames = time.poss.mask_fr;
time.mask_secs = time.poss.mask_secs;

time.response_frames = time.poss.response_fr;
time.response_secs = time.poss.response_secs;

time.soa_number = time.poss.soa_number;
time.soa_frames = time.poss.soa_fr;
time.soa_secs = time.poss.soa_secs;

end


