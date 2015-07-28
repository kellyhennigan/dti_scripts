
clear all
close all


% get experiment-specific paths and cd to main data dir
p = getDTIPaths; cd(p.data);

subjects = getDTISubjects; subject = 'group_sn';

method = 'conTrack';

space = 'sn';

targets = {'caudateL','caudateR';
    'naccL','naccR';
    'putamenL','putamenR'};


t1=readFileNifti([subject '/t1/t1_sn_x2.nii.gz']);

da = readFileNifti([subject '/ROIs/DA_sn_binary_mask.nii.gz']);

cols = getDTIColors('cell',1:3); % colors

% if L and R targets are included, add columns to cols array to match size
if size(targets,2)==2
    cols = repmat(cols,1,2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get fiber groups center of mass and load files 


CoM = getFDCoMCoords(targets, method,'da_endpts_S3',space);

% get image coordinates 
imgCoM = cellfun(@(x) mrAnatXformCoords(t1.qto_ijk,x), CoM,'UniformOutput',0);

% get min, max, and mean coords
maxCoM = max(cell2mat(cellfun(@max, CoM,'UniformOutput',0)));
minCoM = min(cell2mat(cellfun(@min, CoM,'UniformOutput',0))); 
mC = cellfun(@mean, CoM,'UniformOutput',0); % mean
   
% 95% confidence intervals of the mean coord
[h,p,ci,stats]=cellfun(@ttest, CoM,'UniformOutput',0);
ci=cellfun(@(x,y) x-y(1,:), mC, ci, 'UniformOutput',0);



%% plot center of mass dots 

figure
hold on
cellfun(@(x,y) scatter3(x(:,1),x(:,2),x(:,3),50,y,'filled'), CoM, cols)

xlabel('x'); ylabel('y'); zlabel('z');

% make it rotatable
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');

view(3)
axis equal
ax0=axis;


%% plot 3d ellipses around 95% confidence intervals of mean coords


[xe,ye,ze]=cellfun(@(x,y) ellipsoid(x(1),x(2),x(3),y(1),y(2),y(3),50), mC, ci, 'UniformOutput',0);
h=cellfun(@surf, xe,ye,ze, 'UniformOutput',0);
cellfun(@(x,y) set(x,'EdgeColor','none','FaceColor',y,'FaceAlpha',.3), h,cols, 'UniformOutput',0);



%% plot DA mesh 


% render a DA ROI mesh 
h=afq_renderMesh(da,'alpha',.3,'newfig',0)
% axis off


[h,mov] = rotateMesh(h,[10,10],10);



%% plot contourslice

sl = [0 0 -12]; % slice and plane for contour plot

t1.data(da.data>0) = 50; % to give the da roi a strong contour line

[h,d]=plotNiiContourSlice(t1,sl);

axis(ax0)


%% plot an image slice 


AFQ_AddImageTo3dPlot(t1,[0 0 -12])
% axis off


% make it rotatable
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');


hold off 
