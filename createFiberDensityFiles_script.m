%% Make fiber density maps

% assumes all filberfiles have fibers oriented to start in the DA ROI and
% end in the target ROI

% saves out niftis that contain a count of the number of fibers in each
% voxel

%% define directories and file names, load files

clear all
close all

dataDir = '/Users/Kelly/dti/data';

subjects = getDTISubjects(); 
subjects([2,4,5])=[];


% method = 'mrtrix';
method = 'conTrack';
% targets = {'naccL'};
% targets = {'naccL','naccR','caudateL','caudateR','putamenL','putamenR'};


% string to identify fiber group files? 
% fgFileStr = '_autoclean'; % files are named [target fgFileStr '.pdb']


% string to include on outfile? 
outNameStr = '';

t1File = 't1/t1_fs.nii.gz';

% options
only_da_endpts = 1; % create density maps only using da endpoints?
smooth = 3; % 0 or empty to not smooth, otherwise this defines the smoothing kernel

targets = {'null_caudate','null_nacc','null_putamen'};

fgFiles = {'scoredFG__null_caudate_DA_top2500.pdb',...
    'scoredFG__null_nacc_DA_top2500.pdb',...
    'scoredFG__null_putamen_DA_top2500.pdb'};

LR = ['L','R']
%% get to it

cd(dataDir);

i=1;
for i=1:numel(subjects)
    
    
    fprintf(['\n\n Working on subject ',subjects{i},'...\n\n']);
    
    
    % cd to subject's directory
    cd(fullfile(dataDir,subjects{i}))
    
    
    % define fg_densities directory; create if necessary
    fdDir = fullfile(dataDir,subjects{i}, 'fg_densities',method);
    if (~exist(fdDir, 'dir'))
        mkdir(fdDir)
    end
    
    
    % load dt6.mat and t1 images
    dt = dtiLoadDt6(fullfile('dti96trilin','dt6.mat'));
    t1 = readFileNifti(t1File);
    
       roi1 = roiNiftiToMat('ROIs/DA.nii.gz');
    
    for j=1:numel(targets)
        
        
        % load fiber group
%         fg = fgRead(fullfile('fibers',method,[targets{j} fgFileStr '.pdb']));
        fg = fgRead(fullfile('fibers',method,fgFiles{j}));
        
        load(['ROIs/' targets{j} '.mat']); roi2=roi;
       [fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);
 
        
        [fg1{1},fg1{2}]=splitFgLR(fg);
        % define out name for fiber density file
%         outName = fg.name;
    

for lr=1:2
    
    fg=fg1{lr};
        outName = [targets{j} LR(lr)];

        % to use just da endpoints of fibers:
        if only_da_endpts
            fg.fibers = cellfun(@(x) x(:,1), fg.fibers,'UniformOutput',0);
            outName = [outName, '_da_endpts'];
        end
        
        
        % make fiber density maps
        %fdImg = dtiComputeFiberDensityNoGUI(fgs,xform,imSize,normalize,fgNum, endptFlag, fgCountFlag, weightVec, weightBins)
        fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data));
        
%       
        
        % Smooth the image?
        if smooth
            fd = smooth3(fd, 'gaussian', smooth);
            outName = [outName '_S' num2str(smooth)];
        end
        
        
        % save new fiber density file
        outName = [outName outNameStr];
        nii=createNewNii(t1,fd,fullfile(fdDir,outName),'fiber counts per vox');
        writeFileNifti(nii);
        
        imgCoM = centerofmass(nii.data);
        CoM = mrAnatXformCoords(nii.qto_xyz,imgCoM);
       dlmwrite(fullfile(fdDir,[outName '_CoM']),CoM)
       
end % lr
        
    end % targets
    
    
    fprintf(['done with subject ' subjects{i} '.\n\n']);
    
    
end % subjects










