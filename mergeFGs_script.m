% script to merge cleaned L and R fiber groups

% define variables, directories, etc.
clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';


% define subjects to process
subjects=getDTISubjects; subjects = {'sa18','sa24'};


% what tracking method? conTrack or mrtrix
method = 'conTrack';
% method = 'mrtrix';


% define fiber group files to be merged
fgNames = {'naccL_autoclean.pdb','naccR_autoclean.pdb'};


% define out name for merged fg
outFgName = 'nacc_autoclean';



%% DO IT


for i=1:numel(subjects)
    
    cd(dataDir)
    fprintf(['\n\nworking on subject ' subjects{i} '...\n\n'])
    
    % define directory w/fg files
    fgDir = fullfile(dataDir,subjects{i},'fibers',method);
    
    % get cell array of full paths to fg files
    fgPaths = cellfun(@(x) fullfile(fgDir,x), fgNames,'UniformOutput',0);
    
    % merge FGs
    merged_fg = mergeFGs(fgPaths,outFgName,1);
%    merged_fg.name = outFgName;
   
  
% visualize the merged FG
%     AFQ_RenderFibers(merged_fg,'tubes',0,'color',[1 0 0]);
%         title(subjects{i});
    
    fprintf(['\n\ndone with subject ' subjects{i} '.\n\n'])
    
    
end









