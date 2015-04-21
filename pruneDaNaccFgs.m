function fgOut = pruneDaNaccFgs(fg,roi1,roi2,subject,method,LorR,excludeAboveAC,doPlot)
% fgOut = pruneDaNaccPathways(fgIn)
% -------------------------------------------------------------------------
% usage: use this function to specify fiber pruning that is unique to
% DA-Nacc pathways
%
% INPUT:
%   fgIn - .pdb format pathways
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


% default is not to plot
if notDefined('doPlot')
    doPlot = 0;
end



%% 1) Omit fibers that go more than 4 voxels lateral of nacc ROI

fgIn = fg;
o_idx=cellfun(@(x) any(abs(x(1,:))>max(abs(roi2.coords(:,1)))+4), fg.fibers, 'UniformOutput',0);
o_idx = vertcat(o_idx{:});
fg = getSubFG(fg,find(o_idx==0));



%% 2) (if desired) omit fibers that go above  AC

if excludeAboveAC
    
    fgOut = pruneNaccPathwaysAboveAC(fg, LorR, subject, method);

end



%% 3) truncate fibers to the DA and nacc ROIs 

% maybe I only need to do this for mrtrix fibers...


% if strcmpi(method,'mrtrix')
%
%     % truncate fibers to the DA and nacc ROIs
%     % fgName = fgOut.name;
%     fgOut = dtiClipFiberGroupToROIs(fgOut,roi1,roi2);
%
%     % truncate da endpoints at min y-coord and min z-coord
%     %     fgOut=dtiClipFiberGroup(fgOut,[],[-50 min(roi1.coords(:,2))],[-40 min(roi1.coords(:,3))]);
%
%     % truncate nacc endpts at y=5
%     % fgName = fgOut.name;
%     %     fgOut=dtiClipFiberGroup(fgOut,[],[5 80],[]);
%     % fgOut.name = fgName;
%
% end


%% 4) If desired, render kept fibers in blue and omitted fibers in red  

if doPlot
    %     AFQ_RenderFibers(fgIn,'tubes',0,'rois',roi1,roi2); % all input fgs
    %     title('all input fibers')
    AFQ_RenderFibers(fgIn,'tubes',0,'color',[1 0 0],'rois',roi1,roi2);
    AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'newfig',0);
 
end



%%

%  case 'mrtrix'
%
%         if strcmp(subject,'sa01') && strcmpi(LorR,'R')
%             y_evals = 5; z_thresh = -2;
%         elseif strcmp(subject, 'sa07') && strcmpi(LorR,'R')
%             y_eval = 5;
%         elseif strcmp(subject,'sa16') && strcmpi(LorR,'R')
%             z_thresh = -1;
%         elseif strcmp(subject,'sa18') && strcmpi(LorR,'R')
%             z_thresh = -2;
%         elseif strcmp(subject,'sa19') && strcmpi(LorR,'R')
%             z_thresh = -2;
%         elseif strcmp(subject,'sa20') && strcmpi(LorR,'R')
%             z_thresh = -1;
%         elseif strcmp(subject,'sa25')
%             z_thresh = -2;
%         elseif strcmp(subject,'sa26') && strcmpi(LorR,'R')
%             z_thresh = -3;
%         elseif strcmp(subject,'sa27') && strcmpi(LorR,'R')
%             y_eval = -5;
%         elseif strcmp(subject,'sa28')
%             z_thresh = -2;
%         end
%

