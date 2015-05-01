% script to plot diffusivity measures along a pathway for a bunch of subs

% define variables, directories, etc.
clear all
close all

dataDir = '/Users/Kelly/dti/data';


target = 'naccL'; 

% fgMat files relative to dataDir
% fgMatFiles = {['fgMeasures/conTrack/' target '.mat'],...
%     ['fgMeasures/conTrack/' target '_manclean.mat'],...
%     ['fgMeasures/mrtrix/' target '.mat']};
fgMatFiles = {['fgMeasures/conTrack/' target '.mat'],...
    ['fgMeasures/conTrack/' target '_manclean.mat']};

% strings for plotting
fgMatStrs = {'autoclean','manclean'}; 

% plot colors
% c =   [0.8275    0.2118    0.5098
%     0.1490    0.5451    0.8235
%     0.7591    0.3983    0.0493];
c =   [0.8275    0.2118    0.5098
    0.1490    0.5451    0.8235];


figDir = '/Users/Kelly/dti/figures/contrack_vs_mrtrix';

%%


cd(dataDir);
for j=1:numel(fgMatFiles)
    load(fgMatFiles{j})
    fa(:,:,j) = fgMeasures{1};
    md(:,:,j) = fgMeasures{2};
end


cd(figDir); 
for i=1:numel(subjects)
    setupFig
    subplot(1,2,1); hold on
    for j=1:numel(fgMatFiles)
    plot(fa(i,:,j),'color',c(j,:))
    end
    ylabel('FA')
    title([subjects{i} ' ' target ' fibers'])
    hold off
    subplot(1,2,2); hold on
    for j=1:numel(fgMatFiles)
    plot(md(i,:,j),'color',c(j,:))
    end
    ylabel('MD')
    legend(fgMatStrs)
    hold off
    saveas(gcf,[subjects{i} '_' target '.pdf'])
    close all
end


%% Render a fiber group with each point colored based on FA
% See dtiGetValFromFibers
arc_fa = dtiGetValFromFibers(dt.dt6,arc_clean,inv(dt.xformToAcpc),'fa');
rgb = vals2colormap(arc_fa);
AFQ_RenderFibers(arc_clean,'color',rgb,'numfibers',100)

    