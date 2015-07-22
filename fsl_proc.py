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

subjects = ['sa10','sa24'] # subjects to process



# make an fsl directory w/symbolic links to dwi data? 
doInitFslDir = False

# run dtifit to estimate voxel tensors
doDtiFit = False

# do bedpostx for probablistic tracking and modeling crossing fibers?
doBedPostX = False

# do registration between diffusion, structural, and group structural spaces? 
# do this even if its already been done with spm because the fsl-formatted 
# xforms are needed for probtrack
doRegister = True




###############################################################################
# DO IT 


# now loop through subjects
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	subjDir = os.path.join(mainDir,subject)
	os.chdir(subjDir)
	
	# define subject's fsl directory 
	fslDir = os.path.join(subjDir,'fsl_dti/dwi')
	
	
	####################### initialize fsl directory #######################
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
	
	
	##################### run dtifit to estimate tensors ######################
	if doDtiFit: 
		cmd = 'dtifit -k data.nii.gz -o dti_fit -m nodif_brain_mask.nii.gz ' \
			+ '-r bvecs -b bvals'
		os.system(cmd)
		
		
	######################### run bedpostX ###########################
	if doBedPostX:
		cmd = 'bedpostx '+fslDir
		os.system(cmd)
		
	bpDir = fslDir+'.bedpostX/'  # define subj's bedpost dir 
			
			
	######################### registration ###########################
	if doRegister:
		diffFile = fslDir+'/nodif_brain.nii.gz'	# b0 file (no skull)
		t1File = subjDir+'/t1/t1_fs_bet.nii.gz'	# t1 file (no skull)
		t1File_w_skull = subjDir+'/t1/t1_fs.nii.gz'	# t1 file w/skull for fnirt
		gsFile = mainDir+'/templates/MNI_avg152_T1.nii'		# group space template
		xfDir = bpDir+'xfms/'				# xform directory 
		
		diff_strFile = xfDir+'diff_strspace' # name for diff data in native space
		str_stdFile = xfDir+'t1_sn' # name for diff data in native space
		diff_stdFile = xfDir+'diff_stdspace' # name for diff data in native space
				
		# diff 2 structural
		cmd = 'flirt -in '+diffFile+' -ref '+t1File+' ' \
			+ '-omat '+xfDir+'diff2str.mat ' \
			+ '-searchrx -90 90 -searchry -90 90 -searchrz -90 90 ' \
			+ '-dof 6 -cost corratio'
		print cmd	
		#os.system(cmd)
		
		# structural 2 diff
		cmd = 'convert_xfm ' \
			+ '-omat '+xfDir+'str2diff.mat ' \
			+ '-inverse '+xfDir+'diff2str.mat'
		print cmd	
		os.system(cmd)
	
		# structural 2 standard
		cmd = 'flirt -in '+t1File+' -ref '+gsFile+' ' \
			+ '-omat '+xfDir+'str2standard.mat ' \
			+ '-searchrx -90 90 -searchry -90 90 -searchrz -90 90 ' \
			+ '-dof 12 -cost corratio'
		print cmd	
		#os.system(cmd)
		
	
		# standard 2 structural 
		cmd = 'convert_xfm ' \
			+ '-omat '+xfDir+'standard2str.mat ' \
			+ '-inverse '+xfDir+'str2standard.mat'
		print cmd
		#os.system(cmd)
		
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
		

		# non-linear registration
		cmd = 'fnirt ' \
			+ '--in='+t1File_w_skull+' ' \
			+ '--aff='+xfDir+'str2standard.mat ' \
			+ '--cout='+xfDir+'str2standard_warp ' \
			+ '--config=T1_2_MNI152_2mm '
		print cmd	
	#	os.system(cmd)
		
		# invwarp 
		cmd = 'invwarp ' \
			+ '-w '+xfDir+'str2standard_warp ' \
			+ '-o '+xfDir+'standard2str_warp ' \
			+ '-r '+t1File
		print cmd
	#	os.system(cmd)
		
		# convertwarp 
		cmd = 'convertwarp ' \
			+ '-o '+xfDir+'diff2standard_warp ' \
			+ '-r '+gsFile+' ' \
			+ '-m '+xfDir+'diff2str.mat ' \
			+ '-w '+xfDir+'str2standard_warp '
		print cmd	
		os.system(cmd)
		
		# convertwarp 
		cmd = 'convertwarp ' \
			+ '-o '+xfDir+'standard2diff_warp ' \
			+ '-r '+bpDir+'nodif_brain_mask ' \
			+ '-w '+xfDir+'standard2str_warp ' \
			+ '--postmat='+xfDir+'str2diff.mat '
		print cmd	
		os.system(cmd)
		
		# apply xform to diff data > native space 
		cmd = 'flirt ' \
			+ '-in '+diffFile+' ' \
			+ '-ref '+t1File+' ' \
			+ '-applyxfm -init '+xfDir+'diff2str.mat ' \
			+ '-out '+diff_strFile
		print cmd	
		os.system(cmd)
	
		# apply xform ns t1 > standard group space 
		cmd = 'applywarp ' \
			+ '-i '+t1File+' ' \
			+ '-r '+gsFile+' ' \
			+ '-w '+xfDir+'str2standard_warp ' \
			+ '-o '+str_stdFile
		print cmd	
#		os.system(cmd)
		
		# apply xform to diff data > standard group space 
		cmd = 'applywarp ' \
			+ '-i '+diffFile+' ' \
			+ '-r '+gsFile+' ' \
			+ '-w '+xfDir+'diff2standard_warp ' \
			+ '-o '+diff_stdFile
		print cmd	
		os.system(cmd)
		
		cmd = 'fslview '+gsFile+' '+diff_stdFile+' -l "Red-Yellow" -t 1'
		print cmd	
		os.system(cmd)
		
	
	print 'FINISHED SUBJECT '+subject
			



