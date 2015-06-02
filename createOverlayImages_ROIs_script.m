%% define variables for calling createOverlayImages


%% 

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);



% subjects=getDTISubjects;  % define subjects to process
 subjects = {'sa01'};


bgFilePath = '%s/t1/t1_sn.nii.gz'; % file path to background image

cols = getDTIColors(4,1,5); cols = {cols};

olDir = 'ROIs'; % directory of overlay niftis

targets = {'DA_sn_R_cl3_gmm'};
fStr = '';

% define fg densities to overlay on each image
% targets = {'caudate';
%     'nacc';
%     'putamen'};


% t_idx = [1 2 3]; % ONLY PLOT THESE FROM TARGET LIST

    
plane=3; % 1 for sagittal, 2 for coronal, 3 for axial

% acpcSlices = [-8:2:8]; % acpc-coordinate of slice to plot
acpcSlices = []; % acpc-coordinate of slice to plot

c_range = [1:3]
% c_range = [.1 .9]; % range of colormap


saveFigs = 0; % 1 to save out images, otherwise 0
figDir = ['/Users/Kelly/dti/figures/clustering'];
figPrefix = '';



%% 

createOverlayImages


