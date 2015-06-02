#!/usr/bin/python

# filename: fsl_proc.py
# script to loop over subjects to process diffusion data in the fsl pipeline

# see here for more info on fsl's diffusion processing software: 
# http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide

import os
import sys
import glob   # for getting files from a directory using a wildcard 
	

###############################################################################
# EDIT AS NEEDED:

mainDir = '/Users/Kelly/dti/data'		# experiment main data directory

# subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
# 	'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa26','sa27',
# 	'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process

subjects = ['sa13']


# make an fsl directory w/symbolic links to dwi data? 
doInitFslDir = False

# run dtifit to estimate voxel tensors
doDtiFit = False

# do bedpostx for probablistic tracking and modeling crossing fibers?
doBedPostX = False

# do probtrackx analysis? note: make sure a targetList has been made first 
# w/ matlab script makeFSLProbtrackTargetFile_script)
doProbTrackX = True



###############################################################################
# DO IT 


# now loop through subjects
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	subjDir = os.path.join(mainDir,subject)
	os.chdir(subjDir)
	
	# define subject's fsl directory 
	fslDir = os.path.join(subjDir,'fsl_dti/dwi')
	
	
	# initialize fsl directory
	if doInitFslDir: 
		if not os.path.exists(fslDir):
			os.makedirs(fslDir)
		os.chdir(fslDir)
	
		# make symbolic links to preprocessed data, brainmask, bvecs/vals files
		cmd = 'ln -s ../../raw_dti/*aligned_trilin.nii.gz data.nii.gz'
		os.system(cmd)	
		cmd = 'ln -s ../../raw_dti/*aligned_trilin.bvecs bvecs'
		os.system(cmd)	
		cmd = 'ln -s ../../raw_dti/*aligned_trilin.bvals bvals'
		os.system(cmd)	
		cmd = 'ln -s ../../dti*trilin/bin/brainMask.nii.gz ' \
			+ 'nodif_brain_mask.nii.gz'
		os.system(cmd)	
	else: 
		os.chdir(fslDir)
	
	
	# run dtifit to estimate tensors, etc.
	if doDtiFit: 
		cmd = 'dtifit -k data.nii.gz -o dti_fit -m nodif_brain_mask.nii.gz ' \
			+ '-r bvecs -b bvals'
		os.system(cmd)
		
		
	# run dtifit to estimate tensors, etc.
	if doBedPostX:
		cmd = 'bedpostx '+fslDir
		os.system(cmd)
		
		
	if doProbTrackX:
		bpDir = fslDir+'.bedpostX'  # define subj's bedpost dir and cd to it
		os.chdir(bpDir)
 		for lr in ['L','R']:
			cmd = 'probtrackx2 ' \
				+ '-s merged ' \
				+ '-m nodif_brain_mask.nii.gz ' \
				+ '-x ../../ROIs/DA_'+lr+'.nii.gz ' \
				+ '-o fdt_paths ' \
				+ '--os2t ' \
				+ '--targetmasks=../probtrackx/striatum'+lr+'/targetList ' \
				+ '--dir=../probtrackx/striatum'+lr+' ' \
				+ '--forcedir'
			print(cmd)
			os.system(cmd)
		
		
	print 'FINISHED SUBJECT '+subject
			



