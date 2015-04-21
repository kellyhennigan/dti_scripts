%%%%%% Procedure for tracking fibers from an ROI

%% load files etc
cd /home/kelly/data/DTI/sample_data/mrDiffusion_sampleData/dti40
%load dt6 file
dt=dtiLoadDt6('dt6.mat');
% Build ROI at 0 0 0
roi=dtiNewRoi('ACr25','r',dtiBuildSphereCoords([0 0 0],25))
%%  set up tracking parameters and track from this ROI
opts.stepSizeMm = 1.5;
opts.faThresh = 0.25;
opts.lengthThreshMm = 20;
opts.angleThresh = 30;
opts.wPuncture = 0.2;
opts.whichAlgorithm = 1;
opts.whichInterp = 1;
opts.seedVoxelOffsets = [0.25 0.5];
%% track fibers from the sphere defined
fg = dtiFiberTrack(dt.dt6, roi.coords, dt.mmPerVoxel, dt.xformToAcpc,'testFG', opts);
%limit fibers to ones that end in ROI
fg2= dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, [], roi, fg);
% save Fiber group
cd fibers
dtiWriteFiberGroup(fg, 'ACPCr25');
dtiWriteFibersPdb(fg,dt.xformToAcpc,'ACPC_r25');
dtiWriteFiberGroup(fg2, 'ACPCr25_endpoints');
dtiWriteFibersPdb(fg2,dt.xformToAcpc,'ACPC_r25endpoints');


%% to track all the fibers in a hemisphere etc

% First calculate FA
fa = dtiComputeFA(dt.dt6);
fa(fa>1) = 1; fa(fa<0) = 0;
%  to look at the fa image
showMontage(fa)
% define an FA threshold above which to seed fiber tracking
faThresh=.25
roiAll = dtiNewRoi('all');
% make a ROI of all voxels with FA>.2
mask = fa>=faThresh;
% convert to acpc coordinates
[x,y,z] = ind2sub(size(mask), find(mask));
% put coords in roi structure
roiAll.coords = mrAnatXformCoords(dt.xformToAcpc, [x,y,z]);

% LEFT ROI note that you could do any range of coords for example mid
% saggital for sub cortical structures
%midRoi=dtiRoiClip(roiAll, [-20 20],[],[-30 30]);
%roiLeft = dtiRoiClip(roiAll, [-80 -5]);
%roiLeft = dtiRoiClean(roiLeft, 3, {'fillHoles', 'removeSat'});

% RIGHT ROI
%roiRight = dtiRoiClip(roiAll, [5 80]);
%roiRight = dtiRoiClean(roiRight, 3, {'fillHoles', 'removeSat'});

%clear roiAll;

% Track Fibers
% disp('Tracking Left Hemisphere Fibers ...');
% 
% % left hemisphere
% fg = dtiFiberTrack(dt.dt6,roiLeft.coords,dt.mmPerVoxel,dt.xformToAcpc,'LeftHem',opts);
% cd fibers
% dtiWriteFiberGroup(fg, 'LeftHem');
mtrExportFibers(fg, 'LeftHem');
% dtiWriteFibersPdb(fg,dt.xformToAcpc,'LeftHem');
%% so if you want to restrict your fiber group to those fibers that
%  pass through a given ROI
%fg = dtiIntersectFibersWithRoi([], {'and'}, [], roi, fg);

               