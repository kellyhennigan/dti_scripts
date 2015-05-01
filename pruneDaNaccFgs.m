function [fgOut,fg2] = pruneDaNaccFgs(fg,roi1,roi2,subject,method,LorR,excludeAboveAC,doPlot)
% fgOut = pruneDaNaccPathways(fgIn)
% -------------------------------------------------------------------------
% usage: use this function to specify fiber pruning that is unique to
% DA-Nacc pathways
%
% INPUT:
%   fg - .pdb format pathways
%   roi1 - .mat roi file for a subject's da roi
%   roi2 - " " nacc roi
%   subject - subject string (e.g., 'sa01')
%   method - either 'conTrack' or 'mrtrix'
%   LorR - 'L' or 'R' denoting left or right pathways
%   excludeAboveAC - exclude pathways that enter NAc above the AC?
%   doPlot - plot fgs
%
% OUTPUT:
%   fgOut - nacc-DA pathways going below the AC
%   fg2 - nacc-DA pathways going above the AC
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 01-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% default to NOT exclude pathways above AC
if notDefined('excludeAboveAC')
    excludeAboveAC=0;
end

%
if notDefined('subject')
    subject = '';
end


% default is not to plot
if notDefined('doPlot')
    doPlot = 0;
end


fprintf(['\n\n# of fibers before pruneDANaccFgs(): ' num2str(numel(fg.fibers)) '\n']);



%% 1) Omit fibers that go more than 4 voxels lateral of nacc ROI


fgIn = fg;

o_idx=cellfun(@(x) any(abs(x(1,:))>max(abs(roi2.coords(:,1)))+4), fg.fibers, 'UniformOutput',0);
o_idx = vertcat(o_idx{:});

fg = getSubFG(fg,find(o_idx==0));



%% 2) (if desired) get index of fibers that go above the AC

if excludeAboveAC
    
    o_idx2 = pruneNaccPathwaysAboveAC(fg, LorR, subject, method);
    
else
    
    % or get index for fibers that go >4mm voxels above most superior roi vox
    o_idx2=cellfun(@(x) any(x(3,:))>max(roi2.coords(:,3))+4, fg.fibers, 'UniformOutput',0);
    o_idx2 = vertcat(o_idx2{:});
    
    %     o_idx2=zeros(numel(fg.fibers),1);
end


%% exclude fibers based on the above criteria


fgOut = getSubFG(fg,find(o_idx2==0));
fg2 = getSubFG(fg,find(o_idx2==1));



%% If desired, render kept fibers in blue and omitted fibers in red

if doPlot
    %     AFQ_RenderFibers(fgIn,'tubes',0,'rois',roi1,roi2); % all input fgs
    %     title('all input fibers')
    AFQ_RenderFibers(fgIn,'tubes',0,'color',[1 0 0],'rois',roi1,roi2);
    AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'newfig',0);
    AFQ_RenderFibers(fg2,'tubes',0,'color',[0 1 0],'newfig',0);
    
end


fprintf(['# of fibers after pruneDANaccFgs(): ' num2str(numel(fgOut.fibers)) '\n\n']);


