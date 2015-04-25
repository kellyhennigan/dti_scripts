% script to merge cleaned L and R fiber groups

% define variables, directories, etc.
clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';


% define subjects to process
subjects=getDTISubjects;


% what tracking method? conTrack or mrtrix
% method = 'conTrack';
method = 'mrtrix';


% define fiber group files to be merged
fgNames = {'putamenL_autoclean.pdb','putamenR_autoclean.pdb'};


% define out name for merged fg
outFgName = 'putamen_autoclean';



%% DO IT


for i=1:numel(subjects)
    
    fprintf(['\n\nworking on subject ' subjects{i} '...\n\n'])
    
    % define directory w/fg files
    fgDir = fullfile(dataDir,subjects{i},'fibers',method);
    
    % get cell array of full paths to fg files
    fgPaths = cellfun(@(x) fullfile(fgDir,x), fgNames,'UniformOutput',0);
    
    % merge FGs
    merged_fg = mergeFGs(fgPaths,outFgName);
    
    % visualize the merged FG
    %     AFQ_RenderFibers(merged_fg,'tubes',0,'color',[0 0 1]);
    %     title(subjects{i});
    
    fprintf(['\n\ndone with subject ' subjects{i} '.\n\n'])
    
end









