% make exclusionary masks for fsl probtrack analysis


% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
p=getDTIPaths(); cd(p.data);


subjects=getDTISubjects;

%%

for i=1:numel(subjects)
    
    cd(p.data);
    cd(subjects{i})
    
    cd('fsl_dti/dwi.bedpostX')
    
    bm = niftiRead('nodif_brain_mask.nii.gz'); bm.data = single(bm.data);
    
    cd('../ROIs/str')
    da = niftiRead('DA.nii.gz');
    
    [i j k]=ind2sub(size(da.data),find(da.data));
    ythresh=min(j)-3;
    
    % acpcCoords = mrAnatXformCoords(da.qto_xyz,[i j k]);
    % ythresh=floor(min(acpcCoords(:,2)))-2; % fiber tracking won't go more posterior than this
    
    xm = da;
    xm.data = single(zeros(size(xm.data)));
    xm.data(:,ythresh,:) = 1;
    
    xthreshR = floor(mrAnatXformCoords(da.qto_ijk,[-1 0 0]));
    xthreshR=xthreshR(1);
    xthreshL = ceil(mrAnatXformCoords(da.qto_ijk,[1 0 0]));
    xthreshL=xthreshL(1);
    
    % midline exclusionary mask for right side
    xmR = xm;
    xmR.data(xthreshR,:,:) = 1;
    xmR.fname = 'x_mask_R.nii.gz';
    writeFileNifti(xmR)
    
    xmL = xm;
    xmL.data(xthreshL,:,:) = 1;
    xmL.fname = 'x_mask_L.nii.gz';
    writeFileNifti(xmL);
    
end % subjects