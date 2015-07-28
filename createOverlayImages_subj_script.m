%% define variables for calling createOverlayImages


%% 

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


subjects=getDTISubjects;  % define subjects to process
subjects([9,18]) = []; subjects = subjects(10:22);
% subjects = {'sa27'};

bgFilePath = '%s/t1/t1_fs.nii.gz'; % file path to background image
% bgFilePath = '%s/t1/t1_halfmm.nii.gz'; % file path to background image


method = 'conTrack'; % what tracking method? conTrack or mrtrix
fStr = '_da_endpts_S3'; % suffix on input fiber density files?


% target strings
targets = {'caudateL','caudateR';
    'naccL','naccR';
    'putamenL','putamenR'};


t_idx = [1 2 3]; % ONLY PLOT THESE FROM TARGET LIST


plane=3; % 1 for sagittal, 2 for coronal, 3 for axial


% acpcSlices = [-12,-10]; % acpc-coordinate of slice to plot


scale = 1;   % scale so each value is the percentage of the total fg

cols = getDTIColors('fd');


c_range = [0.1 1]; 



saveFigs = 0; % [1/0 to save out slice image, 1/0 to save out cropped image]
figDir = [p.figures '/fg_densities'];
figPrefix = 'CNP';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

% createOverlayImages: 


%%

% if desired, get just a subset of the targets
if ~notDefined('t_idx') && ~isempty('t_idx')
    targets=targets(t_idx,:);
    cols=cols(t_idx,:);
end

nOls = size(targets,1); % useful variable to have


 

%% do it


s=1;
for s=1:numel(subjects)
    
    subj = subjects{s};
    
    acpcSlices = []; % allow acpc slices to vary across subjects
    
    % load background image
    bg = readFileNifti(sprintf(bgFilePath,subj));
    
    
    % load fiber density files
    fd = cellfun(@(x) readFileNifti(fullfile(subj, 'fg_densities',method,[x fStr '.nii.gz'])), targets);
    fdImgs ={fd(:).data}; fdImgs=reshape(fdImgs,size(targets));
    fd = fd(1);  fdXform = fd.qto_xyz;
    
  
   % if thresholding is desired, do it
    if ~notDefined('thresh') && thresh~=0
        fdImgs = cellfun(@(x) threshImg(x, thresh), fdImgs, 'UniformOutput',0);
    end
  
    
    % if scaling is desired, do it
    if ~notDefined('scale') && scale==1
%         fdImgs = cellfun(@scaleFiberCounts, fdImgs, 'UniformOutput',0);
        fdImgs = cellfun(@scaleFiberCounts2, fdImgs, 'UniformOutput',0);
    end
  
    
    % if masking overlays is desired, do it
    if ~notDefined('maskFilePath')  && ~isempty(maskFilePath)
        mask = readFileNifti(sprintf(maskFilePath,subj));
        fdImgs = cellfun(@(x) double(x) .* double(mask.data), fdImgs, 'UniformOutput',0);
    end
   
  
   
    % merge overlays in the same rows (e.g., L and R)
    if size(targets,2)>1
        fdImgs = cellfun(@(x,y) x+y, fdImgs(:,1), fdImgs(:,2), 'UniformOutput',0);
    end
    
    
    % if acpcSlices isn't defined, figure out where to plot here
    if notDefined('acpcSlices') || isempty('acpcSlices')
        coords = round(cell2mat(reshape(cellfun(@(x) getNiiVolStat(x,fd.qto_xyz,'com'), fdImgs, 'UniformOutput',0), [], 1)));
        acpcSlices = unique(coords(:,plane))';
    end
       
        
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
        
    
    
    %% now plot and (if desired) save images
    
    % put acpcSlices into cell array for cellfun
    acpcSlicesOut = num2cell(acpcSlicesOut);
    
    
    % plot overlay and save new figure
    [h,figNames]= cellfun(@(x,y) plotFDMaps(x,plane,y,saveFigs,figDir,figPrefix,subj), slImgs, acpcSlicesOut, 'UniformOutput',0);
    
%     close all
    
     clear olVals olRgb slImgs
    
end % subjects









