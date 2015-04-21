function [fa,md] = makeFaMdNiis(subject)

% this function saves fa and md maps into the subject's dti96trilin/bin
% directory

expPaths = getSAPaths(subject);
cd(expPaths.dti96trilin);

dt = dtiLoadDt6('dt6.mat');
[fa,md] = dtiComputeFA(dt.dt6);
fa(fa>1) = 1; 
fa(fa<0) = 0;
cd bin
b0 = readFileNifti('b0.nii.gz');
faNii = b0;
faNii.fname = 'fa.nii.gz';
faNii.data = fa;
writeFileNifti(faNii);
mdNii = b0;
mdNii.fname = 'md.nii.gz';
mdNii.data = md;
writeFileNifti(mdNii);
