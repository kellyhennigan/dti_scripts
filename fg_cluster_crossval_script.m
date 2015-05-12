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

method = 'mrtrix';
matName = ['DA_striatum' LR '_sn.mat'];  % mat name that contains cell array of endpts


cl_method = 'kmeans'; % cl_method = 'gmm';

maxK = 6;  % max number of clusters to try 

ns = 900; % # of sample fibers to take from each sub


%% load and format subject data

load(fullfile('group_sn','fg_endpts',method,matName));


% get a random sample of ns fibers from each subject
d=cellfun(@(x) x(randperm(size(x,1),ns),:), subj_endpts, 'UniformOutput',0)'; % data in cell array dc

nSubs = numel(d);



%% do it - cross validation method

% create a square identity matrix w/zeros indexing subjects to use in the
% training set and 1 indicating subject data to use as a test set
test_mat = eye(nSubs);

results = nan(nSubs,maxK);  % define a matrix to store results

i=1;
for i = 1:nSubs
    
    d_train = cell2mat(d(test_mat(i,:)==0));  % training data
    d_test = cell2mat(d(test_mat(i,:)==1));   % test data
    
    
    % estimate cluster model params
    [cl_idx,cl_means,err_metric] = cellfun(@(x) clusterEndpts(d_train,x,cl_method),num2cell(1:maxK), 'UniformOutput',0);
    
    results(i,:) = cellfun(@(x) testClusters(d_test,x), cl_means);

    
end % subjects


%% plot results


figure
plot(1:maxK,mean(results),'.-','markersize',10)
set(gca,'XTick',[1:maxK])
xlabel('number of clusters')
ylabel('within cluster sum of squares')
title('where that elbow at?')


