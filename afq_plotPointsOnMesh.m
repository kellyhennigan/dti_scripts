function msh = afq_plotPointsOnMesh(msh, coords, colors, crange, alpha)
% Color mesh vertices based on fiber endpoints
%
% msh = AFQ_meshAddFgEndpoints(msh, fg, colors, crange, alpha, weights, dilate)
%
% Inputs:
%
% msh
% fg      - coords in same coord space as mesh
% colors  - nx3 matrix of rgb values for which to color fiber endpoint
%           density on the cortical surface.
% crange  - The endpoint density to map to the minumum and maximum color
%           values
% alpha   - transparency [>0,  <=1]
%
%
% Copyright - Jason D. Yeatman, December 2013
%
% this is an edited version of Jason's AFQ_meshAddFgEndpoints function
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


% By default just map each fiber to the nearest mesh vertex
distfun = 'nearpoints';


% weight each coord as 1
weights = ones(size(coords,2),1);


% Default to fully opaque coloring
if notDefined('alpha')
    alpha = 1;
end

% jet is default color map
if notDefined('colors')
    colors = jet(256);
end

% Read in the fiber group if a path was given
% if ischar(fg)
%     fg = fgRead(fg)
% end



%% Map fiber endpoints to weights on the cortical surface
% There are multiple distance functions that can be used
% switch(distfun)
%     
%     case{'nearpoints'}
        
        % Find the closest mesh vertex to each start coordinate
        msh_indices1 = nearpoints(coords, msh.vertex.origin');
        
        % Find the weighted endpoint count at each mesh index. To do this first
        % start off with a weight of 0 at each vertex
        w = zeros(size(msh.vertex.origin,1),1);
        % Then loop over mesh vertices
        for ii = 1:length(msh_indices1)
            w(msh_indices1(ii)) = w(msh_indices1(ii))+weights(ii);
        end
        
        % If the color range is not defined then go 1 to 90% of max
        if notDefined('crange')
            crange = [1 prctile(w(w>=1),90)];
        elseif length(crange) == 1
            crange = [crange(1) prctile(w(w>=1),90)];
        end
        
        % Dilate the coloring to adjacent vertices if desired
        % Find faces that touch one of the colored vertices
%         msh_faces = sum(ismember(msh.face.origin, msh_indices1),2)>0;
%         msh_indicesNew = msh.face.origin(msh_faces,:);
%         msh_indicesNew = msh_indicesNew(:);
%         % Confine this to only new mesh vertices that do not already have a fiber
%         % endpoint
%          msh_indicesNew = unique(msh_indicesNew(~ismember(msh_indicesNew,msh_indices1)));
%         % Give these vertices a value as if one fiber is in them if there was zero
%         % fibers. This effectively gives some smoothing
%         for ii = 1:length(msh_indicesNew)
%             % Find the adjacent vertices
%             tmp = msh.face.origin(sum(msh.face.origin == msh_indicesNew(ii),2)>0,:);
%             % And give our vertex in question the average, non-zero, weight of the
%             % adjacent vertices
%             wtmp = w(tmp(:));
%             w(msh_indicesNew(ii)) = mean(wtmp(wtmp>0));
%         end
        
% end





%% Get the rgb color for each mesh vertex

rgb = vals2colormap(w, colors, crange);

% Color current mesh vertices for all vertices where the weight is above
% the defined threshold
msh.tr.FaceVertexCData(w>=crange(1),:) = rgb(w>=crange(1),:);

return

% % Interpolate the coloring along the surface
% shading('interp');
% % Set the type of lighting
% lighting('gouraud');
% % Set the alpha
% alpha(p,params.alpha);
% % Set axis size
% axis('image');axis('vis3d');
% % Set lighiting options of the vol
% set(p,'specularstrength',.5,'diffusestrength',.75);



%% Notes of how to handle other vertex mappings

% % First we need to check to see if the vertices are the same as the
% % original ones
% if  strcmp(msh.map2origin.(msh.vertex.current),'origin')
%     % Combine colors
%     facecolors = alpha.*repmat(color,length(msh_indices),1) + (1-alpha).*msh.tr.FaceVertexCData(msh_indices,:);
%     msh.tr.FaceVertexCData(msh_indices,:) = facecolors;
% else
%     % Find the vertex to origin mapping
%     new_indices = find(ismember(msh.map2origin.(msh.vertex.current), msh_indices));
%     facecolors = alpha.*repmat(color,length(new_indices),1) + (1-alpha).*msh.tr.FaceVertexCData(new_indices,:);
%     msh.tr.FaceVertexCData(new_indices,:) = facecolors;
% end