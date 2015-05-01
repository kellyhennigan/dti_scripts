%% Gaussian Mixture Models - Example

% obj = gmdistribution(mu,sigma)
% 
% constructs an object obj of the gmdistribution class defining a Gaussian mixture distribution.
% 
% mu is a k-by-d matrix specifying the d-dimensional mean of each of the k components.
% 
% sigma specifies the covariance of each component. 

%% Clustering with Gaussian Mixtures (demo)
% 
% http://www.mathworks.com/help/toolbox/stats/bq_679x-24.html
% 
% 
clear all
close all

% Gaussian mixture distributions can be used for clustering data, 
% by realizing that the multivariate normal components of the fitted model 
% can represent clusters.

%  1.   To demonstrate the process, first generate some simulated data 
%  from a mixture of two bivariate Gaussian dist.s using the mvnrnd function:

    mu1 = [1 2];
    sigma1 = [3 .2; .2 2];
    mu2 = [-1 -2];
    sigma2 = [2 0; 0 1];
    X = [mvnrnd(mu1,sigma1,200);mvnrnd(mu2,sigma2,100)];
    figure(1)
    scatter(X(:,1),X(:,2),10,'ko')

% 2.Fit a two-component Gaussian mixture distribution. 
% Here, you know the correct number of components to use. 
% In practice, with real data, this decision would require 
% comparing models with different numbers of components.

options = statset('Display','final');
gm = gmdistribution.fit(X,2,'Options',options);

% This displays: ' 49 iterations, log-likelihood = -1207.91'

% 3. Plot the estimated probability density contours for the two-component 
% mixture distribution. The two bivariate normal components overlap, but 
% their peaks are distinct. This suggests that the data could reasonably be 
% divided into two clusters:

hold on
ezcontour(@(x,y)pdf(gm,[x y]),[-8 6],[-8 6]);
hold off

% 4. Partition the data into clusters using the cluster method for the 
% fitted mixture distribution. The cluster method assigns each point to 
% one of the two components in the mixture distribution.

idx = cluster(gm,X);
cluster1 = (idx == 1);
cluster2 = (idx == 2);
figure(2)
scatter(X(cluster1,1),X(cluster1,2),10,'r+');
hold on
scatter(X(cluster2,1),X(cluster2,2),10,'bo');
hold off
legend('Cluster 1','Cluster 2','Location','NW')

% Each cluster corresponds to one of the bivariate normal components 
% in the mixture distribution. cluster assigns points to clusters based 
% on the estimated posterior probability that a point came from a component; 
% each point is assigned to the cluster corresponding to the highest 
% posterior probability. The posterior method returns those posterior probabilities.
% 
% For example, plot the posterior probability of the first component for each point:

P = posterior(gm,X);
figure(3)
scatter(X(cluster1,1),X(cluster1,2),10,P(cluster1,1),'+')
hold on
scatter(X(cluster2,1),X(cluster2,2),10,P(cluster2,1),'o')
hold off
legend('Cluster 1','Cluster 2','Location','NW')
clrmap = jet(80); colormap(clrmap(9:72,:))
ylabel(colorbar,'Component 1 Posterior Probability')

% An alternative to the previous example is to use the posterior 
% probabilities for "soft clustering". Each point is assigned a membership 
% score to each cluster. Membership scores are simply the posterior
% probabilities, and describe how similar each point is to each cluster's 
% archetype, i.e., the mean of the corresponding component. The points 
% can be ranked by their membership score in a given cluster:

figure(4)
[~,order] = sort(P(:,1));
plot(1:size(X,1),P(order,1),'r-',1:size(X,1),P(order,2),'b-');
legend({'Cluster 1 Score' 'Cluster 2 Score'},'location','NW');
ylabel('Cluster Membership Score');
xlabel('Point Ranking');

AIC = zeros(1,4);
obj = cell(1,4);
for k = 1:4
    obj{k} = gmdistribution.fit(X,k);
    AIC(k)= obj{k}.AIC;
end

[minAIC,numComponents] = min(AIC);

model = obj{2};


