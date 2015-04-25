function [fgImgsc,max_coord] = scaleFiberCounts(fgImg)
% -------------------------------------------------------------------------
% usage: use this function to threshold and transform fiber count imgs.
% 
% INPUT:
%  fgImg - 3d matrix w/values specifying fiber counts per voxel
%   
% 
% OUTPUT:
%  fgImgsc - fgImg thresholded and scaled from [1 0] with 1 being the
%            voxel with the highest fiber count. 
%  max_coord - also returns a vector with the imgCoords of the voxel
%              with the highest value (will be 1), if desired. 
% 
% 
% 
% author: Kelly, kelhennigan@gmail.com, 22-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

% voxels with fiber counts less than this will be set to zero
vox_fc_thresh = 2;


if notDefined('fgImg') || numel(size(fgImg))~=3
    error('fgImg should be a 3d matrix');
end


% threshold fiber counts
fgImg(fgImg<vox_fc_thresh) = 0;
  
        
% log-transform data and scale by the max value, so vals are now btwn 0-1
fgImgsc = log(fgImg+1)./max(log(fgImg(:)+1));


% also return the img coords of the voxel w/the highest fiber count
[~,idx]=max(fgImgsc(:));
[i,j,k]=ind2sub(size(fgImgsc),idx);
max_coord = [i j k];

  
    
