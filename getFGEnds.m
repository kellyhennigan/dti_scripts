function [fgOut,endpts]=getFGEnds(fg,nEnds)
% -------------------------------------------------------------------------
% usage: this function takes in a fiber group and returns two separate
% fiber group structs that contain the first and last endpoints of each
% fiber in the group.
% 
% INPUT:
%   fg - fiber group structure 
%   nEnds - just first or both endpoints (so 1 or 2)
% 
% OUTPUT:
%   fgOut - exact same as fg, except each fiber cell contains only the 
%           endpoint coordinates of each fiber. 
%   endpts - endpt coordinates of the fiber group returned as a M x N
%           matrix, where each column contains the desired endpoints for a
%           single fiber.
% 
% 
% author: Kelly, kelhennigan@gmail.com, 23-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if nEnds isn't given, just give the first endpoint coord
if notDefined('nEnds')
    nEnds = 1; 
end


% get fibers' first endpoints:
if nEnds==1
 fgOut=fg;  
 fgOut.fibers = cellfun(@(x) x(:,1), fgOut.fibers,'UniformOutput',0);
 endpts = [fgOut.fibers{:}];
 
 
% get fibers' first and last endpoints:
elseif nEnds==2
    fgOut=fg;  
    fgOut.fibers = cellfun(@(x) x(:,[1,end]), fgOut.fibers,'UniformOutput',0);
    endpts = cell2mat(cellfun(@(x) reshape(x,6,1), fgOut.fibers, 'UniformOutput',0)');

end


