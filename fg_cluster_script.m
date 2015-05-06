% clustering analysis on dti data

%% define directories and file names, load files

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;


method = 'mrtrix';

matName = 'DA_striatumL.mat';  % mat name that contains cell array of endpts


nC = 3;  % number of clusters to define


plotClusters = 1; % set to 1 for plots
saveFigs = 0; % set to 1 to export new .pdb fiber groups


cols = getDTIColors([4,1,5]);


%% get subject data

matPath = fullfile('group_sn','fg_endpts',method,matName);
load(matPath);


s=1;
% for s=1:numel(subjects)


    subj = subjects{s};
    endpts = subj_endpts{s};
    
    %% do clustering procedure
    
    
    options = statset('Display','final');
    %     gm = gmdistribution.fit(endpts,numClusters,'Options',options);
    gm = fitgmdist(endpts,nC,'Options',options);
    cIdx = cluster(gm, endpts);     % gives a cluster index
    
    
    
    %%  get index of closest striatal roi
    
    
    roiNames = {'caudate','nacc','putamen'};
    roiPaths = cellfun(@(x) fullfile(subj,'ROIs',[x '.mat']), roiNames, 'UniformOutput',0);
    
    
    [roi_idx,d] = closestRoi(gm.mu(:,4:6),roiPaths);
    
    
    
    
    %% plot
    
    t1FilePath = '%s/t1/t1_fs.nii.gz'; % file path to background image
    % load background image
    t1 = readFileNifti(sprintf(t1FilePath,subj));
    
    figure
    subplot(1,2,1), hold on
    scatter3(endpts(:,1),endpts(:,2),endpts(:,3),10,cIdx,'filled')
    colormap(cols)
    view(3)
    axis equal
    ax0 = axis;
    %     [h,d]=plotNiiContourSlice(t1,[0 -18 0]);
    axis(ax0)
    cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
    xlabel('x'), ylabel('y'), zlabel('z')
    title('DA endpoints')
    hold off
    
    subplot(1,2,2), hold on
    scatter3(endpts(:,4),endpts(:,5),endpts(:,6),10,cIdx,'filled')
    colormap(cols)
    view(3)
    axis equal
    ax0 = axis;
    %     [h,d]=plotNiiContourSlice(t1,[0 -1 0]);
    axis(ax0)
    cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
    xlabel('x'), ylabel('y'), zlabel('z')
    title('Striatum endpoints')
    hold off
    
% end % subjects  
    
    
    %% save
    
    
    
    
    
