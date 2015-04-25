% this is a script to normalize subjects' anatomy to standard space. Saves
% out subjects' normalized anatomy in template space, a figure comparing
% the template to subject's anatomy, and the associated transforms.



%% define directories and file names, load files


clear all
close all

% define main data directory
dataDir = '/Users/Kelly/SA2/data';


% define subjects to process
% subjects=getDTISubjects; 
subjects = getSA2Subjects; subjects(1)=[];


% define template file
% templateFile = fullfile(dataDir,'templates/MNI_avg152_T1_w_skull.nii');
templateFile = fullfile(dataDir,'templates/MNI_avg152_T1.nii');



% define path to anat file to normalize w '%s' holder for subject string
% inFile = [dataDir '/%s/t1/t1_fs.nii.gz'];
inFile = [dataDir '/%s/t1/t1_fs_bet.nii.gz'];


%% do it


% For SPM8:
spm_get_defaults; global defaults; params = defaults.normalise.estimate;

% template = readFileNifti(templateFile);


% subject loop
for i=1:numel(subjects)

    
    clear snImg im tIm
    
    subject = subjects{i};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % defined subject main directory
    subjDir =fullfile(dataDir,subject); cd(subjDir);
    
    
    % define 'spatial_norm' (sn) dir to save out sn info
    snDir = fullfile(subjDir,'sn');
    if ~exist(snDir,'dir')
        mkdir(snDir);
    end
    
    
    % load t1 file
    t1=readFileNifti(sprintf(inFile,subject));
    
    
    % Rescale image values to get better gary/white/CSF contrast
    img = mrAnatHistogramClip(double(t1.data),0.3,0.99);
    
    
    % Compute normalization
    [sn, Vtemplate, invDef] = mrAnatComputeSpmSpatialNorm(img, t1.qto_xyz, templateFile, params);
    % returns:
    % sn - deformation field for transforming source image to template space
    % Vtemplate - loaded template nifti
    % invDef - inverse deformation in the form of a coordinate look-up-table (LUT)
    
    % mrAnatXformCoord can use invDef to warp the template to the source image
    % space. (You use the sn to warp the source image to the template.) Also,
    % you can get the template standard space of a source image coordinate
    % with:
    %   ssCoord = mrAnatXformCoords(invDef, acpcCoord)
    
    
    
    %% check normalization & reslice t1 to be in template space
    
    cd(snDir);
    
    % template mmPerVox & bounding box
    mm = diag(chol(Vtemplate.mat(1:3,1:3)'*Vtemplate.mat(1:3,1:3)))';
    bb = mrAnatXformCoords(Vtemplate.mat,[1 1 1; Vtemplate.dim]);
    
    % reslice anat img to match template
    snImg = mrAnatResliceSpm(t1.data, sn, bb, mm, [1 1 1 0 0 0], 0);
    
    
    tIm = mrAnatResliceSpm(double(Vtemplate.dat), inv(Vtemplate.mat), bb, mm, [1 1 1 0 0 0], 0);
    im(:,:,:,1) = uint8(tIm);
    im(:,:,:,2) = uint8(round(clip(snImg)*255));
    im(:,:,:,3) = im(:,:,:,2);
    
    
    % save out spatially normed t1 file:
    outFile = fullfile(subjDir,'t1','t1_sn.nii.gz');
    dtiWriteNiftiWrapper(snImg,Vtemplate.mat,outFile);
    
    
    % Save an image of the spatially normalized data showing the quality of the
    % alignment
    imwrite(makeMontage(im),fullfile(snDir, 'SpatialNormalization.png'));
    
    
    % save out xforms and file info
    save sn_info.mat sn invDef inFile outFile 
    
end


