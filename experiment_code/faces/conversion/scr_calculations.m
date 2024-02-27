function scr = scr_calculations(settings, stimuli_wksp)

stim = stimuli_wksp; 
experiment_settings = settings;

if exist('subject_MRI', 'var')
    %continue 
else
    subject_MRI = input('MRI (1) or test (0): ');
end


if subject_MRI == 1

    %% 7T Room    

    scr.disp_sizeX = 698.4;
    scr.disp_sizeY = 392.9;

    scr.scr_sizeX = 1920;
    scr.scr_sizeY = 1080;
    
    scr.dist = 154 + 30; %cm, 154cm to end of tunnel from mirror, plus 25cm from end of bore
    
    sample_image = imread(stim.images.m_m_f(1).name);
    image_size_original = size(sample_image); 

    image_size_original_x = image_size_original(2);
    image_size_original_y = image_size_original(1);

    image_ratio_yx = image_size_original_y/image_size_original_x;

    scr.desired_va_x = experiment_settings.display_image_size_va;
    scr.desired_va_y = scr.desired_va_x * image_ratio_yx;

    scr.desired_cm_x = vaDeg2cm(scr.desired_va_x,scr);
    scr.desired_cm_y = vaDeg2cm(scr.desired_va_y,scr);

    scr.desired_pix_x = vaDeg2pix(scr.desired_va_x,scr);
    scr.desired_pix_y = vaDeg2pix(scr.desired_va_y,scr);

    scr.scaling_factor = scr.desired_pix_x/image_size_original_x; 
    scr.scaling_factor_ycheck = scr.desired_pix_y/image_size_original_y;


else
    
    %% Manip Laptop
    
    scr.scr_sizeX = 1920;
    scr.scr_sizeY = 1080;

    scr.disp_sizeX = 382;
    scr.disp_sizeY = 215;

    scr.dist = 60; 
   
    sample_image = imread(stim.images.m_m_f(1).name);
    image_size_original = size(sample_image); 

    image_size_original_x = image_size_original(2);
    image_size_original_y = image_size_original(1);

    image_ratio_yx = image_size_original_y/image_size_original_x;

    scr.desired_va_x = experiment_settings.display_image_size_va;
    scr.desired_va_y = scr.desired_va_x * image_ratio_yx;

    scr.desired_cm_x = vaDeg2cm(scr.desired_va_x,scr);
    scr.desired_cm_y = vaDeg2cm(scr.desired_va_y,scr);

    scr.desired_pix_x = vaDeg2pix(scr.desired_va_x,scr);
    scr.desired_pix_y = vaDeg2pix(scr.desired_va_y,scr);

    scr.scaling_factor = scr.desired_pix_x/image_size_original_x; 
    scr.scaling_factor_ycheck = scr.desired_pix_y/image_size_original_y;
    
end

% stim.ScalingFactor = scr.scaling_factor;
% stim.OffsetX = scr.desired_pix_x;
% stim.va_x = scr.desired_va_x;
% stim.va_y = scr.desired_va_y;

end