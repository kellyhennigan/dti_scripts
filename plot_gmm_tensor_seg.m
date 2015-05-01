%

clear all
close all


% get experiment-specific paths and cd to main data directory
p=getDTIPaths(); cd(p.data);

figDir = fullfile(p.figures,'gmm','da_tensors');
saveFigs = 1;
figPrefix = '';

subjects = getDTISubjects;

nC = 3;

col = solarizedColors(nC);

c_range = [1 nC];

plane = 2;

LR = ['L','R']

% acpcSlices = [-14:-8];

%%


% for s= 1:numel(subjects)
    for s= 1:3:numel(subjects)
    
    subject = subjects{s};
    
    t1 = readFileNifti([subject '/t1_fs.nii.gz']);

da=readFileNifti([subject '/ROIs/DA.nii.gz']);

    lr_vols=zeros(256,256,256);
    
    for lr=1:2
        
        filePaths = {[subject '/ROIs/DA_' LR(lr) '_b0_tensor_clust1_of_3.nii.gz'],
            [subject '/ROIs/DA_' LR(lr) '_b0_tensor_clust2_of_3.nii.gz'],
            [subject '/ROIs/DA_' LR(lr) '_b0_tensor_clust3_of_3.nii.gz']};
        
        
        niis = cellfun(@readFileNifti, filePaths);
        
        for c=1:nC
            coms(c,:)=getNiiStat(niis(c),'com');
        end
        
        % organize medial to lateral
        [~,sort_idx]=sort(abs(coms(:,1)));
        d=zeros(size(niis(1).data));
        for c=1:nC
            this_d =niis(sort_idx(c)).data;
            this_d(this_d~=0) = c;
            d = d+this_d;
        end
        
        lr_vols = lr_vols+d;
        
    end
    
    
    ni = niis(1);
    ni.data= lr_vols;
    
    
    [imgRgbs,olMasks,olVals,h,acpcSlices]=plotOverlayImage(ni,t1,col,c_range,plane,[],0);
    
    % plot all fiber groups and save new figure
    
    for k=1:numel(acpcSlices)
        h = plotFDMaps(imgRgbs{k},plane,acpcSlices(k),saveFigs,figDir,figPrefix,subject);
    end
    
    close all
    
end % subjects 

% render a DA ROI mesh
% msh = AFQ_meshCreate(
% afq_renderMesh(da,'overlay',d,'cmap',solarizedColors(6),'crange',[1 6])


