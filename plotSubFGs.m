% script to plot diffusivity measures along a pathway for a bunch of subs

% define variables, directories, etc.
clear all
close all

dataDir = '/Users/Kelly/dti/data';


% fgMat files relative to dataDir
fgMatFiles = {'fgMeasures/conTrack/DA_nacc_20nodesR.mat',...
    'fgMeasures/mrtrix/DA_nacc_20nodesR.mat',...
    'fgMeasures/mrtrix/DA_nacc_20nodesR_iFOD1.mat'};


% strings for plotting
fgMatStrs = {'conTrack','mrtrix','iFOD1'}; 

% plot colors
c =   [0.8275    0.2118    0.5098
    0.1490    0.5451    0.8235
    0.7591    0.3983    0.0493];


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
    title([subjects{i} ' naccR fibers'])
    hold off
    subplot(1,2,2); hold on
    for j=1:numel(fgMatFiles)
    plot(md(i,:,j),'color',c(j,:))
    end
    ylabel('MD')
    legend(fgMatStrs)
    hold off
    saveas(gcf,[subjects{i} '_naccR.pdf'])
    close all
end
    