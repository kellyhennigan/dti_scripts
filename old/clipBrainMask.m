function clipBrainMask(subject)

%% set voxels in brain mask to zero that are more than 3 voxels below the most inferior
% z-coordinate in the subjects DA ROI

    fprintf(['\n\n working on subject ', subject,' ... ']);

    expPaths = getSAPaths(subject);
    cd(expPaths.ROIs);
    load('DA.mat');
    roi_minZ = min(roi.coords(:,3));
    z_thresh = roi_minZ-3;
    fprintf(['z-coordinate threshold is ',num2str(z_thresh),'\n\n']);
    
    cd(expPaths.dti96trilin);
    cd bin
    
    mask = readFileNifti('brainMask.nii.gz');
    
    % save out original mask nifit w/a new name
    origMask = mask;
    origMask.fname = 'brainMaskOrig.nii.gz';
    writeFileNifti(origMask);
    
    coordIndx = find(mask.data);
    [i,j,k] = ind2sub(size(mask.data), coordIndx); % get imgCoords for mask
    acpcCoords = mrAnatXformCoords(mask.qto_xyz,[i,j,k]); % convert to acpcCoords
    clipIndx = find(acpcCoords(:,3) < z_thresh);
    
    fprintf(['excluding ', num2str(length(clipIndx)),' out of ', ...
        num2str(length(coordIndx)),' voxels from brain mask\n\n']);
    
    mask.data(coordIndx(clipIndx)) = 0;  % exclude coords below z-threshhold from the mask
    writeFileNifti(mask);
    
    fprintf(['\n\ndone\n\n']);
    
end

