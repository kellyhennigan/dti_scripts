%% overlay fiber densities onto subject's T1 in native space

% this script is designed to load fiber density images and plot them as
% color overlays on grayscaled anatomical background images. It's a little
% clunky because it does extra processing to combine rgb images from
% different overlays so that the RGB values are weighted according to the
% relative contributions of the fibe density values (e.g., if a voxel has a
% value of '1' for a fiber density map w/rgb value [1 0 0] and a .5 for
% another map w/rgb value [0 0 1], then the resulting rgb value at that
% voxel will be [.67 0 .33]. 

% targets in the same row of the cell array will be plotted together (e.g.,
% L and R overlays of the same target). 


%% define directories and file names, load files

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if plotting maps of individual subjects (comment out and see below for
% group t-maps):
% 
% subjects=getDTISubjects;  % define subjects to process
% 
% bgFilePath = '%s/t1/t1_fs.nii.gz'; % file path to background image 
% 
% method = 'conTrack'; % what tracking method? conTrack or mrtrix
% 
% % define target strings to identify fiber density files. To plot L and R
% % maps together, define respective L and R target strings in the same row.
% targets = {'caudateL','caudateR';
%     'naccL','naccR';
%     'putamenL','putamenR'};
% 
% fdStr = '_da_endpts_S3'; % suffix on input fiber density files?
% 
% thresh = 0; % for thresholding t-maps
% 
% scale = 1;  % for log-transforming and scaling fiber counts 
% 
% c_range = [.1 .9]; % range of colormap
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if plotting group t-maps (comment out and see above to plot indivdual
% subject maps):

subjects={'group_sn'};

bgFilePath = '%s/t1/t1_sn.nii.gz';

method = 'conTrack';

% define fg densities to overlay on each image
targets = {'caudate';
        'nacc';
        'putamen'};

fdStr = '_da_endpts_S3_sn_T'; % suffix on input fiber density files

thresh = 3.5; % for thresholding t-maps

scale = 0;  % for log-transforming and scaling fiber counts 

c_range = [3.55 4]; % range of colormap


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define more params: 

cols = getFDColors();

plane=3; % 1 for sagittal, 2 for coronal, 3 for axial

acpcSlices = [-10]; % acpc-coordinate of slice to plot

saveFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]
figDir = [p.figures '/fg_densities/' method];
figPrefix = 'CNP';


t_idx = [1 2 3]; % ONLY PLOT THESE FROM TARGET LIST


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

% get perhaps just a subset of the targets
if ~notDefined('t_idx') && ~isempty('t_idx')
    targets=targets(t_idx,:);
    cols=cols(t_idx);
    figPrefix = figPrefix(t_idx);
end

nOls = size(targets,1); % useful variable to have


%% do it

s=1;
for s=1:numel(subjects)
    
    subj = subjects{s};
    
    
    % load background image
    bg = readFileNifti(sprintf(bgFilePath,subj));
    
    
     % fiber density files
     j=1;
     for j = 1:nOls
         
         
         fd = cellfun(@(x) readFileNifti(fullfile(subj,'fg_densities',method,[x fdStr '.nii.gz'])), targets(j,:));
         fdImgs ={fd(:).data};
         fd = fd(1); % in case there are multiple niftis loaded
        
         
         % threshold images?
         if ~notDefined('thresh')  && thresh~=0
             fdImgs = cellfun(@(x) threshImg(x,thresh), fdImgs, 'UniformOutput',0);
         end
         
         
         % log-transform and scale L and R maps separately, so max() of
         % each map=1 (note this script also thresholds counts)
         if ~notDefined('scale') && scale==1
             fdImgs = cellfun(@(x) scaleFiberCounts(x), fdImgs, 'UniformOutput',0);
         end
         
         
         % combine L and R maps (its ok if its just one map)
         fd.data = sum(cat(4,fdImgs{:}),4);
     
        
         % get coords of max value & that value (for reference)
         max_coords{j}(s,:)  = getNiiStat(fd,'max'); 
         mean_coords{j}(s,:) = getNiiStat(fd,'mean_coords'); 
    
        
         % plot fiber density overlay
        [imgRgbs, olMasks,olVals(j,:),~,acpcSlices] = plotOverlayImage(fd,bg,cols{j},c_range,plane,acpcSlices,0);
        
        
        % cell array of just rgb values for overlays
        olRgb(j,:) = cellfun(@(x,y) x.*y, imgRgbs, olMasks,'UniformOutput',0);
        
        
    end % nOls
    
    
    
    %% now combine fiber density overlays for each slice
    
    
    for k=1:numel(acpcSlices)
        
        
        bgImg = imgRgbs{k}; % this is the background image (w/some overlay values for the last fd)
        
        
        % get overlay values for this slice
        sl=cell2mat(permute(olVals(:,k),[3 2 1]));
        
        
        % get fiber density overlay rgb values for this slice
%         rgbOverlays=reshape(cell2mat(permute(olRgb(:,k),[3 2 1])),size(olRgb{1,k},1),size(olRgb{1,k},2),3,[]); 
        rgbOverlays = cell2mat(reshape(olRgb(:,k),1,1,1,nOls));
        
        
        % combine rgb overlay images w/nan values for voxels w/no overlay
        slImg = combineRgbOverlays(rgbOverlays,sl);
        
        
        % add gray scaled background to pixels without an overlay value
        slImg(isnan(slImg))=bgImg(isnan(slImg)); slImg(slImg==0)=bgImg(slImg==0);
        
        
        % plot all fiber groups and save new figure
        h = plotFDMaps(slImg,plane,acpcSlices(k),saveFigs,figDir,figPrefix,subj);
        
        
        
    end % acpcSlices
    
    
end % subjects
    
 
    
    %%  'find the biggest' analysis
    %
    % win_cols = [ 0.9333  0.6980  0.1373; 1 0 0; 0.0314  0.2706  0.5804];
    
    % % get the 'win_idx' - idx of which fd group is biggest for each voxel
    % [~,win_idx]=max(fdImgs,[],4);
    % win_idx(sum(fdImgs,4)==0)=0; % (set voxels without any fibers to zero)
    %
    %
    % % create a new nifti w/win_idx as img data
    % ol = createNewNii('win_idx',fdNiis(1),'',win_idx);
    %
    
    % plot overlay of voxels w/biggest connectivity
    % [imgRgb, maskRgb,h] = plotOverlayImage(ol,bg,win_cols,[1 numel(fdNiis)],plane,acpcSlice);
    
    
    
    
    
    
    
    
