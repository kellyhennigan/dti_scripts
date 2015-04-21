% dtiSaveFGgs

% computes super fiber for given fiber groups for given subjects and saves
% out the results in a mat struct

% sa14 has no right fibers for caudate and putamen; I took the absolute value
% of the x-coords of the left pathways and used those

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

for i = 5:numel(subjects)
    
    subject = subjects{i};
    expPaths = getSAPaths(subject);
    
    fprintf(['\n\nworking on subject ',subject,'\n\n']);

      rSFgs(i).subject = subject;
      lSFgs(i).subject = subject;
      
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
     rFGs(j)=rSFg;
     
     l_fg = getSubFG(fg, ~rIndx);
     [lSuperFiber, lSFg] = dtiComputeSuperFiberRepresentation(l_fg, [], nNodes(j))
     lSFgs(i).SuperFiber(j)=lSuperFiber;
     
     clear fg rIndx 
      end
end      

cd(expPaths.baseDir); cd SFgs;

save('rSFgs.mat','rSFgs')

save('lSFgs.mat','lSFgs')