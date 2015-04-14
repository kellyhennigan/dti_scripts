% script to determine the spatial relationship between DA-striatum pathways

% how to best test/visualize the spatial differences between these
% pathways? 

% - display the fiber endpoints/densities on a coronal/axial orientation
% - " " on a 3d ROI surface mesh

% gaussian distributions showing overlap and relative size



%%
% SuperFiber structure has the fiber groups mean coords & spread: 

%   SuperFiber.fibers: means (for every coordinate, every node)
%   SuperFiber.fibervarcovs: low diag var/cov matrix for coordinates
%                          (every node)): [var(x), cov(x, y),
%                          cov(x, z), var(y), cov(y, z), var(z)]

% cd '/Users/Kelly/dti/data/fgMeasures/mrtrix'
% load('DA_nacc_20nodesR.mat')
% SuperFibers{1}
% SuperFibers{1}.fibervarcovs
% SuperFibers{1}.fibervarcovs{1}

%% display fiber endpoints in 2d planes overlaid on anatomy

%% display fiber endpoint densities in 2d planes overlaid on anatomy

%% display fiber endpoints overlaid on 3d mesh of DA ROI

%% display fiber endpoint densities overlaid on 3d mesh of DA ROI


%% quantify the spatial relationship between pathways

%% group test for spatial relationship between pathways


%% k-means clustering 












