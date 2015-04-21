%% overlay fiber densities onto subject's T1

% overlay fiber density images on subject's anatomy


%% define directories and file names, load files

clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';


% define subjects to process
subjects=getDTISubjects; 


% what tracking method? conTrack or mrtrix
% method = 'conTrack';
method = 'mrtrix';


% define fg densities to overlay on each image
targets = {'caudate','nacc','putamen'};
%  targets = {'nacc'};


% suffix on input fiber density files? 
fdFileStr = '.nii.gz';


% name of file to use as background image (relative to subject's directory)
bgFile = 't1_fs.nii.gz';


% parameters for fiber density images
cols = getFDColors();
% cols = [cols{1};cols{2};cols{3}];

c_range = [.1 .6]; % range of colormap

plane=3; % 1 for sagittal, 2 for coronal, 3 for axial

acpcSlices = [-10]; % acpc-coordinate of slice to plot


saveFigs = 0; % 1 to save out images, otherwise 0
figDir = ['/Users/Kelly/dti/figures/fg_densities/' method];
figPrefix = 'CNP';




%% load and process relevant files

cd(dataDir);

nFDs = numel(targets); % useful variable to have



for i = 1:numel(subjects)

clear fd sl rgbOverlays fdImgs bg rgbImg

fprintf(['\n\nworking on subject ' subjects{i} '...\n\n'])


% cd to subject's directory
cd(fullfile(dataDir,subjects{i}))


% load background image
bg = readFileNifti(bgFile);
bgXform = bg.qto_xyz; % acpc xform


% load fiber density niftis
fd = cellfun(@(x) readFileNifti(fullfile('fg_densities',method,[x fdFileStr])), targets);
fdXform = fd(1).qto_xyz; % acpc xform
% fdImgs=cat(4,fd(:).data); % all fd data
fdImgs={fd(:).data}; % all fd data


% keep track of the voxels with the highest density scores
[hi_counts,hi_idx] = cellfun(@(x) max(x(:)), fdImgs);
[ii,jj,kk]=ind2sub(size(fdImgs{1}),hi_idx(:));
hi_coords(i,:,1:nFDs) = permute(mrAnatXformCoords(fdXform,[ii jj kk]'),[3 2 1]);
clear hi_idx ii jj kk


for j=1:nFDs
    
    % as of now, the values in fd.data are fiber counts. Set any voxel with
    % 2 or less fibers to 0.
    fd(j).data(fd(j).data<=2)=0;
    
    
    % log-transform counts and then normalize by max(fd.data), so values
    % are between 0 and 1.
    fd(j).data=log(fd(j).data+1)./max(log(fd(j).data(:)+1));
    
        
    % plot fiber density overlays
    nii=fd(1);  t1=bg; cmap=cols{1};
    [imgRgbs, olMasks,olVals(j,:),~,acpcSlices] = plotOverlayImage(fd(j),bg,cols{j},c_range,plane,acpcSlices,0);
    
    
    % cell array of just rgb values for overlays
    olRgb(j,:) = cellfun(@(x,y) x.*y, imgRgbs, olMasks,'UniformOutput',0);
    
    
end % FDs



%% now combine fiber density overlays for each slice


for k=1:numel(acpcSlices)
    
    
    bgImg = imgRgbs{k}; % this is the background w/some overlay values that will be changed
    
    
    % get overlay values for this slice
    sl=cell2mat(permute(olVals(:,k),[3 2 1]));
    
    
    % get fiber density overlay rgb values for this slice
    rgbOverlays=reshape(cell2mat(permute(olRgb(:,k),[3 2 1])),size(olRgb{1,k},1),size(olRgb{1,k},2),3,[]);
    
    
    % combine rgb overlay images w/nan values for voxels w/no overlay
    slImg = combineRgbOverlays(rgbOverlays,sl);
    
    
    % add gray scaled background to pixels without an overlay value
    slImg(isnan(slImg))=bgImg(isnan(slImg));
    
    
    % plot all fiber groups and save new figure
    h = plotFDMaps(slImg,plane,acpcSlices(k),saveFigs,figDir,figPrefix,subjects{i});
    text(2,6,subjects{i},'color',[1 1 1],'fontsize',10)
    
    
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








