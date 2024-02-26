function [const]=constConfig(scr,const)
% ----------------------------------------------------------------------
% [const]=constConfig(scr,const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define all constant configurations
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Project : prfexp7t
% Version : 1.0
% ----------------------------------------------------------------------
 
% Fix randomization
rng(100);

%% Colors
const.white             =   [255,255,255];                                                      % white color
const.black             =   [0,0,0];                                                            % black color
const.gray              =   [128,128,128];                                                      % gray color
const.yellow            =   [200,200,0];                                                        % yellow color
const.background_color  =   const.black;                                                        % background color
const.stim_color        =   const.white;                                                        % stimulus color
const.ann_color         =   const.white;                                                        % define anulus around fixation color
const.ann_probe_color   =   const.white;                                                        % define anulus around fixation color when probe
const.dot_color         =   const.white;                                                        % define fixation dot color
const.dot_probe_color   =   const.black;                                                        % define fixation dot color when probe

%% Time parameters
const.TR_dur            =   1.6;                                                                % repetition time
const.TR_num            =   (floor(const.TR_dur/scr.frame_duration));                           % repetition time in screen frames
const.bar_dir_num       =   9;                                                                  % number of bar passes and break

const.bar_step_ver      =   24;                                                                 % bar steps for vertical bar pass
const.bar_step_hor      =   24;                                                                 % bar steps for horizontal bar pass 
const.blk_step          =   12;                                                                 % blank period step

const.noise_freq        =   10;                                                                 % compute noise frequency in hertz
const.patch_dur         =   1/const.noise_freq;                                                 % compute single patch duration in seconds
const.patch_num         =   (round(const.patch_dur/scr.frame_duration));                        % compute single patch duration in screen frames

const.bar_step_dur_ver  =   const.TR_dur;                                                       % bar step duration for vertical bar pass in seconds
const.bar_step_drawf_ver=   (round(const.bar_step_dur_ver/const.patch_dur));                    % bar step duration for vertical bar pass in screen frames drawn
const.bar_step_dur_hor  =   const.TR_dur;                                                       % bar step duration for horizontal bar pass in seconds
const.bar_step_drawf_hor=   (round(const.bar_step_dur_hor/const.patch_dur));                    % bar step duration for horizontal bar pass in screen frames drawn
const.blk_step_dur      =   const.TR_dur;                                                       % blank step duration in seconds
const.blk_step_drawf    =   (round(const.blk_step_dur/const.patch_dur));                        % blank step duration in screen frames drawn

const.frame_to_draw_ver =   const.bar_step_ver*const.bar_step_dur_ver*const.noise_freq;         % number of drawn frame per pass for vertical bar pass
const.frame_to_draw_hor =   const.bar_step_hor*const.bar_step_dur_hor*const.noise_freq;         % number of drawn frame per pass for horizontal bar pass
const.frame_to_draw_blk =   const.blk_step*const.TR_dur*const.noise_freq;                       % number of drawn frame per bar pass for blank

const.num_drawf_max_hor =   round(const.bar_step_hor*const.TR_dur/const.patch_dur);             % number of flip per pass in horizontal bar pass
const.num_drawf_max_ver =   round(const.bar_step_ver*const.TR_dur/const.patch_dur);             % number of flip per pass in vertical bar pass
const.num_drawf_max_blk =   round(const.blk_step*const.TR_dur/const.patch_dur);                 % number of flip per pass when blank bar pass

const.dur_max_hor       =   const.bar_step_hor*const.TR_dur;                                    % duration of pass in horizontal bar pass
const.dur_max_ver       =   const.bar_step_ver*const.TR_dur;                                    % duration of pass in vertical bar pass
const.dur_max_blk       =   const.blk_step*const.TR_dur;                                        % duration of pass when blank bar pass

const.probe_duration    =   const.patch_dur*6;                                                  % probe duration in seconds
const.probe_drawf       =   (round(const.probe_duration/const.patch_dur));                      % probe duration in screen frames drawn
const.bef_probe_drawf   =   (const.bar_step_drawf_ver - const.probe_drawf)/2;                   % time before probe per bar step in screen frames drawn

%% Stim parameters
% Noise patches
const.noise_num         =   5;                                                                  % number of generated patches per kappa
const.stim_size         =   [scr.scr_sizeY/2,scr.scr_sizeY/2];                                  % full screen stimuli size in pixels

const.stim_rect         =   [   scr.x_mid-const.stim_size(1);...                                % rect of the actual stimulus
                                scr.y_mid-const.stim_size(2);...
                                scr.x_mid+const.stim_size(1);...
                                scr.y_mid+const.stim_size(2)];

const.num_steps_kappa   =   15;                                                                 % number of kappa steps
const.noise_kappa       =   [0,10.^(linspace(-1,1.5,const.num_steps_kappa-1))];                 % von misses filter kappa parameter (1st = noise, last = less noisy)
const.good_4_harder     =   3;                                                                  % amount of trials before (harder) staircase update
const.bad_4_easier      =   1;                                                                  % amount of trials before (easier) staircase update
const.stim_stair_val    =   round(const.num_steps_kappa*0.60);                                  % starting value of the bar staircase kappa value
if const.mkVideo
    const.stim_stair_val     =   const.num_steps_kappa;                                         % starting value of the stimulus staircase kappa value
end
const.noise_size        =   sqrt((const.stim_size(1)*2)^2+(const.stim_size(1)*2)^2);            % size of the patch to allow 45deg rotation
const.noise_angle       =   [45,-45,NaN];                                                       % noise rotation angles
const.noise_pixelVal    =   0.1;                                                               % stimulus noise pixel size in degrees
const.noise_pixel       =   vaDeg2pix(const.noise_pixelVal,scr);                                % stimulus noise pixel size in pixels
const.native_noise_dim  =   round([const.noise_size/const.noise_pixel,...
                                   const.noise_size/const.noise_pixel]);                        % starting size of the patch
const.noise_color       =   'pink';                                                             % stimuli noise color ('white','pink','brownian');
const.apt_rad_val       =   6;                                                                  % aperture stimuli radius in dva
const.apt_rad           =   vaDeg2pix(const.apt_rad_val,scr);                                   % aperture stimuli radius in pixels

% compute random image order
const.rand_num_tex      =   [];
for t = 1:ceil((const.bar_step_hor*const.TR_dur*const.noise_freq)/const.noise_num)
    new_rand_num_tex        =   randperm(const.noise_num);
    if t > 1
        while new_rand_num_tex(1) == rand_num_tex(end)
            new_rand_num_tex    =   randperm(const.noise_num);
        end
    end
    rand_num_tex            =   new_rand_num_tex;
    const.rand_num_tex       =   [const.rand_num_tex,rand_num_tex];
end
const.rand_num_tex_ver  =   const.rand_num_tex(1:round(const.frame_to_draw_ver));
const.rand_num_tex_hor  =   const.rand_num_tex(1:round(const.frame_to_draw_hor));
const.rand_num_tex_blk  =   const.rand_num_tex(1:round(const.frame_to_draw_blk));

const.rect_noise        =  [scr.x_mid - const.noise_size/2;...                                  % noise native rect
                            scr.y_mid - const.noise_size/2;...
                            scr.x_mid + const.noise_size/2;...
                            scr.y_mid + const.noise_size/2];

% Apertures
const.rCosine_grain     =   80;                                                                 % grain of the radius cosine steps
const.aperture_blur     =   0.01;                                                               % ratio of the apperture that is blured following an raised cosine
const.raised_cos        =   cos(linspace(-pi,pi,const.rCosine_grain*2));
const.raised_cos        =   const.raised_cos(1:const.rCosine_grain)';                           % cut half to have raising cosinus function
const.raised_cos        =   (const.raised_cos - min(const.raised_cos))/...
                                    (max(const.raised_cos)-min(const.raised_cos));              % normalize raising cosinus function
                                

% Stimulus circular aperture
const.stim_aperture     =   compStimAperture(const);                                            % define stimulus aperture alpha layer

% Fixation circular aperture
const.fix_out_rim_radVal=   0.3;                                                                % radius of outer circle of fixation bull's eye
const.fix_rim_radVal    =   0.75*const.fix_out_rim_radVal;                                      % radius of intermediate circle of fixation bull's eye in degree
const.fix_radVal        =   0.25*const.fix_out_rim_radVal;                                      % radius of inner circle of fixation bull's eye in degrees
const.fix_out_rim_rad   =   vaDeg2pix(const.fix_out_rim_radVal,scr);                            % radius of outer circle of fixation bull's eye in pixels
const.fix_rim_rad       =   vaDeg2pix(const.fix_rim_radVal,scr);                                % radius of intermediate circle of fixation bull's eye in pixels
const.fix_rad           =   vaDeg2pix(const.fix_radVal,scr);                                    % radius of inner circle of fixation bull's eye in pixels
const.fix_aperture      =   compFixAperture(const);                                             % define fixation aperture
const.fix_annulus       =   compFixAnnulus(const);
const.fix_dot           =   compFixDot(const);
const.fix_dot_probe     =   const.fix_dot;

% Fixation lines
const.line_width = const.fix_rad;                                               % fixation line width
const.line_color = const.white;                                                 % fixation line color
const.line_fix_up_left = [0,...                                                 % up left part of fix cross x start
                          scr.scr_sizeX/2 - const.fix_out_rim_rad;....          % up left part of fix cross x end
                          -(scr.scr_sizeX-scr.scr_sizeY)/2,...                  % up left part of fix cross y start
                          scr.scr_sizeY/2 - const.fix_out_rim_rad];             % up left part of fix cross y end

const.line_fix_up_right = [scr.scr_sizeX/2 + const.fix_out_rim_rad,...          % up right part of fix cross x start
                           scr.scr_sizeX;....                                   % up right part of fix cross x end
                           scr.scr_sizeY/2 - const.fix_out_rim_rad,...          % up right part of fix cross y start
                           -(scr.scr_sizeX-scr.scr_sizeY)/2];                   % up right part of fix cross y end
                       
const.line_fix_down_left = [0,...                                               % down left part of fix cross x start
                            scr.scr_sizeX/2 - const.fix_out_rim_rad;....        % down left part of fix cross x end
                            scr.scr_sizeY+(scr.scr_sizeX-scr.scr_sizeY)/2,...   % down left part of fix cross y start
                            scr.scr_sizeY/2 + const.fix_out_rim_rad];           % down left part of fix cross y end

const.line_fix_down_right = [scr.scr_sizeX/2 + const.fix_out_rim_rad,...        % down right part of fix cross x start
                             scr.scr_sizeX;....                                 % down right part of fix cross x end
                             scr.scr_sizeY/2 + const.fix_out_rim_rad,...        % down right part of fix cross y start
                             scr.scr_sizeY+(scr.scr_sizeX-scr.scr_sizeY)/2];    % down right part of fix cross y end

% Bar
const.bar_dir_run       =   [9,1,9,3,9,5,9,7,9];                                                % direction (1 = 180 deg, 2 = 225 deg, 3 =  270 deg, 4 = 315 deg,
                                                                                                %            5 = 0 deg,   6 = 45 deg,  7 = 90 deg,   8 = 135 deg; 9 = none)

const.bar_width_deg     =   2;                                                                  % bar width in dva
const.bar_width         =   vaDeg2pix(const.bar_width_deg,scr);                                 % bar width in pixels

const.bar_mask_size     =   const.stim_size(1)*4;                                               % bar mask size in pixels
const.bar_aperture      =   compBarAperture(const);                                             % compute bar aperture mesh

const.bar_dir_ang_start =   0;                                                                  % first direction angle
const.bar_step_dir_ang  =   45;                                                                 % step between direction angles
const.bar_dir_ang       =   const.bar_dir_ang_start:const.bar_step_dir_ang:(360-const.bar_step_dir_ang+const.bar_dir_ang_start);

const.bar_aperture_rect =  [scr.x_mid - const.bar_mask_size/2,...                               % bar native rect
                            scr.y_mid - const.bar_mask_size/2,...
                            scr.x_mid + const.bar_mask_size/2,...
                            scr.y_mid + const.bar_mask_size/2];
const.bar_step_size_ver =   const.stim_size(2)*2/(const.bar_step_ver-1);                        % bar step size in pixels for vertical bar pass
const.bar_step_size_hor =   const.stim_size(1)*2/(const.bar_step_hor-1);                        % bar step size in pixels for horizontal bar pass

const.left_propixx_hide = [0,...                                                                % square  left side hider
                           0,...
                           (scr.scr_sizeX-scr.scr_sizeY)/2,...
                           scr.scr_sizeY];
const.right_propixx_hide = [(scr.scr_sizeX-scr.scr_sizeY)/2+scr.scr_sizeY,...                   % square screen right side hider
                            0,...
                            scr.scr_sizeX,...
                            scr.scr_sizeY];

% Define bar positions
% --------------------
  
% define horizontal bar pass
for tAng = 1:size(const.bar_dir_ang,2)
    for tSteps = 1:const.bar_step_hor
        
        const.barCtr_hor(1,tSteps,tAng) =  scr.x_mid + (cosd(const.bar_dir_ang(tAng)) * const.stim_size(1))...
                                                     - (cosd(const.bar_dir_ang(tAng)) * const.bar_step_size_hor*(tSteps-1));    % bar center coord x
        const.barCtr_hor(2,tSteps,tAng) =  scr.y_mid + (-sind(const.bar_dir_ang(tAng)) * const.stim_size(2))...
                                                     - (-sind(const.bar_dir_ang(tAng)) * const.bar_step_size_hor*(tSteps-1));   % bar center coord y
        
        const.bar_aperture_rect_hor(:,:,tSteps,tAng) =  CenterRectOnPoint(const.bar_aperture_rect,const.barCtr_hor(1,tSteps,tAng),const.barCtr_hor(2,tSteps,tAng));                 % bar rect
        const.bar_aperture_rect_hor(:,:,tSteps,tAng) =  const.bar_aperture_rect_hor(:,:,tSteps,tAng);% + [const.stim_offset(const.cond2,:),const.stim_offset(const.cond2,:)];
    end
end

% Define vertical bar pass
for tAng = 1:size(const.bar_dir_ang,2)
    for tSteps = 1:const.bar_step_ver
        
        const.barCtr_ver(1,tSteps,tAng) =  scr.x_mid + (cosd(const.bar_dir_ang(tAng)) * const.stim_size(1))...
                                                     - (cosd(const.bar_dir_ang(tAng)) * const.bar_step_size_ver*(tSteps-1));    % bar center coord x
        const.barCtr_ver(2,tSteps,tAng) =  scr.y_mid + (-sind(const.bar_dir_ang(tAng)) * const.stim_size(2))...
                                                     - (-sind(const.bar_dir_ang(tAng)) * const.bar_step_size_ver*(tSteps-1));   % bar center coord y
        
        const.bar_aperture_rect_ver(:,:,tSteps,tAng) =  CenterRectOnPoint(const.bar_aperture_rect,const.barCtr_ver(1,tSteps,tAng),const.barCtr_ver(2,tSteps,tAng));     % bar rect
        const.bar_aperture_rect_ver(:,:,tSteps,tAng) =  const.bar_aperture_rect_ver(:,:,tSteps,tAng);% + [const.stim_offset(const.cond2,:),const.stim_offset(const.cond2,:)];
        
   end
end


% Define all drawing frames
% -------------------------
% define horizontal bar pass
for tAng = 1:size( const.bar_dir_run,2)
    for drawf = 1:const.num_drawf_max_hor
        
        % define bar position step number
        const.bar_steps_hor(drawf,tAng)    =   ceil(drawf/const.bar_step_drawf_hor);
        
        % define trial start & end drawing frames
        if drawf == (const.bar_steps_hor(drawf,tAng))*const.bar_step_drawf_hor
            const.trial_start_hor(drawf,tAng)  =   1;
            const.trial_end_hor(drawf,tAng)   =   1;
        else
            const.trial_start_hor(drawf,tAng)  =   0;
            const.trial_end_hor(drawf,tAng)   =   0;
        end
        
        % define time probe drawing frames
        if drawf >= (const.bar_steps_hor(drawf,tAng)-1)*const.bar_step_drawf_hor + const.bef_probe_drawf + 1 &&  ...
                drawf <= (const.bar_steps_hor(drawf,tAng)-1)*const.bar_step_drawf_hor + const.bef_probe_drawf + const.probe_drawf...
                && const.bar_dir_run(tAng)~=9
            const.time2probe_hor(drawf,tAng)  =   1;
        else
            const.time2probe_hor(drawf,tAng)  =   0;
        end
        
        % define probe onset drawing frames
        if drawf == (const.bar_steps_hor(drawf,tAng)-1)*const.bar_step_drawf_hor + const.bef_probe_drawf + 1 ...
            && const.bar_dir_run(tAng)~=9
            const.probe_onset_hor(drawf,tAng)  =   1;
        else
            const.probe_onset_hor(drawf,tAng)  =   0;
        end

        % define response drawing frames
        if drawf >= (const.bar_steps_hor(drawf,tAng)-1)*const.bar_step_drawf_hor + const.bef_probe_drawf + 1 &&  ...
                drawf <= (const.bar_steps_hor(drawf,tAng)-1)*const.bar_step_drawf_hor + const.bar_step_drawf_hor ...
                && const.bar_dir_run(tAng)~=9
            const.time2resp_hor(drawf,tAng)  =   1;
        else
            const.time2resp_hor(drawf,tAng)  =   0;
        end
        
        % define response reset drawing frames
        if drawf == (const.bar_steps_hor(drawf,tAng)-1)*const.bar_step_drawf_hor + 1 ...
                && const.bar_dir_run(tAng)~=9
            const.resp_reset_hor(drawf,tAng)  =   1;
        else
            const.resp_reset_hor(drawf,tAng)  =   0;
        end
    end
end

% define vertical bar pass
for tAng = 1:size( const.bar_dir_run,2)
    for drawf = 1:const.num_drawf_max_ver
                      
        % define bar position step number
        const.bar_steps_ver(drawf,tAng)    =   ceil(drawf/const.bar_step_drawf_ver);
        
        % define trial start & end drawing frames
        if drawf == (const.bar_steps_ver(drawf,tAng))*const.bar_step_drawf_ver
            const.trial_start_ver(drawf,tAng)  =   1;
            const.trial_end_ver(drawf,tAng)   =   1;
        else
            const.trial_start_ver(drawf,tAng)  =   0;
            const.trial_end_ver(drawf,tAng)   =   0;
        end
                         
        % define time probe drawing frames
        if drawf >= (const.bar_steps_ver(drawf,tAng)-1)*const.bar_step_drawf_ver + const.bef_probe_drawf + 1 &&  ...
                drawf <= (const.bar_steps_ver(drawf,tAng)-1)*const.bar_step_drawf_ver + const.bef_probe_drawf + const.probe_drawf ...
                && const.bar_dir_run(tAng)~=9
            const.time2probe_ver(drawf,tAng)  =   1;
        else
            const.time2probe_ver(drawf,tAng)  =   0;
        end
        
        % define probe onset drawing frames
        if drawf == (const.bar_steps_ver(drawf,tAng)-1)*const.bar_step_drawf_ver + const.bef_probe_drawf + 1 ...
            && const.bar_dir_run(tAng)~=9
            const.probe_onset_ver(drawf,tAng)  =   1;
        else
            const.probe_onset_ver(drawf,tAng)  =   0;
        end

        % define response drawing frames
        if drawf >= (const.bar_steps_ver(drawf,tAng)-1)*const.bar_step_drawf_ver + const.bef_probe_drawf + 1 &&  ...
                drawf <= (const.bar_steps_ver(drawf,tAng)-1)*const.bar_step_drawf_ver + const.bef_probe_drawf*2 + const.probe_drawf ...
                && const.bar_dir_run(tAng)~=9
            const.time2resp_ver(drawf,tAng)  =   1;
        else
            const.time2resp_ver(drawf,tAng)  =   0;
        end
        
        % define response reset drawing frames
        if drawf == (const.bar_steps_ver(drawf,tAng)-1)*const.bar_step_drawf_ver + 1 && const.bar_dir_run(tAng)~=9
            const.resp_reset_ver(drawf,tAng)  =   1;
        else
            const.resp_reset_ver(drawf,tAng)  =   0;
        end
    end
end

% define TR for scanner
if const.scanner
    const.TRs = 0;
    for bar_pass = 1:const.bar_dir_num        
        if  const.bar_dir_run(bar_pass) == 9
            TR_bar_pass             =   const.blk_step;
        else
            if  const.bar_dir_run(bar_pass) == 1 ||  const.bar_dir_run(bar_pass) == 5
                TR_bar_pass     =   const.bar_step_hor;
            elseif  const.bar_dir_run(bar_pass) == 3 || const.bar_dir_run(bar_pass) == 7
                TR_bar_pass     =   const.bar_step_ver;
            end
        end
        const.TRs               =   const.TRs + TR_bar_pass;
    end
    const.TRs = const.TRs;
    fprintf(1,'\n\tScanner parameters; %1.0f TRs, %1.2f seconds, %s\n',const.TRs,const.TR_dur,datestr(seconds((const.TRs*const.TR_dur)),'MM:SS'));
end

const.ppd               =   vaDeg2pix(1,scr);                                                  % get one pixel per degree

end