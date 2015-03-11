#!/usr/bin/python

# filename: mrtrix3_proc_run.py
# script to loop over subjects to process diffusion weighted data using mrtrix3 commands

# see here for more info on mrtrix3: https://github.com/jdtournier/mrtrix3/wiki/Tutorial-DWI-processing

import os
import sys
import glob   # for getting files from a directory using a wildcard 
	

##########################################################################################
# EDIT AS NEEDED:

mainDir = '/Users/Kelly/dti/data'		# experiment main data directory

# subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
# 	'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa26','sa27',
# 	'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process
subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
	'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa27',
	'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process

#subjects = ['sa26']


# estimate response function? for more info: https://github.com/jdtournier/mrtrix3/wiki/dwi2response
doEstimateResponseFxn = True

# estimate fiber orientation distribution? for more info: https://github.com/jdtournier/mrtrix3/wiki/dwi2fod
doEstimateFOD = True	

# do fiber tractography? for more info: https://github.com/jdtournier/mrtrix3/wiki/tckgen
doTrackFibers = False			

# do fiber desnsity? for more info: https://github.com/jdtournier/mrtrix3/wiki/tckmap
doFiberDensity = False


# variables necessary for estimating the response function and FOD
gradfile = 'dti96trilin/bin/b_file'  					# b-vecs and b-vals file in mrtrix format
maskfile = 'dti96trilin/bin/brainMask.nii.gz' 	# binary brain mask
lmax = '6'										# max harmonic degree of the response fxn 
dwifilestr = 'raw_dti/*_aligned_trilin.nii.gz' 	# preprocessed dwi data - its ok to use wildcards here
respfile = 'dti96trilin/bin/response'+str(lmax)	# name for response file
FODfile = 'dti96trilin/bin/CSD'+str(lmax)+'.mif'				# name for FOD file

# variables necessary for doing whole-brain fiber tracking 
ft_input = FODfile					# tensor or CSD file 
alg = 'SD_Stream'					# will do iFOD2 by default
num_fibers = 300000					# number of fiber tracts to generate 
ft_file = 'fibers/mrtrix/wb.tck' # filename for whole-brain fiber tracks file

# variables necessary for making fiber density maps 
fd_input = ft_file					# define fiber .tck file to compute density from
templatefile = 't1_fs.nii.gz'		# template file for bounding box and transform
vox_size = '1'						# isotropic voxel size (in mm)
fd_file = 'fibers/mrtrix/wb_fd.nii.gz' # out fiber density file

##########################################################################################
# DO IT 


# now loop through subjects
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	subjDir = os.path.join(mainDir,subject)
	os.chdir(subjDir)
	
	# get this subject's processed diffusion-weighted data file
	dwifilelist = glob.glob(dwifilestr)
	if len(dwifilelist)!=1:
		print 'yikes! either raw data file wasn''t found or more than 1 was found'
	else:
		dwifile=dwifilelist[0]
			
	
	# estimate response function
	if doEstimateResponseFxn:	
		cmd = 'dwi2response -grad '+gradfile+' -mask '+maskfile+' -lmax '+str(lmax)+' '+dwifile+' '+respfile
		print 'command for estimating response function: '
		print cmd
 		os.system(cmd)		

	# estimate FOD
	if doEstimateFOD:
		cmd = 'dwi2fod -grad '+gradfile+' -mask '+maskfile+' '+dwifile+' '+respfile+' '+FODfile
		print 'command for estimating fiber orientation distribution: '
		print cmd
 		os.system(cmd)		

	# whole-brain tractography
	if doTrackFibers:
		cmd = 'tckgen -algorithm '+alg+' -grad '+gradfile+' -mask '+maskfile+' -seed_image '+maskfile+' -number '+str(num_fibers)+' '+ft_input+' '+ft_file
		print 'command for fiber tracking: '
		print cmd
 		os.system(cmd)		
		
	# fiber density imaging
	if doFiberDensity:
		cmd = 'tckmap -template '+templatefile+' vox '+vox_size+' '+ft_file+' '+fd_file
		print 'command for fiber density mapping: '
		print cmd
		os.system(cmd)		
		
	print 'FINISHED SUBJECT '+subject
			




