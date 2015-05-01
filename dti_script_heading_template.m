%% standard variables, paths, etc. to define for a dti script


%% define directories and file names, load files

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;


% what tracking method? conTrack or mrtrix
method = 'conTrack';
% method = 'mrtrix';


% define fg densities to overlay on each image
targets = {'caudate','nacc','putamen'};
fdFileStr = '_autoclean_smooth.nii.gz';



% parameters for fiber density images
cols = getFDColors();
% cols = [cols{1};cols{2};cols{3}];



%% DO SOMETHING

