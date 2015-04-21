%% Subject make ROI loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define base directory, subject folders, freesurfer labels, and ROI names

% base dir (one above subject directories)
baseDir = '/home/kelly/data/DTI';

% subject directories
% subjects = {'ak090724','am090121','db061209','er100302','hh100622',...
% 'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};
%subjects = {'ak090724'};
subjects = {'am090121','db061209','er100302','hh100622',...
'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};


% resulting ROI nii filenames (should correspond with freesurfer labels)
 roiNames{1} = {'Lcaudalanteriorcingulate.nii.gz','Rcaudalanteriorcingulate.nii.gz'};
 roiNames{2} = {'Lcaudalmiddlefrontal.nii.gz','Rcaudalmiddlefrontal.nii.gz'};
 roiNames{3} = {'Lfrontalpole.nii.gz','Rfrontalpole.nii.gz'};
 roiNames{4} = {'Llateralorbitofrontal.nii.gz','Rlateralorbitofrontal.nii.gz'};
 roiNames{5} = {'Lmedialorbitofrontal.nii.gz','Rmedialorbitofrontal.nii.gz'};
 roiNames{6} = {'Lparsopercularis.nii.gz','Rparsopercularis.nii.gz'};
 roiNames{7} = {'Lparsorbitalis.nii.gz','Rparsorbitalis.nii.gz'};
 roiNames{8} = {'Lparstriangularis.nii.gz','Rparstriangularis.nii.gz'};
 roiNames{9} = {'Lprecentral.nii.gz','Rprecentral.nii.gz'};
 roiNames{10} = {'Lrostralanteriorcingulate.nii.gz','Rrostralanteriorcingulate.nii.gz'};
 roiNames{11} = {'Lrostralmiddlefrontal.nii.gz','Rrostralmiddlefrontal.nii.gz'};
 roiNames{12} = {'Lsuperiorfrontal.nii.gz','Rsuperiorfrontal.nii.gz'};
 
 outName{1} = {'caudalanteriorcingulate.nii.gz'};
 outName{2} = {'caudalmiddlefrontal.nii.gz'};
 outName{3} = {'frontalpole.nii.gz'};
 outName{4} = {'lateralorbitofrontal.nii.gz'};
 outName{5} = {'medialorbitofrontal.nii.gz'};
 outName{6} = {'parsopercularis.nii.gz'};
 outName{7} = {'parsorbitalis.nii.gz'};
 outName{8} = {'parstriangularis.nii.gz'};
 outName{9} = {'precentral.nii.gz'};
 outName{10} = {'rostralanteriorcingulate.nii.gz'};
 outName{11} = {'rostralmiddlefrontal.nii.gz'};
 outName{12} = {'superiorfrontal.nii.gz'};

%% Get to it

for i = 1:length(subjects)          % subject loop
%     fsIn = fullfile(baseDir, subjects{i},'aparc+aseg.nii.gz');  % subject's aparc+aseg nii file
    roiDir = fullfile(baseDir, subjects{i},'ROIs');
    for j = 1:length(roiNames) 
        newRoiName = outName{j};     % work around because 'outName{j}' is a cell
        mergeRois(roiDir, newRoiName{1}, roiNames{j});
        convertRoiNiiToMat(roiDir, newRoiName{1});
        clear newRoiName
    end
end


