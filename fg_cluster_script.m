% clustering analysis on dti data

% estimate clusters as a group or individually?
% use k-means or gmm?
% use cross-validation, Cramer's V, or ??
%

%% define directories and file names

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;

LR = 'R'; % left or right

method = 'conTrack';
matName = ['DA_striatum' LR '_sn.mat'];  % mat name that contains cell array of endpts


cl_method = 'gmm'; % cl_method = 'gmm';

maxK = 5;  % max number of clusters to evaluate

ns = 2000; % # of sample fibers to take from each sub

doGroupEstimation = 1; % 1 to estimate clusters as a group, otherwise 0 to do it individually


%% load and format subject data

load(fullfile('group_sn','fg_endpts',method,matName));


% get a random sample of ns fibers from each subject
d=cellfun(@(x) x(randperm(size(x,1),ns),:), subj_endpts, 'UniformOutput',0)'; % data in cell array dc


% to estimate all subjects together, concatenate all data into 1 cell:
if doGroupEstimation
    d{1} = cell2mat(d); d(2:end) = [];
end

nSubs = numel(d);


%% do it - fit each subj individually

k=1;
for k = 1:maxK
    [cl_idx(k),cl_means(k),err_metric] = cellfun(@(x) clusterEndpts(x,k,cl_method),d, 'UniformOutput',0);
    results(:,k) = cell2mat(err_metric);  % for k-means, this is R2, for gmm, its BIC
end


%% plot results

switch lower(cl_method)
    case 'gmm'
        ylab = 'mean bayesian info criterion';
    case 'kmeans'
        ylab = 'mean fractional variance explained';
end

figure
plot(1:maxK,mean(results),'.-','markersize',10)
set(gca,'XTick',[1:maxK])
xlabel('number of clusters')
ylabel(ylab)
title('where that elbow at?')


%% plot segmentation w/X clusters

cl_plot = 2;
[h,hm] = plot_fgClusters(d{1},cl_means{cl_plot},cl_idx{cl_plot},LR);

[hm(1),mov] = rotateMesh(hm(1),[0,1],1);
[hm(2),mov] = rotateMesh(hm(2),[1,0],1);



%% save


%%  get index of closest striatal roi

% roiNames = {'caudate','nacc','putamen'};
% roiPaths = cellfun(@(x) fullfile(subj,'ROIs',[x '.mat']), roiNames, 'UniformOutput',0);
% [roi_idx,d] = closestRoi(gm.mu(:,4:6),roiPaths);


