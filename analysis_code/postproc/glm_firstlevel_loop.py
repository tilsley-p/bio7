#!/usr/bin/env python3
"""
-----------------------------------------------------------------------------------------
fit_glm.py
-----------------------------------------------------------------------------------------
Goal of the script:
First level GLM analysis of task runs on participant level
-----------------------------------------------------------------------------------------
Input(s):
sys.argv[1]: base_dir (e.g. /BIO7/data/bids)
sys.argv[2]: subject name (e.g. sub-8761)
sys.argv[3]: session (e.g. ses-02)
sys.argv[4]: task (e.g. faces, faceloc)
sys.argv[5]: space (e.g. T1w)
sys.argv[6]: run number to analyse (e.g. run-01)
sys.argv[7]: pre-processing label of fmri image (desc-prepoc)
-----------------------------------------------------------------------------------------
Output(s):
...
-----------------------------------------------------------------------------------------
To run:
On mesocentre
>> cd to where glm analyses and scripts folders are located
>> python glm/fit_glm.py [base_dir] [subject] [session] [task] [reg] [preproc]
-----------------------------------------------------------------------------------------
Example:

cd /Volumes/DATA_CNS/CNS_HUMAN/BIO7/data/bids/derivatives/mri_analysis/
python scripts_glm/fit_glm_firstlevel.py /Volumes/DATA_CNS/CNS_HUMAN/BIO7/data/bids sub-8761 ses-02 faces T1w desc-preproc

-----------------------------------------------------------------------------------------
"""

# Stop warnings
# -------------
import warnings
warnings.filterwarnings("ignore")

# General imports
# ---------------
import os
import sys
import json
import numpy as np
import pandas as pd
import scipy.stats as stats
import pdb
deb = pdb.set_trace

# MRI imports
# -----------
import nibabel as nb

# Functions import
# ----------------
import importlib.util

# GLM imports
# -----------
from nilearn.glm.first_level import make_first_level_design_matrix
from nilearn.glm.first_level import FirstLevelModel
from nilearn.glm import threshold_stats_img
from nilearn import plotting
from nilearn.plotting import plot_design_matrix
from nilearn.image import mean_img
from nilearn.maskers import NiftiMasker
from nilearn.interfaces.fmriprep import load_confounds

# Plot imports 
# -----------
try:
    import matplotlib.pyplot as plt
except ImportError:
    raise RuntimeError("This script needs the matplotlib library")

# Get inputs
# ----------
base_dir =  sys.argv[1]
subject = sys.argv[2]
session = sys.argv[3]
task = sys.argv[4] 
space = sys.argv[5] 
preproc = sys.argv[6] 

subject_folder = subject if space=='T1w' else '{}_mni'.format(subject) # output folder

# Define GLM parameters
# ---------------------
glm_alpha = 0.05
glm_noise_model = "ar1"
hrf_model = 'spm'

# Define GLM ouput folder
# -----------------------

glm_folder = '{base_dir}/derivatives/glm_{task}/{subject}/{session}/glm_first_level/summarystat/'.format(base_dir=base_dir, task=task, subject=subject_folder, session = session)

try: os.makedirs(glm_folder)
except: pass

glm_folder_concatenated = glm_folder.replace("summarystat", "concatenated")
try: os.makedirs(glm_folder_concatenated)
except: pass

# Define scan parameters
# --------------------------

tr = 1.08 #repetition time in seconds 

if task == "faces": 
    if subject == "sub-8761":
        n_scans = 255 #number of scans/volumes in fMRI run, same for all runs, subject 1 less
    else:
        n_scans = 260 #number of scans/volumes in fMRI run, same for all runs
elif task == "faceloc": 
    if subject == "sub-8761":
        n_scans = 200 #number of scans/volumes in fMRI run, same for all runs, subject 1 less
    else:
        n_scans = 170 #number of scans/volumes in fMRI run, same for all runs
    
#number of frames in total in seconds 
frame_times = np.arange(n_scans) * tr

