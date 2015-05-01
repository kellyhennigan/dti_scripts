function colors = getDTIColorsCell()

% % returns rgb values for the following: 
% 1) NAcc pathways
% 2) Caudate "
% 3) Putamen "
% 4) Dorsal Tier
% 5) Ventral Tier
% 6) DA ROI

% same as getDTIColor except returning output in a cell array
% 
%%%%%%%%%%%%%%%%%%%

caud{1} = [238,178,35]./255;       % yellow
nacc{1} = [203 24 29]./255;        % red
putamen{1} = [33, 113, 181]./255;  % blue
dTier{1} = [244 101 7]./255;       % orange
vTier{1} = [44, 129, 162]./255;     % blue (different from putamen blue)
daRoi{1} = [35 132 67]./255;       % green

colors = [caud; nacc; putamen; dTier; vTier; daRoi]; % needs to match the number of elements in area vector
