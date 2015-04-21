function [Cnew,del_Mnew] = choosepc(C,m,ind,x0)

m = m(:);
ind = sort(ind); ind = ind(:)';
ind0 = setdiff([1:5],ind);

% rearrange the eignevectors and eigenvalues of C
[U,L] = eig(C);
U = [U(:,ind),U(:,ind0)];
Ldiag = 1./(4*diag(L));
L = diag(Ldiag([ind,ind0]));
Ce = U*L*U';

if nargin<3
    x0 = [0;0]; %since original center is at origin, i.e. M=0, and
    % we are taking a section at M(ind0) (default);
end

% cost function
Cenew = Ce(1:3,1:3);
dnew = (Ce(1:3,4:5)+Ce(4:5,1:3)')*x0; %since d is zero.
cnew = x0'*Ce(4:5,4:5)*x0-1; % old c = -1: std eqn.

Cenew = -1/cnew*Cenew; % normalize to get the right radii.
dnew = -1/cnew*dnew;
del_Mnew = -inv(Cenew)*dnew;

[Ue,Le] = eig(Cenew);
Lediag = 1./(4*diag(Le));
Cnew = Ue*diag(Lediag)*Ue';