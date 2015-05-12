% script to visually inspect all fg endpts to ensure all endpts start at DA
% ROI and end in striatum ROI

% this is annoying to do, but its important bc clustering gets wonky if
% even a few endpts are switched

% the idea is to:
% 1) run this as a loop for all subjects, saving out reoriented fibers if
%    necessary, and plotting endpoints for visual inspection.
% 2) based on plotted endpoints, note any 'bad' subjects w/incorrectly
%    oriented pathways.
% 3) re-run this script for each of those 'bad' subjects and use code at
%    the bottom of the script to omit the wonky pathways.
% 4) re-run again on all subjects w/reorientFibers set to 0 to double-check
%    everything looks good.

% reOrientFibers shold be set to 1 for the first 3 steps, then 0 for the
% last step.



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


reorientFibers = 0; % set this to 1 to reorient fibers, otherwise 0

%% do it


s=1;
for s=1:numel(subjects)

subj = subjects{s};
fprintf(['\n\n Working on subject ' subj '...\n\n']);


% load fiber group
fg = fgRead(fullfile(subj,'fibers',method,fgName));


if reorientFibers
    
    % load rois
    load(fullfile(subj,'ROIs',[roi1Str '.mat'])); roi1 = roi;
    load(fullfile(subj,'ROIs',[roi2Str '.mat'])); roi2 = roi;
    
    % reorient fibers so they all start in DA ROI
    [fg,flipped] = AFQ_ReorientFibers(fg,roi1,roi2);
    
    
    flip_idx = find(flipped==1);
    if ~isempty(flip_idx)
        fprintf(['\n\nsome fibers were flipped for subj ' subj '. ',...
            'Saving out reoriented fibers .\n\n']);
        fgWrite(fg,fullfile(subj,'fibers',method,fg.name));
    end

end

% get just fg endpoints
[~,endpts] = getFGEnds(fg,2); endpts = endpts';

% plot endpts to visually check to make sure all fibers were flipped
figure
subplot(1,2,1)
scatter3(endpts(:,1),endpts(:,2),endpts(:,3),5,[1 0 0],'filled')
title([subj ' da endpoints'])
axis equal
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
xlabel('x'), ylabel('y'), zlabel('z')

subplot(1,2,2)
scatter3(endpts(:,4),endpts(:,5),endpts(:,6),5,[.5 0 1],'filled')
title([subj ' striatum endpoints'])
axis equal
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
xlabel('x'), ylabel('y'), zlabel('z')


fprintf(' done.\n\n');


end % subjects




%%%%%%%%%%%%%%%%%% USE CODE BELOW  SUBS %%%%%%%%%%%%%%%%%%%%%
%% if there are fibers that aren't oriented correctly, ditch them

% define omit idx, 'o_idx' in the command window based on figures
error('define o_idx in command window before continuing');


keep_idx = 1:numel(fg.fibers);

keep_idx(o_idx) = [];

fg = getSubFG(fg,keep_idx);


% save out fibers
fgWrite(fg,fullfile(subj,'fibers',method,fg.name));
