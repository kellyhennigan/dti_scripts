function roiFormatForProbtrack(roiInPath,refNii,roiOutPath)
% -------------------------------------------------------------------------
% usage: this function formats roi mask nifti files for running probtrackx
% this shouldn't have to be done normally - it's because the roi masks
% saved for each subject have the dimensions of 't1.nii.gz', whereas the
% str space for fsl takes the 't1_fs.nii.gz' dimensions

% INPUT:
%   roiInPath - roi nifti file
%   refNii - refnii w/the desired dimensions for the outRoi
%   roiOutPath - filepath for saving out roi w/refnii dimensions
%
% OUTPUT: will save out roiOutPath nifti file
%

% NOTES:

% author: Kelly, kelhennigan@gmail.com, 14-Jul-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

% input variable checks
if notDefined('roiInPath') || notDefined('refNii') || notDefined('roiOutPath')
    error('roiInPath, refNii, and roiOutPath must all be defined')
end

% if roiOutPath already exists, do nothing
if exist('roiOutPath','file')
    return
    
% otherwise, create the file
else
    
    roi = roiNiftiToMat(roiInPath); % get roi coords
    
    roi=roiMatToNifti(roi,refNii,0); % put the mask in refNii dimensions
    
    [pa,~]=fileparts(roiOutPath);
    if ~exist(pa,'dir')
        mkdir(pa);
    end
    
    roi.fname = roiOutPath; % save out roi according to roiOutPath
    roi.data = single(roi.data);
    writeFileNifti(roi);
    
end

end


