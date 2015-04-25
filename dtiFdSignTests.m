% test for anatomical specificity within an roi of fiber groups endpoints

%%%%%%%%%%%%%%%%%%%%% this approach :

%     do a one-way ANOVA/t-tests on x,y, and z coordinates
% respectively of fiber groups within each subject;
% assign 1,0, or -1 depending on outcome of each test;
% do a sign test on these values to test for sig differences along the
%  med-lat (x-coord), ant-posterior (y-coord) and sup-inferior axes across
%  subjects

% use this script for approach 1


%% files, subjects, etc.

clear all
close all

dataDir = '/Users/Kelly/dti/data';

subjects = getDTISubjects;


method = 'conTrack';

% rois = {'caudate','nacc','putamen'};
rois = {'caudateL','caudateR'};

% string to identify fiber files
fStr = '_da_endpts_s3'; 


nNodes = [20 20 20];


% index for two fiber groups to compare/test (should correspond to order in
% FG_fnames cell array)

% 1=caudate  2=nacc  3=putamen
fgA = 1; 
fgB = 2; 


% [sf2, fgRes2] = dtiComputeSuperFiberRepresentation(fgB, [], 20);


%% do it 



for s=1:numel(subjects)
%    
    subject=subjects{s};
%  
%     
    fprintf(['\n\n Working on subject ' subject '...']);
%     
    
    % load subject's fiber files
    fds=cellfun(@(x) readFileNifti(fullfile(dataDir,subject,'fg_densities',method,[x fStr '.nii.gz'])), rois);
    imgs={fds(:).data};
    
%    get fiber density center of mass
    CoM = cell2mat(cellfun(@(x) centerofmass(x), imgs,'UniformOutput',0))';
%     all_CoM(s,: = 
    
    
% get img values, coordinates w/non-zero values, and make a group idx
D = [];  coords = [];  gi = [];
    for r=1:numel(rois)
        
        idx=find(imgs{r});    
        
        D=[D;imgs{r}(idx)];
        
        [i j k]=ind2sub(size(imgs{r}),idx);
        
        coords = [coords; [i j k]];
        
        gi = [gi; r.* ones(length(idx),1)]; % group index 
        
    end
    
    acpcCoords = mrAnatXformCoords(fds(1).qto_xyz,coords);
    acpcCoords(:,1) = abs(acpcCoords(:,1));  % get abs() of x-coords
    
    
    %% do anova/ttests
    
    [px, tablex, statsx] = anova1(acpcCoords(:,1), gi,'off')
    [py, tabley, statsy] = anova1(acpcCoords(:,2), gi,'off')
    [pz, tablez, statsz] = anova1(acpcCoords(:,3), gi,'off')
  
        
    % t-tests of NAcc vs putamen FG da endpt coords
    
    [h(1),p(1)] = ttest2(acpcCoords(gi==fgA,1),acpcCoords(gi==fgB,1));   % x-coords
    [h(2),p(2)] = ttest2(acpcCoords(gi==fgA,2),acpcCoords(gi==fgB,2));   % y-coords
    [h(3),p(3)] = ttest2(acpcCoords(gi==fgA,3),acpcCoords(gi==fgB,3));   % z-coords
    
   
    %% fill in sign test values - 1,0, or -1 for each subject
    
    for k = 1:3     % x,y, & z-coordinate t-tests
        
        if (h(k) == 0)          % if there's no sig difference
            signtest_vals(k,s)=0;
        else
            if mean(acpcCoords(gi==fgA,k)) > mean(acpcCoords(gi==fgB,k))    % find out which group is greater
                signtest_vals(k,s)=1;
            else
                signtest_vals(k,s)=-1;
            end
        end
    end
    
    clear h p k px py pz
    
end  % subjects


%% across subjects sign-tests results

fprintf('\n\n x-coordinates sign test\n\n'); % laterality
[px, hx] = signtest(signtest_vals(1,:))

fprintf('\n\n y-coordinates sign test\n\n');  % anterior-posterior
[py, hy] = signtest(signtest_vals(2,:))

fprintf('\n\n z-coordinates sign test\n\n'); % superior-inferior
[pz, hz] = signtest(signtest_vals(3,:))


