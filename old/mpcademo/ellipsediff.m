function [xout,yout,zout] = ellipsediff(delta,r,rc,n)
 
% Draws the geometric difference between two congruent ellspoids
% of radii defined by the 3 d vector r and where the centeres
% differ by the vector delta

%r = [5 2 1];
% delta = [.7 .9 .5];

[x,y,z] = ellipsoid(0,0,0,r(1),r(2),r(3),n);
[xc,yc,zc] = ellipsoid(0,0,0,rc(1),rc(2),rc(3),n);
z1 = z;
z2 = zc;

if min(r) <= eps
    error('Non trivial ellipoids only')
end    
for i=1:size(x,1)
    for j=1:size(x,2)
        if (rc.^-2)*([x(i,j); y(i,j); z(i,j)]-delta).^2 <=1
            % exclude points in the non-shifted ellispoid but inside the shifted ellispoid
            % this is the outer shell
            z1(i,j) = NaN;
        end
        if (r.^-2)*([xc(i,j); yc(i,j); zc(i,j)]+delta).^2 >=1
            z2(i,j) = NaN;
            % exclude points in the shifted ellispoid but outside the non-shifted ellispoid
            % 
        end
    end
end
xout = [x xc+delta(1)];
yout = [y yc+delta(2)];
zout = [z1 z2+delta(3)];
% surf([x xc+delta(1)],[y yc+delta(2)],[z1 z2+delta(3)])
% shading interp;

