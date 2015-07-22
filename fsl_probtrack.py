#!/usr/bin/python

# filename: fsl_proc.py
# script to run probtrack2 dti analyses using fsl utility probtrack2
# assumes fsl_proc.py has already been run 

# also, matlab function 'roiFormatForProbtrack' must already have been run for 
# all seed and target rois

# see here for more info on fsl's diffusion processing software: 
# http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide

import os
import sys
import glob   # for getting files from a directory using a wildcard 
	

###############################################################################
# EDIT AS NEEDED:

mainDir = '/Users/Kelly/dti/data'		# experiment main data directory

subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
	'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa26','sa27',
	'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process



fsl_subj_dir = 'fsl_dti' # fsl directory relative to subject's main dir

# name of directory for results of this analysis. 
# Dir must contain 'targetList' text file specifying the target roi filepaths
ptDirName = 'striatum_naccdilR'

# define roi mask file to use as a seed mask
seedFile = 'DA_sn_binary_maskR.nii.gz'

# use the same seed mask for all subs? If true, define seedFilePath here. 
# If false, seedFilePath will be defined for each subj in the loop below.
useGroupSeedMask = True 
seedFilePath = mainDir+'/group_sn/ROIs/fsl/'+seedFile
	
space = 'std' # must be either diff, str (t1 native space), or std

# define xform and inverse xform files (path is defined in subj loop)
xfFile = 'standard2diff_warp.nii.gz' 
invxfFile = 'diff2standard_warp.nii.gz'


xMaskFilePath = mainDir+'/group_sn/ROIs/fsl/X_mask_R.nii.gz'


###############################################################################
# DO IT 


# now loop through subjects
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	subjDir = os.path.join(mainDir,subject)
	os.chdir(subjDir)
	
	# define relevant directories and file paths
	bpDir = subjDir+'/fsl_dti/dwi.bedpostX/'  	#  bedpost dir
	ptDir = subjDir+'/fsl_dti/probtrackx/'+space+'/'+ptDirName # probtrackx dir
	targetList = ptDir+'/targetList'
	xfPath = bpDir+'xfms/'+xfFile
	invxfPath = bpDir+'xfms/'+invxfFile
	
	# if using subj-specific seed masks, define the filepath here
	if not useGroupSeedMask:
		seedFilePath = subjDir+'/fsl_dti/ROIs/'+space+'/'+seedFile
			
	cmd = 'probtrackx2 ' \
		+ '-s '+bpDir+'merged ' \
		+ '-m '+bpDir+'nodif_brain_mask ' \
		+ '-x '+seedFilePath+' ' \
		+ '-o fdt_paths ' \
		+ '--os2t ' \
		+ '--opd ' \
		+ '-l ' \
		+ '--targetmasks='+targetList+' ' \
		+ '--xfm='+xfPath+' ' \
		+ '--invxfm='+invxfPath+' ' \
		+ '--dir='+ptDir+' ' \
		+ '--forcedir ' \
		+ '--avoid='+xMaskFilePath
	print(cmd)
	os.system(cmd)
			
	os.chdir(ptDir)		 # now do find_the_biggest command
	cmd = 'find_the_biggest seeds_to* biggest'
	os.system(cmd)
		
	print 'FINISHED SUBJECT '+subject
			



