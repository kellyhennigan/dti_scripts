%% define variables for calling createOverlayImages


%% define directories and file names, load files

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


subjects={'group_sn'};  % group is subject


bgFilePath = '%s/t1/t1_sn.nii.gz';  % averaged t1 anat


maskFilePath =  '%s/ROIs/DA_sn_binary_mask.nii.gz';  % comment out or set to '' to not use


method = 'mrtrix';
fStr = '_da_endpts_S3_sn_T'; % suffix on input fiber density files


% define fg densities to overlay on each image
targets = {'caudate';
    'nacc';
    'putamen'};

t_idx = [1 2 3]; % ONLY PLOT THESE FROM TARGET LIST


plot_biggest = 1; % uncomment out or set to '' to not do this


plane=2; % 1 for sagittal, 2 for coronal, 3 for axial


acpcSlices = []; % acpc-coordinate of slice to plot


c_range = [3 4]; % range of colormap


thresh = 3; % for thresholding t-maps


saveFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]
figDir = [p.figures '/fg_densities/' method];
figPrefix = 'CNP';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

createOverlayImages
 









