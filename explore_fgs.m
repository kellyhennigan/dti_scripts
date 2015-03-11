% goal: get DA<-> Nacc tracks without having to manually clean errant
% fibers

dataDir = '/Users/Kelly/dti/data';
subj = 'sa26';
rois = {'nacc','caudate','putamen'};


%% 

cd(fullfile(dataDir,subj,'fibers'))


%% try using Jason's AFQ_removeFiberOutliers()
% software on scored (but not cleaned) fibers tracked using conTrack

cd conTrack

fg = mtrImportFibers('scoredFG__nacc_DA_top2500.pdb');

maxDist=4;
maxLen=4;
numNodes=10;
M='median';
count = 1;
maxIter=5;
show=1;

[fg keep]=AFQ_removeFiberOutliers(fg,maxDist,maxLen,numNodes,M,count,maxIter,show)

% this isn't gettings rid of the wonky pathways


%% what about fibers generated using Mrtrix3,
% using DA as a seed image and nacc as an include ROI?

cd ../mrtrix

for i=1:numel(rois)
    
fg =dtiImportFibersMrtrix([rois{i} '.tck']);
fg.name = [rois{i} '.pdb'];
mtrExportFibers(fg,fg.name);

end

% its clear that at least for the NAcc, there are too few fibers generated;
% for some subjects its 0 fibers (using a max_num of 1,000,000 generated)


%% what about fibers tracked using Mrtrix3 
% only dilating the DA and Striatal ROIs by 2mm, so that the ROIs interface
% with white matter? 




%% try tracking whole brain fibers using mrtrix, then import them into matlab
% and keep only those that intersect DA and Nacc dilated ROIs






