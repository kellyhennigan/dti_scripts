% test for anatomical specificity within an roi of fiber groups endpoints

%%%%%%%%%%%%%%%%%%%%% approach 1:

%     do a one-way ANOVA/t-tests on x,y, and z coordinates
% respectively of fiber groups within each subject;
% assign 1,0, or -1 depending on outcome of each test;
% do a sign test on these values to test for sig differences along the
%  med-lat (x-coord), ant-posterior (y-coord) and sup-inferior axes across
%  subjects

% use this script for approach 1

%%%%%%%%%%%%%%%%%%%%% approach 2:

%     use dtiComputeDiffusionPropertiesAlongFG,
%         dtiFiberGroupPropertyWeightedAverage, &
%         dtiComputeSuperFiberRepresentation
%     to compute mean and var/covar matrices along fiber group pathway nodes

% use (what script??) for approach 2

%% files, subjects, etc.

clear all
close all

% rois = {'null_caudate','null_nacc','null_putamen'};
% 
% FG_fnames = {'scoredFG__null_caudate_DA_top2500.pdb',...
%     'scoredFG__null_nacc_DA_top2500.pdb','scoredFG__null_putamen_DA_top2500.pdb'};

rois = {'caudate','nacc','putamen'};

FG_fnames = {'scoredFG__caudate_DA_top2500_clean.pdb',...
    'scoredFG__nacc_DA_top2500_clean.pdb','scoredFG__putamen_DA_top2500_clean.pdb'};

% FG_fnames = {'scoredFG__caudate_DA_top2500.pdb',...
%     'scoredFG__nacc_DA_top2500.pdb','scoredFG__putamen_DA_top2500.pdb'};

nNodes = [32 16 32];

subjects = getSASubjects('dti');

% index for two fiber groups to compare/test (should correspond to order in
% FG_fnames cell array)

% 1=caudate  2=nacc  3=putamen
fg1 = 1; 
fg2 = 3; 


%% approach 1

FGs = struct();

for i = 1:numel(subjects)
    
    subject = subjects{i};
    expPaths = getSAPaths(subject);
    
    fprintf(['\n\nworking on subject ',subject,'\n\n']);
    
    cd(expPaths.fibers); cd conTrack;
    
    xCoords = [];
    yCoords = [];
    zCoords = [];
    group = {};
    groupIndx = [];
    
    for j = 1:length(FG_fnames)                % load fibers
        %         j=1;
        fg = mtrImportFibers(FG_fnames{j});
        [fg, da_endpts] = getDAEndpoints(fg);   % keep only DA endpoints of the fiber group
        da_endpts = da_endpts';
        da_endpts(:,1) = abs(da_endpts(:,1));    % take the absolute value of the x coord
        FGs(j).name = fg.name;
        FGs(j).meanCoords(i,:) = mean(da_endpts);
        FGs(j).sdCoords(i,:) = std(da_endpts);
        xCoords = [xCoords; da_endpts(:,1)];    % one column vector of x-coordinates (same for y & z)
        yCoords = [yCoords; da_endpts(:,2)];    
        zCoords = [zCoords; da_endpts(:,3)];
        group = [group, repmat(rois(j),1,length(da_endpts))]; % fiber group label
        groupIndx = [groupIndx,ones(1,length(da_endpts)).*j];
    end
    
    %% one-way anovas
    
    [px, tablex, statsx] = anova1(xCoords, group,'off');
    [py, tabley, statsy] = anova1(yCoords, group,'off');
    [pz, tablez, statsz] = anova1(zCoords, group,'off');
    
    
    %%  t-tests of NAcc vs putamen FG da endpt coords
    
    [h(1),p(1)] = ttest2(xCoords(groupIndx==fg1),xCoords(groupIndx==fg2));   % x-coords
    [h(2),p(2)] = ttest2(yCoords(groupIndx==fg1),yCoords(groupIndx==fg2));   % y-coords
    [h(3),p(3)] = ttest2(zCoords(groupIndx==fg1),zCoords(groupIndx==fg2));   % z-coords
    
    %% fill in sign test values - 1,0, or -1 for each subject
    
    for k = 1:3     % x,y, & z-coordinate t-tests
        
        if (h(k) == 0)          % if there's no sig difference
            signtest_vals(k,i)=0;
        else
            if (FGs(2).meanCoords(i,k) < FGs(3).meanCoords(i,k))    % find out which group is greater
                signtest_vals(k,i)=1;
            else
                signtest_vals(k,i)=-1;
            end
        end
    end
    
    clear h p k px py pz
    
end  % subjects


%% across subjects sign-tests of NAcc vs putamen coords

fprintf('\n\n x-coordinates sign test\n\n'); % laterality
[px, hx] = signtest(signtest_vals(1,:))

fprintf('\n\n y-coordinates sign test\n\n');  % anterior-posterior
[py, hy] = signtest(signtest_vals(2,:))

fprintf('\n\n z-coordinates sign test\n\n'); % superior-inferior
[pz, hz] = signtest(signtest_vals(3,:))


