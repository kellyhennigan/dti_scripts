%% isosurface example

% Example 1
% This example uses the flow data set, which represents the speed profile of a submerged jet within an infinite tank (type help flow for more information). The isosurface is drawn at the data value of -3. The statements that follow the patch command prepare the isosurface for lighting by
% 
% Recalculating the isosurface normals based on the volume data (isonormals)
% 
% Setting the face and edge color (set, FaceColor, EdgeColor)
% 
% Specifying the view (daspect, view)
% 
% Adding lights (camlight, lighting)

figure(1)
[x,y,z,v] = flow;
p = patch(isosurface(x,y,z,v,-3));
isonormals(x,y,z,v,p)
set(p,'FaceColor','red','EdgeColor','none');
daspect([1,1,1])
view(3); axis tight
camlight 
lighting gouraud

%% Draw contour lines on a series of slice planes

% This example uses the flow data set to illustrate the use of contoured 
% slice planes. (Type doc flow for more information on this data set.) 
% 
% Notice that this example:
% 
% Specifies a vector of length = 9 for Sx, 
% an empty vector for the Sy, and a scalar value (0) for Sz. 
% This creates nine contour plots along the x direction in the y-z plane, 
% and one in the x-y plane at z = 0.
% 
% Uses linspace to define a 10-element vector of linearly spaced values 
% from -8 to 2. This vector specifies that 10 contour lines be drawn, 
% one at each element of the vector.
% 
% Defines the view and projection type (camva, camproj, campos).
% 
% Sets figure (gcf) and axes (gca) characteristics.

figure(2)
[x y z v] = flow;
h = contourslice(x,y,z,v,[1:9],[],[0],linspace(-8,2,10));
axis([0,10,-3,3,-3,3]); daspect([1,1,1])
camva(24); camproj perspective;
campos([-3,-15,5])
set(gcf,'Color',[.5,.5,.5],'Renderer','zbuffer')
set(gca,'Color','black','XColor','white', ...
	'YColor','white','ZColor','white')
box on

%% plot 3D ellipsoid
% developed from the original demo by Rajiv Singh
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/42966
% 5 Dec, 2002 13:44:34
% Example data (Cov=covariance,mu=mean) is included.

figure(3)
Cov = [1 0.5 0.3
       0.5 2 0
       0.3 0 3];
mu = [1 2 3]';

[U,L] = eig(Cov);
% L: eigenvalue diagonal matrix
% U: eigen vector matrix, each column is an eigenvector

% For N standard deviations spread of data, the radii of the eliipsoid will
% be given by N*SQRT(eigenvalues).

N = 1; % choose your own N
radii = N*sqrt(diag(L));

% generate data for "unrotated" ellipsoid
[xc,yc,zc] = ellipsoid(0,0,0,radii(1),radii(2),radii(3));

% rotate data with orientation matrix U and center mu
a = kron(U(:,1),xc);
b = kron(U(:,2),yc);
c = kron(U(:,3),zc);

data = a+b+c; n = size(data,2);

x = data(1:n,:)+mu(1);
y = data(n+1:2*n,:)+mu(2);
z = data(2*n+1:end,:)+mu(3);

% now plot the rotated ellipse
% sc = surf(x,y,z); shading interp; colormap copper
h = surfl(x, y, z); colormap copper
title('actual ellipsoid represented by mu and Cov')
axis equal
alpha(0.7)

