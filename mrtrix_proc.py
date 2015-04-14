# mrtrix3 commands module

# filename: mrtrix3_proc.py

# this module is designed to define mrtrix commands that can be called from the batch 
# script, mrtrix3_proc_run.py

# see here for more info on mrtrix3: https://github.com/jdtournier/mrtrix3/wiki/Tutorial-DWI-processing


##########################################################################################


# estimate response function
# for more info: https://github.com/jdtournier/mrtrix3/wiki/dwi2response
dwi2response <Input DWI> <Output response text file> -mask <Input DWI mask>	

# estimate fiber orientation distribution 
# for more info: https://github.com/jdtournier/mrtrix3/wiki/dwi2fod
dwi2fod <Input DWI> <Input response text file> <Output FOD image> -mask <Input DWI mask>

# whole-brain tractography
# for more info: https://github.com/jdtournier/mrtrix3/wiki/tckgen
tckgen <Input FOD image> <Output track file> -seed_image <Input DWI mask> -mask <Input DWI mask> -number <Number of tracks>

# track density imaging 
# for more info: https://github.com/jdtournier/mrtrix3/wiki/tckmap
tckmap <Input track file> <Output TDI> -vox <Voxel size in mm>

	
	
	
	
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
			




