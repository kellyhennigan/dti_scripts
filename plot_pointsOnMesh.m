function msh = plot_pointsOnMesh(msh, coords, cl_idx,colors, alpha)
% Color mesh vertices based on fiber endpoints
%
% msh = AFQ_meshAddFgEndpoints(msh, fg, colors, crange, alpha, weights, dilate)
%
% Inputs:
%
% msh
% coords - M x 3 matrix of x,y,z coords 
% cl_idx - M x 1 index vector indicating cluster assignment
% colors  - K x 3 matrix of r,g,b column vectors. K should be the # of 
%           clusters as indexed in cl_idx
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
weights = ones(size(coords,1),1);


% Default to fully opaque coloring
if notDefined('alpha')
    alpha = 1;
end

% jet is default color map
if notDefined('colors')
    colors = jet(size(coords,1));
end



%% find nearest mesh vertex to each point using nearpoints

        
        % Find the closest mesh vertex to each start coordinate
        msh_idx = nearpoints(coords', msh.vertex.origin');
       
        % get list of all unique mesh vertices to be colored
        mi = unique(msh_idx);
        
        
        
% color mesh vertices according to the cluster group w/the most coords 
%     closest to it
        for i=1:numel(mi)
            ci = mode(cl_idx(msh_idx==mi(i))); 
            msh.tr.FaceVertexCData(mi(i),:) = colors(ci,:);

        end
%         
%         rgb = getRgbVec(col_idx,colors);
%         
%         
%         
%         % Find the weighted endpoint count at each mesh index. To do this first
%         % start off with a weight of 0 at each vertex
%         w = zeros(size(msh.vertex.origin,1),1);
%         % Then loop over mesh vertices
%         for ii = 1:length(msh_indices1)
%             w(msh_indices1(ii)) = w(msh_indices1(ii))+weights(ii);
%         end
%         
    
       
        


%% Get the rgb color for each mesh vertex

% rgb = vals2colormap(w, colors, crange);

% Color current mesh vertices for all vertices where the weight is above
% the defined threshold
% msh.tr.FaceVertexCData(w>=crange(1),:) = rgb(w>=crange(1),:);

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