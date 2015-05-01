% render a mesh of the group DA mesh and place 1 dot at the mean coord of
% subjects' L and R fiber endpoints. 


%%

clear all
close all


% get experiment-specific paths and cd to main data dir
p = getDTIPaths; cd(p.data);


subjects = getDTISubjects;

% daStr = 'DA';
da = readFileNifti('group_sn/ROIs/DA_sn_binary_mask.nii.gz');


method = 'conTrack';

targetsL = {'caudateL','naccL','putamenL'};
targetsR = {'caudateR','naccR','putamenR'};

fdStr = '_da_endpts_S3_sn';

fgStr = '_autoclean';

% colors
c{1} = [0.965  0.733  0.224]; c{2} = [1 0 0]; c{3} = [0.031  0.271  0.580];
    
t1=readFileNifti('group_sn/t1/t1_sn.nii.gz')

%% do it using fiber density center of mass 


% render a DA ROI mesh 
h=afq_renderMesh(da,'alpha',.3)
axis off
hold on

AFQ_AddImageTo3dPlot(t1,[0 -18 0])
axis off

[h,mov] = rotateMesh(h,[10,10],10);


CoML = getFDCoMCoords(targetsL, method, fdStr);
CoMR = getFDCoMCoords(targetsR, method, fdStr);

cellfun(@(x,y) scatter3(x(1,:),x(2,:),x(3,:),100,y,'filled'), CoML, c);
cellfun(@(x,y) scatter3(x(1,:),x(2,:),x(3,:),100,y,'filled'), CoMR, c);



