% this script gets tensors for each voxel with each subject's DA ROI mask 
% and saves them out as as a cell array of matrices 


clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;


LR = ['L','R']; % loop through left and right sides separately


outDir = fullfile('cluster_data','tensors');
outName = 'tensor_values_DA';



%% get tensor values

s=1;
for s=1:numel(subjects)
  
    subj = subjects{s};
    fprintf(['\n\n Working on subject ' subj '...\n\n']);
    
    cd(subjects{s})
    
    t1 = readFileNifti('t1_fs.nii.gz');
    
    cd dti96trilin
    dt = dtiLoadDt6('dt6.mat');
    
    [vec, val] = dtiEig(dt.dt6);
    
    tensorNii = readFileNifti(dt.files.tensors);
    tensors = squeeze(tensorNii.data);
    tensors = reshape(tensors,prod(tensorNii.dim(1:3)),[]);
    
    %% get ROI coords
    
    cd ../ROIs
    
    for lr = 1:2
        
        load(['DA_' LR(lr) '.mat'])
        
        % get the dti img coords of the roi
        imgCoords = round(mrAnatXformCoords(inv(dt.xformToAcpc), roi.coords));
        idx = sub2ind(size(tensorNii.data),imgCoords(:,1),imgCoords(:,2),imgCoords(:,3));
       
        roiTensors = tensors(idx,:);
 
        subj_dataLR{s,lr} = roiTensors; 
        
        fprintf(' done.\n\n');
  
        
    end % lr
    
      cd(p.data);
  
end % subjects


%% save out subj_endpts cell array

subj_data = subj_dataLR(:,1); % left 
save(fullfile(outDir,[outName '_L']),'subj_data');

subj_data = subj_dataLR(:,2); % right
save(fullfile(outDir,[outName '_R']),'subj_data');


%% save cluster voxel coords
        
%         if (saveClusters==1)
%             
%             for c = 1:nClusters
%                 
%                 cluster_roi = roi;
%                 cluster_roi.coords = cluster_roi.coords(idx==c,:);
%                 cluster_roi.name = ['DA_' LR(lr) '_b0_tensor_clust',num2str(c),'_of_',num2str(nClusters)];
%                 dtiWriteRoi(cluster_roi,cluster_roi.name);
%                 roiMatToNifti(cluster_roi,t1,1);
%             end
%             
%         end
%         
%     end % L or R
%     
% end
