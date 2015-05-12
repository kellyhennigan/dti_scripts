
function [h,hm] = plot_fgClusters(d,cl_means,cl_idx,LR)
% -------------------------------------------------------------------------
% usage: takes in fiber cluster info and plots it
% 
% INPUT:
%   d - N x p matrix of data w/N observations and p dimensions 
%   cl_means - cluster means
%   cl_idx - Nx1 index vector specifying which cluster each obs belongs to
%   LR - 'L' for left or 'R' for right (just used to figure out which roi
%        mask to load
%    

% OUTPUT:
%   h - fig handles
%   h - structural arrays with mesh handles and camera objects 
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 07-May-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


% colors for plotting
colors = getDTIColors([4,1,5]);

if size(cl_means,1)==2
    colors(2,:) = [];
end

% load some nift files for background
t1 = readFileNifti('group_sn/t1/t1_sn_x2.nii.gz');
roi{1}=readFileNifti('group_sn/ROIs/DA_sn_binary_mask_x2.nii.gz');
roi{2}=readFileNifti(['group_sn/ROIs/striatum_3dconn_x2' LR '.nii.gz']);


% t1 = readFileNifti('group_sn/t1/t1_sn.nii.gz');
% roi{1}=readFileNifti('group_sn/ROIs/DA_sn_binary_mask.nii.gz');
% roi{2}=readFileNifti(['group_sn/ROIs/striatum-con-label-thr25-3sub-2mm' LR '.nii.gz']);

t1.data(roi{1}.data~=0)=max(t1.data(:))+1; % do this so that the DA roi mask is white


ax1 = [-30 30 -30 -10 -25 -5]; % this is an ok axis for DA endpts
% ax1 = [-20,4,-28,-4,-24,0];

ax2 = [-40,20,-18,30,-36,36];  % " " for striatum endpts


% get 3-column vector of rgb values according to cluster assignment
[~,b]=sort(cl_means(:,6));
colors = colors(b,:);
cols = getRgbVec(cl_idx,colors);


%% fig 1


h(1) = figure; hold on;
pos=get(gcf,'Position'); % get default position placement

scatter3(d(:,1),d(:,2),d(:,3),2,cols,'filled')
view(3)  % view(-20,20)
axis equal
ax0 = axis;

%     AFQ_AddImageTo3dPlot(da,[0 -18 0],flipud(gray))
plotNiiContourSlice(t1,[0 -18 0]);
axis(ax1);
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
xlabel('x'), ylabel('y'), zlabel('z')
title('DA endpoints')
hold off



%% fig 2

h(2) = figure; hold on;
set(gcf,'Position',[pos(1),pos(2)-20,pos(3),pos(4)])


scatter3(d(:,4),d(:,5),d(:,6),2,cols,'filled')
view(3)
axis equal
ax02 = axis;

% AFQ_AddImageTo3dPlot(t1,[0 1 0],flipud(gray))

plotNiiContourSlice(t1,[0 -1 0]);
axis(ax2);
hold off
grid off
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
xlabel('x'), ylabel('y'), zlabel('z')
title('Striatum endpoints')


%% mesh figures

for i = 1:2
    
%     h(i+2) = figure; hold on;
%     set(gcf,'Position',[pos(1),pos(2)-40,pos(3),pos(4)])

    % create a DA ROI mesh
    msh = AFQ_meshCreate(roi{i},'alpha',.7);
    msh = plot_pointsOnMesh(msh, d(:,3*(i-1)+1:3*(i-1)+3), cl_idx,colors);
    hm(i) = afq_renderMesh(msh); hold on
    axis off
    [hm(i),mov] = rotateMesh(hm(i),[2,2],1);
    hold off
    
end







