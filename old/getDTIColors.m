function colors = getDTIColors()

% % returns rgb values for the following: 
% 1) NAcc pathways
% 2) Caudate "
% 3) Putamen "
% 4) Dorsal Tier
% 5) Ventral Tier
% 6) DA ROI

%%%%%%%%%%%%%%%%%%%

caud = [238,178,35]./255;       % yellow
% nacc = [203 24 29]./255;        % red
nacc = [255 24 29]./255;        % red
putamen = [33, 113, 181]./255;  % blue
dTier = [244 101 7]./255;       % orange
vTier = [44, 129, 162]./255;     % blue (different from putamen blue)
daRoi = [35 132 67]./255;       % green

colors = [caud; nacc; putamen; dTier; vTier; daRoi]; % needs to match the number of elements in area vector

%  0.925 0.528 0.169 1 % nice purple complimentary to the caudate yellow
     
%  0.916 0.010 0.458 %% GREAT hot pink!!!!