# -*- coding: utf-8 -*-
"""
Created on Mon Jan  9 11:03:27 2023

@author: Tilsley

-----------------------------------------------------------------------------------------
tar2bids.py

script location: projects/bio7/analysis_code/preproc/bids/tar2bids.py
-----------------------------------------------------------------------------------------
Goal of the script:
Create bids directory from tarfiles on mesocentre
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project data directory (e.g. /scratch/jstellmann/data/bio7)
sys.argv[2]: individual subject level or automatic all remaining (e.g., sub-8761 or 8761, all)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/bio7/analysis_code/preproc/bids
>> python tar2bids.py [meso_proj_dir] [subject_number]
-----------------------------------------------------------------------------------------
"""

# General imports
# ---------------
import os
import sys
import subprocess

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Convert subjects .tar files in sourcedata to bids. Uses bids structure defined in bids_heuristic_file_{project}.py. Raw bids directory is copied to sourcedata',
    epilog = ' ')
parser.add_argument('[meso_proj_dir]', help='path to project data directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_number]', help='subject to analyse. OPTIONS: all (treating any untreated subjects), OR, treating specific subjects, accepted formats: 8762, sub-8762, 876-2')
parser.parse_args()


# Get inputs
# ----------
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]

# os.getlogin() userid e.g., ptilsley

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir):
    print("meso project input OK")
    if meso_proj_dir.endswith("/"):
        #True
        meso_proj_dir = meso_proj_dir[:-1]
    else:
        #True
        pass            
else:
    print("meso project input doesnt exist")
    exit()

    
# Define sourcedirectory
#-----------------------
meso_src_dir = os.path.join(meso_proj_dir,"sourcedata")
meso_dir_code = os.path.join(meso_proj_dir, "code")

# Define home + project
#-----------------------
meso_home_dir = os.path.expanduser('~')

projname = meso_proj_dir.split('/')[-1]

# Bids codes location
#---------------------
bids_code_dir = "{}/projects/{}/analysis_code/preproc/bids".format(meso_home_dir,projname)

# Define code directories
#-------------------------
meso_code_dir = os.path.join(meso_proj_dir,"code")
meso_singularity_dir = os.path.join(meso_code_dir,"singularity")

# Finding tar2bids sif
#----------------------
tar2bids_file = [sif for sif in os.listdir(meso_singularity_dir) if "tar2bids" in sif and sif.endswith(".simg")]
tar2bids_path = os.path.join(meso_singularity_dir, tar2bids_file[0])

# Finding .bidsignore file
#-------------------------
bidsignore_file = [bd for bd in os.listdir(meso_code_dir) if "bidsignore" in bd]
bidsignore_path = os.path.join(meso_code_dir, bidsignore_file[0])

# Finding heuristics file
#------------------------
heuristics_file = [hr for hr in os.listdir(bids_code_dir) if "heuristic" in hr and meso_proj_dir.split("/")[-1] in hr]
heuristics_path = os.path.join(bids_code_dir, heuristics_file[0])

# Create bids dir meso
# --------------------
meso_dir_tarfiles = os.path.join(meso_src_dir,"tarfiles")
meso_dir_bids = os.path.join(meso_src_dir,"bids")
meso_dir_bidswd = os.path.join(meso_src_dir,"tmp")
meso_dir_logs = os.path.join(meso_src_dir,"logs")

os.makedirs(meso_dir_bids,exist_ok=True)
os.makedirs(meso_dir_bidswd,exist_ok=True)
os.makedirs(meso_dir_logs,exist_ok=True)

# Echo subjects
#--------------
meso_subs_tar = os.listdir(meso_dir_tarfiles)
print("Mesocentre has subject(s): " + str(meso_subs_tar) + " as tarfiles")

meso_subs_tar_spl = []
for trs in meso_subs_tar:
    meso_subs_tar_spl.append(trs.split("_")[0])
meso_subs_tar_norm = list(set(meso_subs_tar_spl))

meso_subs_bids = os.listdir(meso_dir_bids)
print("Mesocentre has subject(s): " + str(meso_subs_bids) + " as bids")

meso_subs_bids_norm = []
for bds in meso_subs_bids:
    meso_subs_bids_norm.append(bds.split("-")[-1])

# Subject_level = "all" 
# Finding missing subject bids
#-----------------------------
subtobids = list(set(meso_subs_tar_norm) - set(meso_subs_bids_norm))

