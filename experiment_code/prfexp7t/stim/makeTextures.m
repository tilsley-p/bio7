function makeTextures(scr,const,expDes)
% ----------------------------------------------------------------------
% makeTextures(scr,const,expDes)
% ----------------------------------------------------------------------
% Goal of the function :
% Make textures for later drawing them
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% expDes : struct containg experimental design
% ----------------------------------------------------------------------
% Output(s):
% none - images saved
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Project : prfexp7t
% Version : 1.0
% ----------------------------------------------------------------------
fprintf(1,'\n\tDrawing all texture screens\n\t');

% delete old folder
if isfolder(const.stim_folder)
    rmdir(const.stim_folder,'s')
end
if ~isfolder(const.stim_folder)
    mkdir(const.stim_folder)
end

% waiting draw image
[imageToDraw,~,alpha]   =   imread('instructions/image/WaintingTex.png');
imageToDraw(:,:,4)      =   alpha;
t_handle                =   Screen('MakeTexture',scr.main,imageToDraw);
texrect                 =   Screen('Rect', t_handle);
Screen('FillRect',scr.main,const.background_color);
Screen('DrawTexture',scr.main,t_handle,texrect,[0,0,scr.scr_sizeX,scr.scr_sizeY]);
Screen('Flip',scr.main);
Screen('Close',t_handle);

% Make black noise
black_fix_noise(:,:,1)  =   zeros(round(const.noise_size),round(const.noise_size),1)+const.background_color(1);
black_fix_noise(:,:,2)  =   zeros(round(const.noise_size),round(const.noise_size),1)+const.background_color(2);
black_fix_noise(:,:,3)  =   zeros(round(const.noise_size),round(const.noise_size),1)+const.background_color(3);
black_fix_noise(:,:,4)  =   const.fix_aperture;
tex_black_fix_noise     =   Screen('MakeTexture',scr.main,black_fix_noise);

% Make bar aperture
tex_bar_aperture        =   Screen('MakeTexture',scr.main,const.bar_aperture);

% Make annulus
fix_ann                 =   ones(round(const.noise_size),round(const.noise_size),4);
fix_ann_no_probe(:,:,1) =   fix_ann(:,:,1)*const.ann_color(1);
fix_ann_no_probe(:,:,2) =   fix_ann(:,:,2)*const.ann_color(2);
fix_ann_no_probe(:,:,3) =   fix_ann(:,:,3)*const.ann_color(3);
fix_ann_no_probe(:,:,4) =   const.fix_annulus;
tex_fix_ann_no_probe    =   Screen('MakeTexture',scr.main,fix_ann_no_probe);

% Make annulus when probe
fix_ann_probe(:,:,1)    =   fix_ann(:,:,1)*const.ann_probe_color(1);
fix_ann_probe(:,:,2)    =   fix_ann(:,:,2)*const.ann_probe_color(2);
fix_ann_probe(:,:,3)    =   fix_ann(:,:,3)*const.ann_probe_color(3);
fix_ann_probe(:,:,4)    =   const.fix_annulus;
tex_fix_ann_probe       =   Screen('MakeTexture',scr.main,fix_ann_probe);

% Make fixation dot
fix_dot                 =   ones(round(const.noise_size),round(const.noise_size),4);
fix_dot_no_probe(:,:,1) =   fix_dot(:,:,1)*const.dot_color(1);
fix_dot_no_probe(:,:,2) =   fix_dot(:,:,2)*const.dot_color(2);
fix_dot_no_probe(:,:,3) =   fix_dot(:,:,3)*const.dot_color(3);
fix_dot_no_probe(:,:,4) =   const.fix_dot;
tex_fix_dot_no_probe    =   Screen('MakeTexture',scr.main,fix_dot_no_probe);

% Make fixation dot when probe
fix_dot_probe(:,:,1)    =   fix_dot(:,:,1)*const.dot_probe_color(1);
fix_dot_probe(:,:,2)    =   fix_dot(:,:,2)*const.dot_probe_color(2);
fix_dot_probe(:,:,3)    =   fix_dot(:,:,3)*const.dot_probe_color(3);
fix_dot_probe(:,:,4)    =   const.fix_dot_probe;
tex_fix_dot_probe       =   Screen('MakeTexture',scr.main,fix_dot_probe);

% Make noise and combine all
bar_step_num_hor        =   const.bar_step_hor;
bar_step_num_ver        =   const.bar_step_ver;

kappa_val_num           =   const.num_steps_kappa;
noise_rand_num          =   const.noise_num;
stim_ori_num            =   size(expDes.oneR,1);

numPrint                =   0;
rect_noise              =   const.rect_noise;

% compute total amount of picture to print
total_amount            =   ((kappa_val_num-1) * noise_rand_num * stim_ori_num * bar_step_num_hor) + ...
                            ((kappa_val_num-1) * noise_rand_num * stim_ori_num * bar_step_num_ver) + ...
                            noise_rand_num * bar_step_num_hor + ...
                            noise_rand_num * bar_step_num_ver + ...
                            1;

textprogressbar('Progress: ');

