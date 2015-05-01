function h = afq_renderMesh(vol, varargin)
% function [p, msh, lightH] = afq_renderMesh(vol, varargin)
%
% note: this is Jason's AFQ_RenderCorticalSurface() function with some
% edits to make compatible with rendering roi meshes, too.
%
% Render the volume surface from a binary segmentation image
%
%
% [p, msh, lightH] = AFQ_RenderCorticalSurface(vol, 'param', value ...)
%
% This function takes in a segmentation image and renders it in 3d. It is
% optimized to look good for the cortical surface but any image will work.
% The rendering will be added to the current figure window so you can add
% the vol to a rendering of fiber groups and adjust it's transparency.
% The only input that is required is a segmentation image. There are also a
% number of parameters that can be set in the form of 'parameter', value,
% combinations. All the examples below will run if the AFQ mesh directory
% is your working directory:
% [~, AFQdata] = AFQ_directories; cd(fullfile(AFQdata,'mesh'))
%
% Inputs:
% vol  - A msh, mesh structure (see AFQ_meshCreate) or a path to a
%           nifti image to render. It must be a binary mask.
%           AFQ_RenderCorticalSurface('segmentation.nii.gz');
% color   - RGB value for the surface of the rendering. Default is "brain"
%           color. For example to render the vol in orange:
%           AFQ_RenderCorticalSurface('segmentation.nii.gz', 'color', [1, 0.5, 0])
% alpha   - The transparency of the surface (alpha). 0 is completely
%           transparent and 1 is completely opaque. For example to render
%           the vol half way transparent:
%           AFQ_RenderCorticalSurface('segmentation.nii.gz', 'alpha', 0.5)
% overlay - Another image to use to color the surface (for example an fMRI
%           contrast or fiber endpoint image). For example to render the
%           vol with a heatmap of arcuate fasciculus endpoints:
%           im = 'Left_Arcuate_Endpoints.nii.gz'
%           AFQ_RenderCorticalSurface('segmentation.nii.gz', 'overlay', im)
% thresh  - A threshold above/below which overlay values will be
%           painted on the vol and the vol will be left vol
%           colored. Thresh can be a single number (minumum) or a vector of
%           2 numbers (minimum and maximum).
%           im = 'Left_Arcuate_Endpoints.nii.gz'
%           AFQ_RenderCorticalSurface('segmentation.nii.gz', ...
%           'overlay', im, 'thresh', 0.01)
% crange  - Define which overlay values should be mapped to the minimum and
%           maximum values of the color map. All values below crange(1)
%           will be colored the minimum value and all values above
%           crange(2) will be colored the maximum value. The default color
%           range is defined by the minimum and maximum values of the
%           overlay image that get mapped to any mesh vertex.
%           im = 'Left_Arcuate_Endpoints.nii.gz'
%           AFQ_RenderCorticalSurface('segmentation.nii.gz', ...
%           'overlay', im, 'thresh', 0.01, 'crange', [.02 .2])
% cmap    - Name of the colormap to use. For example 'jet' or 'autumn'
%           im = 'Left_Arcuate_Endpoints.nii.gz'
%           AFQ_RenderCorticalSurface('segmentation.nii.gz', ...
%           'overlay',im, 'thresh',0.01, 'crange',[.02 .2], 'cmap','hot')
% newfig  - Whether or not to open a new figure window
%           AFQ_RenderCorticalSurface('segmentation.nii.gz','newfig',true);
%
% Outputs:
% p       - Handel for the patch object that was added to the figure
%           window. The rendering can be deleted with delete(p)
% msh     - The mesh object of the cortical surface.
% lightH  - Handle to the light object
%
% Example:
%
% % Get data
% [~, AFQdata] = AFQ_directories;
% vol = fullfile(AFQdata,'mesh','segmentation.nii.gz');
% overlay = fullfile(AFQdata,'mesh','Left_Arcuate_Endpoints.nii.gz');
% thresh = .01; % Threshold for the overlay image
% crange = [.01 .8]; % Color range of the overlay image
% % Render the cortical surface colored by the arcuate endpoint density
% [p, msh, lightH] = AFQ_RenderCorticalSurface(vol, 'overlay' , overlay, 'crange', crange, 'thresh', thresh)
%
% Copyright Jason D. Yeatman November 2012

% Create a parameters structure from any parameters that were defined
params = CreateParamsStruct(varargin);
params
if ~isfield(params,'alpha')
    params.alpha = 1;
end

if ~isfield(params,'newfig')
    params.newfig = 1;
end
%% Build a mesh of the cortical surface

% If a msh structure was sent in then get the triangles. If an image was
% sent in then build a mesh with the defined parameters
if ismesh(vol)
    tr = AFQ_meshGet(vol,'triangles');
    % Set outputs
    msh = vol;
else
    msh = AFQ_meshCreate(vol, params);
    tr = AFQ_meshGet(msh, 'triangles');
end

%% Render the cortical surface

scSize = get(0,'ScreenSize'); % get screensize for pleasant figure viewing :)

if params.newfig == 1
    figure;
    
    % place figure in top right of monitor for more convenient viewing
    pos = get(gcf,'Position');
    set(gcf,'Position',[scSize(3)-pos(3), scSize(4)-pos(4), pos(3), pos(4)])
    
end
% Use patch to render the mesh
p = patch(tr);
%p = patch(tr,'facecolor',color,'edgecolor','none');

% Interpolate the coloring along the surface
shading('interp');
% Set the type of lighting
lighting('gouraud');
% Set the alpha
alpha(p,params.alpha);
% Set axis size
axis('image');axis('vis3d');
% Set lighiting options of the vol
set(p,'specularstrength',.5,'diffusestrength',.75);

% If it was a new figure window add a light to it
if params.newfig == 1
    view([270 0])
    lightH = camlight('right');
end

% make it rotatable
cameratoolbar('Show');
cameratoolbar('SetMode','orbit');


%% testing putting all output into 1 structural array of handles

h = struct();
h.p = p;      % patch object handle
h.msh = msh;  % mesh handle
if exist('lightH','var')
    h.l = lightH; % light object handle
end