if subject_level == "all":
    print("Converting subject(s) " + str(subtobids) + " tar to bids")
    
    for subj in subtobids:
        
        subj_tars = [su for su in meso_subs_tar if subj in su]
        print("Subject " + str(subj) + " has following tars: " + str(subj_tars))
        
        for subsess in subj_tars:
            print("Converting " + str(subsess)+ " to bids")
            inp = '{subject}_{session}'
            subsess_tarpath = os.path.join(meso_dir_tarfiles, subsess)
            
            # Call singularity tar2bids
            # per subject per session
            #---------------------------
            print(["singularity","run", "-e", "-B", meso_proj_dir + "," + meso_home_dir, tar2bids_path, "-h", heuristics_path, \
                   "-T", inp, "-w", meso_dir_bidswd, "-b", bidsignore_path, "-o", meso_proj_dir, subsess_tarpath])            
            
            subprocess.call(["singularity","run", "-e", "-B", meso_proj_dir + "," + meso_home_dir, tar2bids_path, "-h", heuristics_path, \
                             "-T", inp, "-w", meso_dir_bidswd, "-b", bidsignore_path, "-o", meso_proj_dir, subsess_tarpath])
            
            # Mv and rename output log in sourcedata/code
            #--------------------------------------------  
            tmp_logdoc = [t2b for t2b in os.listdir(meso_dir_code) if t2b.startswith("tar2bids")]
        
            for lg in tmp_logdoc:
                tmp_logdoc_path = os.path.join(meso_dir_code, lg)
                rename = "sub-" + subsess.split('_')[0] + "_ses-" + subsess.split('_')[1].split('.')[0] + '_tar2bids_log'
                new_logdoc_path = os.path.join(meso_dir_logs, rename)
                print("Copying " + lg + " log folder to " + meso_dir_logs + " as " + rename)
                subprocess.call(["mv", tmp_logdoc_path, new_logdoc_path])
                
        # Find and rename output .tar files
        #----------------------------------     
        bidsfolder = "sub-" + subj
        tmp_bidsfolder_created = os.path.join(meso_proj_dir, bidsfolder) #/bio7/sub-8761
        tmp_bidsfolder_dest = meso_dir_bids + "/" #bio7/sourcedata/bids/
         
        print("Copy subject " + subj + "bids data from" + tmp_bidsfolder_created + " to " + tmp_bidsfolder_dest)
        subprocess.call(["cp", "-r", tmp_bidsfolder_created, tmp_bidsfolder_dest])

        
# Subject_level = "induvidual" 
#-----------------------------               
else:
    #Account for input as sub-* or just subject number
    subj = subject_level.split("-")[-1]
    
    if len(subj)<4:
        #Account for input subject number without dashes
        subj_dcmid = subject_level
        s = subject_level.replace("-","")
    else:
        #Account for input subject number as label or full number
        subj_dcmid = subj[0:3] + '-' + subj[3:] 
        s = subj
    
    
    subj_tars = [su for su in meso_subs_tar if s in su]
    print("Subject has following tars: " + str(subj_tars))
    
    for subsess in subj_tars:
        print("Converting " + str(subsess)+ " to bids")
        inp = '{subject}_{session}'
        subsess_tarpath = os.path.join(meso_dir_tarfiles, subsess)
        
        # Call singularity tar2bids
        # per session
        #---------------------------
        print(["singularity","run", "-e", "-B", meso_proj_dir + "," + meso_home_dir, tar2bids_path, "-h", heuristics_path, \
               "-T", inp, "-w", meso_dir_bidswd, "-b", bidsignore_path, "-o", meso_proj_dir, subsess_tarpath])
        
        subprocess.call(["singularity","run", "-e", "-B", meso_proj_dir + "," + meso_home_dir, tar2bids_path, "-h", heuristics_path, \
                         "-T", inp, "-w", meso_dir_bidswd, "-b", bidsignore_path, "-o", meso_proj_dir, subsess_tarpath])
        
        
        # Mv and rename output log in sourcedata/code
        #--------------------------------------------  
        tmp_logdoc = [t2b for t2b in os.listdir(meso_dir_code) if t2b.startswith("tar2bids")]
        
        for lg in tmp_logdoc:
            tmp_logdoc_path = os.path.join(meso_dir_code, lg)
            rename = "sub-" + subsess.split('_')[0] + "_ses-" + subsess.split('_')[1].split('.')[0] + '_tar2bids_log'
            new_logdoc_path = os.path.join(meso_dir_logs, rename)
            print("Copying " + lg + " log folder to " + meso_dir_logs + " as " + rename)
            subprocess.call(["mv", tmp_logdoc_path, new_logdoc_path])
        
    #Find and rename output .tar files
    #----------------------------------    
#     bidsfolder = "sub-" + subj
    tmp_bidsfolder_created = os.path.join(meso_proj_dir, bidsfolder) #/bio7/sub-8761
    tmp_bidsfolder_dest = meso_dir_bids + "/" #bio7/sourcedata/bids/
     
    print("Copy subject " + subj + "bids data from" + tmp_bidsfolder_created + " to " + tmp_bidsfolder_dest)
    subprocess.call(["cp", "-r", tmp_bidsfolder_created, tmp_bidsfolder_dest])
    