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

dataDir = '/Users/Kelly/dti/data';

subjects = getDTISubjects;


method = 'conTrack';

rois = {'caudate','nacc','putamen'};

% string to identify fiber files
fStr = '_da_endpts_s3'; 


nNodes = [20 20 20];


% index for two fiber groups to compare/test (should correspond to order in
% FG_fnames cell array)

% 1=caudate  2=nacc  3=putamen
fg1 = 2; 
fg2 = 3; 


% [sf2, fgRes2] = dtiComputeSuperFiberRepresentation(fg2, [], 20);


%% do it 



s=1
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
    CoM = cellfun(@(x) centerofmass(x), imgs,'UniformOutput',0);
    
    
% get img values, coordinates w/non-zero values, and make a group idx
D = [];  coords = [];  g_idx = [];
    for r=1:numel(rois)
        
        idx=find(fds{r}.data);    
        
        D=[D;fds{r}.data(idx)];
        
        [i j k]=ind2sub(size(fds{r}.data),idx);
        
        coords = [coords; [i j k]];
        
        g_idx = [g_idx;ones(length(idx),1).*r]; % group index 
        
    end
    
    acpcCoords = mrAnatXformCoords(fds{r}.qto_xyz,coords);
    acpcCoords(:,1) = abs(acpcCoords(:,1));
    
    
    %% do anova/ttests
    
    [px, tablex, statsx] = anova1(acpcCoords(:,1), g_idx,'off')
    [py, tabley, statsy] = anova1(acpcCoords(:,2), g_idx,'off')
    [pz, tablez, statsz] = anova1(acpcCoords(:,3), g_idx,'off')
  
        
    % t-tests of NAcc vs putamen FG da endpt coords
    
    [h(1),p(1)] = ttest2(acpcCoords(g_idx==fg1,1),acpcCoords(g_idx==fg2),1);   % x-coords
    [h(2),p(2)] = ttest2(acpcCoords(g_idx==fg1,2),acpcCoords(g_idx==fg2),2);   % y-coords
    [h(3),p(3)] = ttest2(acpcCoords(g_idx==fg1,3),acpcCoords(g_idx==fg2),3);   % z-coords
    
   
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


