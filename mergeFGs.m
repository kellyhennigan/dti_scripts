
function merged_fg = mergeFGs(fgs,merged_fg_name,saveOut)
% -------------------------------------------------------------------------
% usage: merge fiber groups
%
% INPUT:
%   fgs - cell array of fiber groups, either filepath strings or loaded
%         fiber groups structs. If fiber groups are loaded, fgs can also be
%         a structural array. All fgs must be given in the same format,
%         whether they are loaded or filenames. If fgs elements are
%         filenames, this function will save out the merged_fg to the same
%         directory as fgs{1}.
% 
% OUTPUT:
%   merged_fg - merged fiber group
%
%
% author: Kelly, kelhennigan@gmail.com, 17-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% check to make sure fgs argument is given
if notDefined('fgs')
    error('input fgs argument is required');
end

% if no name is given for the merged_fg, make one up
if notDefined('merged_fg_name')
    merged_fg_name = 'merged_fg';
end

% default is to not save
if notDefined('saveOut')
    saveOut = 0;
end

% if fgs are filenames, load them
if iscell(fgs) && ischar(fgs{1})
    
    % define the directory to save out merged roi (same dir as fgs{1})
    [saveDir,~] = fileparts(fgs{1});
    
    % load them
    if strfind(fgs{1},'.pdb')      % .pdb format
        fgs=cellfun(@(x) mtrImportFibers(x), fgs);
        
    elseif strfind(fgs{1},'.tck')      % mrtrix format
        fgs=cellfun(@(x) dtiImportFibersMrtrix(x), fgs);
        
    else % can add more file formats here if necessary
        
    end
    
end

% if fgs are loaded in a cell array, convert to struct
if iscell(fgs)
    fgs=cell2mat(fgs);
end

% merge fgs
merged_fg = fgs(1);
merged_fg.name = merged_fg_name;
merged_fg.fibers = vertcat(fgs(:).fibers);

% ** add check to make sure pathway Info has same fields!! (NOT YET IMPLEMENTED)
% pI_names = fieldnames(merged_fg.pathwayInfo);


% merge pathwayInfo 
merged_fg.pathwayInfo=[fgs(:).pathwayInfo];

% try to merge params in the future (NOT IMPLEMENTED) 
% for now, ditch them 
merged_fg.params = {};


% save out merged_fg if saveDir is defined
if saveOut
    if ~exist('saveDir','var')
        saveDir = '';
    end
    fprintf(['\nsaving out merged fg ' merged_fg.name '...\n']);
    mtrExportFibers(merged_fg,fullfile(saveDir,merged_fg.name));
    fprintf('done.\n\n');
end




