%% kmeans plots

subjects = {'ak090724','am090121','db061209','er100302',...
'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};

baseDir = '/home/kelly/data/DTI';
figsDir = fullfile(baseDir, 'paper_figs','kmeans');
% fiberFile = 'scoredFG_strROIs_all.pdb'

cd(figsDir)

% %% Set parameters
% 
% maxClustersToTry = 7;
% numClusters = 2; % leave this blank (ie, numClusters = []; ) to not create and save k-means clusters as .pdb files

%% make and save figures

for i = 1:length(subjects) % for each subject
  
fig = figure(i)
clf
h1 = plot(sumd_all(i,:));
set(fig, 'color', 'white');
set(h1, 'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Black');
set(h1, 'Marker', 'o','MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', [0 0 0],'MarkerSize', 8.0);
set(gca, 'Box', 'off'); % here gca means get current axis
set(gca, 'TickDir', 'out', 'XTick', [1:maxClustersToTry], 'YTick', [0 2500000]);
xlabel('number of clusters (k)', 'fontsize', 18);
ylabel('Mean of within-cluster sum of squared distances', 'fontsize', 18);

% save plot
figname = strcat('kmeans_',subjects(i));
saveas(fig, figname{1}, 'epsc');
saveas(fig, figname{1}, 'jpg');

end

% group mean plot
sumd_mean = mean(sumd_all,1);
fignum = length(subjects)+1;
fig = figure(fignum);
clf
h1 = plot(sumd_mean);
set(fig, 'color', 'white');
set(h1, 'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Black');
set(h1, 'Marker', 'o','MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', [0 0 0],'MarkerSize', 8.0);
set(gca, 'Box', 'off'); % here gca means get current axis
set(gca, 'TickDir', 'out', 'XTick', [1:maxClustersToTry], 'YTick', [0 2500000]);
xlabel('number of clusters (k)', 'fontsize', 18);
ylabel('Group mean of within-cluster sum of squared distances', 'fontsize', 18);
% save plot
cd '/home/kelly/data/DTI/figures';
saveas(fig, 'kmeans_group_mean', 'epsc');
saveas(fig,'kmeans_group_mean', 'jpg');


mycolor = [49 73 94]./255;
figure(1)
clf
title('Normalized Histogram of Striatum - DA ROI endpoint z coordinates', 'fontsize', 18);
for i = 1:length(subjects)
    diffZ = endpts{i}(:,6) - endpts{i}(:,3);
    subplot(3,3,i);
    [xo,no] = histnorm(diffZ,'plot');
    set(fig, 'color', 'white');
    set(gca, 'Box', 'off'); % here gca means get current axis
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',mycolor,'EdgeColor','w');
end

fig = figure(1)
% save plot
figname = strcat('diff_z_coords');
saveas(fig, figname, 'epsc');
saveas(fig, figname, 'jpg');




    %% make some plots
    
    cmap = colormap(summer);
    
%     % X-coordinates of DA and Striatum endpoints
%     figure(1);
%     subplot(1,2,1)
%     scatter(abs(endptsDA(1,:)), abs(endptsStr(1,:)), [], 'color', cmap(1,:));
%     xlabel('DA endpoint (medial - lateral)')
%     ylabel('Striatum endpoint (medial - lateral)')
%     title('X-coordinates of fiber endpoints (absolute values)');
%     
%     diff_x = abs(endptsStr(1,:))-abs(endptsDA(1,:))
%     subplot(1,2,2)
%     hist(diff_x)
%     title('Histogram of striatum - DA endpoint x-coordinates (abs value)');
    
    % Y-coordinates of DA and Striatum endpoints
    figure(2);
    colormap(summer);
    subplot(1,2,1)
    s = scatter(endptsDA(2,:), endptsStr(2,:));
    xlabel('DA endpoint (inferior - superior)')
    ylabel('Striatum endpoint (inferior - superior)')
    title('Z-coordinates of fiber endpoints');
    
    diff_y = endptsStr(2,:) - endptsDA(2,:);
    subplot(1,2,2)
    hist(diff_y)
    title('Histogram of striatum - DA endpoint y-coordinates');
    
    % Z-coordinates of DA and Striatum endpoints
    figure(3);
    colormap(summer);
    subplot(1,2,2)
    s = scatter(endptsDA(3,:), endptsStr(3,:));
    xlabel('DA endpoint (inferior - superior)')
    ylabel('Striatum endpoint (inferior - superior)')
    title('Z-coordinates of fiber endpoints');
    
    diff_z = endptsStr(3,:) - endptsDA(3,:);
    subplot(1,2,2)
    hist(diff_z)
    title('Histogram of striatum - DA endpoint z-coordinates');
    
    %%%%%%%%%%
   