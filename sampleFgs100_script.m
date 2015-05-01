% resample fiber groups to be 100 fibers each for viewing purposes. Do this
% separately for the left and right fibers, then combine them.

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);

subjects = getDTISubjects;


method = 'conTrack';


% will take subset from left and right fibers separately
% targets = {'caudate','nacc','putamen'};
targets = {'nacc'};

LR = ['L','R']; % characters denoting left and right fiber files

fgStr = '_autoclean';

ns = 100; % # of fiber samples to get

%%

for s=1:numel(subjects)
    
    for t=1:numel(targets)
        
        fgDir = fullfile(subjects{s},'fibers',method);
        
        for lr=1:2
            
            fg=fgRead(fullfile(fgDir,[targets{t} LR(lr) fgStr '.pdb']));
            
            % if there are >=100 fibers, get a random subset of them
            if numel(fg.fibers)>=ns
                idx = randperm(numel(fg.fibers),ns); % get random index of 100 fibers
                fgs100(lr) = getSubFG(fg,idx);
                
                % if there are <100 fibers, duplicate some
            else
                idx=[]; i=0;
                while numel(fg.fibers)+numel(idx)<ns
                    i=i+1;
                    idx(i) = randperm(numel(fg.fibers),1);
                end
                fg2 = getSubFG(fg,idx);
                fgs100(lr) = mergeFGs({fg,fg2});
            end
            
        end % lr
        
        % save out new fiber file w/100 fibers on left and right hemis
        fgOut = mergeFGs(fgs100,[targets{t} fgStr '_' num2str(ns)]);
        fgWrite(fgOut,fullfile(fgDir,fgOut.name));
        
    end % targets
    
end % subjects




