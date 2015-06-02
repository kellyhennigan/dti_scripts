% script to save out fg endpts
%
% ********NOTE: make sure plot_fgEndpts_script is run first to make sure
% all endpts of each pathway start in roi1 (DA) and end in roi2 (striatum)

%% define directories and file names, load files

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% define subjects to process
subjects=getDTISubjects;


method = 'conTrack';


roi1Str = 'DA';
roi2Str = 'striatumL';

fgName = [roi2Str '_all_autoclean.pdb'];


xform_coords = 1; % 1 to xform coords into group space, otherwise 0



%% define a few more variables


outDir = fullfile('cluster_data','fg_endpts',method);
outName = [roi1Str '_' roi2Str];

if xform_coords
    xf_mat = 'sn/sn_info.mat';  % path to subject's xform info
    outName = [outName '_sn'];
end


%% do it


s=1;
for s=1:numel(subjects)
    
    subj = subjects{s};
    fprintf(['\n\n Working on subject ' subj '...\n\n']);
    
    
    % load fiber group (*NOTE: this assumes that all pathways start in roi1
    % and end in roi2)
    fg = fgRead(fullfile(subj,'fibers',method,fgName));
    
    
    % get just fgOutfiber endpoints
    [fg,endpts] = getFGEnds(fg,2);
    
    
    if xform_coords
        
        load(fullfile(subj,xf_mat));
        
        fg = dtiXformFiberCoords(fg, invDef); % xform fiber endpt coords
        
        [~,endpts] = getFGEnds(fg,2);
        
    end
    
    
    % put them into all subjects' cell array
    subj_data{s}=endpts';
    
    fprintf(' done.\n\n');
    
    
end % subjects


%% save out subj_endpts cell array


save(fullfile(outDir,outName),'subj_data');






