function [roi_idx,dist] = closestRoi(coords,roiDir,roiNames)

% this function takes a subject string (directory name) and a set of
% coordinates and returns the name of the striatum ROI that the coordinate 
% is closest to/falls into. (betweclosest roiof the NAcc, Caudate, or Putamen ROIs the
% coordinates are in.  If N points (gmm means), coords should be a N x 3 array
% with each row containing x,y,z coordinate values for a point.

% assumes the coordinates values given in coords are in the same coord
% system as the loaded ROIs
%%

baseDir = '/Users/Kelly/dti/data';

roiDir = fullfile(baseDir, subj, 'ROIs');



for j = 1:numel(roiNames)
    load(fullfile(roiDir,[roiNames{j},'.mat'])); % loads roi.coords
    [dist(j),~] =  pdist2(roi.coords,coords,'euclidean','Smallest',1);
end



%% this is going to be embarrassingly clunky.  Jus get over it and write
%% the damn thing.

[D,I] = pdist2(X,Y,distance,'Smallest',K)

coords = round(coords);

for c = 1:size(coords,1)
    
    target = coords(c,:);
    
    for j = 1:3    % NAcc, caud, putamen
        for k = 1:3 % x,y,z coords
            [matchIndx{j}(:,k)] = ismember(rois(j).roi.coords(:,k), target(1,k) );
        end
    end
    clear tf

    theRoi{c} = 'noRoi';
    for m = 1:3     % nacc, caud, putamen
        for n = 1:length(matchIndx{m})
            if(matchIndx{m}(n,:))
                theRoi{c} = roiNames{m};
            end
        end
    end
    
end
            
            
            
            
            
