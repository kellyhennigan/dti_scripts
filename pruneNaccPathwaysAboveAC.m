function fgOut = pruneNaccPathwaysAboveAC(fgIn, LorR, subject, method)

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
%   fgOut - nacc-DA pathways going below the AC
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
z_thresh = 0;


switch method
    
    case 'conTrack'
        if strcmp(subject,'sa18')
            z_thresh = -3;
        elseif strcmp(subject,'sa28') && strcmpi(LorR,'L')
            z_thresh = -3;
        elseif strcmp(subject,'sa34') && strcmpi(LorR,'L')
            z_thresh = -2;
        elseif strcmp(subject,'sa24') && strcmpi(LorR,'L')
            z_thresh = 10;
        end
        
        
        
        % if nacc tracked without AC exclude ROI:
        
    case 'mrtrix'
        if strcmp(subject,'sa13') && strcmpi(LorR,'R')
            y_eval = -4;
        elseif strcmp(subject,'sa20') && strcmpi(LorR,'L')
            y_eval = -5;
        elseif strcmp(subject,'sa20') && strcmpi(LorR,'R')
            z_thresh = -1;
        elseif strcmp(subject,'sa25') && strcmpi(LorR,'R')
            z_thresh = 3;
        elseif strcmp(subject,'sa26') && strcmpi(LorR,'R')
            z_thresh = -3;
        elseif strcmp(subject,'sa27')
            z_thresh = 4;
        elseif strcmp(subject,'sa30') && strcmpi(LorR,'L')
            z_thresh = 4;
        elseif strcmp(subject,'sa31') && strcmpi(LorR,'R')
            z_thresh = 8;
        elseif strcmp(subject,'sa34') && strcmpi(LorR,'L')
            z_thresh = 5;
            
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
fg_clipped=dtiClipFiberGroup(fgIn,[],[y_eval 80],[]);


% get the z-coord of where the clipped fibers hit the coronal plane where the AC is
zc=cellfun(@(x) x(3,end), fg_clipped.fibers);


% fibers below the AC
fgOut = getSubFG(fgIn,zc<z_thresh);


% fibers that go above the AC
fg2 = getSubFG(fgIn,zc>=z_thresh);


