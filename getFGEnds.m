function [fg1,fg2]=getFGEnds(fg)
% -------------------------------------------------------------------------
% usage: this function takes in a fiber group and returns two separate
% fiber group structs that contain the first and last endpoints of each
% fiber in the group.
% 
% INPUT:
%   fg - fiber group structure 
%   
% 
% OUTPUT:
%   fg1 - exact same as fg, except each fiber cell contains only the 1st
%   endpoint coordinates of each fiber. 
%   fg2 - same as fg1 except for the 2nd fiber endpoint.
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 23-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get fibers' first endpoints:
fg1=fg;  
fg1.fibers = cellfun(@(x) x(:,1), fg1.fibers,'UniformOutput',0);


% get fibers' last endpoints:
fg2=fg;  
fg2.fibers = cellfun(@(x) x(:,end), fg2.fibers,'UniformOutput',0);
        