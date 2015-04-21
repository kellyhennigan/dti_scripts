function mergeRois(roiNames,mergedRoiName)
%
% Adds the coordinates from the specified rois and
% saves the new merged roi in current directory
%
% this is for nifti or .mat files, it saves the merged ROI in whatever
% format the input files are
%
% Inputs: roiNames - cell array w/file names of ROIs to be merged
%         mergedRoiName - name of merged ROI (w/ ext.)
%
% Outputs: saves merged ROI nifti file in current directory
%
% kjh, 4/2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
fprintf('\n\nmerging rois...\n\n');
% if no outName specified, call it mergedROI
if(~exist('mergedRoiName','var') || isempty(mergedRoiName))
    mergedRoiName = 'mergedROI';
end

% Get the general structure & its coords of ROI
if ~isempty(strfind(roiNames{1},'.nii'))
    buildingRoi = readFileNifti(roiNames{1});  % open the nifti file
    buildingRoi.fname = mergedRoiName;
    % open the other ROI files and add their coords to the 1st ROI file
    for i = 2:length(roiNames)
        addRoi = readFileNifti(roiNames{i});
        buildingRoi.data = buildingRoi.data + addRoi.data;
        clear addRoi
    end
    indx = find(buildingRoi.data > 1);
    fprintf('\nThere are %d overlapping voxels amongst the input ROIs \n\n',length(indx));
    buildingRoi.data(indx) = 1;
    writeFileNifti(buildingRoi);
    
elseif ~isempty(strfind(roiNames{1},'.mat'))
    buildingRoi = load(roiNames{1}); % open the .mat file
    buildingRoi.roi.name = mergedRoiName;
    % open the other ROI files and add their coords to the 1st ROI file
    for i = 2:length(roiNames)
        addRoi = open(fullfile(roiDir, roiNames{i}));
        buildingRoi.roi.coords = [buildingRoi.roi.coords; addRoi.roi.coords];
        clear addRoi
    end
    buildingRoi.roi.coords = sortrows(buildingRoi.roi.coords,[3 2]);
    save(mergedRoiName, '-struct','buildingRoi');
end

fprintf(['saved roi file ',mergedRoiName,'\n\n']);

