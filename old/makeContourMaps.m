%% Make contour maps of DA ROI

%% define directories and file names, load files

% subjects = {'ak090724','am090121','db061209','er100302','hh100622',...
% 'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};

subjects = {'ak090724','am090121','db061209','er100302',...
'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};

% subjects = {'ak090724','er100302'};

baseDir = '/home/kelly/data/DTI';

ROIs = {'DA.nii.gz'};

% for i = 1:length(subjects) % for each subject
i=1;
    subjDir = fullfile(baseDir, subjects{i});
    dt6 = fullfile(subjDir,'dti06trilin','dt6.mat');
    t1_halfmmFile = fullfile(subjDir, 't1_halfmm.nii.gz');
   % for j = 1:length(ROIs)
   j=1;
    roiFile = fullfile(subjDir, 'ROIs', ROIs{j});
    roiFile_halfmm = fullfile(subjDir, 'ROIs','DA_halfmm.nii.gz');
    % load dt6.mat and t1
    [dt, t1] = dtiLoadDt6(dt6);
    t1_halfmm = readFileNifti(t1_halfmmFile);
    % load ROIs
    roi = readFileNifti(roiFile);
    roi_halfmm = readFileNifti(roiFile_halfmm);
    t1_halfmm_xformToAcpc = eye(4,4);
    t1_halfmm_xformToAcpc(4,2) = t1_halfmm.qoffset_x;
    t1_halfmm_xformToAcpc(4,3) =t1_halfmm.qoffset_y;
    t1_halfmm_xformToAcpc(4,4) = t1_halfmm.qoffset_z;
 
    % overlay ROI on T1
        % imgRgb = mrAnatOverlayMontage(overlayImg, xform, anatImg, anatXform, cmap, overlayClipRng, acpcSlices, [fname], [plane=3], [alpha=1], [labelFlag=true], [upsamp=0], [numAcross=[]], [clusterThresh=0], [autoCropBorder=0])
     [roiT1] = mrAnatOverlayMontage(roi.data,t1.xformToAcpc, double(t1.img), t1.xformToAcpc, bone(256), [0 1], [-10]);    
%        [roiT1halfmm] = mrAnatOverlayMontage(roi_halfmm.data,t1_halfmm_xformToAcpc, t1_halfmm.data, t1_halfmm_xformToAcpc, bone(256), [0 1], [-10]);    
        % [fdNAccT1] = mrAnatOverlayMontage(smooth3(uint16(fdNAcchalfmm),'gaussian',[7 7 7]), newNAccXform, uint16(T1halfmm), newXform, autumn(256), [.02 .3], [-18:1:-7]);
        % [fdPutT1] = mrAnatOverlayMontage(fdPuthalfmm, newPutXform, double(t1halfmm.img), t1halfmm.xformToAcpc, winter(256), [0 .2], [-18:1:-7]);
        
        % define names for out files
        strIndx = strfind(fiberFiles{j},'.pdb');
        baseOutName = fiberFiles{j}(1:strIndx-1);
        outName = strcat(baseOutName, '_fd.nii.gz');
        outName_S3 = strcat(baseOutName, '_fd_S3.nii.gz');
%         outName_halfmm = strcat(baseOutName, '_fd_halfmm.nii.gz');
%         outName_halfmm_S5 = strcat(baseOutName, '_fd_halfmm_S5.nii.gz');
        
        % save fiber density images and resliced t1 as nii files in fiber directory
        cd(fdDir);
        dtiWriteNiftiWrapper(fdGroups{j}, dt.xformToAcpc, outName);
        dtiWriteNiftiWrapper(fdGroups_S3{j}, dt.xformToAcpc, outName_S3);
%         dtiWriteNiftiWrapper(fdGroups_halfmm{j}, fd_halfmm_xform, outName_halfmm);
%         dtiWriteNiftiWrapper(fdGroups_halfmm_S5{j}, fd_halfmm_xform, outName_halfmm_S5);
        
        clear strIndx baseOutName outName outName_S3  
%         clear outName_halfmm outName_halfmm_S5
        
    end     % fiberFiles
    
    % put subject specific data into fd struct()
    fd_gmm2(i).subj = subjects{i};
    fd_gmm2(i).fiberFiles = fiberFiles;
    fd_gmm2(i).fdGroups = fdGroups;
    fd_gmm2(i).fdGroups_S3 = fdGroups_S3;
%     fd(i).fdGroups_halfmm = fdGroups_halfmm;
%     fd(i).fdGroups_halfmm_S5 = fdGroups_halfmm_S5;
%     
    % save subject's fiber density info for all fiber groups and t1_halfmm
    outMatFile = 'fd_gmm2_data.mat'
    fd_subj = fd(i);
    save(outMatFile, 'fd_subj');
    cd(subjDir);
%     dtiWriteNiftiWrapper(t1_halfmm, t1_halfmm_xform, 't1_halfmm.nii.gz');
    
    clear outMatFile subjDir dt6 fibersDir fdDir dt t1 fiberGroups fdGroups fdGroups_S3 
%     clear t1_halfmm t1_halfmm_xform fdGroups_halfmm fdGroups_halfmm_S5
         
end     % subjects
























