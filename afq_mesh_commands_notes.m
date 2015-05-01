% check out some AFQ mesh commands

% first run the following to set up directories, etc. 
subjDir = '/Users/Kelly/dti/data/sa01';

% t1 file 
t1 = readFileNifti(fullfile(subjDir,'t1_fs.nii.gz'));

% segmentation file
im = readFileNifti(fullfile(subjDir,'t1','t1_class.nii.gz')); 
im = readFileNifti(fullfile(subjDir,'t1','aparc+aseg.nii.gz')); 

% example fiber density overlay 
fd = readFileNifti(fullfile(subjDir,'fg_densities','parsopercularisL_man_clean.nii.gz')); 

% ROI of interest
load(fullfile(subjDir,'ROIs/parsorbitalisL.mat'));

% fiber group of interest
fg = mtrImportFibers(fullfile(subjDir,'fibers/mrtrix/parsopercularisL_man_clean.pdb'));

% note: to move with arrow keys: 
cameratoolbar('Show');
cameratoolbar('SetMode','orbit');

lightH = camlight('right');
lighting('gouraud');


%% plot a cortex mesh 

% create a cortical mesh from a segmentation file and plot it: 
msh = AFQ_meshCreate(im);
% [p, msh, lightH] = AFQ_RenderCorticalSurface(msh);
% 
% % this can also be done by just calling AFQ_RenderCorticalSurface to create
% % and render a new mesh: 
[p, msh, lightH] = AFQ_RenderCorticalSurface(im);
% 
% 
% % cortex mesh constructed from a filtered version of the image (will make
% % the cortical surface look more full)
% [p, msh, lightH] = AFQ_RenderCorticalSurface(im,'boxfilter',5);



%% cortex mesh colored by fiber density overlay


msh = AFQ_meshCreate(im);
% msh = AFQ_meshColor(msh, 'overlay', fd, 'thresh',.01, 'crange', [.01 .8], 'cmap', autumn)

% alternatively, the mesh can be created and rendered just using the
% AFQ_RenderCorticalSurface command: 

% [p, msh, lightH] = AFQ_RenderCorticalSurface(...
%     im,'overlay',fd,'crange',[.01 .8],'thresh',.01,'cmap',autumn,'alpha',.5,'newfig',1);

% the command above demonstrates all possible input argument options for
% AFQ_RenderCorticalSurface

% outputs from AFQ_RenderCorticalSurface: 

% p       - Handle for the patch object that was added to the figure
%           window. The rendering can be deleted with delete(p)
% msh     - The mesh object of the cortical surface.
% lightH  - Handle to the light object

% close all 
% clear p msh lightH



%% now color mesh vertices based on ROI and fiber group endpoints 

msh = AFQ_meshCreate(im);

% color mesh based on ROI
dilate = 5;
msh = AFQ_meshAddRoi(msh, roi, [1 0 0], dilate);

% color mesh based on fiber group endpoints 
crange = [1 100];
msh = AFQ_meshAddFgEndpoints(msh, fg, winter, crange);

% render mesh 
[p, msh, lightH] = AFQ_RenderCorticalSurface(msh);

 
close all
clear p msh lightH



%% now plot a fiber group and a cortical mesh 

lightH = AFQ_RenderFibers(fg,'color',[1 0 0],'numfibers',500,'newfig',1)

p = AFQ_RenderCorticalSurface(im, 'boxfilter', 5,'alpha',.5, 'newfig', 0);


% Delete the light object and put a new light to the right of the camera
delete(lightH); % or maybe delete lightH?
lightH=camlight('right');

% Turn of the axes
axis('off');

% ** see CortexandFibersMovie in AFQ tutorials to see how to make a video of this!! 

close all 
clear p msh lightH


    
 


%% now make a mesh of an ROI 

% AFQ_RenderFibers(fg,'color',[0 0 1],'numfibers',100)
 h = AFQ_RenderRoi(roi, [1 0 0],[], 'surface')
 axis off
 

set(h,'FaceAlpha',.5)



%% mesh params that can be set and get: 

% AFQ_meshSet(msh,'color',[1 0 0]) to set a param (eg color)
% AFQ_meshGet(msh,'color')         to set a param 

% 'color' - vector of rgb values. To get, must specify a colorname(?)

% 'triangles' - Get the the current faces, vertices and colors and return 
%   them in a structure that can be rendered with the MATLAB patch function.

% 'vertexcolors' - Get the rgb values of the current mesh vertices.
%
% 'vertexorigin' - Get the original vertices, before any smoothing. These
%   correspond to acpc coordinates of the original segmentaion image.
%
% 'basecolor' - Get the base color that is used to color the mesh surface
%   (without any overlay colors).
%
% 'currentvertexname' - Return the name of the current vertices. These are
%   the ones that will be rendered.

