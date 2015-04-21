%% Gaussian Mixture Models Analysis

function gmm_plots(figsDir, fg_ends_trueX, cluster, i) 
%
% i is subject loop number
% cluster is 1 x numClusters cell array with boolean index of cluster
% number
% fg_ends_trueX is fiber group endpoints with real X-coordinates (as
% opposed to absolute value)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define some colors

% dorsal ventral tier colors
mycolors = [
    244 101 7
    44 129 162
    255, 98, 0]./255;

mycolors2 = [
     23 113 181
    16 77 124
    34, 99, 81
    70, 148, 126
    155 142 28
    242 173 10
    255, 98, 0
    223 62 44
    187, 33, 90
    136 22 112]./255;

colormap(mycolors);

%% make some plots
    
    %% 3D scatter plots
    % scatter3(fg_ends(:,1), fg_ends(:,2), fg_ends(:,3),5,mycolors(5,:));
    fig = figure(i)
    clf
    subplot(2,2,1);
    for c = 1:length(cluster)
        scatter3(fg_ends_trueX(cluster{c},1), fg_ends_trueX(cluster{c},2), fg_ends_trueX(cluster{c},3),10, mycolors(c,:));
    hold on
    end
    hold off
%     legend('Cluster 1','Cluster 2','Location','NW')
    subplot(2,2,2);
     for c = 1:length(cluster)
        scatter3(fg_ends_trueX(cluster{c},4), fg_ends_trueX(cluster{c},5), fg_ends_trueX(cluster{c},6),10, mycolors(c,:));
    hold on
    end
    hold off
   
    
    %% 2D scatter plot at y=-16 for DA ROI and y=0 for striatum ROI
%     yDA = (fg_ends_trueX(:,2) >= -16.5 & fg_ends_trueX(:,2) < -15.5);
%     y1{1} = (yDA & cluster{c});
%     y1{2} = (yDA & cluster{c});
%     yStr = (fg_ends_trueX(:,5) >= -1 & fg_ends_trueX(:,5) < 1);
%     y2{1} = (yStr & cluster{c});
%     y2{2} = (yStr & cluster{c});
%     
% coronal
 subplot(2,2,3);
    for c = 1:length(cluster)
        scatter(fg_ends_trueX(cluster{c},1), fg_ends_trueX(cluster{c},3),10, mycolors(c,:));
    hold on
    end
    hold off
%     legend('Cluster 1','Cluster 2','Location','NW')
    subplot(2,2,4);
    for c = 1:length(cluster)
       scatter(fg_ends_trueX(cluster{c},4), fg_ends_trueX(cluster{c},6),10, mycolors(c,:));
    hold on
    end
    hold off
    legend('Cluster 1','Cluster 2','Location','NW');  
    % save plot
    cd(figsDir)
    figname = (['gmm_',num2str(length(cluster)),'clusters_subj' num2str(i)]);
saveas(fig, figname, 'epsc');
saveas(fig, figname, 'jpg');
end



%% some plot commands

% % fig = figure(i)
% % clf
% % h1 = plot(sumd_all(i,:));
% % set(fig, 'color', 'white');
% % set(h1, 'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Black');
% % set(h1, 'Marker', 'o','MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', [0 0 0],'MarkerSize', 8.0);
% % set(gca, 'Box', 'off'); % here gca means get current axis
% % set(gca, 'TickDir', 'out', 'XTick', [1:maxClustersToTry], 'YTick', [0 2500000]);
% % xlabel('number of clusters (k)', 'fontsize', 18);
% % ylabel('Mean of within-cluster sum of squared distances', 'fontsize', 18);
% % 
% % % save plot
% % figname = strcat('kmeans_',subjects(i));
% % saveas(fig, figname{1}, 'epsc');
% % saveas(fig, figname{1}, 'jpg');


