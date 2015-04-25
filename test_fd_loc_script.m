% test for anatomical specificity of fiber densities


%% files, subjects, etc.

clear all
close all

dataDir = '/Users/Kelly/dti/data';

subjects = getDTISubjects;

% relative to subjects' directory
inDir = 'fg_densities/conTrack';


% strings specifying files to process
rois = {'caudateL','naccL','putamenL'};
fdStr = '_da_endpts_S3_sn.nii.gz';



%% do it

%
CoM = []; % center of mass coords
gi = [];  % group index


for j=1:numel(rois); % rois
    
    % load fiber density files
    fds=cellfun(@(x) readFileNifti(fullfile(dataDir,x,inDir,[rois{j} fdStr])), subjects);
    imgs={fds(:).data};
    
    %    get fiber density center of mass
    CoM = [CoM; cell2mat(cellfun(@(x) centerofmass(x), imgs,'UniformOutput',0))'];
    gi = [gi;ones(numel(fds),1).*j];
    
end


acpcCoords = mrAnatXformCoords(fds(1).qto_xyz,CoM);


%% do manova test

[d,p,stats]=manova1(acpcCoords,gi)

manovacluster(stats,'average')



