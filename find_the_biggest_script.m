
% 


clear all
close all

p=getDTIPaths();
cd(p.data);


targets = {'null_caudate','null_nacc','null_putamen'};

% olFiles relative to data dir
olDir = 'group_sn/fg_densities/conTrack';
olPath = '%s_da_endpts_S3_sn_percent_mean.nii.gz';

big_method = 'mean'; % either 'subj_mode','T', or 'mean'

outName = 'null_CNP_biggest';

%% do it

cd(olDir)

switch big_method

       fd = cellfun(@(x) readFileNifti(sprintf(olPath,x)), targets);

    
    case 'subj_mode'

 
   i=1;
   for i=1:size(fd(1).data,4)
       
       subj_fds=cat(4,fd(1).data(:,:,:,i),fd(2).data(:,:,:,i),fd(3).data(:,:,:,i));
      
        % get the 'win_idx' - idx of which fd group is biggest for each voxel
        [~,win_idx]=max(subj_fds,[],4);
        win_idx(sum(subj_fds,4)==0)=0;
        
        % create a new nifti w/win_idx as img data
        win_vols(:,:,:,i)=win_idx;
   
   end
   
 
   nii=createNewNii(fd(1),win_vols,outName);
   writeFileNifti(nii);
   
   vol = nii.data;
   vol(vol==0)=nan;
   vol = mode(vol,4);
   vol(isnan(vol))=0;
   
     nii2=createNewNii(nii2,vol,outName2);
       writeFileNifti(nii2);
 
       
    case 'mean'
        
         fd = cellfun(@(x) readFileNifti(sprintf(olPath,x)), targets);
        
         vol(:,:,:,1) = fd(1).data;
         vol(:,:,:,2) = fd(2).data;
         vol(:,:,:,3) = fd(3).data;
         
         [~,win_idx]=max(vol,[],4);
         win_idx(sum(vol,4)==0)=0;
      
         nii=createNewNii(fd(1),win_idx,outName);
    writeFileNifti(nii)
    
         
  