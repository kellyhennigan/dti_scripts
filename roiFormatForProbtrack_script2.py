#!/usr/bin/python

# filename: fsl_probtrack_prep.py
# script to set up ROIs for running probtrack

# see here for more info on fsl's diffusion processing software: 
# http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide

# 1) run fsl_proc
# 2) roiFormatForProbtrack_script
# 3) roiFormatForProbtrack_script2
# 4) fsl_probtrack

import os
import sys
import glob   # for getting files from a directory using a wildcard 
	

###############################################################################
# EDIT AS NEEDED:

mainDir = '/Users/Kelly/dti/data'		# experiment main data directory

subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
	'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa26','sa27',
	'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process



# roi files to xform into desired space for probtrack analysis
# roiFiles = ['DA_R.nii.gz','caudateR.nii.gz','naccR.nii.gz','putamenR.nii.gz',
# 	'DA_L.nii.gz','caudateL.nii.gz','naccL.nii.gz','putamenL.nii.gz',
# 	'dorsalstriatumL.nii.gz','dorsalstriatumR.nii.gz','DA.nii.gz']
roiFiles = ['naccR_dilated.nii.gz','naccL_dilated.nii.gz']

	
space = 'std' # must be either diff, str (t1 native space), or std


###############################################################################
# DO IT 


# now loop through subjects
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	subjDir = os.path.join(mainDir,subject)
	os.chdir(subjDir)
	
	# define subject specific directories
	fslDir = os.path.join(subjDir,'fsl_dti')
	fslRoiDir = os.path.join(fslDir,'ROIs')
	xfDir = os.path.join(fslDir,'dwi.bedpostX/xfms/')	# xform dir

	# make fsl_dti/ROI/[space] directory if it doesn't exist yet
	if not os.path.exists(os.path.join(fslRoiDir,space)):
		os.makedirs(os.path.join(fslRoiDir,space))

	# create roi masks in desired space if they don't already exist
	for roiFile in roiFiles: 
		roiInPath = os.path.join(fslRoiDir,'str',roiFile) # roi to be xformed
		roiOutPath = os.path.join(fslRoiDir,space,roiFile) # 
		if not os.path.exists(roiOutPath):
			if space=='std':	
				refNii = mainDir+'/templates/MNI_avg152_T1.nii'
				cmd = 'applywarp ' \
					+ '-i '+roiInPath+' ' \
					+ '-r '+refNii+' ' \
					+ '-w '+xfDir+'str2standard_warp ' \
					+ '-o '+roiOutPath
				print cmd	
				os.system(cmd)
			
			if space=='diff':	
				refNii = fslDir+'/dwi/nodif_brain.nii.gz'
				cmd = 'flirt ' \
					+ '-in '+roiInPath+' ' \
					+ '-ref '+refNii+' ' \
					+ '-applyxfm -init '+xfDir+'str2diff.mat ' \
					+ '-out '+roiOutPath
				print cmd	
				os.system(cmd)
				
			cmd = 'fslmaths '+roiOutPath+' -thr 0.2 -bin '+roiOutPath
			print cmd
			os.system(cmd)
			
	print 'FINISHED SUBJECT '+subject
			
			
	
	
			

