"""
Created on Fri Mar 24 09:48:39 2023

@author: penny

-----------------------------------------------------------------------------------------
org_beh_faces.py

script location: projects/bio7/analysis_code/preproc/functional/org_beh_faces.py
-----------------------------------------------------------------------------------------
Goal of the script:
Organise behavioural data with correct subject label
Also finds MRI task-data and gives beh data same sess label. Only works if 1-1 relationship
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project data directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[2]: desired subject number (e.g., sub-8761 or 8761)
sys.argv[3]: given dataset subject number (e.g., sub-8761 or 8761)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/functional
>> python org_beh_faces.py [meso_proj_dir] [subject_number] [given_subject_number] [task]
-----------------------------------------------------------------------------------------
"""

import os
import sys
import subprocess

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Organise behavioural data with correct subject label',
    epilog = '')
parser.add_argument('[meso_proj_dir]', help='path to project data directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_number]', help='desired subject number for dataset: 8762, sub-8762')
parser.add_argument('[given_subject_number]', help='subejct number given when running task: 001, sub-001')
parser.add_argument('[task]', help='transfer data from which task: faces, faceloc, resting')
parser.parse_args()


# inputs
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]
subject_task_level = sys.argv[3]
task = sys.argv[4]

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir): print("meso sourcedata input OK")
else: print("meso sourcedata input doesnt exist"); exit()

if meso_proj_dir.endswith("/"): meso_proj_dir=meso_proj_dir[:-1]
else: pass

#Define subject
#--------------
if subject_task_level.split("-")[0] == "sub": sub_task_label = subject_task_level
else: sub_task_label = "sub-{}".format(subject_task_level)
sub_task_number = sub_task_label[4:]  

#Define subject
#--------------
if subject_level.split("-")[0] == "sub": sub_label = subject_level
else: sub_label = "sub-{}".format(subject_level)
sub_number = sub_label[4:]  
    
# Define home + project
#-----------------------
meso_home_dir = os.path.expanduser('~')
projname = meso_proj_dir.split('/')[-1]

## Organising task inputs
##-----------------------
exp_data_dir = "{}/sourcedata/beh/{}/data".format(meso_proj_dir, task)
exp_code_dir = "{}/projects/{}/experiment_code/{}".format(meso_home_dir, projname, task)
data_output_dir = "{}/sourcedata/beh/{}".format(meso_proj_dir, task)

## Finding corresponding session MRI 
##----------------------------------

sub_dir = "{}/{}".format(meso_proj_dir, sub_label)

sessions = [sm for sm in os.listdir(sub_dir) if "ses-" in sm]
sessions.sort()

for sess in sessions:
    sub_sess_dir = os.path.join(sub_dir, sess)
    
    print("\n    loop start, searching sessions")
    
    sub_sess_func_dir = os.path.join(sub_sess_dir, 'func')
    
    if os.path.isdir(sub_sess_func_dir):
        #sub-no/ses-no/func/
        
        if task == "faces": tasksearch = "task-emotion"
        elif task == "faceloc": tasksearch = "task-localiseremo"
     
        taskfile = [tf for tf in os.listdir(sub_sess_func_dir) if "task-{}".format(task) in tf]
        
        taskfile.sort()
        
        if len(taskfile) == 0:
            print("no tasks found for " + sub_sess_func_dir)
        else:
            corr_session = sub_sess_func_dir.split('/')[-2]
            
            print("following tasks found for " + sub_sess_func_dir + "\n")
            print(*taskfile, sep = "\n")
            
            data_output_dirs = '{}/{}/{}'.format(data_output_dir, sub_label, corr_session)  
            os.makedirs(data_output_dirs, exist_ok = True)
            log = os.path.join(data_output_dirs, 'logs')
            os.makedirs(log, exist_ok = True)
            
            if task != 'resting':
                datafiles = [outf for outf in os.listdir(exp_data_dir) if sub_task_label in outf and outf.endswith(".csv")]
                datafiles.sort()
            
                for d in datafiles:

                    copy_from = os.path.join("{}/{}".format(exp_data_dir, d))
                    d_rename = d.replace(sub_task_label, "{}_{}".format(sub_label,corr_session))
                    d_rename2 = d_rename.replace(tasksearch, "task-{}".format(task))
                    copy_to = os.path.join("{}/{}".format(data_output_dirs, d_rename2))

                    print('copying beh file ' + d + ' to/as: ' + copy_to)
                    subprocess.call(['cp', copy_from, copy_to])

                    sh_dir = os.path.join(log, "{}_{}_copy_equiv.log".format(sub_label, corr_session))
                    of = open(sh_dir, 'a')
                    of.write("{} copied to/as {}\n".format(copy_from, copy_to))
                    of.close()

                exec_dir = os.path.join(exp_code_dir, "execution")

                print("\n   find exec files in " + exec_dir) 

                exec_files = [design for design in os.listdir(exec_dir) if design.endswith("design.csv") or design.endswith("design_test.csv")]

                for e in exec_files:
                    copy_from = os.path.join("{}/{}".format(exec_dir, e))
                    copy_to = os.path.join("{}/{}".format(data_output_dirs, e))
                    print('copying beh file ' + e + ' to: ' + copy_to)
                    subprocess.call(['cp', copy_from, copy_to])
                    
            else:
                pass
                
            readme_files = [rm for rm in os.listdir(exp_code_dir) if "README" in rm]

            for rm in readme_files:
                copy_from = os.path.join("{}/{}".format(exp_code_dir, rm))
                copy_to = os.path.join("{}/{}".format(log, rm))
                print('copying readme file ' + rm + ' to: ' + copy_to)
                subprocess.call(['cp', copy_from, copy_to])