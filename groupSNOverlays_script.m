% this script takes individual subjects' L and R fiber count maps and does
% the following:

% transforms maps into MNI space, calculates the map's center of mass,
% 
% thresholds each map so that voxels with counts < thresh are set to
% zero, log-transforms the counts, and normalizes them to be between [0 1],
%  (See scale fiber counts for more details),

% combines left and right fiber density maps for a given target roi, 

% and then concatenates the maps across subjects and saves out a
% nifti w/subjects' density maps in the 4th dim. 

% also performs a one-sample t-test and saves out the resulting t-map.

%%


clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;


% specify directory & files to xform, relative to subject's dir
method = 'conTrack';


% strings specifying left and right fiber density files
roiStr = 'nacc'; 
LR = {'L','R'}; 
fdStr = '_da_endpts_S3';


% relative to main datadir
outDir = fullfile('group_sn','fg_densities',method);



%% do it

s=1
for s=1:numel(subjects)
    
    subj = subjects{s}; 
    
    fprintf(['\n\n Working on subject ' subj '...\n\n']);
       
      
    % load spatial normalization xform info
    load([subj '/sn/sn_info.mat']); % loads vars sn and invDef

    
    % define left and right fiber density filepaths
    fdFilePaths = cellfun(@(x) fullfile(subj,'fg_densities',method,[roiStr x fdStr '.nii.gz']), LR, 'UniformOutput',0);
    fdFiles = cellfun(@readFileNifti, fdFilePaths, 'UniformOutput',0);

      
    % transform fd maps to mni space
    fdsn = cellfun(@(x) xform_native2standard(sn,invDef,x,'nii',0), fdFilePaths);
%     fds_sn = cellfun(@(x) xform_native2standard(sn,invDef,x,'nii',0), fdFiles);
    

    % put the left and right fiber density maps into a 1x2 cell array
    fdImgLR={fdsn(:).data};
    
    
    % calculate CoM for L and R fiber density maps. It's probably best to
    % consistently use CoM coords from subjects' native space. But
    % calculate them here anyway save, just in case. 
    imgCoM = cellfun(@centerofmass,fdImgLR,'UniformOutput',0); % CoM in img coords
    CoM(s,1:2) = cellfun(@(x) mrAnatXformCoords(fdsn(1).qto_xyz,x), imgCoM, 'UniformOutput',0);
    
    
    % threshold, log-transform, and scale L and R maps separately, so max() of each map=1
    fdImgLR = cellfun(@(x) scaleFiberCounts(x), fdImgLR, 'UniformOutput',0);
    
    
    % now combine L and R maps and put into a matrix w/subs in the 4th dim
    d(:,:,:,s)=fdImgLR{1}+ fdImgLR{2};
    
    
    fprintf(' done.\n\n');

    
end % subjects


%% save out files


% CoM coords in MNI space 
CoML = cell2mat(CoM(:,1)); 
dlmwrite(fullfile(outDir,[roiStr 'L' fdStr '_sn_CoM']),CoML);
CoMR = cell2mat(CoM(:,2)); 
dlmwrite(fullfile(outDir,[roiStr 'R' fdStr '_sn_CoM']),CoMR);


% save out a nifti file w/all subjects' fiber density maps 
outFName = [roiStr fdStr '_sn'];
nii=createNewNii(fdsn(1),d,fullfile(outDir,outFName));
writeFileNifti(nii);
    
    
% do a t-test on fiber density values and save out t-map
dR=reshape(d,prod(nii.dim(1:3)),[])';
[~,p,~,stats]=ttest(dR);
tMap = reshape(stats.tstat,[nii.dim(1:3)]); tMap(isnan(tMap)) = 0;
tNii=createNewNii(nii,tMap,fullfile(outDir,[outFName '_T']));
writeFileNifti(tNii);
    


