function results = testClusters(d,cl_means)
% -------------------------------------------------------------------------
% usage: evaluate cluster model estimated on independent data on new test
% data
% 
% INPUT:
%   var1 - integer specifying something
%   var2 - string specifying something
% 
% OUTPUT:
%   var1 - etc.
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 11-May-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %% test clusters on held-out data - kmeans
    
  nc = size(cl_means,1); % number of clusters
  
        % get cluster assignment for held out data
        idx = kmeans(d,nc,'MaxIter',1,'Start',cl_means);
        
        
        % calculate within cluster sum of squared error for each cluster
        for c = 1:nc
            cluster_SSw(c) = sum(pdist2(d(idx==c,:),cl_means(c,:)).^2);
        end
        
        % sum across clusters
        results = sum(cluster_SSw);
        