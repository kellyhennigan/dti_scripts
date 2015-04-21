%% of the voxels from which a pathway group came from, 
% get the average pathway count per voxel for fiber groups
% then conduct anova, t-test, or nothing across subjects 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baseDir = '/home/kelly/data/DTI/';

subjects = {'ak090724','am090121','db061209','er100302','hh100622',...
    'ka040923','ns090526','rb080930','rfd100302','sr090327'};
% subjects = {'ak090724'};

%% for null fiber groups

% FGs = {'null_NAcc_scored_fd.nii.gz','null_Caudate_scored_fd.nii.gz',...
%     'null_Putamen_scored_fd.nii.gz'};

%% for NAcc, Caudate, and Putamen

% FGs = {'DA_NAcc_top2.5per_clean_fd_DAends.nii.gz',...
%     'DA_Caud_top2.5per_clean_fd_DAends.nii.gz','DA_Putamen_top2.5per_clean_fd_DAends.nii.gz'}

%% for gmm fiber groups

FGs = {'gmm_1_of_2_clusters_fd.nii.gz','gmm_2_of_2_clusters_fd.nii.gz'};
FGs2 = {'gmm_2_of_2_clusters_fd.nii.gz','gmm_1_of_2_clusters_fd.nii.gz'};
vtFirstSubs = [1 3 4 9 10]; % subjects with ventral tier as first group

%% get values

for i = 1:length(subjects)
    
    subjDir = fullfile(baseDir, subjects{i});
    cd(subjDir);
    fdDir = fullfile(subjDir, 'fibers', 'conTrack','fg_densities');
    cd(fdDir);
    for j = 1:length(FGs)
        
% for gmm fiber groups
         if (ismember(i, vtFirstSubs))
          fg = readFileNifti(FGs2{j});
        else
        fg = readFileNifti(FGs{j});
         end

% %% for NCP and null groups
%  fg = readFileNifti(FGs{j});
 
 %%
        idx = find(fg.data);
        % for some reason, a voxel that has 1 endpoint has the value 2 and so on.  
        nFibers = sum(fg.data(idx))./2; % total # of fibers
        nVox = length(idx);             % total number of voxels from which the pathways originate
        fibersPerVox(i,j) = nFibers./nVox;  
        clear fg idx nFibers nVox 
    end % FGs
    
end % subjects

meanFDs = mean(fibersPerVox)
seFDs = std(fibersPerVox)./(sqrt(length(subjects)));
if (length(FGs)>2)
    p = anova1(fibersPerVox)
elseif (length(FGs)==2)
    [h,p,ci,stats]=ttest(fibersPerVox(:,1), fibersPerVox(:,2))
end
