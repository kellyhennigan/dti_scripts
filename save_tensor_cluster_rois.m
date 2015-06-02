% plot clustered data

% clustering analysis on dti data. use this script and/or
% fg_cluster_cross_script to determine the best # of clusters to use.



%% define directories and file names

clear all
close all

rng(1); % For reproducibility

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);

subjects = getDTISubjects;

LR = ['L','R']; % left or right
% LR = 'L';

% data_type = 'fg_endpts/mrtrix';  % 'fg_endpts/mrtrix', 'fg_endpts/conTrack', or 'tensors'
data_type = 'tensors';

cl_method = 'kmeans'; % 'gmm' or 'kmeans'

K = 3;  % max number of clusters to evaluate

for lr=1:numel(LR)
    dataFileName{lr} = ['tensor_values_DA_' LR(lr) '.mat'];
end



%% load and format subject data


if K==2
    colors = getDTIColors(4,5);
elseif K==3
    colors = getDTIColors(4,1,5);
else
    colors = solarizedColors(K);
end

lr = 1;
for lr=1:numel(LR)

load(['cluster_data/' data_type '/' dataFileName{lr}]); 
D = subj_data;


%% estimate clustering

s=1;
for s = 1:numel(subj_data);

subj = subjects{s};

clear cl_idx roi  % clear these variables for the upcoming subject

X = D{s};  % get tensor values for this subject

switch cl_method
    
    case 'gmm'
        
        %%%%%%%%%%% estimate model
        gm = fitgmdist(X,K);  % estimate mixture model
        cl_idx = cluster(gm, X);     % gives a cluster index
        cl_means = gm.mu;
        
    case 'kmeans'
        
        %%%%%%%%%%% estimate model
        [cl_idx,cl_means,sumd]=kmeans(X,K,'MaxIter',1000); % estimate k-means clusters
        
end  % cl_method


%% match clustering indices to roi coords

load([subj '/ROIs/DA_' LR(lr) '.mat']);

% figure out mean coords for each cluster
for k=1:K
    cl_mean_coords(k,:) = mean(roi.coords(cl_idx==k,:));
end

% make sure cluster index is arranged so that 1 is the most medial, etc.
[~,c]=sort(abs(cl_mean_coords(:,1)));
temp=cl_idx;
for k=1:K
    temp(cl_idx==c(k))=k;
end
cl_idx=temp;
clear temp


%% make new roi with voxels segmented according to cluster assignment


t1 =readFileNifti([subj '/t1_fs.nii.gz']);

outRoi = createNewNii(t1,['DA_tensor_cl' num2str(K) '_' cl_method]);

imgCoords = round(mrAnatXformCoords(outRoi.qto_ijk,roi.coords));
out_idx = sub2ind(size(outRoi.data),imgCoords(:,1),imgCoords(:,2),imgCoords(:,3));

for k=1:K
    outRoi.data(out_idx(cl_idx==k))=k;
end

% plotOverlayImage(outRoi,t1,colors,[1 K],2,-18);
% title(subj)

%% now xform segmentation into standard space 


load([subj '/sn/sn_info.mat']);

for k=1:K
    cl_roi = outRoi;
    cl_roi.data(cl_roi.data~=k)=0; cl_roi.data(cl_roi.data>0)=1;
    cl_roi_sn = xform_native2standard(sn,invDef,cl_roi,'nii',0);
    cl_roi_sn.data(cl_roi_sn.data<.3)=0; 
    cl_vol(:,:,:,k) = cl_roi_sn.data;
end

[~,vol]=max(cl_vol,[],4);
vol(sum(cl_vol,4)==0)=0;

% t1sn =readFileNifti([subj '/t1/t1_sn.nii.gz']);
%  outRoisn = createNewNii(t1sn,vol,['DA_sn_' LR '_tensor_cl' num2str(K) '_' cl_method]);
% plotOverlayImage(outRoisn,t1sn,colors,[1 K],2,-18);
% title([subj ' SN'])

all_vols(:,:,:,s) = vol;

clear vol 

 end % subjects


%% now assign each voxel to its mode cluster and mask it with the group sn da roi

mask = niftiRead('group_sn/ROIs/DA_sn_binary_mask.nii.gz');
t1sn =readFileNifti('group_sn/t1/t1_sn.nii.gz');

all_vols(all_vols==0)=nan;

vol = mode(all_vols,4);

vol = vol.*mask.data;
vol(isnan(vol))=0;

volLR{lr} = vol; % save L and R vols in a cell array

outRoisn = createNewNii(t1sn,vol,['DA_sn_' LR(lr) '_tensor_cl' num2str(K) '_' cl_method]);
plotOverlayImage(outRoisn,t1sn,colors,[1 K],2,-18);

end % LR


% combine L and R clustering data 
outRoisn.fname = ['DA_LR_tensor_cl' num2str(K) '_' cl_method];
outRoisn.data(volLR{1}~=0) = volLR{1}(volLR{1}~=0);
plotOverlayImage(outRoisn,t1sn,colors,[1 K],2);

% save out? 
cd group_sn/ROIs
niftiWrite(outRoisn)
