function [x,y,z] = compute_ellipsoid(M,C,nSD)
%COMPUTE_ELLIPSOID is a subroutine than computes the surface points of a
% 2 standard deviations (95% confidence) ellipsoid coresponding to the provided
% mean (M) and covariance (C) data.
%
%
% kjh, added nSD as input so that 1 sd can be used

[U,L] = eig(C);
%
%     For 2 standard deviation spread of data, the radii of the ellipsoid will
%     be given by 2*SQRT(eigenvalues).

radii = nSD*sqrt(diag(L)); 
[xc,yc,zc] = ellipsoid(0,0,0,radii(1),radii(2),radii(3),50);
%
a = kron(U(:,1),xc); b = kron(U(:,2),yc); c = kron(U(:,3),zc);
data = a+b+c; 
n = size(data,2);
x = data(1:n,:)+M(1); 
y = data(n+1:2*n,:)+M(2); 
z = data(2*n+1:end,:)+M(3);
%--------------------------------------------------------------------------