% quick and dirty script to view multiple fiber groups 

% clear all
% close all


fgNames = {'fibers/conTrack/scoredFG__nacc_DA_top2500_R.pdb',...
    'fibers/mrtrix/naccR.tck'}
% fgNames = {'fibers/conTrack/naccR_autoclean.pdb',...
%     'fibers/mrtrix/naccR_autoclean.pdb'}


dataDir = '/Users/Kelly/dti/data';
cd(dataDir);


% subjects = getDTISubjects;
subjects = {'sa23'};

saveFigs = 0;
figDir = '/Users/Kelly/dti/figures/naccR_tract_profiles';

cols = solarizedColors(numel(fgNames));

%% do it



i=1;
for i = 1:numel(subjects)
    
fprintf(['\n\nworking on subject... ' subjects{i}]);
    cd(fullfile(dataDir,subjects{i}))
    
    
    % load ROIs
    da = load('ROIs/DA.mat');
    nacc = load('ROIs/nacc.mat');
    caud = load('ROIs/caudate.mat');
    put = load('ROIs/putamen.mat');
    
    
    % load dt6 struct
    dt = dtiLoadDt6('dti96trilin/dt6.mat');
    b0 = readFileNifti('dti96trilin/bin/b0.nii.gz');
    
  
    % load t1
    t1 = readFileNifti('t1_fs.nii.gz')
    
    
    % load fgs
    for f=1:numel(fgNames)
        fg{f} = fgRead(fgNames{f});
    end
    
    % plot fgs
%     AFQ_RenderFibers(fg{1},'dt',dt);
%     title(gca,subjects{i});
      
    % Then add the slice X = -2 to the 3d rendering.
%     AFQ_AddImageTo3dPlot(t1,[-1, 0, 0]);
 

AFQ_RenderFibers(fg{1},'tubes',0,'color',cols(1,:));
for j=2:numel(fg)
    AFQ_RenderFibers(fg{j},'tubes',0,'color',cols(j,:),'newfig',0);
end

title(gca,subjects{i})




    % save figs?
    if saveFigs
        cd(figDir);
        saveas(gcf,[subjects{i} '.pdf'])
        close all
    end
    
    
end



