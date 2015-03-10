#!/usr/bin/python

# filename: fibertrack_subs.py
# this script loops over subjects to perform fiber tracking using the mrtrix command tckgen

# see here for more info on tckgen: https://github.com/jdtournier/mrtrix3/wiki/tckgen


import os,sys

mainDir = '/Users/Kelly/dti/data'		# experiment main data directory

# subjects = ['sa01','sa07','sa10','sa11','sa13','sa14','sa16','sa18',
# 	'sa19','sa20','sa21','sa22','sa23','sa24','sa25','sa26','sa27',
# 	'sa28','sa29','sa30','sa31','sa32','sa33','sa34'] # subjects to process
subjects = ['sa13']
	

##########################################################################################
# EDIT AS NEEDED:


# define these directories relative to the subject's main directory: 
inDir = 'dti96trilin/bin'			# directory w/in diffusion data and b-gradient file and mask
roiDir = 'ROIs' 					# directory w/ROIs
outDir = 'fibers/mrtrix'			# directory for saving out fiber file

# these should be defined: 
infile = 'CSD8.mif'					# tensor or CSD file 
alg = 'SD_Stream'					# will do iFOD2 by default
gradfile = 'b_file' 				# b-gradient encoding file in mrtrix format
maskfile = 'brainMask.nii.gz' 		# this should be included

# define ROIs 
seedStr = 'DA'						# if false, will use the mask as seed ROI by default
roi2Strs = ['nacc','caudate','putamen']		# can be many or none; if not defined, fibers will just be tracked from the seed ROI

# fiber tracking options; leave blank or comment out to use defaults:
number = '1000'						# number of tracks to produce
maxnum = str(int(number)*1000)		# max number of candidate fibers to generate (default is number x 100)
maxlength = ''						# max length (in mm) of the tracks
stop = True							# stop track once it has traversed all include ROIs
step_size = ''						# define step size for tracking alg (in mm); default is .1* voxel size
cutoff = ''							# determine FA cutoff value for terminating tracks (default is .1)



##########################################################################################
# DO IT 
	
	
# now loop through subjects
for subject in subjects:
	
	print 'WORKING ON SUBJECT '+subject

	subjDir = os.path.join(mainDir,subject)
	os.chdir(subjDir)
	
	for roi in roi2Strs:
		
# 		outfile = seedStr+'_'+roi+'.tck' 
		outfile = roi+'.tck' 			 # name out file based on roi string
	
		cmd = 'tckgen'
		if alg:
			cmd = cmd+' -algorithm '+alg
		if gradfile: 
			cmd = cmd+' -grad '+os.path.join(inDir,gradfile)
		if maskfile: 
			cmd = cmd+' -mask '+os.path.join(inDir,maskfile)
		if seedStr:
			cmd = cmd+' -seed_image '+os.path.join(roiDir,seedStr+'.nii.gz')
		if roi:
			cmd = cmd+' -include '+os.path.join(roiDir,roi+'.nii.gz')
		if number:
			cmd = cmd+' -number '+str(number)
		if maxnum:
			cmd = cmd+' -maxnum '+str(maxnum)
		if maxlength:
			cmd = cmd+' -maxlength '+str(maxlength)
		if stop:
			cmd = cmd+' -stop'
		if step_size:
			cmd = cmd+' -step '+str(step_size)
		if cutoff:
			cmd = cmd+' -cutoff '+str(cutoff)
		cmd = cmd+' -info '+os.path.join(inDir,infile)+' '+os.path.join(outDir,outfile)
		print cmd
		os.system(cmd)		

		
	print 'FINISHED SUBJECT '+subject
			