for kappa_val_stim = 2:kappa_val_num
    for noise_rand = 1:noise_rand_num
        
        % make stim texture full screen
        mat_noise               =   genNoisePatch(const,const.noise_kappa(kappa_val_stim));
        mat_noise_resize        =   imresize(mat_noise,round([const.noise_size,const.noise_size]),'bilinear');
        noise_patch(:,:,1)      =   mat_noise_resize*const.stim_color(1);
        noise_patch(:,:,2)      =   mat_noise_resize*const.stim_color(2);
        noise_patch(:,:,3)      =   mat_noise_resize*const.stim_color(3);
        noise_patch(:,:,4)      =   const.stim_aperture;
        bar_dir_list = [1,3];
        
        tex_stim                =   Screen('MakeTexture',scr.main,noise_patch);
        clear noise_patch
        
        for stim_ori = 1:stim_ori_num
            
            for bar_dir = bar_dir_list
                if bar_dir == 1
                    % horizontal bar pass
                    bar_step_num = bar_step_num_hor;
                    bar_aperture_rect = const.bar_aperture_rect_hor;
                    dir_txt = 'hor_';
                    
                elseif bar_dir == 3
                    % horizontal bar pass
                    bar_step_num = bar_step_num_ver;
                    bar_aperture_rect = const.bar_aperture_rect_ver;
                    dir_txt = 'ver_';
                end
                
                for bar_step = 1:bar_step_num
                    
                    % define all texture parameters
                    rects                   =   [   rect_noise,...                                                  % stim noise
                                                    bar_aperture_rect(:,:,bar_step,bar_dir)',...                    % bar aperture
                                                    rect_noise,...                                                  % fix annulus
                                                    rect_noise,...                                                  % empty center
                                                    rect_noise];                                                    % fixation dot
                    
                    texs                    =   [   tex_stim,...                                                    % stim noise
                                                    tex_bar_aperture,...                                            % bar aperture
                                                    tex_fix_ann_probe,...                                           % fix anulus
                                                    tex_black_fix_noise,...                                         % empty center
                                                    tex_fix_dot_probe];                                             % fixation dot
                    
                    angles                  =   [   const.noise_angle(stim_ori),...                                 % stim noise
                                                    -const.bar_dir_ang(bar_dir)+90,...                              % bar aperture
                                                    0,...                                                           % fix anulus
                                                    0,...                                                           % empty center
                                                    0];                                                             % fixation dot
                    
                    % draw all textures
                    Screen('FillRect',scr.main,const.background_color);
                    Screen('DrawTextures',scr.main,texs,[],rects,angles)
                    Screen('FillRect',scr.main,const.background_color,const.left_propixx_hide)
                    Screen('FillRect',scr.main,const.background_color,const.right_propixx_hide)
                    Screen('DrawLines',scr.main, const.line_fix_up_left, const.line_width, const.white, [], 1);
                    Screen('DrawLines',scr.main, const.line_fix_up_right, const.line_width, const.white, [], 1);
                    Screen('DrawLines',scr.main, const.line_fix_down_left, const.line_width, const.white, [], 1);
                    Screen('DrawLines',scr.main, const.line_fix_down_right, const.line_width, const.white, [], 1);
                    Screen('DrawingFinished',scr.main,[],1);
                    
                    if const.drawStimuli
                        % plot and save the sreenshot
                        Screen('Flip',scr.main);
                        screen_stim             =   Screen('GetImage', scr.main,const.stim_rect,[],0,1);
                    else
                        % save the sreenshot
                        screen_stim             =   Screen('GetImage', scr.main,const.stim_rect,'backBuffer',[],1);
                    end
                    screen_filename         =   sprintf('%s/%sprobe_barStep-%i_kappaStim%i_stimOri-%i_noiseRand%i.mat',...
                        const.stim_folder,dir_txt,bar_step,kappa_val_stim,stim_ori,noise_rand);
                    %save(screen_filename,'screen_stim','-v7.3','-nocompression')
                    save(screen_filename,'screen_stim')
                    clear screen_stim
                    
                    numPrint                =   numPrint+1;
                    textprogressbar(numPrint*100/total_amount);
                end
            end
        end
        % close opened texture
        Screen('Close',tex_stim);
    end
end

