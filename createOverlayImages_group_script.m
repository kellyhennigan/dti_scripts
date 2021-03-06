%% define variables for calling createOverlayImages


%% define directories and file names, load files

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


subjects={'group_sn'};  % group is subject


bgFilePath = '%s/t1/t1_sn.nii.gz';  % averaged t1 anat


maskFilePath =  '%s/ROIs/DA_sn_binary_mask.nii.gz';  % comment out or set to '' to not use


% olFiles relative to subj dir; %s will be targets
olFilePath = '%s/fg_densities/conTrack/%s_da_endpts_S3_sn.nii.gz';


% define fg densities to overlay on each image
targets = {'caudate';
    'nacc';
    'putamen'};

t_idx = [1:3]; % ONLY PLOT THESE FROM TARGET LIST

plot_biggest = 1; % uncomment out or set to '' to not do this
cols = getDTIColors(1:3);

plane=2; % 1 for sagittal, 2 for coronal, 3 for axial

acpcSlices = [-17]; % acpc-coordinate of slice to plot

c_range = []; % range of colormap

thresh = 0; % for thresholding t-maps

saveFigs = 0; % [1/0 to save out slice image, 1/0 to save out cropped image]
figDir = [p.figures '/fg_densities'];
figPrefix = 'CNP';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

%% overlay fiber densities onto subject's T1 in native space


% unless otherwise specified, use FDColors for colormaps
if notDefined('cols')
    cols = getDTIColors('fd');
end



%%

% if desired, get just a subset of the targets
if ~notDefined('t_idx') && ~isempty('t_idx')
    targets=targets(t_idx,:);
    cols=cols(t_idx,:);
end

nOls = size(targets,1); % useful variable to have


%% do it


s=1;
    
    subj = subjects{s};
    
    
    % load background image
    bg = readFileNifti(sprintf(bgFilePath,subj));
    
    
    % load fiber density files
    
    fd = cellfun(@(x) readFileNifti(sprintf(olFilePath,subj,x)), targets);
    fdImgs ={fd(:).data}; fdImgs=reshape(fdImgs,size(targets));
    fd = fd(1);  fdXform = fd.qto_xyz;
    
  
   % if thresholding is desired, do it
    if ~notDefined('thresh') && thresh~=0
        fdImgs = cellfun(@(x) threshImg(x, thresh), fdImgs, 'UniformOutput',0);
    end
  
    
    % if scaling is desired, do it
    if ~notDefined('scale') && scale==1
        fdImgs = cellfun(@scaleFiberCounts, fdImgs, 'UniformOutput',0);
    end
  
    
    % if masking overlays is desired, do it
    if ~notDefined('maskFilePath')  && ~isempty(maskFilePath)
        mask = readFileNifti(sprintf(maskFilePath,subj));
        fdImgs = cellfun(@(x) double(x) .* repmat(double(mask.data),1,1,1,size(x,4)), fdImgs, 'UniformOutput',0);
    end
   
   
    % merge overlays in the same rows (e.g., L and R)
    if size(targets,2)>1
        fdImgs = cellfun(@(x,y) x+y, fdImgs(:,1), fdImgs(:,2), 'UniformOutput',0);
    end
    
    
    % do hard segmentation of voxels based on strongest connectivity?
    if plot_biggest==1
        
        allImgs = cat(4,fdImgs{:});
        
        % get the 'win_idx' - idx of which fd group is biggest for each voxel
        [~,win_idx]=max(allImgs,[],4);
        win_idx(sum(allImgs,4)==0)=0;
        
        % create a new nifti w/win_idx as img data
        fd.data=win_idx;
        
        % plot overlay of voxels w/biggest connectivity
        [slImgs,~,~,~,acpcSlicesOut] = plotOverlayImage(fd,bg,cols,[1 numel(fdImgs)],plane,acpcSlices,0);
        
        
    else
        
        
        j=1;
        for j = 1:nOls
            
            
            % put L/R density maps into nifti structure for its header info
            fd.data = fdImgs{j};
            
            
            % plot fiber density overlay
            [imgRgbs, olMasks,olVals(j,:),~,acpcSlicesOut] = plotOverlayImage(fd,bg,cols{j},c_range,plane,acpcSlices,0);
            
            
            % cell array of just rgb values for overlays
            olRgb(j,:) = cellfun(@(x,y) x.*y, imgRgbs, olMasks,'UniformOutput',0);
            
            
        end % nOls
        
        
        
        %% now combine fiber density overlays for each slice
        
        
        for k=1:numel(acpcSlicesOut)
            
            
            bgImg = imgRgbs{k}; % this is the background image (w/some overlay values for the last fd)
            
            
            % get overlay values for this slice
            sl=cell2mat(permute(olVals(:,k),[3 2 1]));
            
            
            % get fiber density overlay rgb values for this slice
            rgbOverlays = cell2mat(reshape(olRgb(:,k),1,1,1,nOls));
            
            
            % combine rgb overlay images w/nan values for voxels w/no overlay
            thisImg = combineRgbOverlays(rgbOverlays,sl);
            
            
            % add gray scaled background to pixels without an overlay value
            thisImg(isnan(thisImg))=bgImg(isnan(thisImg)); thisImg(thisImg==0)=bgImg(thisImg==0);
            
            
            % cell array w/all combined overlays to plot
            slImgs{k} = thisImg;
            
            
        end % acpcSlices
        
        
    end % plot_biggest
    
    
    
    %% now plot and (if desired) save images
    
    % put acpcSlices into cell array for cellfun
    acpcSlicesOut = num2cell(acpcSlicesOut);
    
    
    % plot overlay and save new figure
    [h,figNames]= cellfun(@(x,y) plotFDMaps(x,plane,y,saveFigs,figDir,figPrefix,subj), slImgs, acpcSlicesOut, 'UniformOutput',0);
    
%     close all
    
    








 









