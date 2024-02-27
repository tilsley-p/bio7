function [my_key]=keyConfig(const)
% ----------------------------------------------------------------------
% [my_key]=keyConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Unify key names and define structure containing each key names
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% my_key : structure containing keyboard configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Project : prfexp7t
% Version : 1.0
% ----------------------------------------------------------------------

KbName('UnifyKeyNames');

if const.training
    my_key.mri_trVal        =   's';                    % mri trigger letter
    my_key.left1Val         =   'a';                    % left button 1
    my_key.left2Val         =   'q';                    % left button 1
    my_key.right1Val        =   'p';                    % right button 1
    my_key.right2Val        =   'm';                    % right button 1
else
    my_key.mri_trVal        =   's';                    % mri trigger letter
    my_key.left1Val         =   'b';                    % left button index (inside)
    my_key.left2Val         =   'q';                    % left button thumb (outside)
    my_key.right1Val        =   'c';                    % right button index (inside)
    my_key.right2Val        =   'd';                    % right button thumb (outside)
end
   
my_key.escapeVal        =   'escape';               % escape button
my_key.spaceVal         =   'space';                % space button

my_key.mri_tr           =   KbName(my_key.mri_trVal);
my_key.left1            =   KbName(my_key.left1Val);
my_key.right1           =   KbName(my_key.right1Val);
my_key.escape           =   KbName(my_key.escapeVal);
my_key.space            =   KbName(my_key.spaceVal);

my_key.keyboard_idx     =   GetKeyboardIndices;
for keyb = 1:size(my_key.keyboard_idx,2)
    KbQueueCreate(my_key.keyboard_idx(keyb));
    KbQueueFlush(my_key.keyboard_idx(keyb));
    KbQueueStart(my_key.keyboard_idx(keyb));
end

[~,keyCodeMat]   = KbQueueCheck(my_key.keyboard_idx(1));
my_key.keyCodeNum  = numel(keyCodeMat);

end