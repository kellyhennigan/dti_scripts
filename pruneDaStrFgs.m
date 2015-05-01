function [fgOut,omittedFg] = pruneDaStrFgs(fg,roi1,roi2,method,doPlot)
% fgOut = pruneDaNaccPathways(fgIn)
% -------------------------------------------------------------------------
% usage: use this function to specify fiber pruning that is unique to
% DA-Str pathways
%
% INPUT:
%   fgIn - .pdb format pathways
%   roi1 - .mat roi file for a subject's da roi
%   roi2 - " " nacc roi
%   doPlot - plot fgs
%
% OUTPUT:
%   fgOut - str-DA pathways not omitted
%   fg2 - str-DA pathways omitted
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 01-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% default is not to plot
if notDefined('doPlot')
    doPlot = 0;
end

fprintf(['\n\n# of fibers before pruneDAStrFgs(): ' num2str(numel(fg.fibers)) '\n']);

%% as of now, only do pruning for conTrack fibers

if strcmpi(method, 'conTrack')
    
    %% 1) get index for fibers that go >4 voxels above most superior roi vox
    
    
    o_idx=cellfun(@(x) any(abs(x(3,:))>max(abs(roi2.coords(:,3)))+4), fg.fibers, 'UniformOutput',0);
    o_idx = vertcat(o_idx{:});
    
    
    
    %% 2) get index for fibers that go >4 voxels behind most posterior ROI vox
    
    
    o_idx2=cellfun(@(x) any(x(2,:)<min(roi2.coords(:,2))-4), fg.fibers, 'UniformOutput',0);
    o_idx2 = vertcat(o_idx2{:});
    
    
    
    %% omit fibers that meet above criteria
    
    o_idx = o_idx+o_idx2;
    
    fgOut = getSubFG(fg,find(o_idx==0));
    omittedFg = getSubFG(fg,find(o_idx>0));
    
    
end % method

fprintf(['# of fibers after pruneDAStrFgs(): ' num2str(numel(fgOut.fibers)) '\n\n']);

%% If desired, render kept fibers in blue and omitted fibers in red

if doPlot
    AFQ_RenderFibers(omittedFg,'tubes',0,'color',[1 0 0],'rois',roi1,roi2);
    AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'newfig',0);
end



%%



