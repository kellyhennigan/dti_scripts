
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
ptDir = 'fsl_dti/probtrackx/std/striatum_naccdil'; % L or R will be added to end

roiStrs = {'caudate','nacc','putamen'};

%%% procedure/values based on Cohen et al (2008)
thresh = 10;


colors = getDTIColors(1:3);

%%  do it


for lr = 1:numel(LR)
      
    ptDirLR = [ptDir LR(lr)]; % left or right ptDir
    
    s=1;
    for s=1:numel(subjects)
        
        subj = subjects{s};
        
        
        fprintf(['\n\n Working on subject ' subj '...\n\n']);
        
        cd(p.data); cd(subj);
        
        % load subject's t1 nifti in fsl-standard space
        t1 = niftiRead('fsl_dti/dwi.bedpostX/xfms/t1_sn.nii.gz');
        
        
        cd(ptDirLR)
        
        for j=1:numel(roiStrs)
            f=dir(['seeds_to_' roiStrs{j}  '*']); % * wild card to allow L/R chars
            nii = niftiRead(f.name);
            %         nii.fname
            %         unique(nii.data(:))
            %         plotOverlayImage(nii,t1)
            vols(:,:,:,j) = nii.data;
        end
        
        % threshold
        vols(vols<thresh) = 0;
        
        % convert into proportions
        vols = vols./repmat(sum(vols,4),1,1,1,numel(roiStrs));
        vols(isnan(vols)) = 0;
        
        % find the biggest
        [~,biggest]=max(vols,[],4);
        biggest(sum(vols,4)==0)=0;
        
        % plot it
        if any(biggest(:)>0)
            nii.data = biggest;
            plotOverlayImage(nii,t1,colors,[1 numel(roiStrs)],3,'best');
            title(subj)
        else
            fprintf(['\n\nall zero voxels for subject ' subj '\n\n']);
        end
        
        % now keep track of roi proportions and biggest vol for all subs
        big_LR{lr}(:,:,:,s) = biggest;
        for j=1:numel(roiStrs)
            roi_p_LR{j,lr}(:,:,:,s) = vols(:,:,:,j);
        end
        
        
    end % subjects
    
end % LR

%% 

cd(p.data)

t1 = niftiRead('group_sn/ROIs/fsl/t1_sn_fsl.nii.gz'); % group averaged t1
big=big_LR{1}+big_LR{2}; % find_the_biggest index for all subjs
for j=1:numel(roiStrs)
    roi_p{j}=roi_p_LR{j,1}+roi_p_LR{j,2};  % PICO (proportion of connectivity index) for each roi, for each subj
end

big(big==0)=nan;
big=mode(big,4);
big(isnan(big))=0;
nii.data = big;
plotOverlayImage(nii,t1,colors,[1 3])


