%%%%% computFiberDensities
%
% save info about the number of fibers in each group (so I know how many
% fibers were manually removed for reporting purposes)
%
%
%% define directories and file names, load files

% subjects = {'ak090724','am090121','db061209','er100302','hh100622',...
% 'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};

subjects = {'ak090724'};

baseDir = '/home/kelly/data/DTI';

for i = 1:length(subjects) % for each subject
subjDir = fullfile(baseDir, subjects{i});
dt6 = fullfile(subjDir,'dti06trilin','dt6.mat');
fibersDir = fullfile(subjDir, 'fibers', 'conTrack');
fdDir = fullfile(subjDir, 'fibers', 'conTrack', 'fg_densities');
if (~exist(fdDir, 'dir'))
    mkdir(fdDir)
end
% load dt6.mat and t1
[dt, t1] = dtiLoadDt6(dt6);

% load and reorient fibers (reorient function retains only endpts)
% NAcc, Caud, and Putamen fiber groups
fiberGroups(1) = mtrImportFibers('DA_NAcc_top2.5per_clean.pdb');
fiberGroups(1) = dtiReorientFibers(fiberGroups(1),2);
fiberGroups(2) = mtrImportFibers('DA_Caud_top2.5per_clean.pdb');
fiberGroups(2) = dtiReorientFibers(fiberGroups(2),2);
fiberGroups(3) = mtrImportFibers('DA_Putamen_top2.5per_clean.pdb');
fiberGroups(3) = dtiReorientFibers(fiberGroups(3),2);

%% make fiber density maps, reslice t1 and density maps, save niftis

% make fiber density maps
% [fdImg] = dtiComputeFiberDensityNoGUI(fiberGroups, xformImgToAcpc, imSize, normalize, fiberGroupNum, endptFlag, fgCountFlag, weightVec, weightBins)
[fdNAcc] =  dtiComputeFiberDensityNoGUI(fiberGroups, dt.xformToAcpc, size(dt.b0), [1],[1],[1]);
[fdCaud] =  dtiComputeFiberDensityNoGUI(fiberGroups, dt.xformToAcpc, size(dt.b0), [1],[2],[1]);
[fdPut] =  dtiComputeFiberDensityNoGUI(fiberGroups, dt.xformToAcpc, size(dt.b0), [1],[3],[1]);

% reslice anatomical and fiber density images to .5mm isotropic res
% [newImg,xform,deformField] = mrAnatResliceSpm(img, xform, [boundingBox], [mmPerVox], [bSplineParams=[7 7 7 0 0 0]], [showProgress=1])
[t1halfmm, newXform] = mrAnatResliceSpm(t1.img, inv(t1.xformToAcpc),[], [.5 .5 .5],[1 1 1 0 0 0]); % (use [1 1 1 0 0 0] for last argument for trilinear method)
[fdNAcc_halfmm, fdNAcc_halfmm_xform] = mrAnatResliceSpm(fdNAcc, inv(dt.xformToAcpc),[], [.5 .5 .5], [1 1 1 0 0 0]);
[fdCaud_halfmm, fdCaud_halfmm_xform] = mrAnatResliceSpm(fdCaud, inv(dt.xformToAcpc),[], [.5 .5 .5], [1 1 1 0 0 0]);
[fdPut_halfmm, fdPut_halfmm_xform] = mrAnatResliceSpm(fdPut, inv(dt.xformToAcpc),[], [.5 .5 .5], [1 1 1 0 0 0]);

%% Now lets smooth all density maps with gaussian kernel

fdNAccS4 = smooth3(fdNAcc,'gaussian',[4 4 4]);
fdCaudS4 = smooth3(fdCaud,'gaussian',[4 4 4]);
fdNAccS9=smooth3(fdNAcchalfmm,'gaussian',[9 9 9]);

%% now overlay the fiber density maps on subject's T1
% imgRgb = mrAnatOverlayMontage(overlayImg, xform, anatImg, anatXform,
% cmap, overlayClipRng, acpcSlices, [fname], [plane=3], [alpha=1], [labelFlag=true], [upsamp=0], [numAcross=[]], [clusterThresh=0], [autoCropBorder=0])

% % regular res
% [fdNAccT1] = mrAnatOverlayMontage(fdNAcc, dt.xformToAcpc, double(t1.img), t1.xformToAcpc, autumn(256), [0 .2], [-18:1:-7]);
% 
% [fdPutT1] = mrAnatOverlayMontage(fdPut, dt.xformToAcpc, double(t1.img), t1.xformToAcpc, winter(256), [0 .2], [-18:1:-7]);
% 
% % resampled res
% [fdNAccT1] = mrAnatOverlayMontage(smooth3(uint16(fdNAcchalfmm),'gaussian',[7 7 7]), newNAccXform, uint16(T1halfmm), newXform, autumn(256), [.02 .3], [-18:1:-7]);
% [fdPutT1] = mrAnatOverlayMontage(fdPuthalfmm, newPutXform, double(t1halfmm.img), t1halfmm.xformToAcpc, winter(256), [0 .2], [-18:1:-7]);
% 


%% save fiber density images and resliced t1 as nii files in fiber directory

cd(fibersDir);
dtiWriteNiftiWrapper(single(t1halfmm./max(t1halfmm(:))),newXform,'t1_halfmm');

%% repeat for multiple striatal ROIs


% multiple striatal ROI fiber groups
for j = 1:6     
    strFGs(j) = mtrImportFibers(['scoredFG_strROIs_Striatum_fs_ind' num2str(j) '_of_8_DA_top5000.pdb']);
    strFGs(j) = dtiReorientFibers(fiberGroups(j),2);
end

for k = 1:length(strFGs)
    strFDs(k) =  dtiComputeFiberDensityNoGUI(strFGs, dt.xformToAcpc, size(dt.b0), [1],[k],[1]);
end
% 
% % to write to a nifti file
% % dtiWriteNiftiWrapper(single(fd./max(fd(:))),dt.xformToAcpc,'someFibers');
% dtiWriteNiftiWrapper(single(T1halfmm./max(T1halfmm(:))),newXform,'T1_halfmm');
% dtiWriteNiftiWrapper(fdNAccS5,newNAccXform,'fdNAcc_halfmmSmooth5');
% 
% dtiWriteNiftiWrapper(single(fdNAcchalfmm./max(fdNAcchalfmm(:))),newNAccXform,'fdNAcc_halfmm');
% dtiWriteNiftiWrapper(single(fdPuthalfmm./max(fdPuthalfmm(:))),fdPuthalfmm.xformToAcpc,'fdPut_halfmm');
% 
% dtiWriteNiftiWrapper(single(fdStr1ROIs./max(fdStr1ROIs(:))),dt.xformToAcpc,'fd_Str1ROIs');
% dtiWriteNiftiWrapper(single(fdStr2ROIs./max(fdStr2ROIs(:))),dt.xformToAcpc,'fd_Str2ROIs');
% dtiWriteNiftiWrapper(single(fdStr7ROIs./max(fdStr7ROIs(:))),dt.xformToAcpc,'fd_Str7ROIs');
% dtiWriteNiftiWrapper(single(fdStr8ROIs./max(fdStr8ROIs(:))),dt.xformToAcpc,'fd_Str8ROIs');
% dtiWriteNiftiWrapper(single(fdPut./max(fdPut(:))),dt.xformToAcpc,'fd_Put');
% 


