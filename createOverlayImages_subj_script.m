%% define variables for calling createOverlayImages


%% 

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


subjects=getDTISubjects;  % define subjects to process


bgFilePath = '%s/t1/t1_fs.nii.gz'; % file path to background image


method = 'mrtrix'; % what tracking method? conTrack or mrtrix
fStr = '_da_endpts_S3'; % suffix on input fiber density files?


% target strings
targets = {'caudateL','caudateR';
    'naccL','naccR';
    'putamenL','putamenR'};


t_idx = [1 2 3]; % ONLY PLOT THESE FROM TARGET LIST


plot_biggest = 0; % 1 to do hard segmentation based on strongest connectivity, otherwise 0


plane=3; % 1 for sagittal, 2 for coronal, 3 for axial


acpcSlices = []; % acpc-coordinate of slice to plot


c_range = [.1 .9]; % color_range


scale = 1;   % log-transform and scale fiber counts to be btwn [1 0]


ac = 0;  % do autocrop


saveFigs = 1; % [1/0 to save out slice image, 1/0 to save out cropped image]
figDir = [p.figures '/fg_densities/' method];
figPrefix = 'CNP';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do it

createOverlayImages






