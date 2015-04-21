%% Gaussian Mixture Models Analysis
% 
% this script takes in DA-striatal pathways and clusters them using a 
% gaussian mixture model. 

%% define some parameters

numClusters = 2;
uncCluster = 0; % set to 1 to form an additional fiber group based on posterior probability
uncertainCrit = .05; % threshold for inclusion in the uncertain cluster
saveNewFGs = 1; % set to 1 to export new .pdb fiber groups
plotClusters = 0; % set to 1 for plots

%% get data

cd '/home/kelly/data/DTI';
baseDir = pwd;

% load data
load('gmm_data.mat'); % this should load a subjects cell array along with data (indexed according
% to subjects cell array

%% fit a k component Gaussian mixture model

% for i = 1:length(subjects)
  for i=7;
    
    fg_ends = endpts{i};
    fg_ends_trueX = endpts_trueX{i};
    
    %% estimate Gaussian mixture model with n components defined by numClusters
    
    options = statset('Display','final');
    gm = gmdistribution.fit(fg_ends,numClusters,'Options',options);
    idx = cluster(gm, fg_ends);     % gives a cluster index
    c_mu{i} = gm.mu;
    c_strRoi{i,:} = whichStrRoi(subjects{i},c_mu{i}(:,4:6));
    c_strRoi{i} % figure out which striatal ROI the centroid of this fiber group is located in 

    
    %% make another cluster for high uncertainty fibers?
    
    if uncCluster == 1
        P = posterior(gm, fg_ends); % gives the posterior probablity of component 1 in column 1, comp. 2 in column 2, etc.
        chance = 1./numClusters; % e.g. .5 for 2 clusters, .33 for 3 clusters
        uncertainIdx = (P(:,1) > chance - uncertainCrit & P(:,1) < chance + uncertainCrit);
        idx(uncertainIdx) = numClusters + 1;
    end
    
    %% make a cluster index
    
    for c = 1:max(idx)    % number of clusters (numClusters + 1 if there's an uncertainCluster)
        component{c} = (idx == c);
    end
    
    %% save new cluster fiber groups?
    
    if saveNewFGs == 1  % make fiber group files and export
        fgDir = fullfile(baseDir, subjects{i}, 'fibers', 'conTrack');
        cd(fgDir);
        
        for c = 1:max(idx)
            
            fiberCluster = strFGs(i);   % copy the .pdb file's format
            fiberCluster = downsampleFibers(fiberCluster,component{c});  % returns only fibers in cluster according to component{c}
            fprintf('\n Saving fiber cluster %d with %d fibers for subject %s \n', c, length(fiberCluster.fibers), subjects{i});
            if c == numClusters + 1
                fiberCluster.name = ['gmm_uncertain_cluster.pdb'];
            else
                fiberCluster.name = ['gmm_', num2str(c),'_of_' num2str(numClusters) '_clusters.pdb'];
            end
            mtrExportFibers(fiberCluster, fiberCluster.name);   % save fiber Cluster as a .pdb file
%             ds_indx = randn(length(fiberCluster.fibers),1) > .5;  % create a logical index to keep about half of these fibers so 
%             ds_fiberCluster = downsampleFibers(fiberCluster,ds_indx);   % downsample # of fibers so Quench doesn't crash when loading
            strIndx = strfind(fiberCluster.name, '.pdb');
%             ds_fiberCluster.name = [fiberCluster.name(1:strIndx-1), '_ds.pdb'];
%             mtrExportFibers(ds_fiberCluster, ds_fiberCluster.name);   % save downsampled fiber cluster
            
            % work around so Quench doesn't crash when loading fibers
            fg = mtrImportFibers(fiberCluster.name);
            fg = dtiClearQuenchStats(fg);
            mtrExportFibers(fg, fg.name);
%             fg = mtrImportFibers(ds_fiberCluster.name);
%             fg = dtiClearQuenchStats(fg);
%             mtrExportFibers(fg, fg.name);
            
            % now save DA endpoints and striatal endpoints as separate
            % files
            [fg1, fg2] = getFiberEnds(fg);
             mtrExportFibers(fg1, fg1.name);  
             mtrExportFibers(fg2, fg2.name); 
        end
    end % clusters
    
    
    
    
    
    
    
    
    
    
    
    %% plot clusters?
    
    if plotClusters == 1
        figsDir = fullfile(baseDir, 'gmm_figs');
        gmm_plots(figsDir, fg_ends_trueX, component, i);
    end
    %     clear subjDir fibersDir fg_ends fg_ends_trueX gm idx cluster c fiberCluster
    
end

%% info on Gaussian Mixture Model objects in Matlab

% obj = gmdistribution(mu,sigma)
%
% constructs an object obj of the gmdistribution class defining a Gaussian mixture distribution.
%
% mu is a k-by-d matrix specifying the d-dimensional mean of each of the k components.
%
% sigma specifies the covariance of each component.
%
% CovType       Type of covariance matrices
% DistName      Type of distribution
% Mu            Input matrix of means MU
% NComponents	Number k of mixture components
% NDimensions	Dimension d of multivariate Gaussian distributions
% PComponents	Input vector of mixing proportions
% SharedCov     true if all covariance matrices are restricted to be the same
% Sigma         Input array of covariances
%
% Objects constructed with fit have the additional properties listed in the following table.
% AIC           Akaike Information Criterion
% BIC           Bayes Information Criterion
% Converged     Determine if algorithm converged
% Iters         Number of iterations
% NlogL         Negative of log-likelihood
% RegV          Value of 'Regularize' parameter


