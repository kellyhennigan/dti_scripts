% code from here:
% http://www.mathworks.com/matlabcentral/fileexchange/3171-visualization-tools-for-process-condition-monitoring/content/walk_through_demo.html

cd ~/dti/scripts/mpcademo/

clc
g = get(0,'defaultfigureunits');
set(0,'defaultfigureunits','normalized');
%
load calibration_data
whos t udat

umat = squeeze(reshape(udat,37,1,[]));
avg = mean(umat);
st = std(umat);
umat = (umat-ones(37,1)*avg)./(ones(37,1)*st);
%
whos umat

[P, sc, L, t2] = princomp(umat);

bar(L(1:20)/sum(L)*100)
xlabel('Principal Component number'), ylabel('% of variability explained')

Pc = P(1:3,:); % first 3 direction vectors

mapped_calib_data = umat*Pc.'; %3 coordinates for 37 batches in a 
                               %37 x 3 matrix; coordinates are called
                               %"scores".

M = mean(mapped_calib_data);
C = cov(mapped_calib_data);

% M = [0;0;0];
% 
% C = [1 1 1;
%     1 1 1;
%     1 1 1;];
    

[x,y,z] = compute_ellipsoid(M,C); 

% x=real(x);
% y=real(y);
% z=real(z);



% (x, y, z) are the points on the surface of the 95% confidence ellipsoid.
% We can visualize this region as follows:

% f = figure('pos',[0.0016,0.3867,0.4789,0.5039],'color','w');
f = figure('color','w')
sc = surf(x,y,z,0.6*ones([size(z),3])); % surface plot 
shading interp
xlabel('med-lat','fontweight','bold'); 
ylabel('ant-post','fontweight','bold'); 
zlabel('inf-sup','fontweight','bold')
%
% Apply advanced graphics options:
alpha(sc,0.4); % change transparency of ellipsoid
camlight headlight % add light for 3-D effect
lighting phong


load testdata
whos gooddata baddata

mapped_good_data = gooddata*Pc.'; % scores for a normal batch
mapped_bad_data = baddata*Pc.';   % scores for a faulty batch

figure(f);
hold on
plot3(mapped_good_data(1),mapped_good_data(2),mapped_good_data(3),...
    'b.','markersize',15);
plot3(mapped_bad_data(1),mapped_bad_data(2),mapped_bad_data(3),...
    'r.','markersize',15);
cameratoolbar
title({'Ellipsoid of "in-control" region','and scores for completed batches'},...
    'fontweight','bold')

available_data =  gooddata(1:38); % only 1/3 of total data is available
%
% Compute the covariance of the training (calibration data), re-distributed
% along the first 3 directions.
% This will take a few seconds...

L1 = L(1:3); L1 = L1(:);
n = size(P,1);
L2 = ((sum(L)-sum(L1))/(n-3))*ones(n-3,1);
newL = [L1;L2];
S = P*diag(newL)*P.';

% Partition the covariance information: 
S11 = S(1:38,1:38);
S12 = S(1:38,39:end);
S21 = S(39:end,1:38);
S22 = S(39:end,39:end);

W1 = P(1:3,1:38);
W2 = P(1:3,39:end);

% Compute the score mean and covariance
score_mean =  (W1+W2*S21*inv(S11))*available_data.';
score_cov = W2*(S22-S21*inv(S11)*S12)*W2.';
%

[xd,yd,zd] = compute_ellipsoid(score_mean,score_cov); %
%
f1 = figure('pos',[0.4555,0.3740,0.5086,0.5166],'color','w');
mymap1(:,:,1) = repmat(0,51,51); 
mymap1(:,:,2) = repmat(0,51,51); 
mymap1(:,:,3) = repmat(1,51,51);

s = surf(xd,yd,zd,mymap1); % forecasted score region
alpha(s,1); 
hold on
sc = surf(x,y,z,0.6*ones([size(z),3])); % in-control region
set(sc,'Edgecolor','n')
alpha(sc,0.4);

shading interp
xlabel('S_1','fontweight','bold'); 
ylabel('S_2','fontweight','bold'); 
zlabel('S_3','fontweight','bold')
camlight headlight, lighting phong
cameratoolbar

available_data =  baddata(1:38); % only 1/3 of total data is available

score_mean =  (W1+W2*S21*inv(S11))*available_data.';
score_cov = W2*(S22-S21*inv(S11)*S12)*W2.';

[xf,yf,zf] = compute_ellipsoid(score_mean,score_cov); %
figure(f1);
mymap2(:,:,1) = repmat(1,51,51); 
mymap2(:,:,2) = repmat(0,51,51); 
mymap2(:,:,3) = repmat(0,51,51);
sf = surf(xf,yf,zf,mymap2);
alpha(sf,0.8)
shading interp
camlight headlight, lighting phong
title({'Forecasted regions for incomplete normal (blue)','and faulty (red) batches'},...
    'fontweight','bold')
axis equal
%

echo off
set(0,'defaultfigureunits',g);