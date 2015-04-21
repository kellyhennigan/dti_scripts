%%  Script to run k-means analysis on fibers

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


subjects = {'ak090724','am090121','db061209','er100302',...
'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};

% subjects = {'er100302'};
baseDir = '/home/kelly/data/DTI';
figsDir = fullfile(baseDir, 'paper_figs','kmeans');
fiberFile = 'scoredFG_strROIs_all.pdb'


%% Set parameters

maxClustersToTry = 7;
numClusters = 2; % leave this blank (ie, numClusters = []; ) to not create and save k-means clusters as .pdb files

%% load fibers

for i = 1:length(subjects) % for each subject
    subjDir = fullfile(baseDir, subjects{i});
    fibersDir = fullfile(subjDir, 'fibers', 'conTrack');
    cd(fibersDir);
   strFGs(i) = mtrImportFibers(fiberFile);
   strFGs_endpts(i) = dtiReorientFibers(strFGs(i),2); % reorient fibers (keeps only endpts)

%% put into a 6 column matrix & use absolute values of x-coordinates
   
    for j = 1:length(strFGs_endpts(i).fibers)
        endpts{i}(j,1:3) = strFGs_endpts(i).fibers{j}(:,1);
        endpts{i}(j,4:6) = strFGs_endpts(i).fibers{j}(:,2);
    end
    endpts_trueX = endpts;  % save the true X coordinates
    endpts{i}(:,1) = abs(endpts{i}(:,1));
    endpts{i}(:,4) = abs(endpts{i}(:,4));
   
    clear j
    
%% if numClusters is given, cluster fibers into k groups and export groups

if (~isempty(numClusters))
    
    % how many fiber groups?
    [kindx]=kmeans(endpts{i},numClusters);
    kindx_all{i} = kindx;
    
    for r = 1:numClusters
        fiberCluster = strFGs(i);   % copy the .pdb file's format
        fiberCluster.name = ['fg_str_kmeans_', num2str(r),'_of_' num2str(numClusters) '_clusters.pdb'];
        fiberCluster.fibers = strFGs(i).fibers(kindx==r);
        fiberCluster.pathwayInfo = strFGs(i).pathwayInfo(kindx==r);
        for q = 1:length(strFGs(i).params)
            fiberCluster.params{q}.stat = strFGs(i).params{q}.stat(kindx==r);
        end
        fprintf('\n Saving fiber cluster %d of %d for subject %s \n', r, numClusters, subjects{i});
        mtrExportFibers(fiberCluster, fiberCluster.name);   % save fiber Cluster as a .pdb file
    end
    
    clear  fiberCluster kindx r q
end

%% Compare within cluster distances using various clusters
    
for p = 1:maxClustersToTry
    [kindx, C, sumd_this]=kmeans(endpts{i},p);
    % k_indx = index of cluster assignment
    % C - K cluster centroid locations in a K-by-P matrix
    % sumd_this - the within-cluster sums of point-to-centroid distances in a 1-by-k vector
    sumd(p) = mean(sumd_this,1);
end;

sumd_all(i,:) = sumd;

clear sumd_this sumd p 

end


