%% get fiber density values and ROI voxel numbers

% 4 outputs:

% - 1) nVox: m x n vector of the # of voxels containing endpoints for each
% fiber group (FG) for each subject

% - nFibers: m x n matrix containing the number of fibers for each group
% for each subject

% nVoxOL: matrix containing the number of voxels containing endpoints for:
%
% 1) 1st FG
% 2) 1st and 2nd FG
% 3) 2nd FG
% 4) 2nd and 3rd FG
% 5) 3rd FG
% 6) 3rd and 1st FG   (etc depending on # of FGs)
% 7) all FGs
%
% for each subject
%
% - fdOL: same as above but for fiber density (defined by # of endpoints in
% a voxel) instead of voxel number

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baseDir = '/Users/Kelly/data/DTI/';

subjects = {'ak090724','am090121','db061209','er100302','hh100622',...
    'ka040923','ns090526','rb080930','rfd100302','sr090327'};
% subjects = {'ak090724'};

FGs = {'DA_NAcc_top2.5per_clean_fd_DAends.nii.gz',...
    'DA_Caud_top2.5per_clean_fd_DAends.nii.gz','DA_Putamen_top2.5per_clean_fd_DAends.nii.gz'};

% FGs = {'scoredFG_null_dist_NAcc_fs_null_DA_top_fd_DAends.nii.gz','scoredFG_null_dist_Caudate_fs_null_DA_top_fd_DAends.nii.gz',...
%     'scoredFG_null_dist_Putamen_fs_null_DA_top_fd_DAends.nii.gz'};

%% get values

for i = 1:length(subjects)
    
    subjDir = fullfile(baseDir, subjects{i});
    cd(subjDir);
%     fdDir = fullfile(subjDir, 'fibers', 'conTrack','fg_densities');
%     cd(fdDir);
    for j = 1:length(FGs)
        fg{j} = readFileNifti(FGs{j});
        % for some reason, a voxel that has 1 endpoint has the
        % value 2.  Get the number of voxels with more than 1 fiber
        % endpoint
        idx{j} = find(fg{j}.data);
        nVox(i,j) = length(idx{j});        % array with num voxels for each fiber group
        nFibers(i,j) = sum(fg{j}.data(idx{j})); % array with number of fibers (*2) for each fiber group
    end
    
    all_fg = fg{1}.data + fg{2}.data + fg{3}.data;
    N_fibers(i,1) = sum(nFibers(i,:)); % total number of fibers *2
    
    %% make an index of which fiber groups overlap where (use 4 for 3 so that
    % all possible combos (i.e. 1-2, 2-3, 1-3, & 1-2-3) have unique values
    
    overlapMap = zeros(size(all_fg));
    overlapMap(idx{1}) = overlapMap(idx{1}) + 1;
    overlapMap(idx{2}) = overlapMap(idx{2}) + 2;
    overlapMap(idx{3}) = overlapMap(idx{3}) + 4;
    
    %% get overlap values
    for k = 1:7
        overlapIdx = find(overlapMap==k);
        nVoxOL(i,k) = length(overlapIdx);
        fdOL(i,k) = sum(all_fg(overlapIdx))./N_fibers(i);    % normalize by total # of fibers / subject
    end
    
    clear subjDir j k fg all_fg idx sum_vals overlapIdx overlapMap
end % subjects

%% summary stats

nVox_mu = mean(nVox);
nVox_se = std(nVox)./(sqrt(length(subjects)));

fd_vox = nFibers./nVox;
fd_vox_mu = mean(fd_vox);
fd_vox_se = std(fd_vox)./(sqrt(length(subjects)));

% test if nacc voxels are greater than putamen (meaning NAcc fibers were
% more distributed in DA ROI)
% [h, p, ci, stats] = ttest(nVox(:,1),nVox(:,3));
[p,table,stats]=anova1(fd_vox);

nVoxOL_mu = mean(nVoxOL);

% 
% for null dist fibers:
% % nVox_mu = nVox;
% % nVoxOL_mu = nVoxOL;


%% make a figure representing degree of overlap



OL(1)=nVoxOL_mu(3);  % 1 & 2 overlap
OL(2)=nVoxOL_mu(5);  % 1 & 3 overlap
OL(3)=nVoxOL_mu(6);  % 2 & 3 overlap
OL(4)=nVoxOL_mu(7);  % 1,2, & 3 overlap

makeOverlapFig(nVox_mu, OL);
