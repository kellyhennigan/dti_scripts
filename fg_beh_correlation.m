% fg_beh_correlation new

clear all
close all

scaleToTest = 'NS2'; % impulsivity
scaleStr = 'impulsivity scores';


% fgMDir = '/Users/Kelly/dti/data/fgMeasures/mrtrix';
fgMDir = '/Users/Kelly/dti/data/fgMeasures/conTrack';
fgMatName = 'naccR.mat';


fgMeasureToTest = 'MD'; % options are FA, MD, AD, or RD
fgMeasureToPlot = 'FA';


saveFigs =0;   % 1 to save figs to outDir otherwise 0
outDir = '/Users/Kelly/dti/figures/fg_beh_corr';


 omit_subs = {'sa19','sa28'};

% omit_subs = { };


%%  get fiber group measures & tci data

load(fullfile(fgMDir,fgMatName));
% subjects(ismember(subjects,omit_subs))=[];

scores = getTciScores(scaleToTest,subjects);

% omit any subjects?
oIdx = unique([find(ismember(subjects,omit_subs)), find(isnan(scores))]);
fgMeasures=cellfun(@(x) x(find(~ismember(1:numel(subjects),oIdx)),:), fgMeasures, 'UniformOutput',0);
scores(oIdx) = []; subjects(oIdx) = [];
nSubs = numel(subjects);

fa = fgMeasures{1}; md = fgMeasures{2}; rd = fgMeasures{3}; ad = fgMeasures{4};

thisMeasure = fgMeasures{strcmp(fgMeasureToTest,fgMLabels)}; % fg test measure
thisMeasurePlot = fgMeasures{strcmp(fgMeasureToPlot,fgMLabels)}; % fg measure to plot



%% correlation test

% calculate correlation btwn scores & fg measure averaged over the whole fg
[r_wholefg,p_wholefg]=corr(scores,mean(thisMeasure,2));

fprintf(['\n\n TCIscore-' fgMeasureToTest ' corr averaged over the whole fg:\n r=%4.2f, p=%6.4f\n'],...
    r_wholefg, p_wholefg);

% calculate correlation between scores & fg Measure at each node
[r,p]=corr(scores,thisMeasure);

% find the strongest correlation
[best_p,best_node] = min(p);

fprintf(['\n\n TCIscore-' fgMeasureToTest ' corr at the best node:\n r=%4.2f, p=%6.4f\n'],...
    r(best_node), best_p);


% text for figure title
fig_text = sprintf('node %d; r = %3.2f; p = %3.4f (uncorrected),',...
    best_node,r(best_node),best_p);


% plot the strongest correlation
h = plotCorr(scores,zscore(thisMeasure(:,best_node)),scaleStr,fgMeasureToTest,fig_text);


%% plot the fgMeasures w/correlation strength in color

h(end+1)=dti_plotCorr(thisMeasure,r,[min(r) max(r)],fgMeasureToTest);

h(end+1)=dti_plotCorr(thisMeasurePlot,r,[min(r) max(r)],fgMeasureToPlot);



%% save figures?


if saveFigs==1   % then save correlation figure
    cd(outDir) 
    for f=1:numel(h)
        figure(h(f));
        saveas(gcf,[strrep(fgMatName,'.mat','') '_corr_fig' num2str(f)],'pdf');
    end
    
end

%% 

% % % get md values for each subject at the fiber group peak in FA
[best_fa,peak_idx] = max(fa(:,6:20),[],2);
peak_idx=peak_idx+5;
for i=1:nSubs
    best_md(i,1)=md(i,peak_idx(i));
    best_ad(i,1)=ad(i,peak_idx(i));
    best_rd(i,1)=rd(i,peak_idx(i));
end
fprintf(['\n corr with diffusion measurements taken from where FA peaks:\n\n'])
fprintf(['MD: ' num2str(corr(scores,best_md)) '\n\n']);
fprintf(['AD: ' num2str(corr(scores,best_ad)) '\n\n']);
fprintf(['RD: ' num2str(corr(scores,best_rd)) '\n\n']);
fprintf(['FA: ' num2str(corr(scores,best_fa)) '\n\n']);

figure(1)
