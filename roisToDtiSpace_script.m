% a quick script to loop over subjects to save out niftis of rois in dti
% space/dimensions for running probtrack.

clear all
close all

roiStrs = {'DA_','nacc','caudate','putamen'};

LR = ['L','R'];

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;



%%
s=1;
for s=1:numel(subjects)
    
    cd(p.data);
    cd(subjects{s});
    
    nii = niftiRead('dti96trilin/bin/brainMaskOrig.nii.gz');
    
    cd('ROIs')
    
    if ~exist('dti_space','dir')
        mkdir('dti_space');
    end
    
    r=1;
    for r=1:numel(roiStrs)
        
        lr = 1;
        for lr = 1:numel(LR)
            roi = roiMatToNifti([roiStrs{r} LR(lr) '.mat'],nii,0);
            roi.data = uint8(roi.data);
            roi.fname = ['dti_space/' roi.fname];
            writeFileNifti(roi);
            
        end
        
    end
    
end





