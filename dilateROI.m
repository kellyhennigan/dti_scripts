function outRoi = dilateROI(inRoi,nVoxDilation)
% -------------------------------------------------------------------------
% usage: takes in a nifti roi and expands it by nVox. This will hopefully
% be useful for fiber tracking, to expand a gray matter roi by a bit so
% that it interfaces with white matter

% INPUT:
%   inROI - nifti roi struct or roi coords. If coords are given, they must
%           be either N x 3 or 3 x N matrix
%   nVoxDilation - number of voxels to expand the roi by. Default is 1.
% 
% OUTPUT:
% 	outRoi - returns a nifti roi if that's what's given, or if just coords
% 	are given, coords are returned
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 10-Mar-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if notDefined('inRoi')
    error('either a nifti roi or a set of roi coords must be provided as input')
end

if notDefined('nVoxDilation')
    nVoxDilation = 1;
end

fprintf(['\n\ndilating roi by ' num2str(nVoxDilation) ' voxel...\n\n']);

if isstruct(inRoi)
    [i, j, k] = ind2sub(size(inRoi.data),find(inRoi.data));
else
    if size(inRoi,1)==3  % then these are 3 x N coords - flip them to be N x 3
        inRoi = inRoi';
    end
    if size(inRoi,2) ~=3
        error('inRoi must be either a nifti struct or N x 3 matrix of coords')
    else
       i = inRoi(:,1); j = inRoi(:,2); k = inRoi(:,3);
    end
end
in_coords = [i,j,k];

% so now we have in_coords as N x 3 matrix - define out_coords by just
% expanding out coords in every direction
out_coords = in_coords;
for n=1:nVoxDilation
    out_coords = [out_coords;out_coords+1;out_coords-1];
end
out_idx = sub2ind(max(out_coords),out_coords(:,1),out_coords(:,2),out_coords(:,3));
out_idx = unique(out_idx);
[i, j, k]=ind2sub(max(out_coords),out_idx);

if isstruct(inRoi)  % then fill in roi data as binary mask
    outRoi = inRoi;
    outRoi.fname = strrep(outRoi.fname,'.nii.gz',['_dilated_' num2str(nVoxDilation) '_vox.nii.gz']);
    outRoi.data(sub2ind(size(outRoi.data),i,j,k))=1;

else                % just return the dilated coords
    outRoi = [i j k];
end





