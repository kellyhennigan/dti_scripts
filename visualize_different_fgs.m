% view fgs

clear all
close all


fgNames = {'fibers/conTrack/scoredFG__nacc_DA_top2500_R_autoclean.pdb',...
    'fibers/mrtrix/naccR_clip_autoclean.pdb',...
    'fibers/mrtrix/naccR_iFOD1_autoclean.pdb'};

dataDir = '/Users/Kelly/dti/data';
cd(dataDir);


subjects = getDTISubjects;


saveFigs = 0;
figDir = '/Users/Kelly/dti/figures/naccR_tract_profiles';


%%



i=1;
for i = 1:24
    
i=i+1;
fprintf(['\n\nworking on subject... ' subjects{i}]);
    cd(fullfile(dataDir,subjects{i}))
    
    
    % load ROIs
%     da = load('ROIs/DA.mat');
    % nacc = load('ROIs/nacc.mat');
    % caud = load('ROIs/caudate.mat');
    % put = load('ROIs/putamen.mat');
    
    
    % load dt6 struct
%     dt = dtiLoadDt6('dti96trilin/dt6.mat');
    % b0 = readFileNifti('dti96trilin/bin/b0.nii.gz');
    
  
    % load t1
%     t1 = readFileNifti('t1_fs.nii.gz')
    
    
    % load fgs
    for f=1:numel(fgNames)
        fg{f} = mtrImportFibers(fgNames{f});
    end
    
    % plot fgs
%     AFQ_RenderFibers(fg{1},'dt',dt);
%     title(gca,subjects{i});
    
    
    % Then add the slice X = -2 to the 3d rendering.
%     AFQ_AddImageTo3dPlot(t1,[-2, 0, 0]);
    
  AFQ_RenderFibers(fg{1},'tubes',0,'color',[0 0 1]);
AFQ_RenderFibers(fg{2},'tubes',0,'color',[1 0 0],'newfig',0);
AFQ_RenderFibers(fg{3},'tubes',0,'color',[.5 .5 0],'newfig',0);
title(gca,subjects{i})

    % save figs?
    if saveFigs
        cd(figDir);
        saveas(gcf,[subjects{i} '.pdf'])
        close all
    end
    
    
end



