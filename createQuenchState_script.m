% createQuenchState_script

% this script calls function createQST() to create quench state files for
% easier, less-mouse-clicking viewing of subjects' fiber tracts in Quench.

% createQST():
% createQST(qsDir,templatefile,volPaths,fgPaths,fgColors,outfilename)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

subs=getDTISubjects;
% subs = {'sa18','sa23','sa27'};

qsDir = '/Users/Kelly/dti/data/quench_states'; % directory to house the quench state file

templatefile = ['quench_state_template.qst']; % example quench state file to use as a template


% define paths to volumes, fiber groups, etc.
% paths must be *relative to the directory of the quench state out file.
% use %s for subject string

% Volumes
volPaths = {'../%s/t1/t1_fs.nii.gz'}; % *relative* path to t1 volume

% FGs
fgPaths = {
    '../%s/fibers/conTrack/scoredFG__caudate_DA_top2500_clean.pdb',...
    '../%s/fibers/conTrack/scoredFG__nacc_DA_top2500_clean.pdb',...
    '../%s/fibers/conTrack/scoredFG__putamen_DA_top2500_clean.pdb'};


fgColors = [  0.9333    0.6980    0.1373
    0.7961    0.0941    0.1137
    0.1294    0.4431    0.7098];
     

% vis_idx = ones(numel(fgPaths),1);
vis_idx = [1 1 1];


% out file name
% outfilename = ['QS_%s_wb.qst'];
outfilename = ['QS_%s_conTrack_man_clean.qst'];



for i=1:numel(subs)
    
    % subject
    subj = subs{i};
    
    this_volPaths=cellfun(@sprintf,volPaths,repmat({subj},1,numel(volPaths)),'UniformOutput',0);
    this_fgPaths=cellfun(@sprintf,fgPaths,repmat({subj},1,numel(fgPaths)),'UniformOutput',0);
    this_outfilename = sprintf(outfilename,subj);
   
    
%% call createQST()


createQST(qsDir,templatefile,this_volPaths,this_fgPaths,fgColors,vis_idx,this_outfilename);


end
