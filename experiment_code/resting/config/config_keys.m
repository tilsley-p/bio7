%% Configuration file 
% keyboard parameters 

%% outputs structure containing keyboard codes/letters 

KbName('UnifyKeyNames');

key.stop_letter = 'x';
key.pause_letter = 'p';
key.left1_letter = 'b'; %'b' % left button index (inside)
key.left2_letter = 'q'; %'a' % left button thumb (outside)
key.right1_letter = 'c'; %'c' % right button index (inside)
key.right2_letter = 'd'; %'d' % right button thumb (outside)
key.trigger_letter = 's';

key.stop = KbName(key.stop_letter);
key.pause = KbName(key.pause_letter);
key.left1 = KbName(key.left1_letter);
key.left2 = KbName(key.left2_letter); 
key.right1 = KbName(key.right1_letter); 
key.right2 = KbName(key.right2_letter); 
key.trigger = KbName(key.trigger_letter);