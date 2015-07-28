% get the mahal distance of N,C, and P pathways


clear all
close all

% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


subjects=getDTISubjects;  % define subjects to process
subjects([9,18]) = []; 

LR = ['L','R'];

ref_fgStr = 'nacc'

fgStrs = {'caudate','putamen'};

%%

% get mahalanobis distance of fgs relative to ref_fg
for lr = 1:2

for s=1:numel(subjects)
    
    
    subj = subjects{s};
    
    % get nacc fg
    ref_fg=fgRead([subj '/fibers/conTrack/' ref_fgStr LR(lr) '_autoclean.pdb']);
    [~,ref_endpts]=getFGEnds(ref_fg,1,1);
    
    for f=1:2
        fg=fgRead([subj '/fibers/conTrack/' fgStrs{f} LR(lr) '_autoclean.pdb']);
        [~,fg_coord]=getFGEnds(fg,1,1);
        fg_coord =mean(fg_coord');
        md{lr}(s,f) = sqrt(mahal(fg_coord,ref_endpts')); % mahalanobis distance
    end
    
end

end








