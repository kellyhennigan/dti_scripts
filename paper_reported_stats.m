% stats for dti paper 


clear all
close all

pa=getDTIPaths();
cd(pa.data);

subjects=getDTISubjects;

omit_subs = {'sa19','sa28'};

keep_idx = ~ismember(subjects,omit_subs);

subjects = subjects(keep_idx);


%% get average da volume 

cd(pa.data)

roiL = cellfun(@(x) niftiRead([x '/ROIs/DA_L.nii.gz']), subjects,'uniformoutput',0);
roiR = cellfun(@(x) niftiRead([x '/ROIs/DA_R.nii.gz']), subjects,'uniformoutput',0);
nvoxL=cellfun(@(x) length(find(x.data)), roiL);
nvoxR=cellfun(@(x) length(find(x.data)), roiR);
nvox = nvoxL+nvoxR;

sprintf('%s%d%s%4.2f\n', 'mean/se vol of DA_L: ',round(mean(nvoxL)), ' +/- ', std(nvoxL)./sqrt(numel(nvoxL)))
sprintf('%s%d%s%4.2f\n', 'mean/se vol of DA_R: ',round(mean(nvoxR)), ' +/- ', std(nvoxR)./sqrt(numel(nvoxR)))
sprintf('%s%d%s%4.2f\n', 'mean/se vol of DA_R: ',round(mean(nvox)), ' +/- ', std(nvox)./sqrt(numel(nvox)))

cd ../../SA2/data
nvox2=dlmread('DA_dti_nvox');
NVOX=[nvox,nvox2]

sprintf('%s%d%s%4.2f\n', 'BOTH COHORTS mean/se vol of DA_R: ',round(mean(NVOX)), ' +/- ', std(NVOX)./sqrt(numel(NVOX)))


%% subjects age

cd(pa.data)
age = dlmread('dti_subs_ages')

cd ../../SA2/data
age2 = dlmread('SA2_dti_subs_age')

all_ages = [age;age2];

sprintf('%s%d%s%4.2f%s%4.2f\n', 'all participants, N=', numel(all_ages), ', mean/sd age: ',mean(all_ages), ' +/- ', std(all_ages))
sprintf('%s%d%s%4.2f%s%4.2f\n', 'SA participants, N=', numel(age), ', mean/sd age: ',mean(age), ' +/- ', std(age))
sprintf('%s%d%s%4.2f%s%4.2f\n', 'SA2 participants, N=', numel(age2), ', mean/sd age: ',mean(age2), ' +/- ', std(age2))

