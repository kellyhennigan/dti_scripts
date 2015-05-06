function [h,d]=plotNiiContourSlice(nii,sl,cmap)
% -------------------------------------------------------------------------
% usage: plot a contour slice of a 3-d volume with acpc coordinates
%
% INPUT:
%   nii - nifti structure of filepath
%   sl - 1x3 vector specifying slice coordinates in acpc space with
%           zeros for the non-slice planes (e.g., for axial slice z=-10, do
%           [0 0 -10]
%
% OUTPUT:
%   h - handle of contour plot
%   d - permuted data
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 03-May-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


% if nii is a string, assume its a filepath and load it
if ischar(nii)
    nii = readFileNifti(nii);
end

% if no slice is defined, plot a mid-sagittal slice
if notDefined('sl')
    sl = [-1 0 0];
end

% if no colormap is given, default is grayscale
if notDefined('cmap')
    cmap = gray;
end


plane = find(sl);   % sagittal, coronal, or axial slice
coord = sl(plane);  % acpc coordinate of slice to contour plot

nii.data=double(nii.data);
[X,Y,Z,d] = getNiiMeshGrid(nii); % creates a mesh grid and returns permuted data


xi = []; yi = []; zi = [];

switch plane

    case 1   % sagittal

        xi = coord;

    case 2   % coronal

        yi=coord;

    case 3   % axial

        zi = coord;

end


h = contourslice(X,Y,Z,d,xi,yi,zi);
% h = slice(X,Y,Z,d,sl(1),sl(2),sl(3));


colormap(cmap);
xlabel('x'); ylabel('y'); zlabel('z');


% make it rotatable
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');





