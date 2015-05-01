
% render a mesh of the group DA mesh and color the face of the mesh
% according to where fiber endpt center of masses are located. 


%%

clear all
close all


% get experiment-specific paths and cd to main data directory
p=getDTIPaths(); cd(p.data);

subjects = getDTISubjects;

% daStr = 'DA';
da = readFileNifti('group_sn/ROIs/DA_sn_binary_mask.nii.gz');


method = 'conTrack';

targetsL = {'caudateL','naccL','putamenL'};
targetsR = {'caudateR','naccR','putamenR'};

targets = {'caudateL','caudateR';
    'naccL','naccR';
    'putamenL','putamenR'};


CoMcoordsL = getFDCoMCoords(targetsL, method); 
CoMcoordsR = getFDCoMCoords(targetsR, method); 

   
cols=getFDColors; % fd colors   


%% do it


% render a DA ROI mesh 
msh = AFQ_meshCreate(da,'alpha',.7);


% h.msh = afq_plotPointsOnMesh(msh, coords(:,s), colors, crange);
% h=afq_renderMesh(h.msh)
% axis off
% [h,mov] = rotateMesh(h,[10,10],10);

for j=1:3
    
    col = cols{j}(5,:);
    coordsL = CoMcoordsL{j}';
    coordsR = CoMcoordsR{j}';
    
for s=1:24
    
msh_idxL = nearpoints(coordsL(:,s), msh.vertex.origin');
msh.tr.FaceVertexCData(msh_idxL,:) = col;

msh_idxR = nearpoints(coordsR(:,s), msh.vertex.origin');
msh.tr.FaceVertexCData(msh_idxR,:) = col;

end

end

h=afq_renderMesh(msh)
axis off
[h,mov] = rotateMesh(h,[2,2],200);




