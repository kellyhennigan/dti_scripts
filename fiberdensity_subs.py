#!/usr/bin/python

# filename: fiberdensity_subs.py
# script to loop over subjects to compute fiber density for some tracks

# see here for more info: https://github.com/jdtournier/mrtrix3/wiki/tckmap

import os,sys

mainDir = '/Users/Kelly/dti/data'		# experiment main data directory

# subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
# 	'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa26','sa27',
# 	'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process
subjects = ['sa01']
	

##########################################################################################
# EDIT AS NEEDED:


# define these directories relative to the subject's main directory: 
inDir = 'fibers/mrtrix'			# directory that has fiber .tck files
outDir = 'fibers/mrtrix'	    # directory to save out fiber density files to

# these should be defined: 
inFibers = ['nacc','caudate','putamen']	# strings defining in .tck files


# options; leave blank or comment out to use mrtrix defaults: 
template = 't1/t1_fs.nii.gz'		# template file for bounding box and transform
vox_size = '1'						# isotropic voxel size (in mm)
# contrast = 'tdi'					# contrast for output image; default is tdi (track density image)
# stat_vox = 'sum'					# statistic for choosing the final voxel intensities; default is sum; mean can also be used
# ends_only = true					# if true, fiber density maps will only reflect fiber endpoints


##########################################################################################
# DO IT 
	
	tckmap -template ../../t1/t1_fs.nii.gz -vox 1 -contrast tdi -stat_vox sum DA_nacc.tck DA_nacc_fd.nii.gz
	
# now loop through subjects
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	subjDir = os.path.join(mainDir,subject)
	os.chdir(subjDir)
		
	for fg in inFibers:
	
		cmd = 'tckmap'
		if template:
			cmd = cmd+' -template '+template
		if vox_size:
			cmd = cmd+' -vox '+str(vox_size)
		if contrast:
			cmd = cmd+' -contrast '+contrast
		if stat_vox:
			cmd = cmd+' -stat_vox '+stat_vox
		if ends_only:
			cmd = cmd+' -ends_only'
		cmd = cmd+' -info '+os.path.join(inDir,fg+'.tck')+' '+os.path.join(outDir,fg+'_fd.nii.gz')
		print cmd
		os.system(cmd)		

		
	print 'FINISHED SUBJECT '+subject
			




