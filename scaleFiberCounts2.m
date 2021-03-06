function [fdImgsc,max_coord] = scaleFiberCounts2(fdImg)
% -------------------------------------------------------------------------
% usage: use this function to threshold and transform fiber count imgs.
% 
% INPUT:
%  fdImg - 3d matrix w/values specifying fiber counts per voxel
%   
% 
% OUTPUT:
%  fdImgsc - fdImg thresholded and scaled from [1 0] with 1 being the
%            voxel with the highest fiber count. 
%  max_coord - also returns a vector with the imgCoords of the voxel
%              with the highest value (will be 1), if desired. 
% 
% 
% 
% author: Kelly, kelhennigan@gmail.com, 22-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

% voxels with vals less than this % of the total # of fibers will be set to
% zero
thresh_percent_of_total = 0.2; 


if notDefined('fdImg') || numel(size(fdImg))~=3
    error('fdImg should be a 3d matrix');
end


%% 


% threshold fiber counts
vox_thresh = sum(fdImg(:)).*(thresh_percent_of_total./100);
fdImg(fdImg<vox_thresh) = 0;
  
        
% scale by sum of all values, then x 100 to make it percentage
fdImgsc = fdImg./sum(fdImg(:));
fdImgsc = fdImgsc.*100;
% 

% also return the img coords of the voxel w/the highest fiber count
[~,idx]=max(fdImgsc(:));
[i,j,k]=ind2sub(size(fdImgsc),idx);
max_coord = [i j k];

  
    
