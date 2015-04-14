% goal: get DA<-> Nacc tracks without having to manually clean errant
% fibers

clear all
close all

subjects=getDTISubjects;
dataDir = '/Users/Kelly/dti/data';
rois = {'nacc','caudate','putamen'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% try using Jason's AFQ_removeFiberOutliers() on contrack and mrtrix fibers


% method = 'conTrack';
% fileStr = 'scoredFG__%s_DA_top2500_%s.pdb';
method = 'mrtrix';
% fileStr = '%s_iFOD2_%s.pdb';
% LR = {'L','R'}; % left or right fiber group

fileStr = 'wb_%s.pdb';


maxIter = 3;  % 5 iterations for conTrack, 2 for mrtrix
maxDist=4;
maxLen=4;
numNodes=16;
M='median';
count = 1;
show = 1;

j=1; i=1; f=1;


for j=1:numel(rois)  % nacc, caudate, putamen
    
    roi = rois{j};
    
    fprintf('\n\n working on %s fibers for roi %s...\n',method,roi);
    
    % define cell arrays to keep track of the # of fibers
    nFibersLR{j} = zeros(numel(subjects),2); % n left and right fibers
    nFibersLR_clean{j} = zeros(numel(subjects),2);   % n clean left and right fibers
    
    for i=1:numel(subjects)
        
        fprintf(['\n\nworking on subject ' subjects{i} '...\n\n'])
        cd(fullfile(dataDir,subjects{i},'fibers',method))
            
            FG = mtrImportFibers(sprintf(fileStr,roi));
             [fg{1},fg{2},fgCross]=splitFgLR(FG);
             
            nFibersLR{j}(i,f)=numel(fg.fibers); % keep track of the # of L and R fibers
            
            [~, keep]=AFQ_removeFiberOutliers(fg,maxDist,maxLen,numNodes,M,count,maxIter,show);     % remove outlier fibers
            
            cleanfg = getSubFG(fg,find(keep),[fg.name '_autoclean']); %
            nFibersLR_clean{j}(i,f)=numel(cleanfg.fibers);  % keep track of the # of L and R fibers
            
            mtrExportFibers(cleanfg,cleanfg.name);  % save out cleaned fibers
            
            
            % to plot two fiber groups on the same plot:
            %             AFQ_RenderFibers(fgL,'numfibers',400,'color',[0 0 1]);
            %             AFQ_RenderFibers(fgR,'numfibers',400,'color',[0 1 0],'newfig',false)
            %
        end
        fprintf('done.')
    end
    
end

cd(dataDir);
save(['fg_' method '_autoclean.mat'],'rois','subjects','nFibersLR',...
    'nFibersLR_clean','maxIter','maxDist','maxLen','numNodes','M');





%% what about mrtrix fibers?

% fiber orientation distribution estimated using a max of 8 harmonics
% ('CSD8.mif' file)

% check fibers tracked using the DA ROI as a seed image and NAcc ROI as an
% "include" ROI (ie ROI must be traversed)

% compare fibers using the following tracking algorithms:
% 1) SD_Stream &
% 2) iFOD2

roi = rois{1};

for i=1:numel(subjects)
    cd(fullfile(dataDir,subjects{i},'fibers','mrtrix'));
    fg = dtiImportFibersMrtrix([roi '_SD_Stream.tck']);
    nFs(i,1) = length(fg.fibers);
    fg = dtiImportFibersMrtrix([roi '_iFOD2.tck']);
    nFs(i,2) = length(fg.fibers);
end

% its clear that iFOD2 produced more fibers for the nacc.


%% now check out fibers using dilated ROIs
%
% for i=1:numel(subjects)
%     cd(fullfile(dataDir,subjects{i},'fibers','mrtrix'));
%     fg = dtiImportFibersMrtrix('nacc_dilated_2_iFOD2.tck');
%     nNs(i,1) = length(fg.fibers);
% end

%% to convert all .tck fiber files to .pdb format:

for i=1:numel(subjects)
    
    
    cd(fullfile(dataDir,subjects{i},'fibers','mrtrix'));
    
    for j=1:numel(rois)
        
        fg =dtiImportFibersMrtrix([rois{j} '_SD_Stream.tck']);
        fg.name = [rois{j} '_SD_Stream.pdb'];
        mtrExportFibers(fg,fg.name);
        
        fg =dtiImportFibersMrtrix([rois{j} '_iFOD2.tck']);
        fg.name = [rois{j} '_iFOD2.pdb'];
        mtrExportFibers(fg,fg.name);
        
        
    end
end

% its clear that at least for the NAcc, there are too few fibers generated;
% for some subjects its 0 fibers (using a max_num of 1,000,000 generated)


%% what about fibers tracked using Mrtrix3
% only dilating the DA and Striatal ROIs by 2mm, so that the ROIs interface
% with white matter?

% cortex rois
% rois = {'amygdala','hippocampus',...
%     'caudalanteriorcingulate','caudalmiddlefrontal',...
%     'frontalpole',...
%     'insula','lateralorbitofrontal','medialorbitofrontal',...
%     'paracentral','parsopercularis',...
%     'parsorbitalis','parstriangularis',...
%     'precentral','rostralanteriorcingulate',...
%     'rostralmiddlefrontal','superiorfrontal'};

rois = {'amygdala','hippocampus','frontal_cortex'};

% first, get all cortex roi FGs
i=1;
for i=1:24
    subj = subjects{i};
    cd(dataDir); cd(subj); cd ROIs
    
    % get rois coords
    da=load('DA.mat');
    for j=1:numel(rois)
        roiMat{j}=load([rois{j} '.mat']);
    end
    
    cd ../fibers/mrtrix;
    
    wb=dtiImportFibersMrtrix('wb.tck');
    
    % get just DA fibers 
    fg= dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, 2, da.roi, wb);
    fprintf(['\nnumber of fibers intersecting DA ROI: ' num2str(numel(fg.fibers)) '\n']);
    
    % now get DA-ROI fibers
    for j=1:numel(rois)
        [fg2,c,keep,keepID]= dtiIntersectFibersWithRoi([], {'and' 'endpoint'}, 2, roiMat{j}.roi, fg);
        fprintf(['\nnumber of DA fibers intersecting roi ' rois{j} ': ' num2str(numel(fg2.fibers)) '\n\n']);
        fg2.name = ['wb_' rois{j}];
        mtrExportFibers(fg2,fg2.name);
    end
  
    
end
   


%% try tracking whole brain fibers using mrtrix, then import them into matlab
% and keep only those that intersect DA and Nacc dilated ROIs

% [fgOut,contentiousFibers, keep, keepID] = dtiIntersectFibersWithRoi(...
% handles, options, minDist, roi, fg)








%% save out R and L fiber groups


for j=1:numel(rois)  % nacc, caudate, putamen
    roi = rois{j};
    for m=1:2  % conTrack or mrtrix
        fprintf('\n\n saving out R and L %s fibers for roi %s...\n',method{m},roi);
        for i=1:numel(subjects)
            fprintf(['\n\nworking on subject ' subjects{i} '...'])
            cd(fullfile(dataDir,subjects{i},'fibers',method{m})); % cd to fiber dir
            FG = mtrImportFibers(sprintf(fileStrs{m},roi));
            % first, split fibers into left and right groups
            [fg{1},fg{2},fgCross]=splitFgLR(FG);
            for f=1:2   % left and right fiber groups
                mtrExportFibers(fg{f},fg{f}.name);  % save out L and R fiber groups
                fprintf('done.')
            end
        end
    end
end




