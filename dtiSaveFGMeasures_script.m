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


nNodes = 20; % number of nodes for fiber tract

fgMLabels = {'FA','MD','RD','AD'};


% roi strings; rois will be in subjDir/ROIs directory
seed = 'DA'; % seed roi string

% targets = {'caudateL','caudateR',...
%     'naccL','naccR',...
%     'putamenL','putamenR'}; % target roi strings
targets = {'naccL'}; % target roi strings



% define fiber group to load
% method = 'conTrack';
method = 'mrtrix';


% string to identify fiber group files? 
fgNameStr = '_autoclean'; % [targets{j} fgNameStr '.pdb'] should be fgName


% string to include on outfile? 
% outNameStr = fgNameStr;
outNameStr = '';


%% do it


for j=1:numel(targets)
    
    target = targets{j};
    
    fprintf(['\n\nworking on ' target ' fiber group...\n\n']);
    
    
    for i = 1:numel(subjects)
        
        
        fprintf(['\n\nworking on subject ',subjects{i},'\n\n']);
        
        subjDir = fullfile(dataDir,subjects{i});
        cd(subjDir);
        
        
        % load t1 and dt6 files
        t1 = readFileNifti(t1file);
        dt = dtiLoadDt6(dt6file);
        %     [fa,md] = dtiComputeFA(dt.dt6);
        
        
        % load ROIs
        load(fullfile('ROIs',[seed '.mat'])); roi1 = roi;
        load(fullfile('ROIs',[target '.mat'])); roi2=roi; clear roi
        
        
        % load fibers
        fg = mtrImportFibers(fullfile('fibers',method,[target fgNameStr '.pdb']));
        
        
        % reorient to start in DA ROI and clip to DA and target ROIs
        %     (this may be already done but do it again just in case)
        fg = AFQ_ReorientFibers(fg,roi1,roi2);
        fg = dtiClipFiberGroupToROIs(fg,roi1,roi2);
        
        
        %  get fa and md measures for correlation test
        [fa, md, rd, ad, cl, fgvol{i}, TractProfiles(i)] = AFQ_ComputeTractProperties(fg, dt,nNodes, 0);
        
        
        %     old method:
        %  get fa and md measures for correlation test
        %     [fa, md, rd, ad, cl, SuperFibers{i},fgClipped,~,~,fgResampled]=...
        %         dtiComputeDiffusionPropertiesAlongFG(fg,dt,roi1,roi2,nNodes,[]);
        
        
        fgMeasures{1}(i,:) = fa;
        fgMeasures{2}(i,:) = md;
        fgMeasures{3}(i,:) = rd;
        fgMeasures{4}(i,:) = ad;
        
        clear fa md rd ad cl dt t1 roi1 roi2
        
        
    end % subjects
    
    
    
    %% save out fg measures
    
    outName = [target outNameStr]; % name of saved out .mat file
    
    cd(fullfile(dataDir,'fgMeasures',method));
    
    % save(outName,'subjects','seed',...
    %     'target','fgName','nNodes','fgMeasures','fgMLabels','SuperFibers');
    
    save(outName,'subjects','seed',...
        'target','fgNameStr','nNodes','fgMeasures','fgMLabels','fgvol','TractProfiles');
    
    fprintf(['\nsaved out file ' outName '\n\n']);
    
    
end % targets loop