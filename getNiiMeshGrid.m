function [D1,D2,D3,vol] = getNiiMeshGrid(nii,plane)
% -------------------------------------------------------------------------
% usage: takes in a nifti struct and returns a meshgrid w/its acpc
% coordinates. If plane is given, then the meshgrid is 2d. If plane isn't
% given, then a meshgrid is made for a 3-d vol.

% INPUT:
%   nii - nii struct or filepath
%   plane = either 1,2, or 3 for sagittal, coronal, or axial

% OUTPUT:
%   D1-3 - dimensions of mesh grid (X,Y, etc.)
%   vol - nii.data(:,:,:,1) permuted to have the same size as mg


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% if nii is a string, assume its a filepath and load it
if ischar(nii)
    nii = readFileNifti(nii);
end


% if plane isn't given, return a meshgrid for a 3d volume
if notDefined('plane')
    plane = 0;
end


xform = nii.qto_xyz;

dim = size(nii.data); dim=dim(1:3); % data dimensions (we only care about the first 3)
voxdim = nii.pixdim;  % voxel dimensions in mm

min_xyz = mrAnatXformCoords(xform,[1,1,1]);
max_xyz = mrAnatXformCoords(xform,[dim(1),dim(2),dim(3)]);

xc = [min_xyz(1):voxdim(1):max_xyz(1)];
yc = [min_xyz(2):voxdim(2):max_xyz(2)];
zc = [min_xyz(3):voxdim(3):max_xyz(3)];


D3 = []; % this will be empty unless meshgrid is for 3d vol

switch plane
    
    case 1   % sagittal
        
        [D1,D2]=meshgrid(yc,zc);
        
        
    case 2   % coronal
        
        [D1,D2]=meshgrid(xc,zc);
        
        
    case 3   % axial
        
        [D1,D2]=meshgrid(xc,yc);
        
        
    otherwise
        
        [D1,D2,D3]=meshgrid(xc,yc,zc);
        
        
end


% permute nii.data in case its requested as output
vol = permute(nii.data,[2 1 3]);










