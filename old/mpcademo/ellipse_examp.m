% CODE SNIPPET TO DEMONSTRATE VISULAIZATION ENABLED ANALYSIS

echo on
% Suppose we have stastistical information about current batch data
% available. For three prinicpal components (PCs) based analysis, suppose we are
% given projections of data covariace and mean onto the PC-space: C and M.

C = [4.6845, -1.8587,  1.6523; -1.8587,  1.3192, -0.7436; 1.6523, -0.7436,  1.2799];  
M = [-9.7275; 4.5526; -5.6775];

% Then the region of interest would be an ellipsoid centered at M, whose
% size will be govered by C.

% Perform eigenvalue analysis on C..
% U: Eigenvectors - dictate orientation of ellipsoid
% L: Eigenvalues - decide size of ellipsoid 
[U,L] = eig(C);

% For 2 standard deviation spread of data, the radii of the eliipsoid will
% be given by 2*SQRT(eigenvalues).

radii = 2*sqrt(diag(L)); 

% draw the ellipsoid (without orientation)
f = figure;
ellipsoid(0,0,0,radii(1),radii(2),radii(3));
title('unrotated ellipsoid centered at origin')

pause 

% now orinet this ellipsoid in proper direction
% first, generate data for ellipsoid
[xc,yc,zc] = ellipsoid(0,0,0,radii(1),radii(2),radii(3));
% second, rotate it with orientation matrix U
a = kron(U(:,1),xc); b = kron(U(:,2),yc); c = kron(U(:,3),zc);
data = a+b+c;  n = size(data,2);
x = data(1:n,:)+M(1); y = data(n+1:2*n,:)+M(2); z = data(2*n+1:end,:)+M(3);

% now plot the rotated ellipse
sc = surf(x,y,z); 
shading interp
title('actual ellipsoid represented by data: C and M')

pause 

% advanced graphics options..
alpha(sc,0.5) % change transparency of ellipsoid
camlight headlight % add light for 3-D effect
lighting phong 

colorbar % add colorbar
cameratoolbar('show') % camera toolbar for animation

pause 

% play more ....
% first, change colormap
colormap copper

pause

colormap summer

pause

% superimpose another ellipsoid: use a wireframe representation for it  
hold on
[x1,y1,z1] = ellipsoid(M(1),M(2),M(3),1,0.5,2);
sc1 = surf(x1+1,y1+1,z1/1.8-1,'facecolor','n','edgecolor','k'); 
hold off

pause

% change transparency and add axes labels
colormap default
alpha(sc,0.3), camlight
xlabel('Score_1'), ylabel('Score_2'), zlabel('Score_3')
echo off