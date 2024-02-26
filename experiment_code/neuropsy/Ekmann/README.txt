README* 

Ekmann 60 Faces Task 
------------

%% Instructions - running the task: 

(fyi: run without being connected to an external screen preferably) 

0. Go into the Training folder to run the participant training (short) or the Exam folder to run the actual test (whole test) 

1. Run A_LoadImages.m to setup the experiment

- this is simply to setup images, screen and get subject inputs, it is not the actual test. each time you want to run or re-run the experiment you will need to do this.
- once you run, questions in the Matlab command window will ask for inputs of subject details, follow what is inside the brackets.

2. Run B_RunEkmann.m to run the actual task with the participant 

- the participant has 5s to look at each image.
- the participant then has max 7s to choose the corresponding emotion once the mouse re-appears in the centre of the screen (else it times out and continues automatically).
- once the emotion has been selected (or timed out) the participant then has 7s to select 'next' to go to the next trial (above 7s this times out and proceeds automatically)
 [during this time the experimenter can also click the 'x' button to stop the experiment if desired]. 

at the end of a run, summary data will be printed in the matlab command window for info. 
each time you want to re-run the experiment, run both the A_ and B_ code as above (steps 1. and 2.) 

-------------

%% Info - data: 

- data is stored in the /data folder. 
- this is arranged by subject and each subject has two .csv files: 
one with all data trial-by-trial (_data) 
the other  with one line for the participant containing overall results summary calculated from all trials (_results)
- there is also a matlab workspace for back-up. 

- if the experiment was cancelled with x _aborted will be appended to all filenames and no _results table made.  

-------------

Contact Penelope Tilsley (tilsley.penelope@gmail.com) if any code problems
