function desiredStat = getNiiStat(nii,desiredStatStr)
% -------------------------------------------------------------------------
% usage: get some useful info about a nifti file. Meant to be a shortcut
% for getting info about fiber density files. Written to work with 3d
% volume niftis. 

% INPUT:
%   nii - filepath or nifti loaded using readFileNifti
%   desiredStatStr - string specifying what stat is desired. Options are listed
%             below. 

% OUTPUT:
%   desiredStat - requested stat.



% author: Kelly, kelhennigan@gmail.com, 26-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% if nii is a string, assume its a filepath and load it
if ischar(nii)
    nii = readFileNifti(nii);
end


%% get the desired stat

switch lower(desiredStatStr)

case 'com'  % return center of mass
    
    desiredStat = mrAnatXformCoords(nii.qto_xyz,centerofmass(nii.data)); 
    

case 'max'  % return acpc coords of max voxel 

    [max_val,idx]=max(nii.data(:)); 
    [i j k]=ind2sub(size(nii.data),idx);
    max_coords = mrAnatXformCoords(nii.qto_xyz,[i j k]);
    
    desiredStat = [max_coords,max_val];
    
    
case 'mean_coords'  % return mean acpc coords 

    [i j k]=ind2sub(size(nii.data),find(nii.data));
    
    desiredStat = round(mrAnatXformCoords(nii.qto_xyz,mean([i j k])));

    
    
end

   
    

















