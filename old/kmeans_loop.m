%% K-MEANS ANALYSIS

% base dir (one above subject directories)
baseDir = '/home/kelly/data/DTI';

% subject directories
subjects = {'ak090724','am090121','db061209','er100302','hh100622',...
     'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};
% subjects = {'ak090724'};
%subjects = {'sr090327'};
% fg_names = {'DA_NAcc_top2.5per_clean.pdb'; 'DA_Caud_top2.5per_clean.pdb'; 'DA_Putamen_top2.5per_clean.pdb'}

maxClustersToTry = 7;
numClusters = 2; % leave this blank (ie, numClusters = []; ) to not create and save k-means clusters as .pdb files

%%

%i = 1;

for i = 1:length(subjects)          % subject loop;
%     DAroi_file = fullfile(baseDir, subjects{i},'ROIs','DA.mat');
%     DA = open(DAroi_file);
%     max_z = max(DA.roi.coords(:,3));
%     clear DA DAroi_file
% get fiber groups
fgDir = fullfile(baseDir, subjects{i},'fibers','conTrack');
cd(fgDir)

%% make striatum ROI or upload from current directory?

% % TO UPLOAD STRIATUM ROI:
fg_striatum = mtrImportFibers('DA_Striatum_top2.5per_clean.pdb');

%     % TO CREATE STRIATUM ROI FILE:
%     for t = 1:length(fg_names)
%         strFibers{t} = mtrImportFibers(fg_names{t});
%     end
%     % reorient fibers if necessary
%     for j = 1:length(strFibers)
%         for k = 1:length(strFibers{j}.fibers)
%             if strFibers{j}.fibers{k}(3,1) > max_z  % if z coordinate of first endpt isnt in the range of the DA roi
%                 strFibers{j}.fibers{k} = fliplr(strFibers{j}.fibers{k});   % flip the fiber coordinates
%             end
%         end
%     end
%     fg_striatum = strFibers{1};   % use the other fiber groups general structure/some values
%     fg_striatum.name = 'DA_Striatum_top2.5per_clean.pdb';
%     fg_striatum.fibers = [strFibers{1}.fibers; strFibers{2}.fibers; strFibers{3}.fibers];
%     fg_striatum.pathwayInfo = [strFibers{1}.pathwayInfo, strFibers{2}.pathwayInfo, strFibers{3}.pathwayInfo];
%     for m = 1:length(fg_striatum.params)
%         fg_striatum.params{m}.stat = [strFibers{1}.params{m}.stat, strFibers{2}.params{m}.stat, strFibers{3}.params{m}.stat];
%     end
%     % save striatum fiber group
%     mtrExportFibers(fg_striatum, fg_striatum.name);
%     clear j k t
% end

%%  get endpoint coordinates

endptsDA =[];       %  coordinates for fiber endpoint in DA ROI
endptsStr = [];     %  " " in Striatum ROI

for n = 1:length(fg_striatum.fibers)
    endptsDA(:,n) = fg_striatum.fibers{n}(:,1);
    endptsStr(:,n) = fg_striatum.fibers{n}(:,end);
end

%% kmeans analysis

% first put DA/Str endpoints into a 6-d matrix
endpts = endptsDA';
endpts(:,4:6) = endptsStr';

% take absolute values of x-coordinates
endpts(:,1) = abs(endpts(:,1));
endpts(:,4) = abs(endpts(:,4));


for p = 1:maxClustersToTry
    [k_indx, C, sumd_this]=kmeans(endpts,p);
    sumd(p) = mean(sumd_this,1);
end;

allsubs_sumd(i,:) = sumd;

fig = figure(i)
h1 = plot(sumd);
set(fig, 'color', 'white');
set(h1, 'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Black');
set(h1, 'Marker', 'o','MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', [0 0 0],'MarkerSize', 8.0);
set(gca, 'Box', 'off'); % here gca means get current axis
set(gca, 'TickDir', 'out', 'XTick', [1:maxClustersToTry], 'YTick', [0 2500000]);
xlabel('number of clusters (k)', 'fontsize', 18);
ylabel('Mean of within-cluster sum of squared distances', 'fontsize', 18);
%% save plots
cd '/home/kelly/data/DTI/figures';
figname = strcat('kmeans_',subjects(i));
saveas(fig, figname{1}, 'epsc');
saveas(fig, figname{1}, 'jpg');
cd(fgDir)

%% group mean plot

sumd_mean = mean(allsubs_sumd,1);
fig = figure(11);
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
cd(fgDir)

%% cluster fibers into k groups

% how many fiber groups?
[kindx]=kmeans(endpts,numClusters);

for r = 1:numClusters
    fiberCluster = fg_striatum;   % copy the .pdb file's format
    fiberCluster.name = ['fg_striatum_kmeans', num2str(r),'.pdb'];
    fiberCluster.fibers = fg_striatum.fibers(kindx==r);
    fiberCluster.pathwayInfo = fg_striatum.pathwayInfo(kindx==r);
    for q = 1:length(fg_striatum.params)
        fiberCluster.params{q}.stat = fg_striatum.params{q}.stat(kindx==r);
    end
    %mtrExportFibers(fiberCluster, fiberCluster.name);   % save fiber Cluster as a .pdb file
end

clear  q p C DAroi_file ans endpts endptsDA endptsStr fgDir fiberCluster
clear kindx k_indx max_z n p q r ti fg_striatum sumd sumd_this fig figname h1 
end  % subjects loop