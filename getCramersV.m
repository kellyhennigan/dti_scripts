function getCramersV
% -------------------------------------------------------------------------
% usage: say a little about the function's purpose and use here

% INPUT:
%   var1 - integer specifying something
%   var2 - string specifying something
% 
% OUTPUT:
%   var1 - etc.
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 28-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cramer's V is a X2 stat scaled to have values between 0-1: 

V = sqrt(X2 / [N * (min(ncols, nrows) - 1)])

where: 
X2 is a chi square
N, # of observations
ncols and nrows are the # of columns and rows


