% dti pre-processing script 
% --------------------------------
% usage: this is a script to pre-process dti data using mrVista software.
% 
% calls dtiInit(), which does the following:
% -finds b=0 volumes in dti file (the first 8 volumes),
% motion corrects them all to the first one, 
% and makes a new nii file of mean b=0 volumes.
% - CNI handles eddy-distortion correction, so this default step should be
% turned off 
% - computes a rigid body transform to align the mean b0 nii to the t1 nii
% (note: make sure this t1.nii is ACPC aligned!!) 
% - resamples raw dw data to be aligned with the t1 using a 7th order b-spline interpolation method
% - b-vector directions are reoriented to match the resampled dw data 
% - fits tensor model for each voxel of resampled ACPC?aligned dw data and
% reoriented vectors.  Default method is least squares, but robust tensor
% fitting is supposed to be better ; to do this change fitMethod in
% dwParams from ?ls? to ?rt? (note this takes longer!  Check to see if it
% actually makes a difference!)

% see here for more info on pre-processing: 
% http://white.stanford.edu/newlm/index.php/DTI_Preprocessing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% subjects = {'9','10','11','12'};
subjects = {'23'};

%% do it

for i = 1:numel(subjects)
    
    subject = subjects{i};
    
    fprintf(['\npre-processing diffusion data for subject ' subject '...\n']);
    
    p=getSA2Paths(subject);
    
    % define raw diffusion and t1 file names
    dwRawFileName = fullfile(p.raw, 'dwi.nii.gz');  % filepath to raw dti data
    t1FileName = fullfile(p.subj, 't1_fs.nii.gz');     % filepath to

    % initialize pre-processing parameters
    dwParams = dtiInitParams;
        % dwParams.fitMethod='rt'
    dwParams.eddyCorrect=0; % this means do motion but not eddy correction (eddy correction already done by cni)
        
%     if ~exist(dwParams.outDir,'dir')
%         mkdirquiet(dwParams.outDir);
%     end


    % call dtiInit() to do pre-processing: 
    [dt6FileName, outBaseDir] = dtiInit(dwRawFileName,t1FileName,dwParams);
    dt6file=dt6FileName{1}; clear dt6FileName
    [outDir,~]=fileparts(dt6file);    % e.g., dti80trilin
    [~,outStr]=fileparts(outBaseDir); % e.g., dwi_aligned_trilin 
    
%% move aligned data to new out dir and fix dt6 file structure accordingly

dt=load(dt6file);
movefile([outBaseDir '*'],outDir); movefile([p.subj, '/*b0*'],outDir);
movefile([p.subj, '/dtiInitLog.mat'],outDir);

dt.files.alignedDwRaw = fullfile(outDir,[outStr '.nii.gz']);
dt.files.alignedDwBvecs = fullfile(outDir,[outStr '.bvecs']);
dt.files.alignedDwBvals = fullfile(outDir,[outStr '.bvals']);
save(dt6file,'-struct','dt');



%% check for any WM voxels with negative eigenvalues; if found, set to zero

dt=dtiLoadDt6(dt6file); % note the use of dtiLoadDt6 here instead of just load
[vec,val] = dtiEig(dt.dt6);  badData = any(val<0, 4);   
wmProb=dtiFindWhiteMatter(dt.dt6,dt.b0,dt.xformToAcpc);  badData(wmProb<0.8)=0;  
nBadWMVox=sum(badData(:));   
fprintf(['\nthis subject has ' num2str(nBadWMVox) ...
    ' white matter voxels with negative eigenvalues\n'])
if nBadWMVox>0
  showMontage(double(badData));
  resp=input('clip neg values to zero? (should say yes if # is low) ','s');
  if strcmpi(resp(1),'y')
      dtiFixTensorsAndDT6(dt6file);
  end
end


%% create FA and diffusivity maps and save them out to dti_proc dir

cd(outDir); cd bin;

[fa,md,rd,ad] = dtiComputeFA(dt.dt6);
% fa(fa>1) = 1; fa(fa<0) = 0;


% load b0 file as a template nii
nii=readFileNifti('b0.nii.gz');
    
% save out fa,md,rd, and ad maps as niftis
out=createNewNii(nii,'fa','fractional anisotropy',fa); writeFileNifti(out);
out=createNewNii(nii,'md','mean diffusivity',md); writeFileNifti(out);
out=createNewNii(nii,'rd','radial diffusivity',rd); writeFileNifti(out);
out=createNewNii(nii,'ad','axial diffusivity',ad); writeFileNifti(out);



%% Add more QA checks here


end % subjects loop

