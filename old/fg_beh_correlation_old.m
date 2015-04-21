% test correlation between behavioral measures and pathway measures

% plot the most significant correlation
% plot individual subject fiber group measures

%%  define directories, files, params, etc. for correlation test

clear all
close all


scaleToTest = 'NS2'; % impulsivity

% fgMethod = 'conTrack';
 fgMethod = 'mrtrix';
fgMDir = ['/Users/Kelly/dti/data/fgMeasures/' fgMethod];
fgMatName = 'DA_nacc_20nodesR.mat';

fgMeasureToTest = 'MD'; % options are FA, MD, AD, or RD
fgMeasureToPlot = 'FA';

alpha = .05; % significance threshold
% alphaFWE = .0009; % alphaFWE for testing FA and MD values of the three pathways
mc_correct = 0; % 1 to correct for multiple comparisons, 0 to leave uncorrected
cmap_val = 'r'; % either p or r for value to use for colormap


saveFig =0;   % 1 to save figs to outDir otherwise 0
outDir = '/Users/Kelly/dti/figures/fg_beh_corr';

% omit_subs = {};
omit_subs = {'sa19','sa28'};


%%  get fiber group measures & tci data

load(fullfile(fgMDir,fgMatName));
% subjects(ismember(subjects,omit_subs))=[];

scores = getTciScores(scaleToTest,subjects);


%% omit any subs?

oIdx = unique([find(ismember(subjects,omit_subs)), find(isnan(scores))]);
fgMeasures=cellfun(@(x) x(find(~ismember(1:numel(subjects),oIdx)),:), fgMeasures, 'UniformOutput',0);
scores(oIdx) = []; subjects(oIdx) = [];

nSubs = numel(subjects);
fa = fgMeasures{1}; md = fgMeasures{2}; rd = fgMeasures{3}; ad = fgMeasures{4};


%% correlation test

thisMeasure = fgMeasures{strcmp(fgMeasureToTest,fgMLabels)};
thisMeasurePlot = fgMeasures{strcmp(fgMeasureToPlot,fgMLabels)};

for n = 1:numNodes
    [r(n),p(n)] = corr(thisMeasure(:,n),scores);
end

% find the strongest correlation
[best_p,best_node] = min(p)
p_indx = find(p<=alpha);
bestMeasure = thisMeasure(:,best_node);

% correct for multiple comparisons
if(mc_correct==1)
    [alphaFWE statFWE clusterFWE stats] = AFQ_MultiCompCorrection_kh(thisMeasure,scores,alpha,[]);
    mc_sig = best_p<=alphaFWE;
    fig_text = sprintf('node %d; r = %3.2f; p = %3.4f (uncorrected), alphaFWE = %3.4f',...
        best_node,r(best_node),best_p,alphaFWE);
else
    fig_text = sprintf('node %d; r = %3.2f; p = %3.4f (uncorrected),',...
        best_node,r(best_node),best_p);
    
end

%% plot strongest correlation

fig=figure; hold on;

plot(scores,zscore(bestMeasure),'.','MarkerSize',20,'color','k')
x = [min(scores)+.25, max(scores)-.25];
xlim([x(1)-.5 x(end)+.5])
y = x.*r(best_node);
plot(x,y,'LineWidth',2.5,'color','k')

set(gcf,'Color','w');
xlabel([scaleToTest, ' z-scores'],'fontName','Helvetica','fontSize',14)
ylabel([fgMeasureToTest, ' z-scores'],'fontName','Helvetica','fontSize',14)
title(fig_text,'fontName','Helvetica','fontSize',14)
set(gca,'fontName','Helvetica','fontSize',14)
hold off


%% plot fg measures 
%
% colors=solarizedColors(nSubs);
% 
% % sort subject order by personality scores for plotting
% [sortedScores,sortIndx] = sort(scores);
% 
% titleStr = [seed,'-',target,' fiber group measures'];
% for f = 1:length(fgMeasures)
%     % for f = 1:2
%     fig(f+1) = figure;
%     hold on;
%     set(gcf,'Color','w');
%     for k = 1:nSubs
%         s=plot(1:numNodes,fgMeasures{f}(sortIndx(k),:),'color',colors(k,:),'Linewidth',2.5);
%     end
%     title(titleStr)
%     xlabel('fiber group nodes')
%     ylabel(fgMLabels{f})
%     xlim([.5,numNodes+.5])
%     yL = ylim;
%     if strcmp(fgMeasureToTest,fgMLabels{f})
%         for k = 1:length(p_indx)
%             text(p_indx(k),yL(2)-.05,'*','FontSize',24,'HorizontalAlignment','center');
%         end
%     end
%     legend(subjects(sortIndx))
%     hold off
% end
% 
% 
%%


h=dti_plotCorr(thisMeasure,r,[min(r) max(r)],fgMeasureToTest);
h=dti_plotCorr(thisMeasurePlot,r,[min(r) max(r)],fgMeasureToPlot);

%% save figs

if saveFig==1   % then save correlation figure
    cd(outDir)
    
    %     for ff=1:length(fig)
    figure(1);
    set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
    saveas(gcf,[seed,'-',target,LorR,'_',fgMeasureToTest,'_',scaleToTest,'_corr'],'epsc');
    saveas(gcf,[seed,'-',target,LorR,'_',fgMeasureToTest,'_',scaleToTest,'_corr'],'png');
    
    %     end
    
    figure(4)
    ylabel('Mean diffusivity')
    set(gcf,'Color','w','InvertHardCopy','off','PaperPositionMode','auto');
    saveas(gcf,[seed,'-',target,LorR,'_',fgMeasureToTest,'_',scaleToTest,'_corr_cmap'],'epsc');
    saveas(gcf,[seed,'-',target,LorR,'_',fgMeasureToTest,'_',scaleToTest,'_corr_cmap'],'png');
end

% % % get md values for each subject at the fiber group peak in FA
[best_fa,peak_idx] = max(fa(:,6:20),[],2);
peak_idx=peak_idx+5;
for i=1:nSubs
  best_md(i,1)=md(i,peak_idx(i));
   best_ad(i,1)=ad(i,peak_idx(i));
    best_rd(i,1)=rd(i,peak_idx(i));
end
corr(scores,best_md)
corr(scores,best_rd)
corr(scores,best_ad)
corr(scores,best_fa)

% peak_indx = peak_indx+5
%
% md_faPeak = allMd(peak_indx);
% [r_peak,p_peak]=corr(scores,md_faPeak)
%
%
%
fig

