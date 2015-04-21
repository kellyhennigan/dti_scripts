%% estimation components for fiber groups using Gaussian Mixture models

% 
% load('kmeans2clusters.mat');
% 
subjects = {'ak090724','am090121','db061209','er100302',...
'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};

mycolors = [
    23 113 181
    16 77 124
    34, 99, 81
    155 142 28
    242 173 10
    255, 98, 0
    223 62 44
    187, 33, 90
    136 22 112]./255;

colormap(mycolors);

maxClusters = 30;

for i = 1:length(subjects)
    
    fg_ends = endpts{i};
    %fg_ends_trueX = endpts_trueX{i};
    
    % estimate Gaussian mixture model with 2 components
    options = statset('Display','final');
    BIC{i} = zeros(1,maxClusters);
    obj = cell(1,maxClusters);
    
    for c = 1:maxClusters
        obj{c} = gmdistribution.fit(fg_ends,c,'Options',options);
        BIC{i}(c)= obj{c}.BIC;
    end
    
    [minBIC,numComponents] = min(BIC{i});
    numComponents_minBIC(i) = numComponents;
    
    fprintf('\n\n %d components is the optimal number for subject %s\n\n', numComponents, subjects{i});
clear fg_ends fg_ends_trueX gm obj numComponents minBIC
end

model = obj{2};

    
    
    
    figure(i)
    clf
    subplot(2,2,1);
    scatter3(fg_ends_trueX(cluster1,1), fg_ends_trueX(cluster1,2), fg_ends_trueX(cluster1,3),10, mycolors(2,:));
    hold on
    scatter3(fg_ends_trueX(cluster2,1), fg_ends_trueX(cluster2,2), fg_ends_trueX(cluster2,3),10, mycolors(7,:));
    scatter3(fg_ends_trueX(cluster3,1), fg_ends_trueX(cluster3,2), fg_ends_trueX(cluster3,3),10, mycolors(5,:));
    hold off
    legend('Cluster 1','Cluster 2','Cluster 3','Location','NW')
    subplot(2,2,2);
    scatter3(fg_ends_trueX(cluster1,4), fg_ends_trueX(cluster1,5), fg_ends_trueX(cluster1,6),10, mycolors(2,:));
    hold on
    scatter3(fg_ends_trueX(cluster2,4), fg_ends_trueX(cluster2,5), fg_ends_trueX(cluster2,6),10, mycolors(7,:));
    scatter3(fg_ends_trueX(cluster3,4), fg_ends_trueX(cluster3,5), fg_ends_trueX(cluster3,6),10, mycolors(5,:));
    hold off
    legend('Cluster 1','Cluster 2','Cluster 3','Location','NW')
    
    % 2-D plot at y=-16 for DA ROI and y=0 for striatum ROI
    y1 = (fg_ends_trueX(:,2) >= -16.5 & fg_ends_trueX(:,2) < -15.5);
    y1c1 = (y1 & cluster1);
    y1c2 = (y1 & cluster2);
    y1c3 = (y1 & cluster3);
    y2 = (fg_ends_trueX(:,5) >= -1 & fg_ends_trueX(:,5) < 1);
    y2c1 = (y2 & cluster1);
    y2c2 = (y2 & cluster2);
    y2c3 = (y2 & cluster3);
    subplot(2,2,3);
    scatter(fg_ends_trueX(y1c1,1), fg_ends_trueX(y1c1,3),10, mycolors(2,:));
    hold on
    scatter(fg_ends_trueX(y1c2,1), fg_ends_trueX(y1c2,3),10, mycolors(7,:));
    scatter(fg_ends_trueX(y1c3,1), fg_ends_trueX(y1c3,3),10, mycolors(5,:));
    hold off
    legend('Cluster 1','Cluster 2','Cluster 3','Location','NW')
    subplot(2,2,4);
    scatter(fg_ends_trueX(y2c1,4), fg_ends_trueX(y2c1,6),10, mycolors(2,:));
    hold on
    scatter(fg_ends_trueX(y2c2,4), fg_ends_trueX(y2c2,6),10, mycolors(7,:));
    scatter(fg_ends_trueX(y2c3,4), fg_ends_trueX(y2c3,6),10, mycolors(5,:));
    hold off
    legend('Cluster 1','Cluster 2','Cluster 3','Location','NW')
    BIC3(i) = gm.BIC;
    BIC3(i) = gm.BIC;
    
     clear fg_ends fg_ends_truX gm idx cluster n
end
