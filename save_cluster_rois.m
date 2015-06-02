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

method = 'conTrack'; 

cl_method = 'kmeans'; % 'gmm' or 'kmeans'

K = 2;  % max number of clusters to evaluate

roiStrs = {'DA','striatum'};

t1 = readFileNifti('group_sn/t1/t1_sn.nii.gz'); % group anat



%% load subject data


if K==2
    colors = getDTIColors(4,5);
elseif K==3
    colors = getDTIColors(4,1,5);
else
    colors = solarizedColors(K);
end


ROIs{1}= readFileNifti(['group_sn/ROIs/' roiStrs{1} '_sn_binary_mask.nii.gz']);
ROIs{2}= readFileNifti(['group_sn/ROIs/' roiStrs{2} '_sn.nii.gz']);


for lr = 1:numel(LR)
    
    dataFileName = ['DA_striatum' LR(lr) '_sn.mat'];
    
    load(['cluster_data/fg_endpts/' method '/' dataFileName]);
    
    
    
    
    % get a random sample of ns fibers from each subject
    % ns = min([2000,(cellfun(@length, subj_data'))]); % take this # of samples from every sub
    % X=cellfun(@(x) x(randperm(size(x,1),ns),:), subj_data, 'UniformOutput',0); % data in cell array dc
    
    
    % X= cell2mat(X);
    
    
    
    %% estimate clustering
    
    s=1;
    for s = 1:numel(subj_data);
        
        subj = subjects{s};
        
        X = subj_data{s};
        
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
        
        
        % get index of clusters by most medial to most lateral in the striatum
        [~,c]=sort(abs(cl_means(:,4)));
        temp = cl_idx;
        for k=1:K
            temp(cl_idx==c(k))=k;
        end
        cl_idx=temp;
        clear temp
        
        
        % separate DA and striatum endpoints
        endpts{1} = X(:,1:3)';  endpts{2} = X(:,4:6)';
        
        
        %% now assign roi voxels to a cluster depending on the cluster with
        %     the most endpoints close to it
        
        
        r=1;
        for r=1:2  % da and striatum rois
            
            roi = ROIs{r};
            
            [i,j,k]=ind2sub(size(roi.data),find(roi.data));
            acpcCoords = mrAnatXformCoords(roi.qto_xyz,[i,j,k]);
            
            
            %% do a hard segmentation of roi coords according to clustered fgs
            
            % create nifti w/a volume of zeros
            cl_vol = zeros(size(roi.data));
            
            cc_idx= nearpoints(endpts{r},acpcCoords'); % closest coord index
            vi = unique(cc_idx); % get list of all unique roi indices to be colored
            % assign each roi voxel to a cluster according to the cl group w/the most close coords
            for v=1:numel(vi)
                ci = mode(cl_idx(cc_idx==vi(v)));  % determine cluster num for this voxel
                cl_vol(i(vi(v)),j(vi(v)),k(vi(v))) = ci;
            end
            
            % keep track of clustering
            cl_vols{r}(:,:,:,s) = cl_vol;
            
            
        end % da and striatum rois
        
        
    end % subjects
    
    
    for r=1:2
        cl_vols{r}(cl_vols{r}==0)=nan;
        
        win_vol = mode(cl_vols{r},4);
        win_vol(isnan(win_vol))=0;
        
        out_vols{r,lr} = win_vol;
        
        outRois{r,lr} = createNewNii(roi,win_vol,['group_sn/ROIs/' roiStrs{r} '_' LR '_mrtrix_cl' num2str(K) '_' cl_method]);
        %     plotOverlayImage(outRois{r},t1,colors,[1,K],3);
        
        %     writeFileNifti(outRois{r});
        
        
    end % da and striatum roi
    
end  % LR


%% combine L and R rois for DA and striatum

% correct for R and L voxel overlap by setting L voxels in the R clustering
% to 0 and vice versa 
midsag_coord = mrAnatXformCoords(roi.qto_ijk,[0 0 0]); midsag_coord = midsag_coord(1);
out_vols{1,1}(midsag_coord+1:end,:,:)=0;
out_vols{1,2}(1:midsag_coord-1,:,:)=0;

for r=1:2
    
    outRoi = createNewNii(roi,out_vols{r,1},['group_sn/ROIs/' roiStrs{r} '_LR_' method '_cl' num2str(K) '_' cl_method]);
    outRoi.data(out_vols{r,2}~=0) = out_vols{r,2}(out_vols{r,2}~=0);
    
    plotOverlayImage(outRoi,t1,colors,[1,K],2,-20);
    niftiWrite(outRoi)
    
end

% %% plot segmentation w/X clusters
%
% [h,hm] = plot_fgClusters(X,cl_means,cl_idx,LR);
%
% [hm(1),mov] = rotateMesh(hm(1),[0,1],1);
% [hm(2),mov] = rotateMesh(hm(2),[1,0],1);


