function [leftFg,rightFg,crossFg]=splitFgLR(fg,appendLRStr)
% -------------------------------------------------------------------------
% usage: takes in a fiber group struct and returns the fibers on the left
% and right hemisphere as separate groups


% INPUT:
%   fg - fiber group struct following mrDiffusion format
%   appendLRStr - 1 to append '_L','_R', or '_Cross' string to filename; 0 otherwise.
%   Default is 1

% OUTPUT:
%   leftFg,rightFg,crossingFg - fibers as a group in the left and right
%   hemisphere as well as fibers that cross hemispheres



% author: Kelly, kelhennigan@gmail.com, 11-Mar-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% distance from mid-sagittal plane that a fiber can cross without
% considering it a crossing fiber
thresh = 2; 

if notDefined('fg') || ~isstruct(fg)
    error('fiber group struct must be given')
end

if notDefined('appendLRStr')
    appendLRStr = 1;
end

l_idx = []; % index of fibers in left hemisphere
r_idx = []; % index of fibers in right hemisphere
cross_idx=[]; % fibers that cross the midsagittal plane


for i=1:numel(fg.fibers)
    
    x_coords=fg.fibers{i}(1,:);  % get x-coordinates of the ith fiber
    
    if all(x_coords-thresh<=0)      % left fiber
        l_idx = [l_idx,i];
        
    elseif all(x_coords+thresh>=0)  % right fiber
        r_idx = [r_idx,i];
        
    else                            % crossing fiber
        cross_idx = [cross_idx,i];
    end
    
end

fprintf(['\n\n ' num2str(length(l_idx)) ' left fibers found.']);
fprintf(['\n ' num2str(length(r_idx)) ' right fibers found.']);
fprintf(['\n ' num2str(length(cross_idx)) ' mid-sag crossing fibers found.\n\n']);

leftFg = getSubFG(fg,l_idx); 
rightFg = getSubFG(fg,r_idx); 
crossFg = getSubFG(fg,cross_idx);

if appendLRStr
    leftFg.name = [leftFg.name '_L'];
    rightFg.name = [rightFg.name '_R'];
    crossFg.name = [crossFg.name '_Cross'];
end
