function [fgOut,fg2] = pruneDaNaccFgs(fg,roi1,roi2,subject,method,LorR,doPlot)
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


% default is not to plot
if notDefined('doPlot')
    doPlot = 0;
end


% omit fibers that go more than 4 voxels lateral of nacc ROI
fgIn = fg;
o_idx=cellfun(@(x) any(abs(x(1,:))>max(abs(roi2.coords(:,1)))+4), fg.fibers, 'UniformOutput',0);
o_idx = vertcat(o_idx{:});
fg = getSubFG(fg,find(o_idx==0));


% define z-coord threshold for determining what pathways are under the AC
thresh = 0;
switch method
    case 'conTrack'
        if strcmp(subject,'sa18')
            thresh = -3;
        elseif strcmp(subject,'sa28') && strcmpi(LorR,'L')
            thresh = -3;
          elseif strcmp(subject,'sa34') && strcmpi(LorR,'L')
            thresh = -2;
         elseif strcmp(subject,'sa24') && strcmpi(LorR,'L')
            thresh = 10;
        end
        
    case 'mrtrix'
        
        if strcmp(subject,'sa26') && strcmpi(LorR,'R')
            thresh = -3;
        elseif strcmp(subject,'sa25')
            thresh = -2;
%         elseif strcmp(subject,'sa28') 
%             thresh = -2;
%          elseif strcmp(subject,'sa20') && strcmpi(LorR,'R')
%             thresh = -1;
%          elseif strcmp(subject,'sa18') && strcmpi(LorR,'R')
%             thresh = -2;
%          elseif strcmp(subject,'sa16') && strcmpi(LorR,'R')
%             thresh = -1;
%          elseif strcmp(subject,'sa01') && strcmpi(LorR,'R')
%             thresh = -2;
%         elseif strcmp(subject,'sa19') && strcmpi(LorR,'R')
%             thresh = -2;
%           elseif strcmp(subject,'sa34') && strcmpi(LorR,'L')
%             thresh = -1;
%   
        end
        
end



% define y-coord of coronal plane for cutoff
y = 0;
switch method 
%     case 'conTrack'
    case 'mrtrix'
        if strcmp(subject, 'sa27') && strcmpi(LorR,'R')
            y = -5;
        elseif strcmp(subject, 'sa07') && strcmpi(LorR,'R')
                y = 5;
%         elseif strcmp(subject, 'sa01') && strcmpi(LorR,'R')
%             y = 5;
        end   
end



% temporarily clip all pathways in the coronal plane at the AC
fg_clipped=dtiClipFiberGroup(fg,[],[y 80],[]);


% get the z-coord of where the clipped fibers hit the coronal plane where the AC is
zc=cellfun(@(x) x(3,end), fg_clipped.fibers);


% fibers below the AC
fgOut = getSubFG(fg,zc<thresh);


% fibers that go above the AC
fg2 = getSubFG(fg,zc>=thresh);



% 
% if strcmpi(method,'iFOD1')
%     
%     len=cellfun(@(x) length(x), fg.fibers);
%     
%     % fibers 32 nodes or less
%     fgOut = getSubFG(fg,len<=32);
%     
%     
%     % fibers longer than 32 nodes
%     fg2 = getSubFG(fg,len>32);
%     
% end

% % % % *** maybe I only need to do this for mrtrix fibers?
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


% render fibers that go below and above the AC
if doPlot
    %     AFQ_RenderFibers(fgIn,'tubes',0,'rois',roi1,roi2); % all input fgs
    %     title('all input fibers')
    AFQ_RenderFibers(fgOut,'tubes',0,'color',[0 0 1],'rois',roi1,roi2);
    AFQ_RenderFibers(fg2,'tubes',0,'color',[1 0 0],'newfig',0)
end


