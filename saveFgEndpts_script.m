% script to save out fg endpts 

%% define directories and file names, load files

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects; 


roi1Str = 'DA';
roi2Str = 'striatumR';

method = 'mrtrix';


fgName = [roi2Str '_autoclean.pdb'];

%% 

outDir = fullfile('group_sn','fg_endpts',method);



%% save out endpoints

for s=1:numel(subjects)

  subj = subjects{s};
  
  % load rois 
load(fullfile(subj,'ROIs',[roi1Str '.mat'])); roi1 = roi;
load(fullfile(subj,'ROIs',[roi2Str '.mat'])); roi2 = roi;


% load fiber group
fg = fgRead(fullfile(subj,'fibers',method,fgName));

% reorient fibers so they all start in DA ROI
[fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);

% get just fiber endpoints
[~,endpts] = getFGEnds(fg,2); 

% put them into all subjects' cell array 
subj_endpts{s}=endpts';

end


%% save out subj_endpts cell array 


outPath = fullfile(outDir, [roi1Str '_' roi2Str '.mat']);

save(outPath, 'subjects', 'subj_endpts');






