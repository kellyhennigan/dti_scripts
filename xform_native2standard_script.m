% this script transforms subjects' rois and fiber density files to standard
% space. It assumes that spatial_normalization_script has been run first,
% which normalizes a subject's anatomy to a standard template (e.g, MNI). 
% That script saves the transform and paths to relevant files in a .mat
% file, sn_info.mat, which is called in this script. 

% goal 1:
%  be able to transform coordinates in subject's native space to standard
%  space

% goal 2:
%  be able to transform ROI masks and other volumes (e.g. fiber density
%  files) from native space to standard space

% goal 3:
%  be able to transform fiber groups from native to standard space

% goal 4:
%  " " for volumes aligned to t1 in native space but with different
%  mmPerVox and/or bounding box

% so far I can do 1-3 but 4 can only be done clumsily by transforming
% imgCoords > acpcCoords > ssAcpcCoords > ssImgCoords (so using the method
% for goal 1).


%%

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;


% define path to .mat file that contains xform info. Path should be
% relative to subject's directory
xf_mat = 'sn/sn_info.mat';


 % specify the type of file to be xformed. As of now, this can be either
 % 'roi','fd', or 'fg'. 
fType = 'nii';

% for goal 1).


% specify directory & files to xform, relative to subject's dir
fDir = 'fg_densities/mrtrix';

% ns_files = {'nacc_da_endpts_S3.nii.gz',...
%     'caudate_da_endpts_S3.nii.gz',...
%     'putamen_da_endpts_S3.nii.gz'};

ns_files = {'naccL_da_endpts_S3.nii.gz','naccR_da_endpts_S3.nii.gz',...
    'caudateL_da_endpts_S3.nii.gz','caudateR_da_endpts_S3.nii.gz',...
    'putamenL_da_endpts_S3.nii.gz','putamenR_da_endpts_S3.nii.gz'};



saveOut = 1; % 1 to save out xformed files, otherwise 0

%% do it


cd(dataDir);

i=1;
for i=1:numel(subjects)

    subject = subjects{i}; cd(fullfile(dataDir,subject));
    fprintf(['\n\n Working on subject ',subject,'...\n\n']);
    
    xf_mat = 'sn/sn_info.mat';

    load(xf_mat); % loads vars sn and invDef
    
    for j=1:numel(ns_files)
        ns_file = fullfile(fDir,ns_files{j});
        sn_file = xform_native2standard(sn,invDef,ns_file,fType,saveOut);
    end

    fprintf(['\n\n done with subject ',subject,'.\n\n']);
end


