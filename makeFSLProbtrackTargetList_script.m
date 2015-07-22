% makeFSLProbtrackTargetFile_script
% -------------------------------------------------------------------------
% usage: script to create a text file called targetList specifying the
% filepaths to various ROI masks to be used as classification targets.
% Given as input to FSL's probtrackx function.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = getDTIPaths; cd(p.data);

subjects = getDTISubjects; 

LR = ['L','R'];

% target files should be named this w/nifti file ext. Assumed that the
% files are in the directory subjDir/ROIs. Will add 'L' and 'R' to left and
% right ROI respectively
targetStrs = {'caudate','nacc','putamen'};

space = 'std'; % desired space for probtrack analysis results - 
% must be either str (t1 native space), std, or diff

% directory string for out file relative to subj dir. 'L' or 'R' will be
% added accordingly.
outDirStr = ['fsl_dti/probtrackx/' space '/striatum_naccdil'];

%%

s=1;
for s = 1:numel(subjects)
    
    subj = subjects{s};
    
    subjDir = fullfile(p.data,subj);
    cd(subjDir);
    
    for lr = 1:numel(LR)
        
        % check if outDir exists and if it doesn't, create it
        outDir = [outDirStr LR(lr)];
        if ~exist(outDir,'dir')
            mkdir(outDir);
        end
        
        % if the targetList file already exists in the outDir, say so and skip
        % this subject
        
        % define an outfile called targetList and write out target filepaths
        outFile = fullfile(outDir,'targetList');
        if exist(outFile,'file')
            fprintf(['\n\nskipping subject ' subj ' because outFile already defined...\n']);
        else
            fid = fopen(outFile,'w');
            for j=1:numel(targetStrs)
                
                if j==2
                    roiFilePath = fullfile(subjDir,'fsl_dti','ROIs',space,[targetStrs{j} LR(lr) '_dilated.nii.gz']);
                else
                % if target nifti files don't exist/aren't recognized, throw an error
                roiFilePath = fullfile(subjDir,'fsl_dti','ROIs',space,[targetStrs{j} LR(lr) '.nii.gz']);
                end
                
                if ~exist(roiFilePath,'file')
                    error(['can''t find target file ' roiFilePath]);
                end
                
                % add this roiFilePath to outfile targetList
                fprintf(fid,'%s\n',roiFilePath);
                
            end
            
            fclose(fid);
            
        end % if outFile exists
        clear outDir
        
    end % LR
    
end % subjects





