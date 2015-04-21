%%%%%% Procedure for deterministic tracking fibers from an ROI

%% change into Reno's dti40 directory
% load ROIs (.mat files) I want to track fibers from
%cd /home/kelly/data/DTI/ak090724/dti40trilin

% load dt6 file
dt=dtiLoadDt6('dt6.mat');

cd ../ROIs
ROI1 = open('DA.mat');
roi1 = ROI1.roi;

ROI2 = open('Caud.mat');
roi2 = ROI2.roi;

ROI3 = open('Putamen.mat');
roi3 = ROI3.roi;

ROI4 = open('NAcc.mat');
roi4 = ROI4.roi;

% NOTE: if ROIs are from ITK gray, they need to be converted into a .mat
% file and their header needs to be fixed using this function: 
% dtiFixITKGrayHeader('File/Path/Filename', 't1 ref file');
% *make sure to do this from the folder the t1 ref file is in*



%%  set up parameters for tracking fibers

opts.stepSizeMm = 1;        % mm
opts.faThresh = 0.15;       % default is .15
opts.lengthThreshMm = [10]; % mm; can enter 1 number for lower bound or 2 for lower/upper bound
opts.angleThresh = 30;      % default is 30 degrees
opts.wPuncture = 0.2;       % default is 0.2
opts.whichAlgorithm = 1;    % default is 1 (STT RK4 algorthm)
opts.whichInterp = 1;       % 0=nearest neighbor, 1=linear
opts.seedVoxelOffsets = [0.25 0.75];

%% track and save fibers 

% track fibers that pass through the 1st roi
fg = dtiFiberTrack(dt.dt6, roi1.coords, dt.mmPerVoxel, dt.xformToAcpc,'DA_FG', opts);

% limit fibers to ones that end in the 1st roi
fg_ends = dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, [], roi1, fg);


% save Fiber groups
cd ..
if (~exist('fibers','dir'))
    mkdir('fibers');
end

cd fibers
if (~exist('DA','dir'))
    mkdir('DA');
end
cd DA

dtiWriteFiberGroup(fg, 'DA_FG');
dtiWriteFibersPdb(fg,dt.xformToAcpc,'DA_FG');
dtiWriteFiberGroup(fg_ends, 'DA_FGends');
dtiWriteFibersPdb(fg_ends,dt.xformToAcpc,'DA_FGends');

%% limit the fibers to those that pass through a 2nd ROI

fg2 = dtiIntersectFibersWithRoi([], {'and'}, [], roi2, fg);

% limit fibers to those with endpoints in both the 1st and 2nd ROI
fg2_ends = dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, [], roi2, fg_ends);

% save Fiber groups
%cd ../../fibers

dtiWriteFiberGroup(fg2, 'DA_Caud_FG');
dtiWriteFibersPdb(fg2,dt.xformToAcpc,'DA_Caud_FG');
dtiWriteFiberGroup(fg2_ends, 'DA_Caud_FGends');
dtiWriteFibersPdb(fg2_ends,dt.xformToAcpc,'DA_Caud_FGends');

%% limit the fibers to those that pass through another ROI

fg3 = dtiIntersectFibersWithRoi([], {'and'}, [], roi3, fg);

% limit fibers to those with endpoints in both the 1st and 2nd ROI
fg3_ends = dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, [], roi3, fg_ends);

% save Fiber groups
% cd ../../fibers

dtiWriteFiberGroup(fg3, 'DA_Putamen_FG');
dtiWriteFibersPdb(fg3,dt.xformToAcpc,'DA_Putamen_FG');
dtiWriteFiberGroup(fg3_ends, 'DA_Putamen_FGends');
dtiWriteFibersPdb(fg3_ends,dt.xformToAcpc,'DA_Putamen_FGends');

%% limit the fibers to those that pass through another ROI

fg4 = dtiIntersectFibersWithRoi([], {'and'}, [], roi4, fg);

% limit fibers to those with endpoints in both the 1st and 2nd ROI
fg4_ends = dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, [], roi4, fg_ends);

% save Fiber groups
% cd ../../fibers

dtiWriteFiberGroup(fg4, 'DA_NAcc_FG');
dtiWriteFibersPdb(fg4,dt.xformToAcpc,'DA_NAcc_FG');
dtiWriteFiberGroup(fg4_ends, 'DA_NAcc_FGends');
dtiWriteFibersPdb(fg4_ends,dt.xformToAcpc,'DA_NAcc_FGends');

%% limit the fibers to those that pass through another ROI
% 
% fg5 = dtiIntersectFibersWithRoi([], {'and'}, [], roi5, fg);
% 
% % limit fibers to those with endpoints in both the 1st and 2nd ROI
% fg5_ends = dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, [], roi5, fg_ends);
% 
% % save Fiber groups
% % cd ../../fibers
% 
% dtiWriteFiberGroup(fg5, 'DA_VentralStriatum_FG_10-95');
% dtiWriteFibersPdb(fg5,dt.xformToAcpc,'DA_VentralStriatum_FG_10-95');
% dtiWriteFiberGroup(fg5_ends, 'DA_VentralStriatum_FGends_10-95');
% dtiWriteFibersPdb(fg5_ends,dt.xformToAcpc,'DA_VentralStriatum_FGends_10-95');

% %% limit the fibers to those that pass through another ROI
% 
% fg6 = dtiIntersectFibersWithRoi([], {'and'}, [], roi6, fg);
% 
% % limit fibers to those with endpoints in both the 1st and 2nd ROI
% fg6_ends = dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, [], roi6, fg_ends);
% 
% % save Fiber groups
% % cd ../../fibers
% 
% dtiWriteFiberGroup(fg6, 'DA_Caudate_FG_10-95');
% dtiWriteFibersPdb(fg6,dt.xformToAcpc,'DA_Caudate_FG_10-95');
% dtiWriteFiberGroup(fg6_ends, 'DA_Caudate_FGends_10-95');
% dtiWriteFibersPdb(fg6_ends,dt.xformToAcpc,'DA_Caudate_FGends_10-95');

