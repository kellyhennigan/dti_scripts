%% sign test of x,y,z coordinates of fiber pathway endpoints

% this script tests whether does within-subject one-way anova one DA endpoint coordinates for given fiber groups (if fgs > 3) paired t-tests for x coordinates
% of NAcc and putamen fiber groups, assigns a value of 1, 0, or -1 for each
% subject depending on the t-test, then does a sign test across subjects to
% test if the groups differ in laterality.  Does the same thing for y and z
% coordinates, too. 
% 
% About sign tests (from Meriaux et al., 2006):
% 
% The sign test [7] is designed to test the mean of a symmetric population (or, more generally, the median of an arbitrary population)
% and may be used in place of the one sample t-test when the normality assumption is questionable. The sign statistic is deﬁned as
% the proportion of positive effects in the sample:
% Ts = n+ / n
% Under the null hypothesis H0, positive and negative signs are
% equally likely, implying that n+ follows a binomial law Bn, 1/2
% whatever the input data. 

%% define directories and file names, load files

subjects = {'ak090724','am090121','db061209','er100302','hh100622','ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};
% subjects = {'ak090724'};

baseDir = '/home/kelly/data/DTI';

fiberFiles = {'DA_NAcc_top2.5per_clean.pdb',...
    'DA_Caud_top2.5per_clean.pdb','DA_Putamen_top2.5per_clean.pdb'};

% fiberFiles = {'null_NAcc_scored.pdb','null_Caudate_scored.pdb','null_Putamen_scored.pdb'};
%% get to it

signtest_vals{1} = nan(3,length(subjects));
signtest_vals{2} = nan(3,length(subjects));
signtest_vals{3} = nan(3,length(subjects));


for i = 1:length(subjects) % for each subject
    subjDir = fullfile(baseDir, subjects{i});
    fibersDir = fullfile(subjDir, 'fibers', 'conTrack');
    cd(fibersDir);
    
    for j = 1:length(fiberFiles)                % load fibers
        fg = mtrImportFibers(fiberFiles{j});
        [fg, da_endpts] = getDAEndpoints(fg);   % keep only DA endpoints of the fiber group
        da_endpts = da_endpts';
        da_endpts(:,1) = abs(da_endpts(:,1));    % take the absolute value of the x coord
        meanCoords{j}(i,:) = mean(da_endpts);
        seCoords{j}(i,:) = std(da_endpts);
        roiCoords{j} = da_endpts;
        nFibers(j) = size(roiCoords{j},1);
        clear da_endpts
    end
    
%     % one way ANOVA
     for xyz = 1:3
         coords{xyz} = [roiCoords{1}(:,xyz); roiCoords{2}(:,xyz); roiCoords{3}(:,xyz)];
         coords_group{xyz} = [ones(1,nFibers(1)), ones(1,nFibers(2)).*2, ones(1,nFibers(3)).*3];
     end
     [px, tablex, statsx] = anova1(coords{1}, coords_group{1});
     [py, tabley statsy] = anova1(coords{2}, coords_group{2});
     [pz, tablez, statsz] = anova1(coords{3}, coords_group{3});
%     
    for fg = 1:length(fiberFiles)
        fg2 = fg+1;
        if (fg2>3)
            fg2 = 1;
        end
        % within subject t-tests of NC, CP, and NP endpt coords
        [h(1),p(1)] = ttest2(roiCoords{fg}(:,1),roiCoords{fg2}(:,1));   % x-coords
        [h(2),p(2)] = ttest2(roiCoords{fg}(:,2),roiCoords{fg2}(:,2));   % y-coords
        [h(3),p(3)] = ttest2(roiCoords{fg}(:,3),roiCoords{fg2}(:,3));   % z-coords
        
        % fill in sign test values - 1,0, or -1
        for k = 1:3
            if (h(k) == 0)          % if there's no sig difference
                signtest_vals{fg}(k,i)=0;
            else
                if (meanCoords{fg}(i,k) < meanCoords{fg2}(i,k))    % find out which group is greater
                    signtest_vals{fg}(k,i)=1;
                else
                    signtest_vals{fg}(k,i)=-1;
                end
            end
        end
        
    end % fg
    
end  % subjects

clear h p

% % across subjects sign-tests of NAcc vs putamen coords
for m = 1:3
    [p{m}(1,1), h{m}(1,1)] = signtest(signtest_vals{m}(1,:)); % laterality
    [p{m}(2,1), h{m}(2,1)] = signtest(signtest_vals{m}(2,:)); % anterior-posterior
    [p{m}(3,1), h{m}(3,1)] = signtest(signtest_vals{m}(3,:)); % superior-inferior
end

