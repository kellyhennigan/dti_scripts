% test correlations between:

% dti, 
% functional,
% and behavior 
% %%%%%%%%%%%%%%%%%%%%%%%%%%

omitSubs = {'sa28'};

subjects = getSASubjects('hab');

% DTI measures info
target_roi = ''; % for dti measures
nNodes = '20';
RorL = 'R'; % options are R, L, or RL
fgMeasureToTest = 'MD'; % options are FA, MD, AD, or RD

% FUNC measures info
funcMeasureDir = 'betas';

% BEHAVIOR measures info
scaleToTest = 'HA';

alpha = .05; % significance threshold

cd ~/ShockAwe/data/

%% dti measures

% cd ../fgMeasures
% 
% load([target_roi,'_',num2str(nNodes),'nodes',RorL,'.mat']);
% dti_subjects = subjects';
% subjects = getSASubjects('fmri&dti');
% indx = ismember(dti_subjects,subjects);
% for f = 1:length(fgMeasures)
%     fgMeasures{f} = fgMeasures{f}(indx,:);
% end
% fgTestIndx = strmatch(fgMeasureToTest,fgMLabels,'exact');
% thisMeasure = fgMeasures{fgTestIndx};

%% func measure

cd(funcMeasureDir);


habt{1}=dlmread('hab_juice_tent_0_10_6_betas')  
habt{2}=dlmread('hab_neutral_tent_0_10_6_betas')
habt{3}=dlmread('hab_shock_tent_0_10_6_betas')

habs{1}=dlmread('hab_juice_spm_hrf_6_16_1_1_10_0_32_betas')
habs{2}=dlmread('hab_neutral_spm_hrf_6_16_1_1_10_0_32_betas')
habs{3}=dlmread('hab_shock_spm_hrf_6_16_1_1_10_0_32_betas')

haba{1}=dlmread('hab_juice_afni_betas')
haba{2}=dlmread('hab_neutral_afni_betas')
haba{3}=dlmread('hab_shock_afni_betas')

habpt{1}=dlmread('hab_juice_per_trial_betas')
habpt{2}=dlmread('hab_neutral_per_trial_betas')
habpt{3}=dlmread('hab_shock_per_trial_betas')


Bs=Bs(~strcmp(subjects,omitSubs));

Bs = dlmread(funcMeasureFile);  % col 1 is juice, col 2 is neutral, col 3 is shock
omitIndx = true(length(subjects),1);
omitIndx = ~ismember(subjects,omitSubs);
Bs = Bs(omitIndx,:);
zBs = zscore(Bs);

%% behavior measures

cd tci_scores

load('tci_scores.mat');

indx = ~isnan(tci_scores(:,2));
omitIndx = ismember(tci_subjects,subjects);
indx = logical(double(indx).*double(omitIndx));
tci_subjects = tci_subjects(indx);
tci_scores = tci_scores(indx,:);

scoreIndx = strmatch(scaleToTest,tci_scaleLabels,'exact');
scores = tci_scores(:,scoreIndx);


%% correlation between scores & dti measure
% 
% for n = 1:nNodes
%     [r(n),p(n)] = corr(thisMeasure(:,n),scores);
% end
% 
% % find the strongest correlation
% [best_p,best_node] = min(p);
% p_indx = find(p<=alpha);
% 
% % correct for multiple comparisons
% [alphaFWE statFWE clusterFWE stats] = AFQ_MultiCompCorrection_kh(thisMeasure,scores,alpha,[]);
% mc_sig = best_p<=alphaFWE;
% 
% mc_sig

%% correlation between betas & tci scores
% 
[r,p]=corr(Bs(:,3),scores) % shock
[r,p]=corr(Bs(:,3)-Bs(:,2),scores) % shock - neutral
[r,p]=corr(Bs(:,3)-Bs(:,1),scores) % shock - juice



%% test for correlation between betas and dti measure at the best node

% if best_node==1
%     best_md = thisMeasure(:,best_node:best_node+2);
% elseif best_node ==nNodes;
%     best_md = thisMeasure(:,best_node-2:best_node);
% else
%     best_md = thisMeasure(:,best_node-1:best_node+1);
% end
% best_md = mean(best_md,2);
% [rr,pp] = corr(betas,best_md);
% 
% fig(1)=figure; hold on;
% set(gcf,'Color','w');
% plot(betas,zscore(best_md),'.','MarkerSize',20,'color','k')
% xlabel(['betas', ' z-scores'],'fontName','Helvetica','fontSize',14)
% ylabel([fgMeasureToTest, ' z-scores'],'fontName','Helvetica','fontSize',14)
% 
% % draw a correlation line
% x = [min(zscores)+.25, max(zscores)-.25];
% xlim([x(1)-.5 x(end)+.5])
% y = x.*r(best_node);
% plot(x,y,'LineWidth',2.5,'color','k')
% fig_text = sprintf('node %d-%d; r = %3.2f; p = %3.4f (uncorrected), alphaFWE = %3.4f',...
%     best_node-1,best_node+1,best_r,best_p,alphaFWE);
% title(fig_text,'fontName','Helvetica','fontSize',14)
% set(gca,'fontName','Helvetica','fontSize',14)
% hold off
% 


