% render a DA mesh w/fiber endpoints 


%%

clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';
cd(dataDir)

subject = 'sa26'; 

% daStr = 'DA';
roi = readFileNifti([subject '/ROIs/DA.nii.gz']);


method = 'conTrack';

targetsL = {'caudateL','naccL','putamenL'};
targetsR = {'caudateR','naccR','putamenR'};


fgStr = '_autoclean';

% colors
c{1} = [0.965  0.733  0.224]; c{2} = [1 0 0]; c{3} = [0.031  0.271  0.580];
      

%% render DA ROI 


% render a DA ROI mesh 
h=afq_renderMesh(roi,'alpha',1)
axis off
[h,mov] = rotateMesh(h,[10,10],10);

hold on


% load fiber files
fgL = cellfun(@(x) fgRead([subject '/fibers/' method '/' x fgStr '.pdb']), targetsL, 'UniformOutput',0);
fgR = cellfun(@(x) fgRead([subject '/fibers/' method '/' x fgStr '.pdb']), targetsR, 'UniformOutput',0);
  



%%

msh = h.msh;
fg = fgR{3};
colors = [ 0.6196    0.7922    0.8824
    0.4196    0.6824    0.8392
    0.2588    0.5725    0.7765
    0.1294    0.4431    0.7098
    0.0314    0.2706    0.5804];
crange = [];
alpha = 1;
weights = [];
distfun = 'nearpoints';
dilate = 1;

% msh = AFQ_meshAddFgEndpoints(h.msh, fgR{3}, c{3}, [], 1,[], [],1)
 h.msh = AFQ_meshAddFgEndpoints(msh, fg, colors, crange, alpha, weights, distfun, dilate)









% plot a dot at the center of masses
cellfun(@(x) scatter3(x(1),x(2),x(3),50,c{t},'filled'), CoML)
cellfun(@(x) scatter3(x(1),x(2),x(3),50,c{t},'filled'), CoMR)

% save out CoM coords into group_sn/fg_densities directory
% fnameL=fullfile('group_sn','fg_densities',method,[targetsL{t} fdStr '_COM_coords']);
% fnameR=fullfile('group_sn','fg_densities',method,[targetsR{t} fdStr '_COM_coords']);
% dlmwrite(fnameL,cell2mat(CoML'))
% dlmwrite(fnameR,cell2mat(CoML'))

end



%% do it using mean coord for fiber groups, transformed into standard space


% render a DA ROI mesh 
h=afq_renderMesh(roi,'alpha',.3)
axis off
[h,mov] = rotateMesh(h,[10,10],10);

hold on


for i=1:numel(subjects)
    
    
    % load subject's xform info
    load([subjects{i} '/sn/sn_info.mat'])
    
    
    % load fiber files
    fgL = cellfun(@(x) mtrImportFibers([subjects{i} '/fibers/' method '/' x fgStr '.pdb']), targetsL, 'UniformOutput',0);
    fgR = cellfun(@(x) mtrImportFibers([subjects{i} '/fibers/' method '/' x fgStr '.pdb']), targetsR, 'UniformOutput',0);
     
    
   % do SuperFiberRep to get fg mean coords
    sfLs = cellfun(@(x) dtiComputeSuperFiberRepresentation(x, [], 2), fgL);
    sfRs = cellfun(@(x) dtiComputeSuperFiberRepresentation(x, [], 2), fgR);
    
    
    % keep just mean DA endpoint and concatenate L and R cell arrays
    fgL_coords = cellfun(@(x) x(:,1), vertcat(sfLs(:).fibers), 'UniformOutput',0);
    fgR_coords = cellfun(@(x) x(:,1), vertcat(sfRs(:).fibers), 'UniformOutput',0);
    
    
    % transform coords into standard space
    sn_coordsL = cellfun(@(x) mrAnatXformCoords(invDef,x), fgL_coords, 'UniformOutput',0)
    sn_coordsR = cellfun(@(x) mrAnatXformCoords(invDef,x), fgR_coords, 'UniformOutput',0)
    
    
    % plot a dot at the fiber group mean endpoint
    cellfun(@(x,y) scatter3(x(1),x(2),x(3),50,y,'filled'), sn_coordsL',c)
    cellfun(@(x,y) scatter3(x(1),x(2),x(3),50,y,'filled'), sn_coordsR',c)

    % to save out mean sn coords: 
sn_coords_targetL{1}(i,:) = sn_coordsL{1};
sn_coords_targetL{2}(i,:) = sn_coordsL{2};
sn_coords_targetL{3}(i,:) = sn_coordsL{3};
sn_coords_targetR{1}(i,:) = sn_coordsR{1};
sn_coords_targetR{2}(i,:) = sn_coordsR{2};
sn_coords_targetR{3}(i,:) = sn_coordsR{3};
 
end


 % to save out mean sn coords: 
 for t=1:3
     fnameL=fullfile('group_sn','fibers',method,[targetsL{t} '_mean_sn_coords']);
     fnameR=fullfile('group_sn','fg_densities',method,[targetsR{t} '_mean_sn_coords']);
     dlmwrite(fnameL,sn_coords_targetL{t})
     dlmwrite(fnameR,sn_coords_targetR{t})
 end
