%% make images of ROI masks


clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';


%% define directories and file names, load files



% define subjects to process
subjects=getDTISubjects; 
subjects = {'sa01'};



% path to file to use as background image (relative to dataDir)
bgFilePath = '%s/t1/t1_fs.nii.gz'; %s is subject



% what tracking method? conTrack or mrtrix
method = 'conTrack';
% method = 'mrtrix';


% define fg densities to overlay on each image
targets = {'caudate','nacc','putamen'};



% olFilePaths = '%s/fg_densities/%s/%s_da_endpts_S3_sn_T.nii.gz';
% %s, subject %s, method %s, targets
olFilePaths = '%s/ROIs/%s.nii.gz';


% parameters for fiber density images
% cols = getFDColors();
cols = getDTIColorsCell();


thresh = 0;     % threshold maps? 
c_range = [.1 10]; % range of colormap


plane=3; % 1 for sagittal, 2 for coronal, 3 for axial

% acpcSlices = [-8:2:8]; % acpc-coordinate of slice to plot
acpcSlices = []; % acpc-coordinate of slice to plot

saveFigs = 1; % 1 to save out images, otherwise 0
% figDir = ['/Users/Kelly/dti/figures/fg_densities/' method];
% figPrefix = 'CNP';
figDir = ['/Users/Kelly/dti/figures/ROIs'];
figPrefix = 'CNP';

t_idx = [1 2 3]; % ONLY PLOT THESE FROM TARGET LIST



%% load and process relevant files


% get perhaps just a subset of the targets
if ~notDefined('t_idx') && ~isempty('t_idx')
    targets=targets(t_idx);
    cols=cols(t_idx);
    figPrefix = figPrefix(t_idx);
end

nOls = numel(targets); % useful variable to have


%%

cd(dataDir);
 

s=1;
for s=1:numel(subjects)
    
    subj = subjects{s};
    
    
    % load background image
    bg = readFileNifti(sprintf(bgFilePath,subj));
    bgXform = bg.qto_xyz; % acpc xform
    
    
    %% load overlays
    
    % fiber density files
%     ol = cellfun(@(x) readFileNifti(sprintf(olFilePaths,subj,method,x)), targets);
   

% ROIs
    ol = cellfun(@(x) readFileNifti(sprintf(olFilePaths,subj,x)), targets);
   
    
    olXform = ol(1).qto_xyz; % acpc xform
    olImgs={ol(:).data}; % all fd data   % olImgs=cellfun(@(x) x.data, ol,'UniformOutput',0)

    
    % threshold images? 
    if ~notDefined('thresh')
        olImgs = cellfun(@(x) threshImg(x,thresh), olImgs, 'UniformOutput',0);
    end
    
    
    % get coords of max value - but don't scale!
    [~,max_coords] = cellfun(@(x) scaleFiberCounts(x), olImgs, 'UniformOutput',0);
    max_coords_acpc=cellfun(@(x) mrAnatXformCoords(olXform,x), max_coords,'UniformOutput',0);
    
    
    
    for j=1:nOls
        
        
        % plot fiber density overlays
        [imgRgbs, olMasks,olVals(j,:),~,acpcSlices] = plotOverlayImage(ol(j),bg,cols{j},c_range,plane,acpcSlices,0);
        
        
        % cell array of just rgb values for overlays
        olRgb(j,:) = cellfun(@(x,y) x.*y, imgRgbs, olMasks,'UniformOutput',0);
        
        
    end % FDs
    
    
    
    %% now combine fiber density overlays for each slice
    
    
    for k=1:numel(acpcSlices)
        
        
        bgImg = imgRgbs{k}; % this is the background image (w/some overlay values for the last fd)
        
        
        % get overlay values for this slice
        sl=cell2mat(permute(olVals(:,k),[3 2 1]));
        
        
        % get fiber density overlay rgb values for this slice
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
    
    
    
    
    
    
    
    
