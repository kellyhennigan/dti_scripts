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

% define main data directory
dataDir = '/Users/Kelly/dti/data';


% define subjects to process
subjects=getDTISubjects;


% define .mat file with xform info. This also specifies the path to the
% template file.
xf_mat = 'sn/sn_info.mat';


% rois to xform:
% roiStrs = {'DA'};


% fiber density files to xform:
fdStrs = {'caudate_autoclean',...
    'nacc_autoclean',...
    'putamen_autoclean'};


% fiber groups to xform:
% fgStrs = {};


% specify method for fiber groups and densities
method = 'conTrack'; 


%% do it


for s=1:numel(subjects)
    
    subject = subjects{s};
    
    fprintf(['\n\nworking on subject ' subject '...\n\n']);
    
    % define subject main directory
    subjDir =fullfile(dataDir,subject); cd(subjDir);
    
    
    %% load xform info
    
    load(xf_mat); % sn invDef templateFile inFile outFile
    
    
    %% if first subject, load the template file and get some info about it
    
    if s==1
        
        template = readFileNifti(templateFile);
        sn_xform = template.qto_xyz; % standard space xform
        mm = diag(chol(sn_xform(1:3,1:3)'*sn_xform(1:3,1:3)))'; % mmPerVox
        bb = mrAnatXformCoords(sn_xform,[1 1 1; size(template.data)]);
        
    end
    
    
    %% xform rois
    
    if ~notDefined('roiStrs')
        
        cd([subjDir '/ROIs']);
        
        for r=1:numel(roiStrs)
            
            roi=readFileNifti([roiStrs{r} '.nii.gz']);
            
            [i,j,k]=ind2sub(size(roi.data),find(roi.data)); % get roi img coords
            acpcCoords =mrAnatXformCoords(roi.qto_xyz,[i j k]); % roi acpc coords
            ssCoords = mrAnatXformCoords(invDef, acpcCoords); % roi acpc coords in ss
            ssImgCoords = round(mrAnatXformCoords(inv(template.qto_xyz),ssCoords)); % roi img coords in ss
            
            newImg = zeros(size(template.data));
            newImg(unique(sub2ind(size(template.data),ssImgCoords(:,1),ssImgCoords(:,2),ssImgCoords(:,3))))=1;
            
            % to save out new roi file:
            dtiWriteNiftiWrapper(newImg,template.qto_xyz,[roiStrs{r} '_sn.nii.gz']);
            
        end
        
    end
    
    
    %% xform fiber density files
    
    
    if ~notDefined('fdStrs')
        
        cd([subjDir '/fg_densities/' method]);
        
        for f=1:numel(fdStrs)
            
            fd = readFileNifti([fdStrs{f} '.nii.gz']);
            
            newImg = mrAnatResliceSpm(fd.data, sn, bb, mm, [1 1 1 0 0 0], 0);
            
            dtiWriteNiftiWrapper(newImg,sn_xform,[fdStrs{f} '_sn.nii.gz']);
            
        end
        
    end
    
    
    %% xform fiber group coords
    
    
    if ~notDefined('fgStrs')
        
        cd([subjDir '/fibers/' method]);
        
        for f=1:numel(fgStrs)
            
            fg = mtrImportFibers([fgStrs{f} '.pdb']);
            
            fg_sn = dtiXformFiberCoords(fg, invDef);
            
            fg_sn.name = [fg_sn.name '_sn'];
            
            mtrExportFibers(fg_sn,fg_sn.name);
            
        end
        
    end
    
    
end % subjects


%%