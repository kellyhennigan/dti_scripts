
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



%% 
% 
% subjects = '9';
% 
% 
% dataDir = '/Users/Kelly/SA2/data';


% rois = {'amygdala.nii.gz','caudalanteriorcingulate.nii.gz',...
%     'caudalmiddlefrontal.nii.gz','caudate.nii.gz',...
%     'frontalpole.nii.gz','hippocampus.nii.gz',...
%     'insula.nii.gz','lateralorbitofrontal.nii.gz','medialorbitofrontal.nii.gz',...
%     'nacc.nii.gz','paracentral.nii.gz','parsopercularis.nii.gz',...
%     'parsorbitalis.nii.gz','parstriangularis.nii.gz',...
%     'precentral.nii.gz','putamen.nii.gz',...
%     'rostralanteriorcingulate.nii.gz','rostralmiddlefrontal.nii.gz',...
%     'superiorfrontal.nii.gz'};
% 

% frontal_rois = {'caudalanteriorcingulate.nii.gz',...
%     'caudalmiddlefrontal.nii.gz','frontalpole.nii.gz',...
%     'insula.nii.gz','lateralorbitofrontal.nii.gz','medialorbitofrontal.nii.gz',...
%     'paracentral.nii.gz','parsopercularis.nii.gz',...
%     'parsorbitalis.nii.gz','parstriangularis.nii.gz',...
%     'precentral.nii.gz',...
%     'rostralanteriorcingulate.nii.gz','rostralmiddlefrontal.nii.gz',...
%     'superiorfrontal.nii.gz'};
% 
% for i=1:numel(subjects)
%     
%     cd(dataDir); cd(subjects{i}); cd ROIs;
% 
% 
% 
% roi=readFileNifti(frontal_rois{1});
% outroi = roi;
% outroi.fname = 'frontal_cortex.nii.gz';
% for r=2:numel(frontal_rois)
%     roi=readFileNifti(frontal_rois{r});
%     outroi.data(find(roi.data))=1;
% end
% writeFileNifti(outroi);
%     
% end