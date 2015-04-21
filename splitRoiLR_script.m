
% define variables, directories, etc.
clear all
close all

subjects=getDTISubjects;
dataDir = '/Users/Kelly/dti/data';
roiStr = 'DA'; 


%% 

for i=1:numel(subjects)

cd(fullfile(dataDir,subjects{i},'ROIs'))

roi = readFileNifti([roiStr '.nii.gz'])

[i j k]=ind2sub(size(roi.data),find(roi.data));
xyz_coords=mrAnatXformCoords(roi.qto_xyz,[i j k]); x = xyz_coords(:,1);

% x-coords <=0 are left; >=0 are right 
fprintf(['there will be ' num2str(length(find(x==0))) ...
    ' overlapping voxels in L and R rois\n']);

l_ijk = [i(x<=0),j(x<=0),k(x<=0)]; % left roi coords
l_idx=sub2ind(size(roi.data),l_ijk(:,1),l_ijk(:,2),l_ijk(:,3));
r_ijk = [i(x>=0),j(x>=0),k(x>=0)]; % right roi coords
r_idx=sub2ind(size(roi.data),r_ijk(:,1),r_ijk(:,2),r_ijk(:,3));

outvol = zeros(size(roi.data)); % new vol of all zeros

% make left roi nii
l_vol = outvol; l_vol(l_idx)=1;
l_roi = createNewNii(roi,[roiStr '_L'],'',l_vol);
writeFileNifti(l_roi); 
roiNiftiToMat(l_roi.fname,[roiStr '_L']);

% make right roi nii
r_vol = outvol; r_vol(r_idx)=1;
r_roi = createNewNii(roi,[roiStr '_R'],'',r_vol);
writeFileNifti(r_roi); 
roiNiftiToMat(r_roi.fname,[roiStr '_R']);



end % subjects 





% some day, make this into a function using the template below: 
% function
% -------------------------------------------------------------------------
% usage: say a little about the function's purpose and use here
% 
% INPUT:
%   var1 - integer specifying something
%   var2 - string specifying something
% 
% OUTPUT:
%   var1 - etc.
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 18-Mar-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%