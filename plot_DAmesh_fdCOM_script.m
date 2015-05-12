
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


CoMcoords = getFDCoMCoords(targets, method); 
CoMcoordsR = getFDCoMCoords(targetsR, method); 

   
cols=getDTIColors(1:3); % fd colors   


%% do it


% render a DA ROI mesh 
msh = AFQ_meshCreate(da,'alpha',.7);

msh_idx = cell2mat(cellfun(@(x) nearpoints(x', msh.vertex.origin'), CoMcoords, 'UniformOutput',0))';
for j=1:size(msh_idx,2)
    for i=1:size(msh_idx,1)
        msh.tr.FaceVertexCData(msh_idx(i,j),:) = cols(j,:);
    end
end


h=afq_renderMesh(msh)
axis off
[h,mov] = rotateMesh(h,[2,2],200);




