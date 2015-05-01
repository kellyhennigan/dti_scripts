
% define variables, directories, etc.
clear all
close all

subjects=getDTISubjects;
dataDir = '/Users/Kelly/dti/data';


rois = {'caudate.nii.gz','nacc.nii.gz','putamen.nii.gz'}

roiFName = 'striatum.nii.gz'; 

%% 

cd(dataDir)

for i=1:numel(subjects)

    
    cd(fullfile(dataDir,subjects{i},'ROIs'))
    
    roiMerge(rois,roiFName,1);
    
    [roiL,roiR]= splitRoiLR(roiFName);
    
end

