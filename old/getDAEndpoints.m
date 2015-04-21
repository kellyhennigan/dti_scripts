function [fg_out_daEndpts, daEndptCoords, fg_out_otherEndpts, otherEndptCoords] = getDAEndpoints(fg_in)

% this function takes a fiber group structural array as input
% (e.g., fg_in = mtrImportFibers('fiberGroup.pdb/)
% and returns the same structural array, only w/ just 
% the endpoint coordinates within the midbrain DA ROI for each pathway.

% optionally it will return fiber endpoint coordinates

%% kjh 4/2011

       [fg_out, startCoords, endCoords] = dtiReorientFibers(fg_in,2); % 2 is for number of nodes
        
        % z-coordinate closest to -10 is DA endpoint coordinate 
        if (abs(-10-startCoords(3)) < abs(-10-endCoords(3)))
            da_end = 1;
            other_end = 2;
        else 
            da_end = 2;
            other_end = 1;
        end
        
        fg_out_daEndpts = fg_out;
        fg_out_otherEndpts = fg_out;
        
        for i = 1:length(fg_out.fibers)
            
            fg_out_daEndpts.fibers{i} = fg_out.fibers{i}(:,da_end);
            daEndptCoords(:,i) = fg_out.fibers{i}(:,da_end);
            
            fg_out_otherEndpts.fibers{i} = fg_out.fibers{i}(:,other_end);
            otherEndptCoords(:,i) = fg_out.fibers{i}(:,other_end);
            
        end
        





