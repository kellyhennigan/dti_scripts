function coords = getFDCoMCoords(target, method, fdStr, space)
% -------------------------------------------------------------------------
% usage: helper function to load center of mass coordinates for fiber densitiies

% INPUT:
%  target - cell array of target strings 
%  method - conTrack or mrtrix
%  fdStr - string identifying which fiber density file to use 
%          (e.g.,"da_endpts_S3")
%  space - sn (standard normalized) or ns (native space)

% OUTPUT:
%   coords - subjects' CoM coords returned as field cell arrays w/the names
%   of each target roi 

% NOTES:

% author: Kelly, kelhennigan@gmail.com, 28-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% get experiment-specific paths 
p = getDTIPaths;


% input defaults
if notDefined('target')
    target = {'caudateL', 'caudateR';
              'naccL', 'naccR';
              'putamenL', 'putamenR'};
end

% if target is given as a string, put it in a cell
if ischar(target)
    target = {target};
end

if notDefined('method')
    method = 'conTrack';
end

if notDefined('fdStr')
    fprintf('\n\n getting CoM coords for da endpts w/smoothing=3...\n\n');
    fdStr = '_da_endpts_S3';
end

if notDefined('space')
    space = 'sn'; % spatially normalized space
end



%% do it

% coords output will be a cell array the same size as input target array
coords = cell(size(target));

switch lower(space)

    
    case 'sn'
        
       % get file names 
        fs=cellfun(@(x) dir([fullfile(p.data, 'group_sn','fg_densities',method) '/*' x '*' fdStr '*CoM*']), target, 'UniformOutput',0);
        
        if any(any(cellfun(@numel, fs)~=1))
            error('more than 1 possible CoM file for at least one of the input targets')
        end
        
        % load CoM coords
        coords = cellfun(@(x) dlmread(fullfile(p.data, 'group_sn','fg_densities',method,x.name)), fs,'UniformOutput',0);
        
   
        
        
    % CoM coords aren't saved out in a text file, so have to load the
    % niftis and compute CoM.
    case 'ns'
        
        subjects = getDTISubjects;

        for t=1:numel(target)
            
    % load fiber density files
    fdPaths = cellfun(@(x) fullfile(p.data,x,'fg_densities',method,[target{1} fdStr '.nii.gz']), subjects,'UniformOutput',0);
    
    fds=cellfun(@readFileNifti, fdPaths);
    
    imgs={fds(:).data};  
    fdxforms = {fds(:).qto_xyz};  % all these xforms should be the same, but just in case, get all of them

%     % coords of fiber density center of mass
     CoM = cellfun(@(x) centerofmass(x), imgs,'UniformOutput',0); % center of mass img coords

     % xform img to acpc coords
     coords{t}=cell2mat(cellfun(@(x,y) mrAnatXformCoords(x,y), fdxforms,CoM,'UniformOutput',0)');
     %     acpcCoords(:,:,j) = mrAnatXformCoords(fds(1).qto_xyz,CoM);

        end % target        
        
end % switch space

 
