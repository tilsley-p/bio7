# BIO7
## About
---
We study the visual and cognitive system and their interaction with multiple sclerosis.</br>
In this repository is kept all codes allowing us to run the experiments and analyse our dataset [OpenNeuro:DSXXXXX](https://openneuro.org/datasets/dsXXXX).</br>

---
## Authors:
---
Penelope Tilsley, Mihaela Nicolescu, Martin Szinte & Jan-Patrick Stellmann

### Main dependencies
---
[PyDeface](https://github.com/poldracklab/pydeface); 
[fMRIprep](https://fmriprep.org/en/stable/); 
[pRFpy](https://github.com/VU-Cog-Sci/prfpy); 
[pybest](https://github.com/lukassnoek/pybest);
[FreeSurfer](https://surfer.nmr.mgh.harvard.edu/)
[Psychtoolbox](http://psychtoolbox.org/)
</br>

### To do

- [ ] mih jps participants tsv redcap > sourcedata 
- [ ] penny: create backup utility function
- [ ] penny: write readme Face task launching instructions
- [ ] penny: do drawio of structural and functional preprocessing
- [ ] penny: adapt preproc_end
- [ ] martin: code pycortex stuffs (be carefull with submillimiter problem)
- [ ] martin: code pRF analysis

## Experiments
---
### Resting state task

### Retinotopy task
- To lauch the code: [expLauncher.m](experiment_code/prfexp7t/main/expLauncher.m)
  - to run use Matlab and Psychtoolbox
  - at first execution, generate the noise pattern stimuli by putting const.genStimuli to 1 (line 48)

### Face task

## Data analysis
---

### Utilities
- [x] utility function to correct file permissions [permission.py](analysis_code/utils/permission.py)
- [ ] Run Locally: backup mesocentre project folder to server [backup_mesocentre.py](analysis_code/utils/backup_mesocentre.py)

### Pre-processing

#### Transfer Data
- [ ] Run Locally Manip Laptop: copy behavioural fMRI data to mesocentre [transfer_beh.py](analysis_code/preproc/transferdata/transfer_beh.py)
- [ ] Run Locally: Copy clinical RedCap data to mesocentre [transfer_clin.py](analysis_code/preproc/transferdata/transfer_clin.py)
- [x] move events files of retin task in BIDS folder [beh_events.py](analysis_code/preproc/bids/beh_events.py)
- [x] create events files of face task with R [events_faces.py](analysis_code/preproc/bids/beh_events_faces.py)
- [x] create events files of faceloc task with R [events_faceloc.py](analysis_code/preproc/bids/events_faceloc.py)
- [X] update events files of resting task [events_resting.py](analysis_code/preproc/bids/events_resting.py)

#### BIDS
See: [preproc_bids.drawio](analysis_code/preproc/bids/preproc_bids.drawio)
- [x] copy dicoms to mesocentre [dicom2mesocentre.py](analysis_code/preproc/bids/dicom2mesocentre.py)
- [x] check over dicoms [dicom_editor.py](analysis_code/preproc/bids/dicom_editor.py)
- [x] convert dicom to tar and delete dicoms from mesocentre [dicom2tar.py](analysis_code/preproc/bids/dicom2tar.py)
- [x] create bids dataset from tar files [tar2bids.py](analysis_code/preproc/bids/tar2bids.py) (calls bids organisation in [bids_heuristic_file_bio7.py](analysis/code/preproc/bids/bids_heuristic_file_bio7.py))
- [x] edition of json files for tasks and anonymysation [json_editor.py](analysis_code/preproc/bids/json_editor.py)
- [x] update participants.tsv [tsv_editor.py](analysis_code/preproc/bids/tsv_editor.py)
- [x] background deletion of T1w images [presurfer.py](analysis_code/preproc/anatomical/run_presurfer.py) (calls [org_presurfer.py](analysis_code/preproc/bids/beh_events.py))
- [x] deface participants anatomical image [deface_sbatch.py](analysis_code/preproc/bids/deface_sbatch.py)
- [x] BIDS validation : [BIDS validator website](https://bids-standard.github.io/bids-validator/) or [bids_validation.py](analysis_code/preproc/bids/bids_validation.py)

#### Structural preprocessing
See: [preproc_anatomical.drawio](analysis_code/preproc/anatomical/preproc_anatomical.drawio)
- [x] Run Locally: manual definition of lesions using ITKsnap [lesion_edits.py](analysis_code/preproc/anatomical/lesion_edits.py)
- [x] fMRIprep with anat-only [fmriprep_anatonly.py](analysis_code/preproc/anatomical/fmriprep_anatonly.py)
- [x] create sagital view video before and after manual edit [sagital_view.py](analysis_code/preproc/anatomical/sagital_view.py)
- [x] Run Locally: manual edit of brain segmentation [pial_edits.sh](analysis_code/preproc/anatomical/pial_edits.py)
- [x] create sagital view video before and after manual edit [sagital_view.py](analysis_code/preproc/anatomical/sagital_view.py)
- [x] re-run freesurfer to include the manual change of the pial surface: [freesurfer_pial.py](analysis_code/preproc/anatomical/freesurfer_pial.py)
- [ ] cut the brain and flatten it [to_be_define_soon](/asdasd/)
- [ ] create pycortex dataset [to_be_define_soon](/asdasd/)

#### Functional preprocessing
See: [preproc_functional.drawio](analysis_code/preproc/anatomical/preproc_functional.drawio)
- [x] fMRIprep for functional preprocessing [fmriprep_functional.py](analysis_code/preproc/functional/fmriprep_functional.py)
- [ ] high-pass, z-score, average and leave-one-out average [preproc_end.py](analysis_code/preproc/functional/preproc_end.py)

### Post-processing

#### GLM analysis
- to be defined later
- idea : https://fitlins.readthedocs.io/en/latest/usage.html

#### PRF analysis
- [ ] copy from stereo_prf