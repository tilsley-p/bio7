
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
   

else
    
    %% Manip Laptop
    
    scr.scr_sizeX = 1920;
    scr.scr_sizeY = 1080;

    scr.disp_sizeX = 382;
    scr.disp_sizeY = 215;

    scr.dist = 60; 
  
    
end
