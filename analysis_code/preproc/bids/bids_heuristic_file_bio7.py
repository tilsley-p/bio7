import os, re

def create_key(template, outtype=('nii.gz'), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return (template, outtype, annotation_classes)

def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where

    allowed template fields - follow python string module:

    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """

    #MP2RAGE
    inv1_mp2rage_m = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_inv-1_run-{item:02d}_part-mag_MP2RAGE')
    inv2_mp2rage_m = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_inv-2_run-{item:02d}_part-mag_MP2RAGE')
    inv1_mp2rage_p = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_inv-1_run-{item:02d}_part-phase_MP2RAGE')
    inv2_mp2rage_p = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_inv-2_run-{item:02d}_part-phase_MP2RAGE')    
    uni_mp2rage    = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-UNI_run-{item:02d}_MP2RAGE')    
    t1w            = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-MP2RAGE_run-{item:02d}_T1w')
    t1map          = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-MP2RAGE_run-{item:02d}_T1map')

    #MPRAGE
    mprage       = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-MPRAGE_run-{item:02d}_T1w')
    mprage_epsi  = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-MPRAGE_rec-EPSI_run-{item:02d}_T1w')
    mprage_dis3D = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-MPRAGE_rec-DIS3D_run-{item:02d}_T1w')

    #FLAWS
    inv1_flaws_m = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_inv-1_run-{item:02d}_part-mag_FLAWS')
    inv2_flaws_m = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_inv-2_run-{item:02d}_part-mag_FLAWS')
    inv1_flaws_p = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_inv-1_run-{item:02d}_part-phase_FLAWS')
    inv2_flaws_p = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_inv-2_run-{item:02d}_part-phase_FLAWS')    
    uni_flaws    = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-UNI_run-{item:02d}_FLAWS')    
    t1w_flaws    = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-FLAWS_run-{item:02d}_T1w')
    t1map_flaws  = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-FLAWS_run-{item:02d}_T1map')    
    flaws        = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-FLAWS_run-{item:02d}_FLAWS') 

    #ME-GRE
    me_gre_m = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_run-{item:02d}_echo_part-mag_MEGRE') 
    me_gre_p = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_run-{item:02d}_echo_part-phase_MEGRE')

    #DWI
    dwi_ap       = create_key('{bids_subject_session_dir}/dwi/{bids_subject_session_prefix}_dir-{dir}_run-{item:02d}_dwi')
    dwi_pa       = create_key('{bids_subject_session_dir}/dwi/{bids_subject_session_prefix}_dir-{dir}_run-{item:02d}_dwi')
    dwi_b0_pa    = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-dwib0_dir-{dir}_run-{item:02d}_epi')
    dwi_b0_ap    = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-dwib0_dir-{dir}_run-{item:02d}_epi')
    
    #DSI
    dsi_ONRight_rl      = create_key('{bids_subject_session_dir}/dwi/{bids_subject_session_prefix}_acq-ONright_dir-{dir}_run-{item:02d}_dwi')
    dsi_ONRight_b0_lr    = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-ONrightb0_dir-{dir}_run-{item:02d}_epi')
    dsi_ONLeft_rl      = create_key('{bids_subject_session_dir}/dwi/{bids_subject_session_prefix}_acq-ONleft_dir-{dir}_run-{item:02d}_dwi')
    dsi_ONLeft_b0_lr    = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-ONleftb0_dir-{dir}_run-{item:02d}_epi')
    
    
    #BOLD
    resting_lr      = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-resting_dir-{dir}_run-{item:02d}_epi')
    resting_rl      = create_key('{bids_subject_session_dir}/func/{bids_subject_session_prefix}_task-resting_dir-{dir}_run-{item:02d}_bold')
    
    retin_ap      = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-retin_dir-{dir}_run-{item:02d}_epi')
    retin_pa      = create_key('{bids_subject_session_dir}/func/{bids_subject_session_prefix}_task-retin_dir-{dir}_run-{item:02d}_bold')

    faces_lr      = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-faces_dir-{dir}_run-{item:02d}_epi')
    faces_rl      = create_key('{bids_subject_session_dir}/func/{bids_subject_session_prefix}_task-faces_dir-{dir}_run-{item:02d}_bold')
    
    faceloc_rl      = create_key('{bids_subject_session_dir}/func/{bids_subject_session_prefix}_task-faceloc_dir-{dir}_run-{item:02d}_bold')
    
    #SPACE
    t2           = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-SPACE_run-{item:02d}_T2w')
    flair        = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-SPACE_run-{item:02d}_FLAIR')

    #TSE
    tse          = create_key('{bids_subject_session_dir}/anat/{bids_subject_session_prefix}_acq-TSE_run-{item:02d}_T2w')

    #FMAP
    fmap_b1_m    = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-anat_run-{item:02d}_TB1TFL')
    fmap_b1_p    = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-famp_run-{item:02d}_TB1TFL')
    fmap_epi_ap  = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_task-rest_dir-{dir}_run-{item:02d}_epi')
    fmap_epi_pa  = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_task-rest_dir-{dir}_run-{item:02d}_epi')
    fmap_gre_p   = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-gre_run-{item:02d}_phasediff')
    fmap_gre_m   = create_key('{bids_subject_session_dir}/fmap/{bids_subject_session_prefix}_acq-gre_run-{item:02d}_magnitude')

    #SODIUM
    na_modspokes = create_key('{bids_subject_session_dir}/sodium/{bids_subject_session_prefix}_acq-23Na_run-{item:02d}_echo_modspokes')
    na_b0b1_m    = create_key('{bids_subject_session_dir}/sodium/{bids_subject_session_prefix}_acq-23Na_run-{item:02d}_echo_part-mag_B0B1map')
    na_b0b1_r    = create_key('{bids_subject_session_dir}/sodium/{bids_subject_session_prefix}_acq-23Na_run-{item:02d}_echo_part-real_B0B1map')

    info = {inv1_mp2rage_m:[],
            inv2_mp2rage_m:[],
            inv1_mp2rage_p:[],
            inv2_mp2rage_p:[],            
            uni_mp2rage:[],            
            t1w:[],
            t1map:[],

            mprage:[],mprage_epsi:[],mprage_dis3D:[],

            inv1_flaws_m:[],
            inv2_flaws_m:[],
            inv1_flaws_p:[],
            inv2_flaws_p:[],            
            uni_flaws:[],            
            t1w_flaws:[],
            t1map_flaws:[],
            flaws:[],

            me_gre_m:[],
            me_gre_p:[],

            t2:[],flair:[],tse:[],

            dwi_ap:[],dwi_pa:[],
            dwi_b0_ap:[],dwi_b0_pa:[],
            dsi_ONRight_rl:[], dsi_ONRight_b0_lr:[],
            dsi_ONLeft_rl:[], dsi_ONLeft_b0_lr:[],
            resting_lr:[],resting_rl:[],
            retin_ap:[],retin_pa:[],
            faces_lr:[],faces_rl:[],
            faceloc_rl:[],
            
            fmap_b1_m:[],fmap_b1_p:[],
            fmap_epi_ap:[],fmap_epi_pa:[],
            fmap_gre_p:[],fmap_gre_m:[],

            na_modspokes:[], na_b0b1_m:[], na_b0b1_r:[]
    }

    for idx, s in enumerate(seqinfo):
        #MP2RAGE
        if ('mp2rage' in (s.series_description).lower()):
            if ('inv1' in (s.series_description).strip().lower()):
                if ('phs' in (s.series_description).strip().lower()):
                    info[inv1_mp2rage_p].append({'item': s.series_id,'part':'phase'})
                else:
                    info[inv1_mp2rage_m].append({'item': s.series_id,'part':'mag'})
            if ('inv2' in (s.series_description).strip().lower()):
                if ('phs' in (s.series_description).strip().lower()):
                    info[inv2_mp2rage_p].append({'item': s.series_id,'part':'phase'})
                else:
                    info[inv2_mp2rage_m].append({'item': s.series_id,'part':'mag'})
            if ('uni_images' in (s.series_description).strip().lower()):
                info[uni_mp2rage].append({'item': s.series_id})
            if ('uniden' in (s.series_description).strip().lower()) and ('corrected' in (s.series_description).strip().lower()):
                info[t1w].append({'item': s.series_id})                                                
            if ('t1' in (s.series_description).strip().lower()) and ('map' in (s.series_description).strip().lower()):
                info[t1map].append({'item': s.series_id})

        #MPRAGE
        if bool(re.search('mprage[-sag|_sag]*', (s.series_description).lower())): #('mprage-sag' in (s.series_description).lower()):
            if ('ND' in s.image_type[3].strip()) and ('epsi' not in (s.series_description).lower()):
                info[mprage].append({'item': s.series_id})   
            if ('epsi' in (s.series_description).lower()):
                info[mprage_epsi].append({'item': s.series_id})                         
            if ('DIS3D' in s.image_type[4].strip()) :
                info[mprage_dis3D].append({'item': s.series_id})                         

       
        #FLAWS
        if ('flaws' in (s.series_description).strip().lower()):
            if ('inv1' in (s.series_description).strip().lower()):
                if ('phs' in (s.series_description).strip().lower()):
                    info[inv1_flaws_p].append({'item': s.series_id,'part':'phase'})
                else:
                    info[inv1_flaws_m].append({'item': s.series_id,'part':'mag'})
            if ('inv2' in (s.series_description).strip().lower()):
                if ('phs' in (s.series_description).strip().lower()):
                    info[inv2_flaws_p].append({'item': s.series_id,'part':'phase'})
                else:
                    info[inv2_flaws_m].append({'item': s.series_id,'part':'mag'})
            if ('uni_images' in (s.series_description).strip().lower()):
                info[uni_flaws].append({'item': s.series_id})
            if ('uni-den' in (s.series_description).strip().lower()):
                info[t1w_flaws].append({'item': s.series_id})                                                
            if ('t1_images' in (s.series_description).strip().lower()):
                info[t1map_flaws].append({'item': s.series_id})
            if ('FLAWS' in (s.series_description).strip()):
                info[flaws].append({'item': s.series_id})

        #ME-GRE
        if ('qsm2_separated' in (s.series_description).strip().lower()):
            if ('M' in s.image_type[2].strip()):
                info[me_gre_m].append({'item': s.series_id})
            if ('P' in s.image_type[2].strip()):
                info[me_gre_p].append({'item': s.series_id})

        #T2
        if ('t2_tse' in (s.series_description).strip().lower()):
            info[tse].append({'item': s.series_id})

        #Timeseries data
        #DWI
        if ('dti' in (s.series_description).lower()) or ('dti' in (s.series_description).strip().lower()):
            if (('DIFFUSION' in s.image_type[2]) and ('NONE' in s.image_type[3])):
                if ('ap' in (s.series_description).lower()):
                    if ('b0' in (s.series_description).lower()):
                        info[dwi_b0_ap].append({'item': s.series_id,'dir':'AP'})
                    else:
                        info[dwi_ap].append({'item': s.series_id,'dir':'AP'})
                elif ('pa' in (s.series_description).lower()):
                    if ('b0' in (s.series_description).lower()):
                        info[dwi_b0_pa].append({'item': s.series_id,'dir':'PA'})
                    else:
                        info[dwi_pa].append({'item': s.series_id,'dir':'PA'})
                        
        if ('dsi' in (s.series_description).lower()) or ('dsi' in (s.series_description).strip().lower()):
            if (('DIFFUSION' in s.image_type[2]) and ('NONE' in s.image_type[3])):
                if ('gauche' in (s.series_description).lower()):
                    if ('b0' in (s.series_description).lower()):
                        info[dsi_ONLeft_b0_lr].append({'item': s.series_id,'dir':'LR'})
                    else:
                        info[dsi_ONLeft_rl].append({'item': s.series_id,'dir':'RL'})
                elif ('droite' in (s.series_description).lower()):
                    if ('b0' in (s.series_description).lower()):
                        info[dsi_ONRight_b0_lr].append({'item': s.series_id,'dir':'LR'})
                    else:
                        info[dsi_ONRight_rl].append({'item': s.series_id,'dir':'RL'})
                                

        #BOLD (EPI)            
        elif ('ep2d' in (s.series_description).strip().lower()):

            #retinotopic mapping 
            if ('retin' in (s.series_description).strip().lower()):
                if ('boldpa' in (s.series_description).lower()) or ('bold_pa' in (s.series_description).lower()):
                    info[retin_pa].append({'item': s.series_id,'dir':'PA'})
                elif ('boldap' in (s.series_description).lower()) or ('bold_ap' in (s.series_description).lower()):
                    info[retin_ap].append({'item': s.series_id,'dir':'AP'})
                        
            #backwards masking - faces
            elif ('faces_' in (s.series_description).strip().lower()):
                if ('boldrl' in (s.series_description).strip().lower()) or ('bold_rl' in (s.series_description).strip().lower()):
                    info[faces_rl].append({'item': s.series_id,'dir':'RL'})
            
            #topup for faces tasks
            elif ('facest' in (s.series_description).strip().lower()):
                if ('boldlr' in (s.series_description).strip().lower()) or ('bold_lr' in (s.series_description).strip().lower()):
                    info[faces_lr].append({'item': s.series_id,'dir':'LR'})
                            
           # resting state
            elif ('rsfmri' in (s.series_description).strip().lower()):
                if ('boldrl' in (s.series_description).strip().lower()) or ('bold_rl' in (s.series_description).strip().lower()):
                    info[resting_rl].append({'item': s.series_id,'dir':'RL'})
                elif ('boldlr' in (s.series_description).strip().lower()) or ('bold_lr' in (s.series_description).strip().lower()):
                    info[resting_lr].append({'item': s.series_id,'dir':'LR'})
                        
           # faces loc
            elif ('facesloc' in (s.series_description).strip().lower()):
                if ('boldrl' in (s.series_description).strip().lower()) or ('bold_rl' in (s.series_description).strip().lower()):
                    info[faceloc_rl].append({'item': s.series_id,'dir':'RL'})

        #SPACE
        if ('space' in (s.series_description).strip().lower()):
            if ('spc3d' in (s.sequence_name).strip().lower()):
                info[t2].append({'item': s.series_id})
            elif ('spcirr3d' in (s.sequence_name).strip().lower()):
                info[flair].append({'item': s.series_id})
        if ('flair' in (s.series_description).strip().lower()):
            info[flair].append({'item': s.series_id})                            

        #FMAP
        if ('b1map' in (s.series_description).strip().lower()):
            if ('M' in s.image_type[2].strip()):
                info[fmap_b1_m].append({'item': s.series_id})
            if ('FLIP' in s.image_type[2].strip()):
                info[fmap_b1_p].append({'item': s.series_id})
        if ('ep-seg-se' in (s.series_description).lower()) or ('ep_seg_se' in (s.series_description).lower()):
            if ('ap' in (s.series_description).strip().lower()):
                info[fmap_epi_ap].append({'item': s.series_id,'dir':'AP'})
            if ('pa' in (s.series_description).strip().lower()):
                info[fmap_epi_pa].append({'item': s.series_id,'dir':'PA'})
        if ('gre_field_mapping' in (s.series_description).lower()) or ('gre_fieldmap' in (s.series_description).lower()):
            if ('M' in s.image_type[2].strip()):
                info[fmap_gre_m].append({'item': s.series_id})
            elif ('P' in s.image_type[2].strip()):
                info[fmap_gre_p].append({'item': s.series_id})

        #SODIUM
        if ('23na' in (s.series_description).strip().lower()) or ('sod' in (s.series_description).strip().lower()):
            if ('modified_spokes' in (s.series_description).strip().lower()):
                info[na_modspokes].append({'item': s.series_id})
            else:
                if ('M' in s.image_type[2].strip()):
                    info[na_b0b1_m].append({'item': s.series_id})
                if ('R' in s.image_type[2].strip()):
                    info[na_b0b1_r].append({'item': s.series_id})                    

    return info
