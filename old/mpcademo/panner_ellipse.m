function [ellipdata,m2] = panner_ellipse(C,m,ind)

if size(C,1)>5
    Cnew = C;
    del_Mnew = zeros(size(C,1),1);
    return;
end
m = m(:);

ind = sort(ind); ind = ind(:)';
ind0 = setdiff([1:5],ind);

% rearrange the eignevectors and eigenvalues of C
[U,L] = eig(C);
U = [U(:,ind),U(:,ind0)];
Ldiag = 1./(4*diag(L));
L = diag(Ldiag([ind,ind0]));
Ce = U*L*U';

% "choose" ellipse (for region of allowable x0).
C2 = Ce(4:5,4:5); % so that x0'*C2*x0+d2'x0-1 is ellipse
%center of ellipse is: m2 = -inv(C2)*d2
d = -Ce*m; 
d2 = d(4:5);
m2 = -inv(C2)*d2;
[U2,L2] = eig(C2);
thet = [0:51]/50*2*pi;
ellipdata = U2*[1/sqrt(L2(1,1))*cos(thet);1/sqrt(L2(2,2))*sin(thet)];
ellipdata = ellipdata+repmat(m2,1,length(thet));