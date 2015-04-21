%% parse DA ROI voxels according to their tensor values

clear all
close all

nClusters = 3;
options = statset('Display','final');
saveClusters = 1;
%% get tensor values

cd ~/ShockAwe/data/sa10/dti96trilin

dt = dtiLoadDt6('dt6.mat');

[vec, val] = dtiEig(dt.dt6);

tensors = readFileNifti(dt.files.tensors);
allTensors = squeeze(tensors.data);

%% get ROI coords

cd ../ROIs

load('DA_b0.mat')

% get the dti img coords of the roi
imgCoords = round(mrAnatXformCoords(inv(dt.xformToAcpc), roi.coords));
i = imgCoords(:,1);
j = imgCoords(:,2);
k = imgCoords(:,3);

% now get tensor values for roi voxels
for a = 1:length(imgCoords)
    roiTensors(a,:) = allTensors(i(a),j(a),k(a),:);
    roiDt6(a,:) = dt.dt6(i(a),j(a),k(a),:);
end

clear indx


%% estimate Gaussian mixture model with n components defined by numClusters

gm = gmdistribution.fit(roiTensors,nClusters,'Options',options);
idx = cluster(gm, roiTensors);     % gives a cluster index

%% save cluster voxel coords

if (saveClusters==1)
    
    for c = 1:nClusters
        
        cluster_roi = roi;
        cluster_roi.coords = cluster_roi.coords(idx==c,:);
        cluster_roi.name = ['DA_b0_tensor_clust',num2str(c),'_of_',num2str(nClusters)];
        dtiWriteRoi(cluster_roi,cluster_roi.name);
        roiMatToNifti([cluster_roi.name,'.mat'],'../t1.nii.gz');
    end
    
end

