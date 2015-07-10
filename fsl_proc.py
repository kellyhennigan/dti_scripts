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

subjects = ['sa19']


# make an fsl directory w/symbolic links to dwi data? 
doInitFslDir = True

# run dtifit to estimate voxel tensors
doDtiFit = True

# do bedpostx for probablistic tracking and modeling crossing fibers?
doBedPostX = True

# do registration between diffusion, structural, and group structural spaces? 
# do this even if its already been done with spm because the fsl-formatted 
# xforms are needed for probtrack
doRegister = True

# do probtrackx analysis? note: make sure a targetList has been made first 
# w/ matlab script makeFSLProbtrackTargetFile_script)
doProbTrackX = False



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
		cmd = 'ln -s ../../dti*trilin/bin/b0_bet.nii.gz ' \
			+ 'nodif_brain.nii.gz'
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
		
	bpDir = fslDir+'.bedpostX'  # define subj's bedpost dir 
			
	# diffusion-structural-group registration 
	if doRegister:
		diffFile = bpDir+'/nodif_brain.nii.gz'	# b0 file (no skull)
		t1File = subjDir+'/t1/t1_fs_bet.nii.gz'	# t1 file (no skull)
		snFile = subjDir+'/t1/t1_sn.nii.gz'		# spatially normed t1 file (no skull)	
		xfDir = bpDir+'/xfms/'				# xform directory 
		
	
		# diff 2 structural
		cmd = 'flirt -in '+diffFile+' -ref '+t1File+' ' \
			+ '-omat '+xfDir+'diff2str.mat ' \
			+ '-searchrx -90 90 -searchry -90 90 -searchrz -90 90 ' \
			+ '-dof 6 -cost corratio'
		print cmd	
		os.system(cmd)
		
		# structural 2 standard
		cmd = 'flirt -in '+t1File+' -ref '+snFile+' ' \
			+ '-omat '+xfDir+'str2standard.mat ' \
			+ '-searchrx -90 90 -searchry -90 90 -searchrz -90 90 ' \
			+ '-dof 12 -cost corratio'
		print cmd	
		os.system(cmd)
		
		# structural 2 diff
		cmd = 'convert_xfm ' \
			+ '-omat '+xfDir+'str2diff.mat ' \
			+ '-inverse '+xfDir+'diff2str.mat'
		print cmd	
		os.system(cmd)
	
		# standard 2 structural 
		cmd = 'convert_xfm ' \
			+ '-omat '+xfDir+'standard2str.mat ' \
			+ '-inverse '+xfDir+'str2standard.mat'
		print cmd
		os.system(cmd)
		
		# diff 2 standard
		cmd = 'convert_xfm ' \
			+ '-omat '+xfDir+'diff2standard.mat ' \
			+ '-concat '+xfDir+'str2standard.mat '+xfDir+'diff2str.mat'
		print cmd
		os.system(cmd)
	
		# standard 2 diff
		cmd = 'convert_xfm ' \
			+ '-omat '+xfDir+'standard2diff.mat ' \
			+ '-inverse '+xfDir+'diff2standard.mat'
		print cmd	
		os.system(cmd)
		
		
	if doProbTrackX:
	
		#os.chdir(bpDir)
 		for lr in ['L','R']:
 			ptDir = os.path.join(subjDir,'fsl_dti/probtrackx/striatum'+lr)
			cmd = 'probtrackx2 ' \
				+ '-s '+bpDir+'/merged ' \
				+ '-m '+bpDir+'/nodif_brain_mask ' \
				+ '-x '+subjDir+'/ROIs/dti_space/DA_'+lr+'.nii.gz ' \
				+ '-o fdt_paths ' \
				+ '--os2t ' \
				+ '--opd ' \
				+ '-l ' \
				+ '--targetmasks='+ptDir+'/targetList ' \
				+ '--dir='+ptDir+' ' \
				+ '--forcedir'
			print(cmd)
 			os.system(cmd)
			
			os.chdir(ptDir)		 # now do find_the_biggest command
			cmd = 'find_the_biggest seeds_to* biggest'
			os.system(cmd)
		
	print 'FINISHED SUBJECT '+subject
			



