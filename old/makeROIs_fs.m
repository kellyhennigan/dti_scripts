%% Make individual ROIs from aparc+aseg.nii.gz file created with Freesurfer
%
% this script uses Michael's fs_aparcAsegLabelToNiftiRoi function
% to make a bunch of nifti ROIs from specified Freesurfer labels
% for specified subjects
%
% merges R and L ROIs and saves as one ROI nifti file
% 
% for Freesurfer label values, see here: 
% http://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI/FreeSurferColorLUT
%
% kjh 4/2011
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define base directory, subject folders, freesurfer labels, and ROI names

% base dir (one above subject directories)
% baseDir = '/home/kelly/ShockAwe/data/';
baseDir = '/Users/Kelly/dti/data';

% this should be either nii or nii.gz for nifti files
f_suffix = '.nii'; 

% subject directories
subjects = getDTISubjects;
% subjects = {'sa01','sa13','sa18','sa23','sa22'};
    
%% freesurfer label numbers and roi names %% 
% 
% roiNames = {'nacc';
%     'caudate';
%     'putamen';
%     'caudalanteriorcingulate';
%     'caudalmiddlefrontal';
%     'lateralorbitofrontal';
%     'medialorbitofrontal';
%     'parsopercularis';
%     'parsorbitalis';
%     'parstriangularis';
%     'precentral';
%     'rostralanteriorcingulate';
%     'rostralmiddlefrontal';
%     'superiorfrontal';
%     'frontalpole';
%     'hippocampus';
%     'amygdala'};
% 
roiNames = {'insula'};
labelVals = {'19','55'};

% 
% labelVals = {'26','58';
%     '11','50';
%     '12','51';
%     '1002','2002';
%     '1003','2003';
%     '1012','2012';
%     '1014','2014';
%     '1018','2018';
%     '1019','2019';
%     '1020','2020';
%     '1024','2024';
%     '1026','2026';
%     '1027','2027';
%     '1028','2028';
%     '1032','2032';
%     '17','53';
%     '18','54'}; % label values corresponding to the left & right ROIs listed}; % label values corresponding to the left & right ROIs listed
% 
% roiNames = {'ventralDC'};


% labelVals = {'28','60'};
  


%% Striatum
% L and R NAcc - 26/58
% L and R Caudate - 11/50
% L and R Putamen - 12/51

% roiNames = {'nacc';
%     'caudate';
%     'putamen'};
% 
% labelVals = {'26','58';
%     '11','50';
%     '12','51'}; % label values corresponding to the left & right ROIs listed


%% Frontal Lobes
% L and R caudalanteriorcingulate - 1002/2002
% L and R caudalmiddlefrontal - 1003/2003
% L and R lateralorbitofrontal - 1012/2012
% L and R medialorbitofrontal - 1014/2014
% L and R parsopercularis - 1018/2018
% L and R parsorbitalis - 1019/2019
% L and R parstriangularis - 1020/2020
% L and R precentral - 1024/2024
% L and R rostralanteriorcingulate - 1026/2026
% L and R rostralmiddlefrontal - 1027/2027
% L and R superiorfrontal - 1028/2028
% L and R frontalpole - 1032/2032
% 
% roiNames = {'caudalanteriorcingulate';
%     'caudalmiddlefrontal';
%     'lateralorbitofrontal';
%     'medialorbitofrontal';
%     'parsopercularis';
%     'parsorbitalis';
%     'parstriangularis';
%     'precentral';
%     'rostralanteriorcingulate';
%     'rostralmiddlefrontal';
%     'superiorfrontal';
%     'frontalpole'};
% 
% labelVals = {'1002','2002';
%     '1003','2003';
%     '1012','2012';
%     '1014','2014';
%     '1018','2018';
%     '1019','2019';
%     '1020','2020';
%     '1024','2024';
%     '1026','2026';
%     '1027','2027';
%     '1028','2028';
%     '1032','2032'}; % label values corresponding to the left & right ROIs listed

%% other structures of interest
% L and R amygdala - 18/54
% L and R hippocampus - 17/53

% roiNames = {'hippocampus';
%     'amygdala'};
% 
% labelVals = {'17','53';
%     '18','54'};
% 
%% Get to it

for i = 1:length(subjects)          % subject loop
    roiDir = fullfile(baseDir, subjects{i},'ROIs');
    cd(roiDir);
    fsIn = fullfile(roiDir,'aparc+aseg.nii.gz');  % subject's aparc+aseg nii file
    
    % make L and R ROI nifti files
    for j = 1:length(roiNames)     % label loop
        roiNameL = fullfile(roiDir,[roiNames{j},'L', f_suffix]);
        roiNameR = fullfile(roiDir,[roiNames{j},'R', f_suffix]);
        fs_aparcAsegLabelToNiftiRoi(fsIn,labelVals{j,1},roiNameL);
        fs_aparcAsegLabelToNiftiRoi(fsIn,labelVals{j,2},roiNameR);
      
    end
   
    % now loop again to merge the L and R ROI files 
    for j = 1:length(roiNames)
        roiNameL = [roiNames{j},'L', f_suffix];
        roiNameR = [roiNames{j},'R', f_suffix];
        mergeRois({roiNameL, roiNameR},[roiNames{j},f_suffix]);
        roiNiftiToMat([roiNames{j},'.nii']);
    end
end


