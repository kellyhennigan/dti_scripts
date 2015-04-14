% this script is similar to cleanFibers_script except that its meant to
% process mrtrix fibers tracked from the whole brain. So this script does
% the following:

% imports wholebrain mrtrix fibers
% keeps only fibers that intersect roi1 and roi2
% reorients fibers so they all start from seedroi (roi1)
% splits each fiber group into left and right fgs,
% clean the groups using AFQ_removeFiberOutliers(),
% and saves out cleaned L, R fiber groups as well as both L and R merged
% together.
% also saves out a .mat file that has info on the parameters used to
% determine outliers in the cleaning procedure.


% define variables, directories, etc.
clear all
close all

subjects=getDTISubjects;
dataDir = '/Users/Kelly/dti/data';
seed = 'DA';  % define seed roi
% rois = {'nacc','caudate','putamen'}; % target rois
target = 'striatum';

method = 'mrtrix';
fileStr = 'wb.tck'; % .tck file w/ %s string is defined by rois
LR = ['L','R']; % left and right fiber groups

% define parameters for pruning fibers
maxIter = 10;  % 5 iterations for conTrack, 2 for mrtrix
maxDist=4;
maxLen=4;
numNodes=20;
M='mean';
count = 1;
show = 1;



%% DO IT: get whole-brain fibers then find fibers that intersect 2 rois


% keep track of the # of L and R fibers for each set of seed/target rois
nFibers = zeros(numel(subjects),1);
nFibers_clean = nFibers;
nIters = nFibers;


% load wholebrain pathways
i=1;
for i=1:numel(subjects)
    
    fprintf(['\n\nworking on subject ' subjects{i} '...\n\n'])
    subjDir = fullfile(dataDir,subjects{i}); cd(subjDir);
    
    % load whole-brain fibers
    FG=dtiImportFibersMrtrix(fullfile('fibers',method,fileStr));
    
    % load seed roi
    roi1=load(fullfile('ROIs',[seed '.mat']));
    
    % get just fibers that intersect the seed roi
    FG= dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, 2, roi1.roi, FG);
    FG.name = ['wb_' seed];
    fprintf(['\nnumber of fibers intersecting ' seed ' ROI: ' num2str(numel(FG.fibers)) '\n']);
    
    % now get fibers that intersect both seed roi and target rois
    roi2 =  load(fullfile('ROIs',[target '.mat']));
    fg = dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, 2, roi2.roi, FG);
    fg.name = [FG.name '_' target];
    fprintf(['\nnumber of ' seed ' fibers intersecting roi ' target ': ' num2str(numel(fg.fibers)) '\n\n']);
    
    % reorient fibers to start at seed roi
    fg= AFQ_ReorientFibers(fg,roi1.roi,roi2.roi);
    
    % clip fibers to start/end in ROIs
    fgname = fg.name;
    fg=dtiClipFiberGroupToROIs(fg,roi1.roi,roi2.roi,2);
    fg.name = fgname;
    
    % omit fibers that go more than 4 voxels lateral of nacc ROI
    o_idx=cellfun(@(x) any(abs(x(1,:))>max(abs(roi2.roi.coords(:,1)))+4), fg.fibers, 'UniformOutput',0);
    o_idx = vertcat(o_idx{:});
    fg = getSubFG(fg,find(o_idx==0));
    
    % save out seed roi - target roi fibers
    %         mtrExportFibers(fg,fg.name);
    
    [~, keep,niter]=AFQ_removeFiberOutliers(fg,maxDist,maxLen,numNodes,M,count,maxIter,show);     % remove outlier fibers
    
    cleanfg = getSubFG(fg,find(keep),[fg.name '_autoclean']); %
    fprintf('\n\n final # of %s cleaned fibers: %d\n\n',target,numel(cleanfg.fibers));
    mtrExportFibers(cleanfg,cleanfg.name);  % save out cleaned fibers
    
    % fill in records of # of fibers, etc.
    nFibers(i) = numel(fg.fibers);
    nIters(i) = niter-1; % -1 because it does 1 more interation wo removing any fibers
    nFibers_clean(i) = numel(cleanfg.fibers);
    
    
end % subjects


% to plot two fiber groups on the same plot:
%             AFQ_RenderFibers(cleanfg{1},'color',[0 0 1]);
%             AFQ_RenderFibers(cleanfg{2},'color',[0 1 0],'newfig',false)


outName = ['wb_fg_' method '_' seed '_' target '_autoclean.mat'];

cd(dataDir); cd fg_autoclean_records;
save(outName,'rois','subjects','nFibers',...
    'nFibers_clean','nIter','maxIter','maxDist','maxLen','numNodes','M');


fprintf('done.')




