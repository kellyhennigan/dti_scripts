% plot a da mesh w/2d anatomical bg slices 

%%

clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';
cd(dataDir)

subject = 'sa01';

t1 = readFileNifti([subject '/t1/t1_fs.nii.gz']);

da=readFileNifti([subject '/ROIs/DA.nii.gz']);


%%

% render da mesh
h=afq_renderMesh(da,'alpha',.3)
axis off
hold on


% add a slice at y=-18
AFQ_AddImageTo3dPlot(t1,[0 -18 0])
axis off

% rotate it 
[h,mov] = rotateMesh(h,[10,10],10);

% add a slice at z=-10
AFQ_AddImageTo3dPlot(t1,[0 0 -10])

% rotate it 
[h,mov] = rotateMesh(h,[10,10],10);

