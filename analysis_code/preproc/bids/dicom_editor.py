# -*- coding: utf-8 -*-
"""
Created on Sat Jan 14 15:45:04 2023

@author: Tilsley

-----------------------------------------------------------------------------------------
dicom_editor.py

script location: projects/bio7/analysis_code/preproc/bids/dicom_editor.py
-----------------------------------------------------------------------------------------
Goal of the script:
Before running dicom2tar.py run this code to log and reformat (if necessary), dicoms. 
Error 1: If MRI run as 1 session, splits into 2 sessions before/after scout scans.
Error 2: Removes dicom screenshots with format 01_5005_*
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project directory (e.g. /scratch/{user}/data/{project})
sys.argv[2]: subject number/label any following format (e.g. 8762, sub-8762, 876-1)
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/{project}/analysis_code/preproc/bids
>> python dicom_editor.py [meso_proj_dir] [subject_number]
-----------------------------------------------------------------------------------------
"""

# General imports
# ---------------
import os
import sys
import shutil
import pydicom

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Log, and reformat (if necessary), dicoms. Searches: MRI acquired in 1 sessions instead of 2, and mpr screenshot dicoms',
    epilog = ' ')
parser.add_argument('[meso_proj_dir]', help='path to data project directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.add_argument('[subject_number]', help='subject to analyse. OPTIONS: all (treating any untreated subjects), OR, treating specific subjects, accepted formats: 8762, sub-8762, 876-2')
parser.parse_args()

# Get inputs
# ----------
meso_proj_dir = sys.argv[1]
subject_level = sys.argv[2]

# Check inputs
# ------------
if os.path.isdir(meso_proj_dir):
    print("meso sourcedata input OK")
else:
    print("meso sourcedata input doesnt exist")
    exit()
    
# Define sourcedirectory
#-----------------------
meso_src_dir = os.path.join(meso_proj_dir,"sourcedata")        
meso_dir_dicoms = os.path.join(meso_src_dir,"dicoms")
meso_dir_logs = os.path.join(meso_src_dir,"logs")

meso_home_dir = os.path.expanduser('~')

#Define subject
#--------------
subj = subject_level.split("-")[-1]

if len(subj)<4:
    #print("error: please input subject number without dashes")
    subj_dcmid = subject_level
else:
    subj_dcmid = subj[0:3] + '-' + subj[3:]
    
serv_subj_input = os.path.join(meso_dir_dicoms,subj_dcmid)

#Find dicom folders
#------------------    
serv_subj_input_lvl = [dc for dc in os.listdir(serv_subj_input)]    

if len(serv_subj_input_lvl) == 1:
    dicom_seq_path = os.path.join(serv_subj_input,serv_subj_input_lvl[0])
    dicom_seqs = os.listdir(dicom_seq_path)
else:
    print("more than one dicom folder in subject?")
    exit()


#List dicoms and save 
#--------------------  
dicom_seqs.sort()
print("subject " + subj + "has following dicoms: " + str(dicom_seqs))

os.makedirs(meso_dir_logs,exist_ok=True)

#Filter dicoms 
#------------- 
dicom_seqs_scout_all = [sct for sct in dicom_seqs if "aahead-scout-32ch-head-coil" in sct]
dicom_seqs_scout = [sct for sct in dicom_seqs_scout_all if not "mpr" in sct] 
dicom_seqs_scout.sort()

#Check dicoms 
#------------ 
dicom_spl_seriesno = []
dicom_spl_scanno = []
dicom_spl_label = []
dicom_spl = []

for elem in dicom_seqs:
    dicom_spl.append(elem.split('_'))
    dicom_spl_seriesno.append(elem.split('_')[0])
    dicom_spl_scanno.append(elem.split('_')[1])
    dicom_spl_label.append(elem.split('_')[2])
  
dicom_unique_seriesno = list(set(dicom_spl_seriesno))
dicom_unique_seriesno.sort()  

# Finding situations MRI runs not split by session
# ------------------------------------------------

if len(dicom_unique_seriesno) == 1:
    # only 1 MRI session
    
    if len(dicom_seqs_scout) > 1:
        
        #Find scout indexes 
        #------------------
        scout_idx = [i for i, e in enumerate(dicom_spl_label) if e == "aahead-scout-32ch-head-coil"]
        remp = []
        
        for x in range(len(scout_idx)):
            
            if x + 1 < len(scout_idx):
                for y in dicom_spl_seriesno[scout_idx[x]:scout_idx[x+1]]:
                    remp.append("0" + str(x+1))
            elif x + 1 == len(scout_idx):
                for y in dicom_spl_seriesno[scout_idx[x]:len(dicom_spl_label)]:
                    remp.append("0" + str(x+1))   
        
        #Create correct sessions 
        #-----------------------
        dicom_spl_seriesno = remp
                  
    else:
        print('only one run; one scout?')

# Rename dicom folders with session indexing
# ------------------------------------------    
dicom_seqs_remp = []
for elem in range(len(dicom_seqs)):
    dicom_seqs_remp.append(dicom_spl_seriesno[elem] + '_' + dicom_spl_scanno[elem] + '_' + dicom_spl_label[elem])

for elem in range(len(dicom_seqs)):
     # rename all the files
         os.rename(os.path.join(dicom_seq_path, dicom_seqs[elem]),  os.path.join(dicom_seq_path, dicom_seqs_remp[elem]))

# Replace Series number info dicom headers
#-----------------------------------------
dicom_seqs_remp_cut = list(set(dicom_seqs_remp) - set(dicom_seqs))

for serelem in dicom_seqs_remp_cut:
    
    print("treating " + serelem)
    
    tmp_elem_dir = os.path.join(dicom_seq_path, serelem)
    tmp_elem_files = [fl for fl in os.listdir(tmp_elem_dir)]  
    
    for fname in tmp_elem_files: 
        fpath = os.path.join(tmp_elem_dir, fname)
        dataset = pydicom.read_file(fpath)
        dataset['StudyID'].value = fname[1]
        dataset.save_as(fpath)
             
# Removing irregular dicom files
# ------------------------------
remove_id = []
remove_id_idx = []
for index, scanno in enumerate(dicom_spl_scanno):
    
    if 5000 <= int(scanno) <= 10000:
        remove_id.append(scanno)
        remove_id_idx.append(index)

dicom_seqs_remove = []        
for x in remove_id_idx:
    dicom_seqs_remove.append(dicom_seqs_remp[x])

for fles in os.listdir(dicom_seq_path):
    
    if any(x == fles for x in dicom_seqs_remove):
        shutil.rmtree(os.path.join(dicom_seq_path, fles))

with open(meso_dir_logs + '/sub-' + subj + '_dicom_log.log', 'w') as fp:
    if(dicom_seqs==dicom_seqs_remp):
        fp.write('Dicoms unchanged for subject '+ subj + '. \n')
        fp.write('Original dicoms for subject '+ subj + ': \n')
        fp.write('\t'.join(dicom_seqs))    
        fp.write('\n Dicoms removed for subject '+ subj + ': \n')
        fp.write('\t'.join(dicom_seqs_remove))
    else:
        fp.write('Dicoms changed for subject '+ subj + '. \n')
        fp.write('Original dicoms for subject '+ subj + ': \n')
        fp.write('\t'.join(dicom_seqs))
        fp.write('\n Modified dicoms for subject '+ subj + ': \n')
        fp.write('\t'.join(dicom_seqs_remp)) 
        fp.write('\n Dicoms removed for subject '+ subj + '\n')
        fp.write('\t'.join(dicom_seqs_remove))
fp.close()