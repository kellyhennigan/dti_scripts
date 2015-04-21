% plots fiber group endpoints as 3d ellipsoids normalized to the first
% fiber group given

%% files, subjects, etc.

clear all
close all

rois = {'caudate','nacc','putamen'}; % order shold correspond to fg names in fg struct

nNodes = [32 16 32];

subjects = getSASubjects('dti');

% index for two fiber groups to compare/test (should correspond to order in
% FG_fnames cell array)
refFg = 2;

colors = [0.9333    0.6980    0.1373;
    1.0000         0         0;
    0.0314    0.2706    0.5804];


%% get FG da endpoints

cd ~/ShockAwe/data/FGs/

load('rFGs_da_endpts.mat')

for i = 1:numel(subjects)
    
    % subject = subjects{i};
    % expPaths = getSAPaths(subject);
    
    fprintf(['\n\nworking on subject ',rFGs(i).subject,'\n\n']);
    
    % get z scores of ref fg endpts and scale other fgs relative to it
    [z_endpts{refFg},mu,sigma]=zscore(rFGs(i).da_endpts{refFg});
    
    for k = 1:length(rois)
        if k~=refFg
            n = length(rFGs(i).da_endpts{k});
            z_endpts{k} = (rFGs(i).da_endpts{k}-repmat(mu,n,1))./repmat(sigma,n,1);
        end
    end
    
    %% plot fiber group endpoints
    
    f(i) = figure('color','w')
    hold on
    
    for j = 1:length(rois)
        
        % compute ellipsoid using mean coords and covariance matrices as input
        M = mean(z_endpts{j});
        C = cov(z_endpts{j});
        [x{j},y{j},z{j}] = compute_ellipsoid(M,C,1); % last input says # of SDs for the radius
        
        % set up colormaps for plotting
        colors3{j}(1,1,:)=colors(j,:);
        cmap{j} = repmat(colors3{j},size(z{j}));
        
        % plot an ellipsoid surface
        sc{j} = surf(x{j},y{j},z{j},cmap{j}); % surface plot
        set(sc{j},'Edgecolor','n') % this may be redundant w/what shading interp does
        alpha(sc{1},0.6); % change transparency of ellipsoid
        
        % plot a dot at the centroid
        plot3(M(1),M(2),M(3),'.','markersize',20,'color',colors(j,:));
        
    end
    
    shading interp
    camlight headlight % add light for 3-D effect
    lighting phong
    % lighting gouraud
    
    axis equal
    grid on
    
    xlabel('med-lat','fontweight','bold');
    ylabel('ant-post','fontweight','bold');
    zlabel('inf-sup','fontweight','bold')
    
    cameratoolbar
    title({'DA endpoints of Caudate, NAcc, and Putamen pathways'},...
        'fontweight','bold')
    
    hold off
    
end % subjects
