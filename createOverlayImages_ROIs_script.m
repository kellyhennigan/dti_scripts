%% define variables for calling createOverlayImages


%% 

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);



subjects=getDTISubjects;  % define subjects to process
subjects = {'sa01'};


bgFilePath = '%s/t1/t1_fs.nii.gz'; % file path to background image


% define fg densities to overlay on each image
targets = {'caudate';
    'nacc';
    'putamen'};

olDir = 'ROIs'; % directory of overlay niftis


t_idx = [1 2 3]; % ONLY PLOT THESE FROM TARGET LIST


plane=3; % 1 for sagittal, 2 for coronal, 3 for axial

% acpcSlices = [-8:2:8]; % acpc-coordinate of slice to plot
acpcSlices = []; % acpc-coordinate of slice to plot


c_range = [.1 .9]; % range of colormap


saveFigs = 0; % 1 to save out images, otherwise 0
figDir = ['/Users/Kelly/dti/figures/ROIs'];
figPrefix = 'CNP';



%% 

createOverlayImages


