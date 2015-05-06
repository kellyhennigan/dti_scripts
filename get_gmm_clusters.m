% define variables, directories, etc.
clear all
close all


% get experiment-specific paths and cd to main data dir
p = getDTIPaths; cd(p.data);

subjects=getDTISubjects; 

subject = 'sa01';

LR = ['L','R'];

fgDir = '%s/fibers/mrtrix/'; % dir relative to dataDir


fgName = 'striatum%s_autoclean.pdb';


roiDir = '%s/ROIs/'; % subject's roi directory relative to dataDir
roiNames = {'caudate','nacc','putamen'};


nC = 3;
uncCluster = 0; % set to 1 to form an additional fiber group based on posterior probability
uncertainCrit = .05; % threshold for inclusion in the uncertain cluster
saveNewFGs = 0; % set to 1 to export new .pdb fiber groups
plotClusters = 1; % set to 1 for plots


cols = getDTIColors('cell');
    


%% 



lr = 1; % left or right

% get roiPaths for this subject - use to determine which roi each cluster
% is closest to
roiPaths = cellfun(@(x) fullfile(sprintf(roiDir,subject),[x '.mat']), roiNames, 'UniformOutput',0);


fgPath = sprintf([fgDir fgName],subject,LR(lr));

fg = fgRead(fgPath);

[~,endpts] = getFGEnds(fg,2); 
endpts=endpts';


  %% estimate Gaussian mixture model with n components defined by numClusters
    
  
    options = statset('Display','final');
%     gm = gmdistribution.fit(endpts,numClusters,'Options',options);
 gm = fitgmdist(endpts,nC,'Options',options);
    cIdx = cluster(gm, endpts);     % gives a cluster index
   
    [roi_idx,d] = closestRoi(gm.mu(:,4:6),roiPaths);
   


 %% make another cluster for high uncertainty fibers?
    
    if uncCluster == 1
        P = posterior(gm, endpts); % gives the posterior probablity of component 1 in column 1, comp. 2 in column 2, etc.
        chance = 1./nC; % e.g. .5 for 2 clusters, .33 for 3 clusters
        uncertainIdx = (P(:,1) > chance - uncertainCrit & P(:,1) < chance + uncertainCrit);
        cIdx(uncertainIdx) = nC + 1;
    end
    
    %% make a cluster index
    
    for c = 1:max(cIdx)    % number of clusters (numClusters + 1 if there's an uncertainCluster)
        component{c} = (cIdx == c);
        fgCl{c} = getSubFG(fg,cIdx==c);
    end

    
    
    %% plot clustered fiber groups
    
    cols = cols(4:6,:);
    
    
    h = AFQ_RenderFibers(fgCl{1},'tubes',0,'color',cols(1,:),'newfig',1)
  figure; hold on 
   h2 = cellfun(@(x,y) AFQ_RenderFibers(x,'tubes',0,'color',y,'newfig',0), fgCl',cols)
    
  % make the figure rotatable
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
  
    
%       %% plot clusters?
%     
%     if plotClusters == 1
        figsDir = fullfile('/Users/Kelly/dti/figures/gmm');
        gmm_plots(figsDir, endpts, component,subject);
%     end
    %     clear subjDir fibersDir fg_ends fg_ends_trueX gm idx cluster c fiberCluster
    