# Defining anatomical image
# --------------------------
anat_img = "{base_dir}/derivatives/fmriprep/fmriprep/{subject}/ses-01/anat/{subject}_ses-01_rec-BcSsLf_run-1_desc-preproc_T1w.nii.gz".\
                format(base_dir=base_dir, subject=subject)

# Finding functional runs and onsets
# ----------------------------------
func_dir = "{base_dir}/{subject}/{session}/func/".format(base_dir=base_dir, subject=subject, session=session)
list_onsets_tsvs = [f for f in os.listdir(func_dir) if f.endswith('events.tsv') and task in f]
list_func_nii = [f for f in os.listdir(func_dir) if f.endswith('_bold.nii.gz') and task in f]

list_onsets_tsvs.sort()
list_func_nii.sort()

print(list_onsets_tsvs)
print(list_func_nii)

events = []
events_df = []
func_imgs = []
confounds = []
confounds_df = []
designmatrices = []
designmatrices_df = []

for idx, i in enumerate(list_onsets_tsvs):
    #extracting subject and run labels from onsets file
    x = i.split("_")
    subno = x[0][4:]
    sublab = x[0]
    seslab = x[1]
    tasklab = x[2]
    dirlab = x[3]
    runno = x[4][4:]
    runnoshort = runno[1] 
    runlab = x[4]
   
    #### EVENTS
    #read in current onsets file 
    onsets_path = func_dir + i
    onsets_run = pd.read_csv(onsets_path,sep='\t')
    onsets_run_headers = list(onsets_run)[1:]
    
    #extracting necessary info
    conditions = list(onsets_run["trial_type"])
    duration = list(onsets_run["duration"])  
    onsets = list(onsets_run["onset"])
    
    event = pd.DataFrame({'trial_type': conditions, 'onset': onsets, 'duration': duration})   
    print(events) 
    event_path = "{glm_folder}{subject}_{session}_task-{task}_{dirlab}_run-{runno}_events.csv".\
                format(glm_folder=glm_folder,subject=subject,session=session,task=task,dirlab=dirlab, runno=runno)
    event.tocsv(event_path)
    events.append(event_path) 
    events_df.append(event)
    
    #### FMRI IMAGES
    fmri_img = "{base_dir}/derivatives/fmriprep/fmriprep/{subject}/{session}/func/{subject}_{session}_task-{task}_{dirlab}_run-{runnoshort}_space-{space}_{preproc}_bold.nii.gz".\
                format(base_dir=base_dir, subject=subject,session=session,task=task,dirlab=dirlab, space=space, runnoshort=runnoshort, preproc = preproc)
    func_imgs.append(fmri_img)
    
    #### CONFOUNDS
    confound = load_confounds(fmri_img, strategy=("motion","high_pass", "wm_csf"), motion="basic",wm_csf="basic", global_signal="basic")
    confound_path = "{glm_folder}{subject}_{session}_task-{task}_{dirlab}_run-{runno}_confounds.csv".\
                format(glm_folder=glm_folder, subject=subject,session=session,task=task,dirlab=dirlab, runno=runno)
    confound[0].tocsv(confound_path)
    confounds.append(confound_path)
    len(confounds[0])
    np.shape(confounds[0]) 
    confounds_df.append(confound)
    
    #### DESIGN MATRIX
    designmatrix = pd.concat([event, confound[0]], axis=1)
    designmatrix_path = "{glm_folder}{subject}_{session}_task-{task}_{dirlab}_run-{runno}_designmatrix.csv".\
                format(glm_folder=glm_folder, subject=subject,session=session,task=task,dirlab=dirlab, runno=runno)
    designmatrix.tocsv(designmatrix_path)
    designmatrices.append(designmatrix_path)           
    designmatrices_df.append(designmatrix)
    
    
    X1 = make_first_level_design_matrix(
        frame_times,
        events,
        drift_model="polynomial",
        drift_order=3,
        add_regs=confound[0],
        add_reg_names=add_reg_names,
        hrf_model=hrf_model,
    
    #rows, columns = 0, 1
    np.shape(designmatrix)
    designmatrix_zeros = np.zeros(np.shape(designmatrix))
    
    for le in range(1,len(list_func_nii)): 
        if le == 1: 
            tmp = np.vstack((designmatrix, designmatrix_zeros))
        else: 
            tmp = np.vstack((tmp, designmatrix_zeros))
            
    if idx == 0: 
        output = tmp
    else: 
        output = np.hstack((output, tmp))
        
    # MASK 
    file_mask_img = '{base_dir}/derivatives/fmriprep/fmriprep/{subject}/{session}/func/{subject}_{session}_task-{task}_{dirlab}_run-1_space-{space}_desc-brain_mask.nii.gz'.\
                    format(base_dir=base_dir, subject=subject,session=session,task=task,dirlab=dirlab, space=space)
           
# Performing CONCATENATION
func_imgs_concat = nb.funcs.concat_images(func_imgs, check_affines=True, axis = -1)

nb.save(func_imgs_concat, "{glm_folder_concatenated}{subject}_{session}_task-{task}_{dirlab}_run-concatenated_bold.nii.gz".\
                format(glm_folder_concatenated=glm_folder_concatenated, subject=subject,session=session,task=task,dirlab=dirlab))      

#zero_matrix = np.zeros(np.shape(designmatrices_df))
#np.fill_diagonal(zero_matrix, designmatrices)  

designmatrix_conc_path = "{glm_folder_concatenated}{subject}_{session}_task-{task}_{dirlab}_designmatrix.csv".\
            format(glm_folder_concatenated=glm_folder_concatenated, subject=subject,session=session,task=task,dirlab=dirlab)
designmatrix_conc_df = pd.DataFrame(output)
designmatrix_conc_df.tocsv(designmatrix_conc_path)

# Run GLM analyses 
# -------------
print('Running concatenated GLM, {} {}'.format(subject, task))   
    
print("concatenated func image " + func_imgs_concat)  # list of fmri image paths 
print("length func image " + len(func_imgs_concat))
print("design matrix concatenated " + designmatrix_conc_df)    # concatenated dataframe design matrix events plus confounds

# Run GLM analyses 
# -------------
print('Running looped summary stat GLM, {} {}'.format(subject, task))   
    
print(func_imgs)  # list of fmri image paths 
print(events_df)   # listed dataframe of events 
print(confounds_df)    # listed dataframe of confounds 

print(" func image " + func_imgs)  # list of fmri image paths 
print("length func image " + len(func_imgs))
print("events " + events_df)
print("events " + confounds_df)


# first level GLM
mask_img = nb.load(file_mask_img)
mean_img = mean_img(func_imgs[0])

fmri_glm = FirstLevelModel( t_r=tr,
                            drift_model='cosine',
                            slice_time_ref=0.5,
                            hrf_model="glover",
                            noise_model="ar1",
                            smoothing_fwhm=3.2,
                            high_pass=0.01,
                            mask_img=mask_img)




fmri_glm = fmri_glm.fit(func_imgs, design_matrices=designmatrices_df)
#fmri_glm = fmri_glm.fit(func_imgs, events, confounds)
design_matrix = fmri_glm.design_matrices_[0]

print(design_matrix.shape)
plot_design_matrix(design_matrix)

#saving for each subject, run, trialtype condition 
filename = glm_folder +"/{}_{}_{}_{}_designmatrix.png".format(sublab, seslab, tasklab, dirlab)
plt.savefig(filename) 
plt.close()

n_columns = design_matrix[0].shape[1]

def pad_vector(contrast_, n_columns):
    """Append zeros in contrast vectors."""
    return np.hstack((contrast_, np.zeros(n_columns - len(contrast_))))

# contrast
if task == 'faceloc':
  
    conditions = {
        'Fear': pad_vector([1., 0., 0.],n_columns),
        'Happy': pad_vector([0., 1., 0.],n_columns),
        'Neutral': pad_vector([0., 0., 1.],n_columns)}
        
    contrasts = {
        'Fear-Neutral': conditions['Fear'] - conditions['Neutral'],
        'Neutral-Fear': conditions['Neutral'] - conditions['Fear'],
        'Happy-Neutral':     conditions['Happy'] - conditions['Neutral'],
        'Neutral-Happy':     conditions['Neutral'] - conditions['Happy'],
        'Fear-Happy':    conditions['Fear'] - conditions['Happy'],
        'Happy-Fear':    conditions['Happy'] - conditions['Fear']}
    
elif task == 'faces':

    conditions = {
        'ConFear': pad_vector([1., 0., 0., 0., 0., 0.],n_columns),
        'UnconFear': pad_vector([0., 0., 0., 1., 0., 0.],n_columns),
        'ConHappy': pad_vector([0., 1., 0., 0., 0., 0.],n_columns),
        'UnconHappy': pad_vector([0., 0., 0., 0., 1., 0.],n_columns),
        'ConNeutral': pad_vector([0., 0., 1., 0., 0., 0.],n_columns),
        'UnconNeutral': pad_vector([0., 0., 0., 0., 0., 1.],n_columns)}
       
    contrasts = {
        'ConFear-UnconFear':    conditions['ConFear'] - conditions['UnconFear'],
        'ConFear-ConHappy':    conditions['ConFear'] - conditions['ConHappy'],
        'ConFear-ConNeutral':    conditions['ConFear'] - conditions['ConNeutral'],
        'ConHappy-UnconHappy':    conditions['ConHappy'] - conditions['UnconHappy'],
        'ConHappy-ConNeutral':    conditions['ConHappy'] - conditions['ConNeutral'],
        'UnconFear-UnconNeutral':    conditions['UnconFear'] - conditions['UnconNeutral'],
        'UnconHappy-UnconNeutral':    conditions['UnconHappy'] - conditions['UnconNeutral'],
        'UnconFear-UnconHappy':    conditions['UnconFear'] - conditions['UnconHappy'],
        'Con-Uncon':    conditions['ConHappy'] + conditions['ConFear'] + conditions['ConNeutral'] - conditions['UnconFear'] - conditions['UnconHappy'] - conditions['UnconNeutral'],
        'Fear-Happy':    conditions['ConFear'] + conditions['UnconFear'] - conditions['ConHappy'] - conditions['UnconHappy'],
        'Fear-Neutral':    conditions['ConFear'] + conditions['UnconFear'] - conditions['ConNeutral'] - conditions['UnconNeutral'],
        'Happy-Neutral':    conditions['ConHappy'] + conditions['UnconHappy'] - conditions['ConNeutral'] - conditions['UnconNeutral'],
        'Effects_of_interest': np.eye(n_columns)[:5]}


# compute glm maps
for contrast in contrasts:
    
    output_fn = '{glm_folder}{subject}_{session}_task-{task}_{runlab}_space-{space}_{preproc}_glm-{contrast}.nii.gz'.\
            format(glm_folder=glm_folder, subject=subject,session=session,task=task,space=space,runlab=runlab,preproc=preproc,contrast=contrast)
    
    print('{}'.format(output_fn))
    
    # stats maps
    eff_map = fmri_glm.compute_contrast(contrasts[contrast],
                                        output_type='effect_size')
    
    z_map = fmri_glm.compute_contrast(contrasts[contrast],
                                        output_type='z_score')

    z_p_map = 2*(1 - stats.norm.cdf(abs(z_map.dataobj)))
        
    fdr_map, th = threshold_stats_img(z_map, alpha=glm_alpha, height_control='fdr')
    fdr_p_map = 2*(1 - stats.norm.cdf(abs(fdr_map.dataobj)))
    
    fdr_cluster10_map, th = threshold_stats_img(z_map, alpha=glm_alpha, height_control='fdr', cluster_threshold=10)
    fdr_cluster10_p_map = 2*(1 - stats.norm.cdf(abs(fdr_cluster10_map.dataobj)))
    
    fdr_cluster50_map, th = threshold_stats_img(z_map, alpha=glm_alpha, height_control='fdr', cluster_threshold=50)
    fdr_cluster50_p_map = 2*(1 - stats.norm.cdf(abs(fdr_cluster50_map.dataobj)))
                             
    fdr_cluster100_map, th = threshold_stats_img(z_map, alpha=glm_alpha, height_control='fdr', cluster_threshold=100)
    fdr_cluster100_p_map = 2*(1 - stats.norm.cdf(abs(fdr_cluster100_map.dataobj)))
                              
    # Save results
    img = nb.load(fmri_img)
    deriv = np.zeros((img.shape[0],img.shape[1],img.shape[2],11))*np.nan
    
    deriv[...,0]  = eff_map.dataobj
    deriv[...,1]  = z_map.dataobj
    deriv[...,2]  = z_p_map
    deriv[...,3]  = fdr_map.dataobj
    deriv[...,4]  = fdr_p_map
    deriv[...,5]  = fdr_cluster10_map.dataobj
    deriv[...,6]  = fdr_cluster10_p_map
    deriv[...,7]  = fdr_cluster50_map.dataobj
    deriv[...,8]  = fdr_cluster50_p_map
    deriv[...,9]  = fdr_cluster100_map.dataobj
    deriv[...,10] = fdr_cluster100_p_map
                              
    deriv = deriv.astype(np.float32)
    new_img = nb.Nifti1Image(dataobj = deriv, affine = img.affine, header = img.header)
    new_img.to_filename(output_fn)

    
#    observed_timeseries = NiftiMasker.fit_transform(fmri_img)
#    predicted_timeseries = NiftiMasker.fit_transform(fmri_glm.predicted[0])
    
    zmap_fn = '{glm_folder}{subject}_{session}_task-{task}_{runlab}_space-{space}_{preproc}_glm-{contrast}_zmap.png'.\
            format(glm_folder=glm_folder, subject=subject,session=session,task=task,space=space,runlab=runlab,preproc=preproc,contrast=contrast)
    
    stat_z_fn = '{glm_folder}{subject}_{session}_task-{task}_{runlab}_space-{space}_{preproc}_glm-{contrast}_stat_z.nii.gz'.\
            format(glm_folder=glm_folder, subject=subject,session=session,task=task,space=space,runlab=runlab,preproc=preproc,contrast=contrast)    
    z_map.to_filename(stat_z_fn)
    
    fdrmap_fn = '{glm_folder}{subject}_{session}_task-{task}_{runlab}_space-{space}_{preproc}_glm-{contrast}_fdr.png'.\
            format(glm_folder=glm_folder, subject=subject,session=session,task=task,space=space,runlab=runlab,preproc=preproc,contrast=contrast)
    
    stat_fdr_fn = '{glm_folder}{subject}_{session}_task-{task}_{runlab}_space-{space}_{preproc}_glm-{contrast}_stat_fdr.nii.gz'.\
            format(glm_folder=glm_folder, subject=subject,session=session,task=task,space=space,runlab=runlab,preproc=preproc,contrast=contrast)    
    fdr_map.to_filename(stat_fdr_fn)
    
    plotting.plot_stat_map(
        z_map, bg_img=mean_img, threshold=3.0, display_mode='z',
        cut_coords=10, title=contrast, output_file=zmap_fn)
    
    plotting.plot_stat_map(
        fdr_map, bg_img=mean_img, display_mode='z',
        cut_coords=10, title=contrast, output_file=fdrmap_fn)
        
#    plotting.plot_stat_map(
#        z_map, bg_img=mean_img, threshold=3.0, display_mode='y',
#        cut_coords=(-60,-45,-30,-15,0,15,30,45,60), title=contrast, output_file=zmap_fn) 
    
    if task == 'faceloc':
        from brainsprite import viewer_substitute
        
        anat_bgimg = nb.load(anat_img)
        print(anat_bgimg)
        
        bsprite = viewer_substitute(threshold=3, opacity=0.5, title="{glmfolder}{subject}_{session}_task-{task}_space-{space}_{contrast}_zmap".\
                                    format(glmfolder=glm_folder,subject=subject, session=session, task=task,space=space,contrast=contrast), 
                                 cut_coords=[36, -27, 66])
        bsprite.fit(z_map, bg_img=anat_bgimg)

        import tempita
        #/Users/penny/.pyenv/versions/3.9.5/lib/python3.9/site-packages/brainsprite/data/html/viewer_template.html
        file_template = '/Users/penny/.pyenv/versions/3.9.5/lib/python3.9/site-packages/brainsprite/data/html/viewer_template.html'
        template = tempita.Template.from_filename(file_template, encoding="utf-8")
        viewer = bsprite.transform(template, javascript='js', html='html', library='bsprite')
        viewer.save_as_html('{glmfolder}{subject}_{session}_task-{task}_space-{space}_{contrast}_zmap.html'.\
                            format(glmfolder=glm_folder, subject=subject, session=session, task=task, space=space, contrast=contrast))
        
        
        bsprite = viewer_substitute(opacity=0.5, title="{glmfolder}{subject}_{session}_task-{task}_space-{space}_{contrast}_fdrmap".\
                                    format(glmfolder=glm_folder,subject=subject, session=session, task=task,space=space,contrast=contrast), 
                                 cut_coords=[36, -27, 66])
        bsprite.fit(fdr_map, bg_img=anat_bgimg)

        import tempita
        #/Users/penny/.pyenv/versions/3.9.5/lib/python3.9/site-packages/brainsprite/data/html/viewer_template.html
        file_template = '/Users/penny/.pyenv/versions/3.9.5/lib/python3.9/site-packages/brainsprite/data/html/viewer_template.html'
        template = tempita.Template.from_filename(file_template, encoding="utf-8")
        viewer = bsprite.transform(template, javascript='js', html='html', library='bsprite')
        viewer.save_as_html('{glmfolder}{subject}_{session}_task-{task}_space-{space}_{contrast}_fdr_map.html'.\
                            format(glmfolder=glm_folder, subject=subject, session=session, task=task, space=space, contrast=contrast))
        
    elif task == 'faces':
        from brainsprite import viewer_substitute
        
        anat_bgimg = nb.load(anat_img)
        print(anat_bgimg)
        
        bsprite = viewer_substitute(threshold=3, opacity=0.5, title="{glmfolder}{subject}_{session}_task-{task}_space-{space}_{runlab}_{contrast}_zmap".\
                                    format(glmfolder=glm_folder,subject=subject, session=session, task=task,space=space,contrast=contrast, runlab=runlab), 
                                 cut_coords=[36, -27, 66])
        bsprite.fit(z_map, bg_img=anat_bgimg)

        import tempita
        #/Users/penny/.pyenv/versions/3.9.5/lib/python3.9/site-packages/brainsprite/data/html/viewer_template.html
        file_template = '/Users/penny/.pyenv/versions/3.9.5/lib/python3.9/site-packages/brainsprite/data/html/viewer_template.html'
        template = tempita.Template.from_filename(file_template, encoding="utf-8")
        viewer = bsprite.transform(template, javascript='js', html='html', library='bsprite')
        viewer.save_as_html('{glmfolder}{subject}_{session}_task-{task}_space-{space}_{runlab}_{contrast}_zmap.html'.\
                            format(glmfolder=glm_folder, subject=subject, session=session, task=task, space=space, contrast=contrast, runlab=runlab))
        
        bsprite = viewer_substitute(opacity=0.5, title="{glmfolder}{subject}_{session}_task-{task}_space-{space}_{runlab}_{contrast}_fdrmap".\
                                    format(glmfolder=glm_folder,subject=subject, session=session, task=task,space=space,contrast=contrast, runlab=runlab), 
                                 cut_coords=[36, -27, 66])
        bsprite.fit(fdr_map, bg_img=anat_bgimg)

        import tempita
        #/Users/penny/.pyenv/versions/3.9.5/lib/python3.9/site-packages/brainsprite/data/html/viewer_template.html
        file_template = '/Users/penny/.pyenv/versions/3.9.5/lib/python3.9/site-packages/brainsprite/data/html/viewer_template.html'
        template = tempita.Template.from_filename(file_template, encoding="utf-8")
        viewer = bsprite.transform(template, javascript='js', html='html', library='bsprite')
        viewer.save_as_html('{glmfolder}{subject}_{session}_task-{task}_space-{space}_{runlab}_{contrast}_fdr_map.html'.\
                            format(glmfolder=glm_folder, subject=subject, session=session, task=task, space=space, contrast=contrast, runlab=runlab))


