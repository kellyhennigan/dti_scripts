function idx = pruneNaccPathwaysAboveAC(fg, LorR, subject, method)

% -------------------------------------------------------------------------
% usage: omit pathways coming from the midbrain that enter the
% NAcc/Striatum above the AC.

% fiber pruning that is unique to DA-Nacc pathways
%
% INPUT:
%   fgIn - .pdb format pathways
%   LorR - 'L' or 'R' denoting left or right pathways
%   subject - subject string (e.g., 'sa01')
%   method - either 'conTrack' or 'mrtrix'
%
%
% OUTPUT:
%   idx - idx indicating fibers that go above the AC w/1 and below w/0
%
%
% NOTES:
%
% author: Kelly, kelhennigan@gmail.com, 01-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% omit fibers that go above  AC

% separate fibers that go below the anterior commissure from those that
% enter the internal capsule. These fibers group into what looks like 2
% distinct trajectories.

% do this by omitting fibers that are above Z=0 at Y=0 (unless otherwise
% specified), which should be the y,z coords of the AC.

% coords below z_thresh at coronal plane y_eval will be kept, those above
% it will be omitted. Subject-specific cases listed below.



fprintf('\n\n omitting fibers that go above the AC...\n\n');

y_eval = 0;
z_thresh = 0; % fibers that are above this at the y-coord y-eval will be excluded

method = 'aboveAC'; 


% subject specific cases to distinguish between fibers that go above and
% below the AC:

switch [method,LorR]
    
    
    case ['conTrack','L']
        
        
        if strcmp(subject,'sa28')
            z_thresh = -3;
        elseif strcmp(subject,'sa01')
            z_thresh = 2;
        elseif strcmp(subject,'sa19')
            z_thresh = 3;
        elseif strcmp(subject,'sa27')
            z_thresh = 3;
        elseif strcmp(subject,'sa20')
            z_thresh = 2;
        elseif strcmp(subject,'sa23')
            z_thresh = 7;
        elseif strcmp(subject,'sa24')
            z_thresh = 15;
        elseif strcmp(subject,'sa34')
            z_thresh = -2;
        elseif strcmp(subject,'sa31')
            z_thresh = -1;
        elseif strcmp(subject,'sa13')
            z_thresh = 4;
        end
        
    case ['conTrack','R']
        
        
        if strcmp(subject,'sa11')
            z_thresh = 1;
        elseif strcmp(subject,'sa13')
            z_thresh = 1;
        elseif strcmp(subject,'sa18')
            z_thresh = -3;
        end
        
        
        
    case ['mrtrix','L']
        
        if strcmp(subject,'sa20')
            y_eval = -5;
        elseif strcmp(subject,'sa27')
            z_thresh = 4;
        elseif strcmp(subject,'sa30')
            z_thresh = 4;
        elseif strcmp(subject,'sa34')
            z_thresh = 5;
        end
        
        
    case ['mrtrix','R']
        
        
        if strcmp(subject,'sa13')
            y_eval = -4;
        elseif strcmp(subject,'sa20')
            z_thresh = -1;
        elseif strcmp(subject,'sa25')
            z_thresh = 3;
        elseif strcmp(subject,'sa26')
            z_thresh = -3;
        elseif strcmp(subject,'sa27')
            z_thresh = 4;
        elseif strcmp(subject,'sa31')
            z_thresh = 8;
        end
        
end



%% old mrtrix exclusionary criteria

%  case 'mrtrix'
%
%         if strcmp(subject,'sa01') && strcmpi(LorR,'R')
%             y_evals = 5; z_thresh = -2;
%         elseif strcmp(subject, 'sa07') && strcmpi(LorR,'R')
%             y_eval = 5;
%         elseif strcmp(subject,'sa16') && strcmpi(LorR,'R')
%             z_thresh = -1;
%         elseif strcmp(subject,'sa18') && strcmpi(LorR,'R')
%             z_thresh = -2;
%         elseif strcmp(subject,'sa19') && strcmpi(LorR,'R')
%             z_thresh = -2;
%         elseif strcmp(subject,'sa20') && strcmpi(LorR,'R')
%             z_thresh = -1;
%         elseif strcmp(subject,'sa25')
%             z_thresh = -2;
%         elseif strcmp(subject,'sa26') && strcmpi(LorR,'R')
%             z_thresh = -3;
%         elseif strcmp(subject,'sa27') && strcmpi(LorR,'R')
%             y_eval = -5;
%         elseif strcmp(subject,'sa28')
%             z_thresh = -2;
%         end
%

%% get the pathways below the AC


% temporarily clip all pathways in the coronal plane at the AC
fg_clipped=dtiClipFiberGroup(fg,[],[y_eval 80],[]);


% get the z-coord of where the clipped fibers hit the coronal plane where the AC is
zc=cellfun(@(x) x(3,end), fg_clipped.fibers);


% idx of fibers that go above the AC
idx = zc>=z_thresh;

% % fibers below the AC
% fgOut = getSubFG(fgIn,zc<z_thresh);
%
%
% % fibers that go above the AC
% fg2 = getSubFG(fgIn,zc>=z_thresh);


