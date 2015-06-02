%% parse DA ROI voxels according to their tensor values

clear all
close all

nClusters = 3;
options = statset('Display','final');
saveClusters = 0;

LR = ['L','R'];

p=getDTIPaths; cd(p.data);

subjects = getDTISubjects;



%% get tensor values

for s=1:numel(subjects)
    
    cd(p.data);
    
    cd(subjects{s})
    
    t1 = readFileNifti('t1_fs.nii.gz');
    
    cd dti96trilin
    dt = dtiLoadDt6('dt6.mat');
    
    [vec, val] = dtiEig(dt.dt6);
    
    tensors = readFileNifti(dt.files.tensors);
    allTensors = squeeze(tensors.data);
    
    %% get ROI coords
    
    cd ../ROIs
    
    for lr = 1:2
        
        load(['DA_' LR(lr) '.mat'])
        
        % get the dti img coords of the roi
        imgCoords = round(mrAnatXformCoords(inv(dt.xformToAcpc), roi.coords));
        i = imgCoords(:,1);
        j = imgCoords(:,2);
        k = imgCoords(:,3);
        
        
        % now get tensor values for roi voxels
        roiTensors = []; roiDt6=[]; 
        for a = 1:length(imgCoords)
            roiTensors(a,:) = allTensors(i(a),j(a),k(a),:);
            roiDt6(a,:) = dt.dt6(i(a),j(a),k(a),:);
        end
        
       
        
        
        %% estimate Gaussian mixture model with n components defined by numClusters
        
        gm = gmdistribution.fit(roiTensors,nClusters,'Options',options);
        idx = cluster(gm, roiTensors);     % gives a cluster index
        
        idx
        
        %% save cluster voxel coords
        
        if (saveClusters==1)
            
            for c = 1:nClusters
                
                cluster_roi = roi;
                cluster_roi.coords = cluster_roi.coords(idx==c,:);
                cluster_roi.name = ['DA_' LR(lr) '_b0_tensor_clust',num2str(c),'_of_',num2str(nClusters)];
                dtiWriteRoi(cluster_roi,cluster_roi.name);
                roiMatToNifti(cluster_roi,t1,1);
            end
            
        end
        
    end % L or R
    
end
