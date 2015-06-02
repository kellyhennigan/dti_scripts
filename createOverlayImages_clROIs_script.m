%% define variables for calling createOverlayImages


%% 

clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);



% subjects=getDTISubjects;  % define subjects to process
 subjects = {'group_sn'};

bgFilePath = '%s/t1/t1_sn.nii.gz'; % file path to background image

olDir = 'ROIs'; % directory of overlay niftis

targets = {'DA_LR'};

method = 'mrtrix'; % conTrack, mrtrix, or tensor

K = 2; % number of clusters

cl_method = 'kmeans'; % gmm or kmeans
  
plane=2; % 1 for sagittal, 2 for coronal, 3 for axial

fStr = ['_' method '_cl' num2str(K) '_' cl_method];

c_range = [1 K];

saveFigs = [0 1]; % 1 to save out images, otherwise 0
figDir = fullfile(p.figures ,'clustering','maps'); 
figPrefix = fStr(2:end);

if K==2
    cols = getDTIColors(4,5);
elseif K==3
    cols = getDTIColors(4,1,5);
else
    cols = solarizedColors(K);
end
cols = {cols};


% acpcSlices = [-22:2:-18]; % acpc-coordinate of slice to plot
acpcSlices = [-14:2:-10]; % acpc-coordinate of slice to plot

if plane==2
   acpcSlices = [-22:2:-18];
elseif plane==3
  acpcSlices = [-14:2:-10]; % acpc-coordinate of slice to plot
else
    acpcSlices = [];
end



%% 

createOverlayImages


