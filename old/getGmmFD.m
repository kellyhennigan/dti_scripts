%% get fiber density values of gmm fiber groups and 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baseDir = '/home/kelly/data/DTI/';

subjects = {'ak090724','am090121','db061209','er100302','hh100622',...
    'ka040923','ns090526','rb080930','rfd100302','sr090327'};
% subjects = {'ak090724'};

FGs = {'gmm_1_of_2_clusters_fd.nii.gz','gmm_2_of_2_clusters_fd.nii.gz'};
FGs2 = {'gmm_2_of_2_clusters_fd.nii.gz','gmm_1_of_2_clusters_fd.nii.gz'};
% FGs = {'scoredFG_null_dist_NAcc_fs_null_DA_top_fd_DAends.nii.gz','scoredFG_null_dist_Caudate_fs_null_DA_top_fd_DAends.nii.gz',...
%     'scoredFG_null_dist_Putamen_fs_null_DA_top_fd_DAends.nii.gz'};

vtFirstSubs = [1 3 4 9 10]; % subjects with ventral tier as first group

%% get values

for i = 1:length(subjects)
    
    subjDir = fullfile(baseDir, subjects{i});
    cd(subjDir);
     fdDir = fullfile(subjDir, 'fibers', 'conTrack','fg_densities');
     cd(fdDir);
    for j = 1:length(FGs)
         if (ismember(i, vtFirstSubs))
          fg = readFileNifti(FGs2{j});
        else
        fg = readFileNifti(FGs{j});
         end
        idx = find(fg.data);
        % for some reason, a voxel that has 1 endpoint has the value 2 and so on.  
        nFibers = sum(fg.data(idx))./2;
        nVox = length(idx);       
        fibersPerVox(i,j) = nFibers./nVox;
        clear fg idx nFibers nVox 
    end % FGs
    
end % subjects

meanFDs = mean(fibersPerVox);
dorsalFD = meanFDs(1)
ventralFD = meanFDs(2)
[h,p]=ttest(fibersPerVox(:,1), fibersPerVox(:,2))
seFDs = std(fibersPerVox)./(sqrt(length(subjects)));
