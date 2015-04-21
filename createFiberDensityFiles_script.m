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

% method = 'mrtrix';
method = 'conTrack';
targets = {'nacc','caudate','putamen'};

fgFileStr = '_manclean'; % files are named [target fgFileStr '.pdb']


% options
only_da_endpts = 1; % create density maps only using da endpoints?
smooth = 3; % 0 or empty to not smooth, otherwise this defines the smoothing kernel



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
    t1 = readFileNifti('t1_fs.nii.gz');
    
    
    for j=1:numel(targets)
        
        
        % load fiber group
        fg = mtrImportFibers(fullfile('fibers',method,[targets{j} fgFileStr '.pdb']));
            
        
        % define out name for fiber density file
%         outName = fg.name;
        outName = targets{j};

        
        % to use just da endpoints of fibers:
        if only_da_endpts
            fg.fibers = cellfun(@(x) x(:,1), fg.fibers,'UniformOutput',0);
            outName = [outName, '_da_endpts'];
        end
        
        
        % make fiber density maps
        %fdImg = dtiComputeFiberDensityNoGUI(fgs,xform,imSize,normalize,fgNum, endptFlag, fgCountFlag, weightVec, weightBins)
        fd = dtiComputeFiberDensityNoGUI(fg, t1.qto_xyz,size(t1.data));
        
%         % set any voxel w/2 fibers or less equal to zero, then normalize by
%         % max(fd) (note: I do this before normalizing the values to ensure
%         % that I know the raw fiber count (2) I am thresholding by for each
%         % voxel
%         fd(fd<=fc_vox_thresh)=0; 
%         fd=fd./max(fd(:));
        
        
        
        % Smooth the image?
        if smooth
            fd = smooth3(fd, 'gaussian', smooth);
            outName = [outName '_s' num2str(smooth)];
        end
        
        
        % save new fiber density file
        nii=createNewNii(fullfile(fdDir,outName),t1,'fiber density image',fd);
        writeFileNifti(nii);
        
        
    end % targets
    
    
    fprintf(['done with subject ' subjects{i} '.\n\n']);
    
    
end % subjects









