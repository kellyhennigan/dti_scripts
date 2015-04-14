% resample a fiber group into N nodes for a set of subjects and calculate
% diffusion properties for each node (e.g., md, fa, etc.) and save out a
% .mat file with these measures.

clear all
close all

dataDir = '/Users/Kelly/dti/data';
subjects=getDTISubjects;

% filepaths relative to each subject's directory
t1file = 't1_fs.nii.gz';
dt6file = 'dti96trilin/dt6.mat';

% roi strings; rois will be in subjDir/ROIs directory
seed = 'DA'; % seed roi string 
target = 'nacc'; % target roi strings

LorR = 'L'; 

% define fiber group to load
% method = 'mrtrix';
% fgName = [target LorR '_clip_autoclean.pdb']; % 1st %s string is defined by rois, 2nd is LorR
% fgName = 'naccR_belowAC_autoclean.pdb';

method = 'conTrack';
fgName = ['scoredFG__' target '_' seed '_top2500_' LorR '_autoclean.pdb']; 
% fgName = ['scoredFG__' target '_' seed '_top2500_' LorR '_clip_autoclean.pdb']; 
% fgName = 'scoredFG__nacc_DA_top2500_R_autoclean_R.pdb';


numNodes = 20;

fgMLabels = {'FA','MD','RD','AD'};

% outName = [seed '_' target '_' num2str(numNodes) 'nodes' LorR '_clip.mat'];
outName = [target LorR '.mat'];

%% do it 


fprintf(['\n\nworking on ' target LorR ' fiber group...\n\n']);
i=1

for i = 1:numel(subjects)
    
    fprintf(['\n\nworking on subject ',subjects{i},'\n\n']);
    subjDir = fullfile(dataDir,subjects{i}); cd(subjDir);
    
    % load t1 and dt6 files
    t1 = readFileNifti(t1file);
    dt = dtiLoadDt6(dt6file);
    %     [fa,md] = dtiComputeFA(dt.dt6);
    
    % load ROIs
    load(fullfile('ROIs',[seed '.mat'])); roi1 = roi;
    load(fullfile('ROIs',[target '.mat'])); roi2=roi; clear roi
    
    % load fibers
    fg = mtrImportFibers(fullfile('fibers',method,fgName));
     
   %  get fa and md measures for correlation test    
    [fa, md, rd, ad, cl, SuperFibers{i},fgClipped,~,~,fgResampled]=...
        dtiComputeDiffusionPropertiesAlongFG(fg,dt,roi1,roi2,numNodes,[]);
    
    fgMeasures{1}(i,:) = fa;
    fgMeasures{2}(i,:) = md;
    fgMeasures{3}(i,:) = rd;
    fgMeasures{4}(i,:) = ad;
    
    clear fa md rd ad dt t1 roi1 roi2
 
 
    % compute fiber density    
%     fd =  dtiComputeFiberDensityNoGUI(SuperFiber, dt.xformToAcpc, size(dt.b0),1,1);
%     outSFDName = [subjects{i} '_' seed '_' target '_SuperFiber_fd.nii.gz'];
%     dtiWriteNiftiWrapper(fd, dt.xformToAcpc, [SFOutStr '_fd.nii.gz']);
%     
     
end % subjects

% clear coordinateSpace da dt expPaths fg i roi subject versionNum
% clear allFa allMd allRd allAd indx


% save out fg measures

cd(dataDir); cd fgMeasures; cd(method);
save(outName,'subjects','seed',...
    'target','fgName','numNodes','fgMeasures','fgMLabels','SuperFibers');


fprintf(['\nsaved out file ' outName '\n\n']);