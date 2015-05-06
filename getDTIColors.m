function colors = getDTIColors(varargin)
% -------------------------------------------------------------------------
% usage: get rgb values for color scheme of dti project.

% INPUT:
%   varargin - integer(s) or string(s) identifying which colors to return.
%   Can be the following:
%          'fd' - specifiying to return colors for fiber density
%                 overlays
%          'cell' - specifying to return rgb values in a cell array
%                   (this is the default for fibe density colors)
%          1, or [1:3], etc. - integer(s) specifying which colors to return

%

% OUTPUT:
%   rgb values for the following:
% 1) Caudate
% 2) Nacc "
% 3) Putamen "
% 4) Dorsal Tier
% 5) Ventral Tier
% 6) DA ROI

%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 02-May-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

caud = [238,178,35]./255;       % yellow
nacc = [250 24 29]./255;        % red
putamen = [33, 113, 181]./255;  % blue
dTier = [244 101 7]./255;       % orange
vTier = [44, 129, 162]./255;    % blue (different from putamen blue)
daRoi = [35 132 67]./255;       % green

colors = [caud; nacc; putamen; dTier; vTier; daRoi]; % needs to match the number of elements in area vector

%  0.925 0.528 0.169 1 % nice purple complimentary to the caudate yellow

%  0.916 0.010 0.458 %% GREAT hot pink!!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fiber density colors:
% yellow
yellow = [
    252, 244, 200
    250, 223, 150
    244, 199, 92
    caud.*255
    221, 151, 28]./255;


% red
red = [
    254   224   210
    252   140   114
    251    91    74
    nacc.*255
    200    15    21]./255;


% blue
blue = [
    158, 202, 225
    107, 174, 214
    66, 146, 198
    putamen.*255
    8, 69, 148]./255;


fdcolors=[{yellow}; {red}; {blue}];


%%

if nargin<1
    return;

else
    
    % return fiber density colors if desired
    if any(strcmpi(varargin,'fd'))
        colors = fdcolors;
    end
    
    
    % if cell array format is requested, return colors in cells (fiber density
    % colors are returned in a cell array by default)
    if any(strcmpi(varargin,'cell')) && ~iscell(colors)
        colors = num2cell(colors,2);
    end
    
    
    % if there's a numeric input, assume its specifiying which colors to return
    num_idx =  cellfun(@isnumeric, varargin);
    if any(num_idx)
        c_idx = [];
        for i=find(num_idx)
            c_idx = [c_idx,varargin{i}];
        end
        colors = colors(c_idx,:);
    end
    
end
    
    
    
    
    
    
    
