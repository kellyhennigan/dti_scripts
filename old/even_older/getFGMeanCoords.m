%% sign test of x,y,z coordinates of fiber pathway endpoints

% this script does within-subject paired t-tests for x coordinates
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

% fiberFiles = {'scoredFG_null_dist_NAcc_fs_null_DA_top.pdb','scoredFG_null_dist_Caud_fs_null_DA_top.pdb',...
%     'scoredFG_null_dist_Putamen_fs_null_DA_top.pdb'};

%% get to it

signtest_vals = nan(3,length(subjects));

for i = 1:length(subjects) % for each subject
    subjDir = fullfile(baseDir, subjects{i});
    fibersDir = fullfile(subjDir, 'fibers', 'conTrack');
    cd(fibersDir);
    
    for j = 1:length(fiberFiles)                % load fibers
        fg = mtrImportFibers(fiberFiles{j});
        [fg, da_endpts] = getDAEndpoints(fg);   % get DA endpoints
        da_endpts = da_endpts';
        da_endpts(:,1) = abs(da_endpts(:,1));    % take the absolute value of the x coord
        meanCoords{j}(i,:) = mean(da_endpts);
        seCoords{j}(i,:) = std(da_endpts);
        roiCoords{j} = da_endpts;
        clear da_endpts
    end
    
    % within subject t-tests of NAcc vs putamen endpt coords
    [h(1,1),p(1,1)] = ttest2(roiCoords{1}(:,1),roiCoords{3}(:,1));   % x-coords
    [h(2,1),p(2,1)] = ttest2(roiCoords{1}(:,2),roiCoords{3}(:,2));   % y-coords
    [h(3,1),p(3,1)] = ttest2(roiCoords{1}(:,3),roiCoords{3}(:,3));   % z-coords
    clear roiCoords
    
    % fill in sign test values - 1,0, or -1
    for k = 1:3
        if (h(k) == 0)          % if there's no sig difference
            signtest_vals(k,i)=0;
        else
            if (meanCoords{1}(i,k) < meanCoords{3}(i,k))    % if NAcc coord val is > than putamen
                signtest_vals(k,i)=1;
            else
                signtest_vals(k,i)=-1;          % if NAcc coord val is < than putamen
            end
        end
    end
    
end

% across subjects sign testst-tests of NAcc vs putamen coords
[hx, px, ci_x, stats_x] = ttest(meanCoords{1}(:,1),meanCoords{3}(:,1));   % x-coords
[hy, py, ci_y, stats_y ] = ttest(meanCoords{1}(:,2),meanCoords{3}(:,2));  % y-coords
[hz, pz, ci_z, stats_z] = ttest(meanCoords{1}(:,3),meanCoords{3}(:,3));   % z-coords


% plotMeanFGCoords(meanCoords, seCoords);
%

