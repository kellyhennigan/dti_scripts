function f = mpcagui2c(f)

clear global
clear('updateGUI')
set(0,'DefaultfigureUnits','nor')
set(0,'DefaultUicontrolUnits','nor')
global ii
if nargin==1
    figure(f)
    delete(get(f,'children'))
else
    close all
    f = figure('name','PCA for Etching Process',...
        'position',[0.0289,0.2705,0.7531,0.6592],'color',1*[1 1 1],'resize','off');
%     f = figure('name','PCA for Etching Process',...
%         'position',[0.0289,0.5879,0.3641,0.3125],'color',1*[1 1 1],'resize','off');
    %,'menubar','none','toolbar','n');
    %f2 = figure('color',0.95*[1 1 1],'pos',[741,73,560,420]);
end

s1 = -0.1; s2 = 0.9; sh = 0.08;
ax = axes('parent',f,'Position',[0.35+s1,0.55+sh,0.3*s2,0.4*s2],...
    'color',0.9*[1 1 1],'tag','ax');
ax_right = axes('parent',f,'Position',[0.65+s1,0.53+sh,0.3*s2,0.4*s2],...
    'color','n','box','off','tag','ax_right');
ax_left = axes('parent',f,'Position',[0.010+s1,0.575+sh,0.3*s2,0.4*s2],...
    'color','n','box','off','tag','ax_left');
ax_down = axes('parent',f,'Position',[0.35+s1,0.15+sh,0.3*s2,0.4*s2],...
    'color','n','box','off','tag','ax_down');
[ax_panner,xpan,ypan] = createPanner(f);

ax_list = [ax;ax_right;ax_left;ax_down;ax_panner];
% data axis 
%ax_time = axes('parent',f,'pos',[0.55 0.05 0.43 0.5],'color',0.95*[1 1 1]);

%------------------------------------------------------------------------
%load batch3a % has 5 PC batches.
%load udat, md = md.';
%load batch_fault % has 5 PC batches.
%load udat_fault, md = md.';
load batch3a
save mybatch c m t umat v 
load udat
save myudat md

load mybatch
load myudat, md = md.';

var = {'Endpt A','He Press','Pressure','RF Tuner','RF Load',...
        'RF Phase Err','RF Pwr','RF Impedance','TCP Tuner','TCP Phase Err',...
        'TCP Impedance','TCP Load'};

[i1 i2] = size(m);
% alp = logspace(-1.5,0,i1);
% alp11 = linspace(32,-6,i1);

c1 = squeeze(c(1,:,:));
m1 = m(1,:); m1 = m1(:);
ind = 1:3; %default PC selection.

% control ellipse
load control_ellip_data
% con_c = squeeze(c(10,:,:));
% con_m = m(end,:); con_m = con_m(:);

ii = 1; 
set(f,'Userdata',{c1,m1,ind,ax_list,con_c,con_m},'toolbar','f');
cameratoolbar('show')
updateGUI(f,[],'mpcagui');
set(f,'handleVisibility','callback');

%--------------------------------------------------------------------------