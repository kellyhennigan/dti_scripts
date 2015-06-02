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

LR = 'L';
% data_type = 'tensors';
data_type = 'fg_endpts/mrtrix';

% dataFilePath = ['cluster_data/' data_type '/tensor_values_DA_' LR '.mat'];
dataFilePath = ['cluster_data/' data_type '/DA_striatum' LR '_sn.mat'];

cl_method = 'kmeans'; % 'gmm' or 'kmeans'
km_method = 'sse'; %  kmeans error metric - either sse or crv (Cramer's V)

maxK = 6;  % max number of clusters to evaluate

data_fit_type = 'subj'; % 'subj' to cross validate each subject individually or 'group' to do leave one out

figName = [LR '_crossval_' data_fit_type '_' cl_method];


%% load and format subject data

load(dataFilePath)

if strcmp(data_fit_type,'group')
    
    
    % get a random sample of ns fibers from each subject
    ns = min([2000,(cellfun(@length, subj_data'))]); % take this # of samples from every sub
    X=cellfun(@(x) x(randperm(size(x,1),ns),:), subj_data, 'UniformOutput',0); % data in cell array dc
    
% create a square identity matrix w/zeros indexing subjects to use in the
% training set and 1 indicating subject data to use as a test set
test_mat = eye(nSubs);

else
    X = subj_data;
end

nSubs = numel(X);
D = size(X{1},2); % number of dimensions in data



%% estimate clustering

results = nan(nSubs,maxK);  % define a matrix to store results

i=1;
for i = 1:nSubs
    
    if strcmp(data_fit_type,'group')
        
        Xtrain = cell2mat(X(test_mat(i,:)==0));  % training data
        Xtest = cell2mat(X(test_mat(i,:)==1));   % test data
        
    else  % perform data fitting for eahc subject individually
        
        Xtrain = X{i};
        test_idx = randperm(size(Xtrain,1),round(size(Xtrain,1)./10)); 
        Xtest = Xtrain(test_idx,:);
        Xtrain(test_idx,:)=[];
        
    end
    
    K=1;
    for K=1:maxK
        
        switch cl_method
            
            case 'gmm'
                
                %%%%%%%%%%% estimate model
                gm = fitgmdist(Xtrain,K);  % estimate mixture model
                %         cl_idx = cluster(gm, Xtrain);     % gives a cluster index
                
                
                %%%%%%%%%%% evaluate model on heldout test data
                [~,nll]=posterior(gm,Xtest);
                
                
                err_metric_str = 'negative log-likelhood'; % name of error metric
                results(i,K) = nll; % neg log likelihood of held out data is the test metric
                
            case 'kmeans'
                
                %%%%%%%%%%% estimate model
                [cl_idx_train,cl_means_train,sumd_train]=kmeans(Xtrain,K,'MaxIter',1000); % estimate k-means clusters
                SSe_train = sum(sumd_train);       % calculate within cluster sum of squares
                SSt_train = sum(pdist2(Xtrain,mean(Xtrain)).^2); % calculate total sum of squares
                R2_train = 1 - SSe_train./SSt_train; % fractional variance
                
                
                %%%%%%%%%%% evaluate model on held out test data
                % get cluster assignment for held out data based on training set
                cl_idx_test = kmeans(Xtest,K,'MaxIter',1,'Start',cl_means_train);
                
                
                if strcmpi(km_method,'sse')
                    %%%% metric 1: calculate SSe on test data w/ model fit on training data
                    for k = 1:K
                        cluster_SSe(k) = sum(pdist2(Xtest(cl_idx_test==k,:),cl_means_train(k,:)).^2);
                    end
                    % total sum of squared error for test data
                    SSe = sum(cluster_SSe);
                    
                    err_metric_str = 'sum of squared error'; % name of error metric
                    results(i,K) = SSe;
                    
                elseif strcmpi(km_method,'crv')
                    %%%% metric 2: use cramer's v to see how well model fit on
                    % training data can predict test data
                    n = size(Xtest,1);  % # of observations/samples
                    
                    cl_idx_test0 = kmeans(Xtest,K); % get best fit kmeans clusters for test data
                    
                    % check agreement between best fit model and model predictd by training data
                    [tbl,chi2stat,pval]=crosstab(cl_idx_test0,cl_idx_test);
                    cramersV =  sqrt(chi2stat./(n.*(K-1))); % Cramer's V
                    
                    err_metric_str = 'Cramers V'; % name of error metric
                    results(i,K) = cramersV;
                    
                end % km_method
                
        end % cl_method
        
    end % maxK
    
end % subjects


%% plot results

if strcmpi(cl_method,'kmeans')
    figName = [figName '_' km_method];
end

figure
plot(1:maxK,mean(results),'.-','markersize',20,'color',[0 0 0])
set(gca,'XTick',1:maxK)
xlabel('number of clusters')
ylabel(err_metric_str)
%     title('where that elbow at?')

cd(p.figures); cd clustering;
cd(data_type)
saveas(gcf,figName,'pdf');

