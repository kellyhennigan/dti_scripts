% dtiCompareFGEndpts

% test for anatomical specificity within an roi of fiber groups endpoints

%%%%%%%%%%%%%%%%% approach 1:

%     do a one-way ANOVA/t-tests on x,y, and z coordinates
% respectively of fiber groups within each subject;
% assign 1,0, or -1 depending on outcome of each test;
% do a sign test on these values to test for sig differences along the
%  med-lat (x-coord), ant-posterior (y-coord) and sup-inferior axes across
%  subjects

% use dtiFGSignTests for approach #1


%%%%%%%%%%%%%%%%% approach 2:

%     use dtiComputeDiffusionPropertiesAlongFG,
%         dtiFiberGroupPropertyWeightedAverage, &
%         dtiComputeSuperFiberRepresentation
%     to compute mean and var/covar matrices along fiber group pathway nodes

% this script is for approach #2

%% files, subjects, etc.

clear all
close all

rois = {'caudate','nacc','putamen'};

FG_fnames = {'scoredFG__caudate_DA_top2500_clean.pdb',...
    'scoredFG__nacc_DA_top2500_clean.pdb','scoredFG__putamen_DA_top2500_clean.pdb'};

nNodes = [32 16 32];

subjects = getSASubjects('dti');

% index for two fiber groups to compare/test (should correspond to order in
% FG_fnames cell array)

fg1 = 2; % nacc
fg2 = 3; % putamen


%% approach 1

rSFgs = struct();
lSFgs = struct();

for i = 1:numel(subjects)
    
    subject = subjects{i};
    expPaths = getSAPaths(subject);
    
    fprintf(['\n\nworking on subject ',subject,'\n\n']);

      rSFgs.subject = subject;
      lSFgs.subject = subject;
      
    cd(expPaths.fibers); cd conTrack;

      for j = 1:length(FG_fnames)                % load fibers
  
    fg = mtrImportFibers(FG_fnames{j});

      % separate into left and right fiber groups
     for c = 1:length(fg.fibers)
        rIndx(c) = fg.fibers{c}(1,1) >= 0;
     end
     r_fg = getSubFG(fg, rIndx);
     [rSuperFiber, rSFg] = dtiComputeSuperFiberRepresentation(r_fg, [], nNodes(j))
     rSFgs(i).SuperFiber(j)=rSuperFiber;
     
     l_fg = getSubFG(fg, ~rIndx);
     [lSuperFiber, lSFg] = dtiComputeSuperFiberRepresentation(l_fg, [], nNodes(j))
     lSFgs(i).SuperFiber(j)=lSuperFiber;
     
     clear fg rIndx 
      end
end      

