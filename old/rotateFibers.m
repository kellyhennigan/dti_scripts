%%%  Rotate t1 images and fiber groups to better visualize dorsal/ventral

% rotate acpc-aligned coordinates counter-clockwise around origin of
% anterior commissure

degrees_rot = 30; % rotate this many degrees
%% Define base directory, subject folders, files to rotate

% base dir (one above subject directories) & fibers dir
baseDir = '/home/kelly/data/DTI';

% subject directories
% subjects = {'am090121','db061209','er100302','hh100622',...
% 'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};
subjects = {'ak090724'};

% fiber groups to rotate (located in subj folder/fibers/conTrack
fgIn_names = {'DA_Putamen_top2.5per_clean.pdb', 'DA_NAcc_top2.5per_clean.pdb'}; 

%% 

% define a suffix for filenames of all rotated data files
f_suffix = strcat('_r', num2str(degrees_rot),'_CCW');

% define the rotation matrix
theta = deg2rad(degrees_rot);
rot_mat = [ 1 0 0 0; 0 cos(theta) -sin(theta) 0; 0 sin(theta) cos(theta) 0; 0 0 0 1];

cd(baseDir)

for i = 1:length(subjects)          % subject loop
    rotDir = fullfile(baseDir, subjects{i},'rotated_fibers');
    % make a new directory for rotated fibers
    if ~exist(rotDir, 'dir')
        mkdir(rotDir);
    end
    t1In = fullfile(baseDir, subjects{i},'t1.nii.gz'); % load subject's t1 and rotate
    t1 = readFileNifti(t1In);
    % do the rotation: how?? rotated_t1 = t1In....
    rotated_t1.fname = strcat(rotDir,'/t1_', f_suffix, '.nii.gz');
    writeFileNifti(rotated_t1);
    % load fiber groups and rotate
    fiberDir = fullfile(baseDir, subjects{i},'fibers/conTrack');
    for j = 1:length(fgIn_names)
        fibersInFile = fullfile(fiberDir, fgIn_names{j});
        fg = mtrImportFibers(fibersInFile);
        fg_rot = fg;    % borrow the structure of the fibers file for rotated fibers file
        for k = 1:length(fg.fibers)
            nCols = length(fg.fibers{k});
            lastCol = [0 0 0 1]';
            fiberMat = [fg.fibers{k}; zeros(1,nCols)];
            fiberMat = [fiberMat lastCol];
            rotated_fibers = rot_mat * fiberMat;
            fg_rot.fibers{k} = rotated_fibers(1:3, 1:nCols);
        end
        fg_rot.name = strcat(fg.name, f_suffix,'.pdb');
        fibersOutFile = fullfile(rotDir, fg_rot.name);
        mtrExportFibers(fg_rot, fibersOutFile);
        clear fg fiberMat
    end
   
end