function rgbVec = getRgbVec(idx,rgbColors)
% -------------------------------------------------------------------------
% usage: this function takes in a 1-D index vector (e.g., [1 2 1 1...]
%        and a 3-column matrix of rgb values and returns a list of rgb
%        values as indexed by idx.
% 
% INPUT:
%   idx - column vector of indices
%   rgbColors - 3-col matrix of rgb values
% 
% OUTPUT:
%   rgbVec - 3-col matrix w/the same # of rows as idx and with the rgb

% 
% NOTES: this is mainly to use with scatter and scatter3 plot commands so
%       that points can be plotted in specific colors while not having to
%       use the figure's colormap, so that for example a colormap of gray
%       can be used for a background image and dots can be plotted in
%       color.

% author: Kelly, kelhennigan@gmail.com, 06-May-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 


% if idx is given as a row vector, transpose it
if size(idx,1)==1
    idx = idx';
end

% define 3-column matrix of nans 
rgbVec = repmat(nan(size(idx)),1,3);

for i=unique(idx)'
   rgbVec(idx==i,:)=repmat(rgbColors(i,:),size(rgbVec(idx==i,:),1),1);
end
    
    

    
    
    
    
    
    