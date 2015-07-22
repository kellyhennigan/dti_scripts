% roiFormatForProbtrack_script
% -------------------------------------------------------------------------
% usage: script to call roiFormatForProbtrack function
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = getDTIPaths; cd(p.data);

subjects = getDTISubjects; 

roiStrs = {'naccR_dilated','naccL_dilated'};

% directory string for out file relative to subj dir
outDir = 'fsl_dti/ROIs/str';

%%

s=1;
for s = 1:numel(subjects)
    
    subj = subjects{s};
    
    subjDir = fullfile(p.data,subj);
    cd(subjDir);
    
    for r = 1:numel(roiStrs)
        
        roiInPath = fullfile(subjDir,'ROIs',[roiStrs{r}, '.nii.gz']);
        refNii = fullfile(subjDir,'t1_fs.nii.gz');
        roiOutPath = fullfile(subjDir,outDir,[roiStrs{r}, '.nii.gz']);
        
    roiFormatForProbtrack(roiInPath,refNii,roiOutPath)
    
    end % roiStrs
    
end % subjects

    



