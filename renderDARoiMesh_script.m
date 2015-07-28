% goal: make DA ROI mesh and plot fiber densities or endpts on the it


%%

clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';
cd(dataDir)


subject = 'group_sn'

% t1Str = 't1_sn_group_mean';
t1Str = 't1_sn';

segFile = 't1_class.nii.gz';

% daStr = 'DA';
daStr = 'DA_sn_binary_mask';


targets = {'nacc','putamen'};

method = 'conTrack';
fgStr = '_autoclean';
fdStr = '_da_endpts_S3_sn';

% cmap = getFDColors2;
cmap=getDTIColors('fd');
crange = [-4 4];


%% get files 

t1 = readFileNifti([subject '/t1/' t1Str '.nii.gz']);

if ~notDefined('segFile')
    seg = readFileNifti([subject '/t1/' segFile]);
end

da = readFileNifti([subject '/ROIs/' daStr '.nii.gz']);
load([subject '/ROIs/' daStr '.mat']);


fg = cellfun(@(x) mtrImportFibers([subject '/fibers/' method '/' x fgStr '.pdb']), targets);

FDs = cellfun(@(x) readFileNifti([subject '/fg_densities/' method '/' x fdStr '.nii.gz']), targets);
fdImgs = {FDs(:).data};
fdImgs = cellfun(@(x) scaleFiberCounts(x), fdImgs, 'UniformOutput',0);
% fd12 = readFileNifti('sa26/fg_densities/fd_NP_S3.nii.gz');
fdImgs{1} = fdImgs{1}.*-1;
fd = FDs(1); fd.data = fdImgs{1} + fdImgs{2};

% now add 1 to fd2 for cmap
% fd2.data(fd2.data~=0)=fd2.data(fd2.data~=0)+1;


cmap=getFDColors2(); 
% red=cmap{1}; blue=cmap{2};
crange = [-4 4];


close all
clear mov msh a ii alpha M


%% make a mesh of DA ROI & color it according to fiber densities 

h=afq_renderMesh(da,'alpha',.3)
axis off

 % coords of fiber density center of mass
 imgs = {FDs(:).data};
 
    CoM = cell2mat(cellfun(@(x) centerofmass(x), imgs,'UniformOutput',0))'; % center of mass img coords
    acpcCoords(:,:,j) = mrAnatXformCoords(fds(1).qto_xyz,CoM);
   

scatter3(70,20,200,50,[1 0 0],'filled')

[sf, fg] = dtiComputeSuperFiberRepresentation(fg(1), [], 200);
sf=getFGEnds(sf,4);

lightH = AFQ_RenderFibers(sf,'color',[1 0 0],'newfig',1)

[sf2, fg2] = dtiComputeSuperFiberRepresentation(fg2, [], 200);
sf2=getFGEnds(sf2,4);

lightH = AFQ_RenderFibers(sf2,'color',[0 0 1],'newfig',0)


h=afq_renderMesh(da,'alpha',.3)
axis off
[h,mov] = rotateMesh(h,[10,10],1);


h=afq_renderMesh(da,'alpha',.3,'newfig',0)

h=afq_renderMesh(da,'overlay',fd,'cmap',cmap,'crange',crange,'alpha',1,'newfig',1)
axis off 

[h,mov] = rotateMesh(h,[90,30],1);

[h,mov] = rotateMesh(h,[90,0],1);
% to change alpha: 
a=.5
alpha(h.p,a)


AFQ_meshAddFgEndpoints(msh, fg, colors, crange, alpha, weights, distfun, dilate)



%% 


%% add bg sagittal image to it for perspective

% (this doesn't work yet)

AFQ_AddImageTo3dPlot(t1,[0 0 0])

%% zoom in on it




%% now plot everyone's fiber densities on the DA ROI mesh 

% a mesh of the DA ROI 

% AFQ_RenderFibers(fg,'color',[0 0 1],'numfibers',100)
%  h = AFQ_RenderRoi(roi, [1 0 0],[], 'surface')
%  axis off
%  
% 
% set(h,'FaceAlpha',.5)



%% example of using AFQ_AddImageTo3dPlot (I think from AFQ_Example): 

% Load the subject's dt6 file (generated from dtiInit).
dt = dtiLoadDt6(fullfile(sub_dir,'dt6.mat'));

% Track every fiber from a mask of white matter voxels. Use 'test' mode to
% track fewer fibers and make the example run quicker.
wholebrainFG = AFQ_WholebrainTractography(dt,'test');

% Visualize the wholebrain fiber group.  Because there are a few hundred
% thousand fibers we will use the 'numfibers' input to AFQ_RenderFibers to
% randomely select 1,000 fibers to render. The 'color' input is used to set
% the rgb values that specify the desired color of the fibers.
AFQ_RenderFibers(wholebrainFG, 'numfibers',1000, 'color', [1 .6 .2]);

% Add a sagittal slice from the subject's b0 image to the plot. First load
% the b0 image.
b0 = readFileNifti(fullfile(sub_dir,'bin','b0.nii.gz'));

% Then add the slice X = -2 to the 3d rendering.
AFQ_AddImageTo3dPlot(b0,[-2, 0, 0]);





%% 

% % first, files for a single subject example 
% t1 = readFileNifti('sa26/t1/t1_fs.nii.gz');
% seg = readFileNifti('sa26/t1/t1_class.nii.gz')
% fg = mtrImportFibers('sa26/fibers/conTrack/naccR_autoclean.pdb')
% fg2 = mtrImportFibers('sa26/fibers/conTrack/putamenR_autoclean.pdb')
% fd = readFileNifti('sa26/fg_densities/conTrack/nacc_da_endpts_s3.nii.gz');
% fd2 = readFileNifti('sa26/fg_densities/conTrack/putamen_da_endpts_s3.nii.gz');
% fd12 = readFileNifti('sa26/fg_densities/fd_NP_S3.nii.gz');
% 
% da = readFileNifti('sa26/ROIs/DA.nii.gz')
% 
% 
% fd.data=scaleFiberCounts(fd.data);
% fd2.data=scaleFiberCounts(fd2.data);

% % now add 1 to fd2 for cmap
% fd2.data(fd2.data~=0)=fd2.data(fd2.data~=0)+1;
% 




%% cortical mesh of brain 


msh = AFQ_meshCreate(seg);
[p, msh, lightH]=afq_renderMesh(msh)


% msh = AFQ_meshColor(msh, 'overlay', fd, 'thresh',.01, 'crange', [.01 .8], 'cmap', autumn)

% alternatively, the mesh can be created and rendered just using the
% AFQ_RenderCorticalSurface command: 

% [p, msh, lightH] = AFQ_RenderCorticalSurface(...
%     im,'overlay',fd,'crange',[.01 .8],'thresh',.01,'cmap',autumn,'alpha',.5,'newfig',1);




%% render fibers within cortex mesh 


lightH = AFQ_RenderFibers(fg,'color',[1 0 0],'numfibers',500,'newfig',1)
AFQ_RenderFibers(fg2,'color',[0 0 1],'numfibers',500,'newfig',0)

p = afq_renderMesh(seg, 'boxfilter', 5,'alpha',.5, 'newfig', 0);


% Delete the light object and put a new light to the right of the camera
delete(lightH); % or maybe delete lightH?
lightH=camlight('right');

% Turn of the axes
axis('off');



%% 





