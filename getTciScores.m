function zscores = getTciScores(scale,subjects)

% getTciScores
% -------------------------------------------------------------------------
% usage: function to load subject's tci scores for experiment ShockAwe 
% 
% INPUT:
%   scale - string specifying which scale is desired 
%   subjects - cell array of subject strings specifying which subjects to return
%              scores for 
% 
% OUTPUT:
%   zscore - z-scores for desired scale
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 26-Mar-2015
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tciScoreFilePath = '/Users/Kelly/dti/data/tci_scores/tci_scores.mat';

load(tciScoreFilePath);

tci_scores(18,:)=nanmean(tci_scores); % sa28

indx =ismember(tci_subjects,subjects);

tci_subjects = tci_subjects(indx);
tci_scores = tci_scores(indx,:);

scoreIndx = strmatch(scale,tci_scaleLabels,'exact');
scores = tci_scores(:,scoreIndx);

zscores=(scores-nanmean(scores))./nanstd(scores); % do this instead of zscore() in case there are nans


