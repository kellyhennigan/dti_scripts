
clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects; 
% subjects = {'sa01','sa07','sa10','sa11','sa13','sa14',...
%     'sa26','sa27','sa28','sa29','sa30'};

% specify directory & files to xform, relative to subject's dir
method = 'fsl';

LR = ['L','R'];

% probtrackx results directory, relative to subjDir
ptDir = 'fsl_dti/probtrackx/std/striatum'; % L or R will be added to end

roiStrs = {'caudate','nacc','putamen'};


% relative to main datadir
outDir = fullfile('group_sn','fg_densities',method);


%%% procedure/values based on Cohen et al (2008)
thresh = 10;


colors = getDTIColors(1:3);

%%  do it

s=1;
for s=1:numel(subjects)
    
    subj = subjects{s};
    
    
    fprintf(['\n\n Working on subject ' subj '...\n\n']);
    
    cd(p.data);
    cd(subj);
    
    % load subject's t1 nifti in native and standard space
    t1 = niftiRead('t1_fs.nii.gz');
    t1sn = niftiRead('t1/t1_sn.nii.gz');
    
    bb = t1.qto_xyz*[1,1,1,1;[size(t1.data),1]]'; % bounding box to match t1_fs
    bb = bb(1:3,:)';
    interp = [1 1 1 0 0 0]; % [1 1 1 0 0 0] for trilinear interpolation
    
    % load spatial normalization xform info
    load('sn/sn_info.mat'); % loads vars sn and invDef
    
    
    % get a list of fiber count files for each classification target
    lr = 1;
    for lr=1:numel(LR)
        
        clear subj_vols
        j=1
        for j=1:numel(roiStrs)
            
            nii = niftiRead(fullfile([ptDir LR(lr)],['seeds_to_' roiStrs{j} LR(lr) '.nii.gz']));
            
            % first xform to t1_fs dim because that is what the sn xform starts with
            vol = mrAnatResliceSpm(nii.data,nii.qto_ijk,bb,t1.pixdim,interp,false);
            vol = xform_native2standard(sn,invDef,vol,'vol',0); % xform to standard space
            vol(isnan(vol))=0;
            CoM{j,lr}(s,:) = mrAnatXformCoords(t1sn.qto_xyz,centerofmass(vol)); % get center of mass
            
            subj_vols(:,:,:,j)=vol;
            
        end
        
        
        subj_vols(subj_vols<thresh) = 0; % threshold
        subj_vols = subj_vols./repmat(sum(subj_vols,4),1,1,1,numel(roiStrs)); % convert into proportions
        subj_vols(isnan(subj_vols)) = 0;
        
        
        [~,win_vol{lr}]=max(subj_vols,[],4);  % find the biggest
        win_vol{lr}(sum(subj_vols,4)==0)=0;
        
        % keep track of proportion maps for all subjects
        for j=1:numel(roiStrs)
            all_subj_vols{j,lr}(:,:,:,s) = subj_vols(:,:,:,j);
        end
        
        
    end % LR
    
    % combine L and R  find_the_biggest maps and plot
    if ~isempty(find(ismember(find(win_vol{1}),find(win_vol{2}))))
        error(['there are overlapping voxels for the L and R sides for subject ' subj]);
    else
        win_vol_lr = win_vol{1}+win_vol{2};
        biggest = createNewNii(t1sn,win_vol_lr);
        plotOverlayImage(biggest,t1sn,colors,[1 3],3,-12);
    end
    
    
    
end % subjects


% combine L and R proportion maps for all subjects
for j=1:numel(roiStrs)
    if ~isempty(find(ismember(find(all_subj_vols{j,1}),find(all_subj_vols{j,2}))))
        error(['there are overlapping voxels for the L and R sides for ROI ' roiStrs{j}]);
    else
        target_maps(:,:,:,j) = mean((all_subj_vols{j,1}+all_subj_vols{j,2}),4);
        nii = createNewNii(t1sn,target_maps(:,:,:,j));
        plotOverlayImage(nii,t1sn,autumn);
    end
end







