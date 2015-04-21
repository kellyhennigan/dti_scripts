function makeFSLROI(fileName)
% This function fixes the header of the NIFTI file made in ITK gray 
% and saves a new ROI file with fsl compatible header data and saves 
% a new file as filename_FSL.nii.gz
%
%EXAMPLE:  dtiFixITKGrayHeader('ROI1.nii.gz'); outputs 'ROI1_FSL.nii.gz'
%
% kjh 1/31/11

%% 
% Read the Nifti Files
ni = readFileNifti(fileName);

%Fix Headers

% append _FSL to file name
ni.fname = strcat(fileName,'_FSL');
strIndx = strfind(ni.fname, '.nii.gz');
ni.fname = strcat(ni.fname(1:strIndx-1), '_FSL.nii.gz');

% change this stuff
ni.data = int16(ni.data);
ni.scl_slope = 0;
ni.cal_max = 4;
ni.intent_code = 1002;
ni.aux_file = 'Red-Yellow';

%generate new file
writeFileNifti(ni);

return