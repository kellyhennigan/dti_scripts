% goal: make DA ROI mesh and plot fiber densities or endpts on the it


%%

clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';
cd(dataDir)


% files for group: 

load('ROIs/DA_sn_binary_mask.mat'); 

t1_group = readFileNifti('sn_anat/t1_sn_group_mean.nii.gz');
da_group = readFileNifti('ROIs/DA_sn_binary_mask.nii.gz')

rois = {'nacc','putamen'};

% fd1 = readFileNifti('fd_overlays_sn/caudate_da_endpts_S3_sn.nii.gz');
% fd2 = readFileNifti('fd_overlays_sn/nacc_da_endpts_S3_sn.nii.gz');
% fd3 = readFileNifti('fd_overlays_sn/putamen_da_endpts_S3_sn.nii.gz');


fd=readFileNifti('fd_overlays_sn/nacc_da_endpts_S3_sn_T.nii.gz');
fd2=readFileNifti('fd_overlays_sn/putamen_da_endpts_S3_sn_T.nii.gz');
fd.data=(fd.data.*-1)+fd2.data;


cmap=getFDColors2(); 
% red=cmap{1}; blue=cmap{2};
crange = [-4 4];


close all
clear mov msh a ii alpha M


%% make a mesh of DA ROI & color it according to fiber densities 

h=afq_renderMesh(da_group,'overlay',fd,'cmap',cmap,'crange',crange,'alpha',1,'newfig',1)
axis off 

[h,mov] = rotateMesh(h,[90,30],1);

[h,mov] = rotateMesh(h,[90,0],1);
% to change alpha: 
a=.5
alpha(h.p,a)






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



%% from script plot_examples: 

%% isosurface example

% Example 1
% This example uses the flow data set, which represents the speed profile of a submerged jet within an infinite tank (type help flow for more information). The isosurface is drawn at the data value of -3. The statements that follow the patch command prepare the isosurface for lighting by
% 
% Recalculating the isosurface normals based on the volume data (isonormals)
% 
% Setting the face and edge color (set, FaceColor, EdgeColor)
% 
% Specifying the view (daspect, view)
% 
% Adding lights (camlight, lighting)

figure(1)
[x,y,z,v] = flow;
p = patch(isosurface(x,y,z,v,-3));
isonormals(x,y,z,v,p)
set(p,'FaceColor','red','EdgeColor','none');
daspect([1,1,1])
view(3); axis tight
camlight 
lighting gouraud

%% Draw contour lines on a series of slice planes

% This example uses the flow data set to illustrate the use of contoured 
% slice planes. (Type doc flow for more information on this data set.) 
% 
% Notice that this example:
% 
% Specifies a vector of length = 9 for Sx, 
% an empty vector for the Sy, and a scalar value (0) for Sz. 
% This creates nine contour plots along the x direction in the y-z plane, 
% and one in the x-y plane at z = 0.
% 
% Uses linspace to define a 10-element vector of linearly spaced values 
% from -8 to 2. This vector specifies that 10 contour lines be drawn, 
% one at each element of the vector.
% 
% Defines the view and projection type (camva, camproj, campos).
% 
% Sets figure (gcf) and axes (gca) characteristics.

figure(2)
[x y z v] = flow;
h = contourslice(x,y,z,v,[1:9],[],[0],linspace(-8,2,10));
axis([0,10,-3,3,-3,3]); daspect([1,1,1])
camva(24); camproj perspective;
campos([-3,-15,5])
set(gcf,'Color',[.5,.5,.5],'Renderer','zbuffer')
set(gca,'Color','black','XColor','white', ...
	'YColor','white','ZColor','white')
box on

%% plot 3D ellipsoid
% developed from the original demo by Rajiv Singh
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/42966
% 5 Dec, 2002 13:44:34
% Example data (Cov=covariance,mu=mean) is included.

figure(3)
Cov = [1 0.5 0.3
       0.5 2 0
       0.3 0 3];
mu = [1 2 3]';

[U,L] = eig(Cov);
% L: eigenvalue diagonal matrix
% U: eigen vector matrix, each column is an eigenvector

% For N standard deviations spread of data, the radii of the eliipsoid will
% be given by N*SQRT(eigenvalues).

N = 1; % choose your own N
radii = N*sqrt(diag(L));

% generate data for "unrotated" ellipsoid
[xc,yc,zc] = ellipsoid(0,0,0,radii(1),radii(2),radii(3));

% rotate data with orientation matrix U and center mu
a = kron(U(:,1),xc);
b = kron(U(:,2),yc);
c = kron(U(:,3),zc);

data = a+b+c; n = size(data,2);

x = data(1:n,:)+mu(1);
y = data(n+1:2*n,:)+mu(2);
z = data(2*n+1:end,:)+mu(3);

% now plot the rotated ellipse
% sc = surf(x,y,z); shading interp; colormap copper
h = surfl(x, y, z); colormap copper
title('actual ellipsoid represented by mu and Cov')
axis equal
alpha(0.7)


