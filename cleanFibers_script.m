% this script does the following:

% import fibers defined from intersecting 2 rois,
% reorients fibers so they all start from roi1 (roi1),
% will keep only left or right fibers if desired,
% keeps only fibers 
% clean the groups using AFQ_removeFiberOutliers(),
% and saves out cleaned L, R fiber groups as well as both L and R merged
% together.
% also saves out a .mat file that has info on the parameters used to
% determine outliers in the cleaning procedure.


% define variables, directories, etc.
clear all
close all

% get experiment-specific paths and cd to main data directory
p=getDTIPaths(); cd(p.data);


subjects=getDTISubjects; 

LorR = 'R';


seed = 'DA';  % define seed roi
target = ['nacc' LorR ];

method = 'conTrack';
fgName = 'scoredFG__nacc_DA_top2500_R.pdb'
%  method = 'mrtrix';
%  fgName = [target '.tck']; 


% define parameters for pruning fibers
maxIter = 10;  % 5 iterations for conTrack (nacc), 2 for mrtrix and all other conTrack
maxDist=4;
maxLen=3;
numNodes=100;
M='mean';
count = 1;
show = 0; % 1 to plot each iteration, 0 otherwise

outFgName = [target '_autoclean_afq_params'];


%% DO IT


fprintf('\n\n working on %s fibers for roi %s...\n\n',method,target);
i=1
for i=1:numel(subjects)
    
    subject = subjects{i}; 
    fprintf(['\n\nworking on subject ' subject '...\n\n'])
    subjDir = fullfile(p.data,subject); cd(subjDir);
    
    % load seed and target rois
    roi1 = roiNiftiToMat(['ROIs/' seed '.nii.gz']);
    roi2 = roiNiftiToMat(['ROIs/' target '.nii.gz']);
 
    % load fiber groups
    cd(fullfile(subjDir,'fibers',method));
    fg = fgRead(fgName);

    % reorient fibers so they all start in DA ROI
    [fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);
    
    
%     % if target roi is the nacc, then do some extra pruning
%     if strcmp(target(1:4),'nacc')
%         fg = pruneDaNaccFgs_SA(fg,roi1,roi2,subject,method,LorR,0,0);
%     end
    
    if strcmp(target(1:4),'nacc')
        pruneAboveAC=0; doPlot=0;
         fg = pruneDaNaccFgs(fg,subject,LorR,roi1,roi2,pruneAboveAC,doPlot);
    end
%    
%     % if target roi is striatum, then do some extra pruning
%     if strcmp(target(1:4),'stri')
%         fg = pruneDaStrFgs(fg,roi1,roi2,method,0);
%     end
%     
    % remove outliers and save out cleaned fiber group
    if ~isempty(fg.fibers)
        
        [~, keep,niter]=AFQ_removeFiberOutliers(fg,...
            maxDist,maxLen,numNodes,M,count,maxIter,show);     % remove outlier fibers
        
        fprintf('\n\n final # of %s cleaned fibers: %d\n\n',fg.name, numel(find(keep)));
       
        cleanfg = getSubFG(fg,find(keep),outFgName);
        
        nFibers_clean(i,1) = numel(cleanfg.fibers); % keep track of the final # of fibers
        
        AFQ_RenderFibers(cleanfg,'tubes',0,'numfibers',500,'color',[1 0 0]);
        title(gca,subject);
       
        fgWrite(cleanfg);  % save out cleaned fibers
     
        
    else
        error('fiber group is empty');
    end
    
end % subjects

