%% Gaussian Mixture Models Analysis

function gmm_plots(figsDir, endpts, cl, subject)
%
% i is subject loop number
% cluster is 1 x numClusters cell array with boolean index of cluster
% number
% endpts is fiber group endpoints with real X-coordinates (as
% opposed to absolute value)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define some colors

% dorsal ventral tier colors
mycolors = [
    244 101 7
    44 129 162
    242 173 10
    .5 .5 .5]./255;

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
fig = figure
clf
subplot(2,2,1);
for c = 1:length(cl)
    scatter3(endpts(cl{c},1), endpts(cl{c},2), endpts(cl{c},3),10, mycolors(c,:),'filled');
    hold on
    xlabel('x'), ylabel('y'), zlabel('z')
end
title('DA endpoints');
% make the figure rotatable
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');

hold off
%     legend('Cluster 1','Cluster 2','Location','NW')
subplot(2,2,2);
for c = 1:length(cl)
    scatter3(endpts(cl{c},4), endpts(cl{c},5), endpts(cl{c},6),10, mycolors(c,:),'filled');
    hold on
    xlabel('x'), ylabel('y'), zlabel('z')
end
% make the figure rotatable
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
title ('striatum endpoints')
hold off


%% 2D scatter plot at y=-16 for DA ROI and y=0 for striatum ROI
%     yDA = (endpts(:,2) >= -16.5 & endpts(:,2) < -15.5);
%     y1{1} = (yDA & cl{c});
%     y1{2} = (yDA & cl{c});
%     yStr = (endpts(:,5) >= -1 & endpts(:,5) < 1);
%     y2{1} = (yStr & cl{c});
%     y2{2} = (yStr & cl{c});
%
% coronal
subplot(2,2,3);
for c = 1:length(cl)
    scatter(endpts(cl{c},1), endpts(cl{c},3),10, mycolors(c,:));
    hold on
end
xlabel('x'), ylabel('z')
title('DA endpts - coronal view')
hold off
%     legend('Cluster 1','Cluster 2','Location','NW')
subplot(2,2,4);
for c = 1:length(cl)
    scatter(endpts(cl{c},4), endpts(cl{c},6),10, mycolors(c,:));
    hold on
end
xlabel('x'), ylabel('z')
title('Striatum endpts - coronal view')
hold off
legend('Cluster 1','Cluster 2','Location','NW');
% save plot
cd(figsDir)
figname = (['gmm_',num2str(length(cl)),'cls_' subject]);
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
% % xlabel('number of cls (k)', 'fontsize', 18);
% % ylabel('Mean of within-cl sum of squared distances', 'fontsize', 18);
% %
% % % save plot
% % figname = strcat('kmeans_',subjects(i));
% % saveas(fig, figname{1}, 'epsc');
% % saveas(fig, figname{1}, 'jpg');


