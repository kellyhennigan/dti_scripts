
function sn_file = xform_native2standard(sn,invDef,ns_file,fType,saveOut)
% -------------------------------------------------------------------------
% usage: this function takes in spatial normalization info and uses it to
% transform files from native to standard space. The function accepts files
% in various formats, though the in file coords should be aligned with the
% subject's native space anatomy (before it was transformed to standard
% space).

% input variables sn and invDef are created by first transforming a
% subject's anatomy from native to standard space using spm_normalise(),
% which performs a nonlinear transformation. Do this using the script
% spatial_normalization_script.

% INPUT:
%   sn - struct with xform info in spm format created by spm_normalise()
%   invDef -inverse deformation field info, also created by spm_normalise()
%   ns_file - file to be xformed from native to standard space. Can be
%             either a filename or loaded file. The xform will be carried
%             out differently depending on the type of file.
%   fType - type of file given as ns_file. Can be:
%             'nii' - nifti file w/same xform and dimensions as t1 in
%                     native space
%             'fg'  - fiber group with fiber coords in acpc native space.
%             'roi' - roi .mat file with acpc coords in roi.coords.
%   saveOut - 1 to save out file, otherwise 0. Default is 0.  
% 
% OUTPUT:
%   sn_file - ns_file transformed to standard space.

% note: this is currently set up to save out the transformed file to the 
% same dir as the input file if its a filename. If the input file is 
% already loaded, then the xformed file is returned but not written out. 

% TODO: add checks on ns_file so that if fType isn't given, the function
% will try to guess what type of file it is.


% author: Kelly, kelhennigan@gmail.com, 22-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% input checks
if notDefined('sn') || notDefined('invDef') || notDefined('ns_file')
    error('sn,invDef, and ns_file must be given as inputs');
end

% save out xformed file? 
if notDefined('saveOut')
    saveOut = 0;
end


%% define some useful local variables

sn_xform = sn.VG.mat;   % standard space img to acpc xform
mm = diag(chol(sn_xform(1:3,1:3)'*sn_xform(1:3,1:3)))'; % mmPerVox
bb = mrAnatXformCoords(sn_xform,[1 1 1; size(sn.VG.dat)]); % bounding box


switch fType
    
    
    case 'roi'              % xform rois
        
        % the goal here is to do the transformation on the acpc coords from
        % a .mat roi, but to save/return a xformed nifti if that's what was
%         given as input. 
        
        % if roi is a nifti, get it in .mat format. Or if it's a .mat
        % filename, load it. 
        roiNii = 0; 
        if ischar(ns_file) && ~isempty(strfind(ns_file,'.nii')) || isfield(ns_file,'data')
            roiNii = 1;
            ns_file = roiNiftiToMat(ns_file,[],0); % get .mat format  
        elseif ischar(ns_file) && ~isempty(strfind(ns_file,'.mat'))
                load(ns_file); ns_file = roi;
        end
        
        snCoords = mrAnatXformCoords(invDef, ns_file.coords); % roi acpc coords from native to standard space
        
        outName = [ns_file.name '_sn']; % new outName
       
        if roiNii==0 % then keep in .mat format
            sn_file = dtiNewRoi(outName,[],round(snCoords));
            
            if saveOut
                dtiWriteRoi(sn_file,fullfile(saveDir,outName), [],'sn_acpc'); % roi, filename, versionNum, coordinateSpace, xform
            end 
            
        
        else        % put into nifti format
            snImgCoords = round(mrAnatXformCoords(inv(sn_xform),snCoords)); % standard acpc to img coords  
            snImg = zeros(sn.VG.dim);
            snImg(unique(sub2ind(sn.VG.dim,snImgCoords(:,1),snImgCoords(:,2),snImgCoords(:,3))))=1;           
            sn_file = dtiWriteNiftiWrapper(snImg,sn_xform,outName,saveOut);

        end
        
    
       
    case 'nii'          % xform niftis
        
        if ischar(ns_file)
            ns_file = readFileNifti(ns_file);
        end
        
        snImg = mrAnatResliceSpm(ns_file.data, sn, bb, mm, [1 1 1 0 0 0], 0);
        
        % if there are nan voxels in the spatially normed volume and there
        % aren't in the native space volume, set them to zero. 
        if isempty(find(isnan(ns_file.data))) && ~isempty(find(isnan(snImg)))
            fprintf('\n\n setting nan voxels in spatially normed volume to 0...\n\n');
            snImg(isnan(snImg))=0;
        end

        % define new outname
        outName = [strrep(strrep(ns_file.fname,'.nii',''),'.gz','') '_sn.nii.gz'];

        sn_file = dtiWriteNiftiWrapper(snImg,sn_xform,outName,saveOut);
       
        
    case 'fg'           % xform fiber group coords
        
        if ischar(ns_file)
            ns_file = mtrImportFibers(ns_file);
        end
        
        sn_file = dtiXformFiberCoords(ns_file, invDef); % xform coords
         sn_file.name = [ns_file.name '_sn'];  % define new outName 
      
         if saveOut
             mtrExportFibers(sn_file,sn_file.name)
         end
        
end % file type



