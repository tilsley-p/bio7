#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 24 17:40:18 2022

@author: penny
-----------------------------------------------------------------------------------------
json_editor.py

Goal of the script:
Clean up and correct json files in bids directories and match fmaps with func runs
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: mesocentre project directory (e.g. /scratch/{user}/data/{project})
-----------------------------------------------------------------------------------------
To run:
On mesocentre

>> cd ~/projects/{project}/analysis_code/preproc/bids
>> python json_editor.py [meso_proj_dir]
-----------------------------------------------------------------------------------------
"""

# General imports
# ---------------
import os
import json
import sys

# Defining Help Messages
#-----------------------
import argparse
parser = argparse.ArgumentParser(
    description = 'Matches fmaps with func bold / dti scans using IntendedFor, and removes institution info',
    epilog = ' ')
parser.add_argument('[meso_proj_dir]', help='path to data project directory on mesocentre. e.g., /scratch/{user}/data/{project}')
parser.parse_args()

# Get inputs
# ----------
meso_proj_dir = sys.argv[1]

# Define sourcedirectory
#-----------------------
meso_src_dir = os.path.join(meso_proj_dir, "sourcedata")

# Find task jsons
#----------------
json_task = [pos_json for pos_json in os.listdir(meso_proj_dir) if pos_json.endswith('.json') if pos_json.startswith('task')]

tasks = []
tasks_short = []

### Making sure the TaskNames field in the json files is correct/updated 

for i in json_task:
    json_path = meso_proj_dir + "/" + i
    tasklabel = i.split("_")
    json_taskedit = i.replace('-','_')
    taskname = json_taskedit.split("_")
    
    print(tasklabel[0])
    
    tasks.append(taskname[1])
    tasks_short.append(taskname[1][:4])
    
    with open(json_path) as json_file:
        json_data = json.load(json_file)
        json_data["TaskName"]= taskname[1]
        json_data["InstitutionAddress"]= 'anonymous'
        json_data["InstitutionName"]= 'anonymous'
        json_data["InstitutionalDepartmentName"]= 'anonymous'
        for element in json_data:
            if 'CogAtlasID' in element:
                del element['CogAtlasID']
        json_file.close
        
        with open(json_path,'w') as json_file:
            json.dump(json_data, json_file, indent=4, sort_keys=True)
            json_file.close
            
tasks_short = list(dict.fromkeys(tasks_short))
subs_list = [subs for subs in os.listdir(meso_proj_dir) if subs.startswith('sub')]
sub_paths = [meso_proj_dir + "/" + sub_elem for sub_elem in subs_list]


### Deleting information about the instutition and removing CogAtlasID


niis = []

for i in sub_paths:
    ses_list = [sess for sess in os.listdir(i) if sess.startswith('ses')]
    i_sub = os.path.basename(i)
    
    for j in ses_list:
        ses_path = i + "/" + j
        dir_list = [di for di in os.listdir(ses_path) if os.path.isdir(os.path.join(ses_path, di))]
        
        for k in dir_list:
            dir_path = ses_path + "/" + k
            json_all = [fl for fl in os.listdir(dir_path) if fl.endswith('.json')]
            #ni_search = dir_path + "/*.nii.gz"
            nii_all = [ni for ni in os.listdir(dir_path) if ni.endswith('.nii.gz')]
            nii_all_path = [i_sub + "/" + j + "/" + nii_all_elem for nii_all_elem in nii_all]
            niis.append(nii_all_path)
            print(json_all)
            
            for l in json_all:
                json_path = dir_path + "/" + l
                
                with open(json_path) as json_file:
                    json_data = json.load(json_file)
                    json_data["InstitutionAddress"]= 'anonymous'
                    json_data["InstitutionName"]= 'anonymous'
                    json_data["InstitutionalDepartmentName"]= 'anonymous'
                    for element in json_data:
                        if 'CogAtlasID' in element:
                            del element['CogAtlasID']
                    json_file.close
                    
                with open(json_path, 'w') as json_file:
                    json.dump(json_data, json_file, indent = 4, sort_keys=True)
                    json_file.close
                    
### Associating fieldmaps with intended scans "IntendedFor" for func data and removing CogAtlasID                    

for i in sub_paths:
    ses_list = [sess for sess in os.listdir(i) if sess.startswith('ses')]
    i_sub = os.path.basename(i)
    
    for j in ses_list:
        ses_path = i + "/" + j
        fmap_path = i + "/" + j + "/fmap"  
        func_path = i + "/" + j + "/func"
        
        if os.path.exists(func_path):
            print('sorting functional run topups:')
            fmap_list = [fm for fm in os.listdir(fmap_path) if fm.endswith('epi.nii.gz')]
            json_fmap = [fm for fm in os.listdir(fmap_path) if fm.endswith('epi.json')]
            print(json_fmap)
            func_list = [func for func in os.listdir(func_path) if func.endswith('bold.nii.gz')]  
                
            for k in json_fmap:
                json_path = fmap_path + "/" + k
                
                for l in tasks_short:
                     if l in k:
                         print(i_sub + ' ' + j + ' ' + l + ' task found')
                         func_shlist = [fc for fc in func_list if l in fc] 
                         func_shlist_path = [j + "/func/" + func_shlist_elem for func_shlist_elem in func_shlist]
                         print(func_shlist_path)
     
                         with open(json_path) as json_file:
                             json_data = json.load(json_file)
                             json_data["IntendedFor"] = func_shlist_path
                             json_file.close
                         
                             with open(json_path, 'w') as json_file:
                                 json.dump(json_data, json_file, indent=4, sort_keys = True)
                                 json_file.close 
                 
                     else:
                         func_shlist = []
                         
            # print('sorted above runs, removing fmap files acq-label')
            
            # for orig in fmap_list:
            #     orig_fmap_path = os.path.join(fmap_path, orig)
            #     name_min_acq = [el for el in orig.split('_') if not 'acq' in el]
            #     newname = '_'.join(name_min_acq)
            #     new_fmap_path = os.path.join(fmap_path, newname)
            #     os.rename(orig_fmap_path, new_fmap_path)
            
            # for origj in json_fmap:
            #     orig_fmapj_path = os.path.join(fmap_path, origj)
            #     namej_min_acq = [el for el in origj.split('_') if not 'acq' in el]
            #     newjname = '_'.join(namej_min_acq)
            #     new_fmapj_path = os.path.join(fmap_path, newjname)
            #     os.rename(orig_fmapj_path, new_fmapj_path)                
                         
	
        else:
            print(i_sub + ' ' + j + ' ' + 'no func files') 


### Associating fieldmaps with intended scans "IntendedFor" for diff data and removing CogAtlasID  
                            
dwi_shlist_path = []

for i in sub_paths:
    ses_list = [sess for sess in os.listdir(i) if sess.startswith('ses')]
    i_sub = os.path.basename(i)
    
    for j in ses_list:
        ses_path = i + "/" + j
        fmap_path = i + "/" + j + "/fmap"  
        dwi_path = i + "/" + j + "/dwi"
        
        if os.path.exists(dwi_path):
            print('sorting diffusion run topups:')
            fmap_list = [fm for fm in os.listdir(fmap_path) if fm.endswith('epi.nii.gz')]
            json_fmap = [fm for fm in os.listdir(fmap_path) if fm.endswith('epi.json')]
            print(json_fmap)
            dwi_list = [dif for dif in os.listdir(dwi_path) if dif.endswith('dwi.nii.gz')]
                
            for k in json_fmap:
                json_path = fmap_path + "/" + k
                
                if 'ONleft' in k:
                    print(i_sub + ' ' + j + ' ' + 'diff ON left found')
                    dwi_shlist = [dw for dw in dwi_list if 'ONleft' in dw]
                    dwi_shlist_path = [j + "/dwi/" + dwi_shlist_elem for dwi_shlist_elem in dwi_shlist]
                    print(dwi_shlist_path)
                    
                    with open(json_path) as json_file:
                        json_data = json.load(json_file)
                        json_data["IntendedFor"] = dwi_shlist_path
                        json_file.close
                            
                    with open(json_path, 'w') as json_file:
                        json.dump(json_data, json_file, indent=4, sort_keys = True)
                        json_file.close 
                    
                elif 'ONright' in k:
                    print(i_sub + ' ' + j + ' ' +'diff ON right found')
                    dwi_shlist = [dw for dw in dwi_list if 'ONright' in dw]
                    dwi_shlist_path = [j + "/dwi/" + dwi_shlist_elem for dwi_shlist_elem in dwi_shlist]                
        
                    
                    with open(json_path) as json_file:
                        json_data = json.load(json_file)
                        json_data["IntendedFor"] = dwi_shlist_path
                        json_file.close
                            
                    with open(json_path, 'w') as json_file:
                        json.dump(json_data, json_file, indent=4, sort_keys = True)
                        json_file.close   
                        
                else:
                    dwi_list = []

        else:
            print(i_sub + ' ' + j + ' ' + 'no diff files')
    

### Removing acq-label from fieldmaps
   