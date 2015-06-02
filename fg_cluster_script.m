% clustering analysis on dti data. use this script and/or
% fg_cluster_cross_script to determine the best # of clusters to use.



%% define directories and file names

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;

LR = 'R'; % left or right

data_type = 'fg_endpts/conTrack';  % 'fg_endpts/mrtrix', 'fg_endpts/conTrack', or 'tensors'

% dataFileName = ['tensor_values_DA_' LR '.mat'];
dataFileName = ['DA_striatum' LR '_sn.mat'];

cl_method = 'kmeans'; % 'gmm' or 'kmeans'

data_fit_type = 'group'; % 'subj' or 'group'

maxK = 6;  % max number of clusters to evaluate

figName = [LR '_' data_fit_type '_' cl_method];



%% load and format subject data

load(['cluster_data/' data_type '/' dataFileName]);

% get a random sample of ns fibers from each subject
ns = min([2000,(cellfun(@length, subj_data'))]); % take this # of samples from every sub
X=cellfun(@(x) x(randperm(size(x,1),ns),:), subj_data, 'UniformOutput',0); % data in cell array dc
% X = subj_data;

D = size(X{1},2); % number of dimensions in data

% concanate subject data for cluster fitting if desired
if strcmpi(data_fit_type,'group')
    X{1} = cell2mat(X); X(2:end) = [];
end

nDSets = numel(X);


%% estimate clustering

results = nan(nDSets,maxK);  % define a matrix to store results

i=1;
for i = 1:nDSets
    
    for K = 1:maxK
        
        switch cl_method
            
            case 'gmm'
                
                %%%%%%%%%%% estimate model
                gm = fitgmdist(X{i},K);  % estimate mixture model
                %         cl_idx = cluster(gm, Xtrain);     % gives a cluster index
                
                err_metric_str = 'BIC'; % name of error metric
                results(i,K) = gm.BIC;  % bayesian info criterion
                
            case 'kmeans'
                
                %%%%%%%%%%% estimate model
                [cl_idx,cl_means,sumd]=kmeans(X{i},K,'MaxIter',1000); % estimate k-means clusters
                SSe = sum(sumd);       % calculate within cluster sum of squares
                SSt = sum(pdist2(X{i},mean(X{1})).^2); % calculate total sum of squares
                R2 = 1 - SSe./SSt; % fractional variance
                
                err_metric_str = 'SSe'; % name of error metric
                results(i,K) = SSe;  % either use SSe or R2
                
%                                 err_metric_str = 'R2'; % name of error metric
%                                 results(i,K) = R2;  % either use SSe or R2
                
        end  % cl_method
        
    end % K
    
end % nDSets

%% plot results


cd(p.figures)

figure
plot(1:maxK,mean(results,1),'.-','markersize',20,'color',[0 0 0])
set(gca,'XTick',1:maxK)
xlabel('number of clusters')
ylabel(err_metric_str)
%     title('where that elbow at?')

cd(p.figures); cd clustering;
cd(data_type)
saveas(gcf,figName,'pdf');

