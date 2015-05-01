function [roi_idx,dist] = closestRoi(coords,rois)

% this function takes in an array of acpc coordinates and a cell array of
% rois (paths or files) and returns an index of the rois in roiPaths
% sorted according to their proximity to the given coords. Also returns the
% shortest distance of each roi (in the sorted order roi_idx) to the given
% coords.

% assumes the coordinates values given in coords are in the same coord
% system as the loaded ROIs

% input coords should be a N x 3 array of x,y,z coordinates


%%

if ~iscell(rois)
    rois = {rois};
end

rois = cellfun(@roiAsMat, rois,'UniformOutput',0);
  
 
n=1;
for n = 1:size(coords,1)
    
    roi_idx(n,:) = [1:numel(rois)];  % e.g., [1 2 3]

    [this_dist,~]=cellfun(@(x) pdist2(x.coords,coords(n,:),'euclidean','Smallest',1), rois);

    [dist(n,:),sort_idx]=sort(this_dist);

    roi_idx(n,:) = roi_idx(n,sort_idx);

end


% 
% 
% %% this is going to be embarrassingly clunky.  Jus get over it and write
% %% the damn thing.
% 
% [D,I] = pdist2(X,Y,distance,'Smallest',K)
% 
% coords = round(coords);
% 
% for c = 1:size(coords,1)
%     
%     target = coords(c,:);
%     
%     for j = 1:3    % NAcc, caud, putamen
%         for k = 1:3 % x,y,z coords
%             [matchIndx{j}(:,k)] = ismember(rois(j).roi.coords(:,k), target(1,k) );
%         end
%     end
%     clear tf
% 
%     theRoi{c} = 'noRoi';
%     for m = 1:3     % nacc, caud, putamen
%         for n = 1:length(matchIndx{m})
%             if(matchIndx{m}(n,:))
%                 theRoi{c} = roiNames{m};
%             end
%         end
%     end
%     
% end
%             
%             
            
            
            
