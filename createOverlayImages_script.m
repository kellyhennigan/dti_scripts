%% overlay fiber densities onto subject's T1

% overlay fiber density images on subject's anatomy


%% define directories and file names, load files

clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';


% define subjects to process
subjects={'group_sn'};


% what tracking method? conTrack or mrtrix
% method = 'conTrack';
method = 'mrtrix';


% define fg densities to overlay on each image
targets = {'caudate','nacc','putamen'};


% suffix on input fiber density files?
fdFileStr = '_da_endpts_S3_sn_T';


% name of file to use as background image (relative to subject's directory)
bgFile = 't1/t1_sn_group_mean.nii.gz';


% parameters for fiber density images
cols = getFDColors();

c_range = [0 3]; % range of colormap

plane=3; % 1 for sagittal, 2 for coronal, 3 for axial

acpcSlices = []; % acpc-coordinate of slice to plot


saveFigs = 1; % 1 to save out images, otherwise 0
figDir = ['/Users/Kelly/dti/figures/fg_densities/' method];
figPrefix = 'CNP';


t_idx = [1 2 3]; % ONLY PLOT THESE FROM TARGET LIST



%% load and process relevant files

cd(dataDir);

% get perhaps just a subset of the targets
if ~notDefined('t_idx') && ~isempty('t_idx')
    targets=targets(t_idx);
    cols=cols(t_idx);
    figPrefix = figPrefix(t_idx);
end

nFDs = numel(targets); % useful variable to have


%%


s=1;
for s=1:numel(subjects)
    
    % cd to subject's directory
    cd(dataDir); cd(subjects{s});
    
    
    % load background image
    bg = readFileNifti(bgFile);
    bgXform = bg.qto_xyz; % acpc xform
    
    
    % load fiber density niftis
    fd = cellfun(@(x) readFileNifti(fullfile('fg_densities',method, [x fdFileStr '.nii.gz'])), targets);
    fdXform = fd(1).qto_xyz; % acpc xform
    % fdImgs=cat(4,fd(:).data); % all fd data
    fdImgs={fd(:).data}; % all fd data
    
    
    % threshold and log-transform data; max_coord gives img coord of max voxel
    [~,max_coords] = cellfun(@(x) scaleFiberCounts(x), fdImgs, 'UniformOutput',0);
    max_coords_acpc=cellfun(@(x) mrAnatXformCoords(fdXform,x), max_coords,'UniformOutput',0);
    
    
    
    for j=1:nFDs
        
        
        % plot fiber density overlays
        [imgRgbs, olMasks,olVals(j,:),~,acpcSlices] = plotOverlayImage(fd(j),bg,cols{j},c_range,plane,acpcSlices,0);
        
        
        % cell array of just rgb values for overlays
        olRgb(j,:) = cellfun(@(x,y) x.*y, imgRgbs, olMasks,'UniformOutput',0);
        
        
    end % FDs
    
    
    
    %% now combine fiber density overlays for each slice
    
    
    for k=1:numel(acpcSlices)
        
        
        bgImg = imgRgbs{k}; % this is the background image (w/some overlay values for the last fd)
        
        
        % get overlay values for this slice
        sl=cell2mat(permute(olVals(:,k),[3 2 1]));
        
        
        % get fiber density overlay rgb values for this slice
        rgbOverlays=reshape(cell2mat(permute(olRgb(:,k),[3 2 1])),size(olRgb{1,k},1),size(olRgb{1,k},2),3,[]);
        
        
        % combine rgb overlay images w/nan values for voxels w/no overlay
        slImg = combineRgbOverlays(rgbOverlays,sl);
        
        
        % add gray scaled background to pixels without an overlay value
        slImg(isnan(slImg))=bgImg(isnan(slImg));
        
        
        % plot all fiber groups and save new figure
        h = plotFDMaps(slImg,plane,acpcSlices(k),saveFigs,figDir,figPrefix,'group');
        
        
        
    end % acpcSlices
    
    
    end
    
    for j=1:nFDs
        fprintf(['\n\nmedian max coords for ' targets{j} ':\n\n'])
        median(cell2mat(max_coords_acpc(:,j)))
    end
    

    
    
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
    
    
    
    
    
    
    
    
