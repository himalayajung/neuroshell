#!/bin/bash 

# calculates estimated TIV, GM volume and WM volume from nifti image
# @author Gajendra Jung Katuwal


T_brain=${FSLDIR}/data/standard/MNI152_T1_1mm_brain

# vertical list of subjects name 
export SUBJECTSFILE=/Volumes/admi/Projects/ABIDE_Comparison_pipelines/subjectsfile
export SUBJECTS_DIR=/Volumes/admi/Projects/ABIDE_Comparison_pipelines/NYU_niigz #where subject images are stored

# skull stripped images
# BET_nifti=/Volumes/admi/Projects/ABIDE_Comparison_pipelines/FSL/FSLVBM/NYU_raw/struc/BET_nifti

## SKULL-STRIPPING  if it has not been done already
# Different combinations of BET options may work better depending on the images. The following is left as a suggestion
# that extracts the brain in two-steps, using FAST for an intemediate bias correction:
# echo "Brain Extraction"
# for subj_id in `cat $SUBJECTSFILE` ; do
# 		bet ${SUBJECTS_DIR}/${subj_id} ${SUBJECTS_DIR}/${subj_id}_braintmp -f 0.2

# 		fast -b --nopve ${SUBJECTS_DIR}/${subj_id}_braintmp

# 		fslmaths ${SUBJECTS_DIR}/${subj_id} -div ${SUBJECTS_DIR}/${subj_id}_braintmp_bias ${SUBJECTS_DIR}/${subj_id}_biascorrected

# 		bet ${SUBJECTS_DIR}/${subj_id}_biascorrected ${SUBJECTS_DIR}/${subj_id}_brain -f 0.3

# done

# # Once the images have been all skull-stripped, are named such as ${subj_id}_brain.nii.gz, and their quality have thoroughly been checked, 
# # then run the following loop to align to a standard brain and segment into gray and white matter:

# echo "FLIRT"
# for subj_id in `cat $SUBJECTSFILE` ; do
# 		flirt -in ${SUBJECTS_DIR}/${subj_id}_brain -ref ${T_brain} -omat ${SUBJECTS_DIR}/${subj_id}_brain_to_T_brain.mat

# 		fast ${SUBJECTS_DIR}/${subj_id}_brain

# done



## Calculate TIV using mat2det and create a  table
echo "mat2det ..writing table"
echo "subj_id,eTIV_FLIRT,FASTvol_noCSF" > global_size_FSL.csv
for subj_id in `cat $SUBJECTSFILE` ; do

		eTIV=`./mat2det.awk ${SUBJECTS_DIR}/${subj_id}_brain_to_T_brain.mat | awk '{ print $2 }'`

		volGM=`fslstats ${SUBJECTS_DIR}/${subj_id}_brain_pve_1 -V -M | awk '{ vol = $2 * $3 ; print vol }'`

		volWM=`fslstats ${SUBJECTS_DIR}/${subj_id}_brain_pve_2 -V -M | awk '{ vol = $2 * $3 ; print vol }'`

		voltissue=`expr ${volGM} + ${volWM}`

		echo "${subj_id},${eTIV},${voltissue}" >> global_size_FSL.csv

done