for noise_rand = 1:noise_rand_num
    
    % make stim texture
    mat_noise               =   genNoisePatch(const,const.noise_kappa(1));
    mat_noise_resize        =   imresize(mat_noise,round([const.noise_size,const.noise_size]),'bilinear');
    noise_patch(:,:,1)      =   mat_noise_resize*const.stim_color(1);
    noise_patch(:,:,2)      =   mat_noise_resize*const.stim_color(2);
    noise_patch(:,:,3)      =   mat_noise_resize*const.stim_color(3);
    noise_patch(:,:,4)      =   const.stim_aperture;
    bar_dir_list            =   [1,3];
    
    tex_stim                =   Screen('MakeTexture',scr.main,noise_patch);
    clear noise_patch
    
    for bar_dir = bar_dir_list
        if bar_dir == 1
            bar_step_num = bar_step_num_hor;
            bar_aperture_rect = const.bar_aperture_rect_hor;
            dir_txt = 'hor_';
        elseif bar_dir == 3
            bar_step_num = bar_step_num_ver;
            bar_aperture_rect = const.bar_aperture_rect_ver;
            dir_txt = 'ver_';
        end
        
        for bar_step = 1:bar_step_num
            
            % define all texture parameters
            rects                   =   [   rect_noise,...                                                  % stim noise
                                            bar_aperture_rect(:,:,bar_step,bar_dir)',...                    % bar aperture
                                            rect_noise,...                                                  % fix annulus
                                            rect_noise,...                                                  % empty center
                                            rect_noise];                                                    % fixation dot
            
            texs                    =   [   tex_stim,...                                                    % stim noise
                                            tex_bar_aperture,...                                            % bar aperture
                                            tex_fix_ann_no_probe,...                                        % fix anulus
                                            tex_black_fix_noise,...                                         % empty center
                                            tex_fix_dot_no_probe];                                          % fixation dot
            
            angles                  =   [   0,...                                                           % stim noise
                                            -const.bar_dir_ang(bar_dir)+90,...                              % bar aperture
                                            0,...                                                           % fix anulus
                                            0,...                                                           % empty center
                                            0];                                                             % fixation dot
            
            
            % draw all textures
            Screen('FillRect',scr.main,const.background_color);
            Screen('DrawTextures',scr.main,texs,[],rects,angles)
            Screen('FillRect',scr.main,const.background_color,const.left_propixx_hide)
            Screen('FillRect',scr.main,const.background_color,const.right_propixx_hide)
            Screen('DrawLines',scr.main, const.line_fix_up_left, const.line_width, const.white, [], 1);
            Screen('DrawLines',scr.main, const.line_fix_up_right, const.line_width, const.white, [], 1);
            Screen('DrawLines',scr.main, const.line_fix_down_left, const.line_width, const.white, [], 1);
            Screen('DrawLines',scr.main, const.line_fix_down_right, const.line_width, const.white, [], 1);
            Screen('DrawingFinished',scr.main,[],1);
            
            if const.drawStimuli
                % plot save the sreenshot
                Screen('Flip',scr.main);
                screen_stim             =   Screen('GetImage', scr.main,const.stim_rect,[],0,1);
            else
                % save the sreenshot
                screen_stim             =   Screen('GetImage', scr.main,const.stim_rect,'backBuffer',[],1);
            end
            screen_filename         =   sprintf('%s/%snoprobe_barStep-%i_noiseRand%i.mat',...
                const.stim_folder,dir_txt,bar_step,noise_rand);
            
            %save(screen_filename,'screen_stim','-v7.3','-nocompression')
            save(screen_filename,'screen_stim')
            clear screen_stim
            
            numPrint                =   numPrint+1;
            textprogressbar(numPrint*100/total_amount);
            
        end
    end
    % close opened texture
	Screen('Close',tex_stim);
end

% make inter-interval screenshot
rects                   =   [rect_noise,...                                                                         % fix annulus
                             rect_noise,...                                                                         % empty center
                             rect_noise];                                                                           % fixation dot
texs                    =   [tex_fix_ann_no_probe,...                                                               % fix annulus
                             tex_black_fix_noise,...                                                                % empty center
                             tex_fix_dot_no_probe];                                                                 % fixation dot

Screen('FillRect',scr.main,const.background_color);
Screen('DrawTextures',scr.main,texs,[],rects)
Screen('FillRect',scr.main,const.background_color,const.left_propixx_hide)
Screen('FillRect',scr.main,const.background_color,const.right_propixx_hide)
Screen('DrawLines',scr.main, const.line_fix_up_left, const.line_width, const.white, [], 1);
Screen('DrawLines',scr.main, const.line_fix_up_right, const.line_width, const.white, [], 1);
Screen('DrawLines',scr.main, const.line_fix_down_left, const.line_width, const.white, [], 1);
Screen('DrawLines',scr.main, const.line_fix_down_right, const.line_width, const.white, [], 1);
Screen('DrawingFinished',scr.main,[],1);

if const.drawStimuli
    % plot and save the screenshot
	Screen('Flip',scr.main);
	screen_stim             =   Screen('GetImage', scr.main,const.stim_rect,[],0,1);
else
    % save the sreenshot
    screen_stim             =   Screen('GetImage', scr.main,const.stim_rect,'backBuffer',[],1);
end
screen_filename         =   sprintf('%s/blank.mat',const.stim_folder);
%save(screen_filename,'screen_stim','-v7.3','-nocompression')
save(screen_filename,'screen_stim')
clear screen_stim

numPrint                =   numPrint+1;
textprogressbar(numPrint*100/total_amount);
textprogressbar(numPrint*100/total_amount);

% Close all textures
Screen('Close',tex_black_fix_noise);
Screen('Close',tex_bar_aperture);
Screen('Close',tex_fix_ann_probe);
Screen('Close',tex_fix_ann_no_probe);
Screen('Close',tex_fix_dot_no_probe);
Screen('Close',tex_fix_dot_probe);

end