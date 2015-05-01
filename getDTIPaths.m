function p = getDTIPaths(subject)
% --------------------------------
% usage: get a structural array containing all relevant paths for project
% dti
%
% INPUT:
%   subject (optional) - subject id string

%
% OUTPUT:
%   p - structural array containing relevant paths
%
%
% author: Kelly, kelhennigan@gmail.com, 09-Nov-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cName=getComputerName;

if strcmp(cName,'psy-jal-ml.stanford.edu') % lab desktop
    baseDir = '/Users/kelly/dti';
elseif strcmp(cName,'mt-tamalpais')        % mt-tam server
    baseDir = '/home/kelly/dti';
elseif strcmp(cName,'cnic2')               % cni server
    baseDir = '/home/hennigan/dti';
else                                       % assume it's moxie
    baseDir = '/Users/Kelly/dti';
end


p = struct();

p.baseDir = baseDir;
p.data = fullfile(p.baseDir, 'data/');
p.figures = fullfile(p.baseDir, 'figures/');
p.scripts = fullfile(p.baseDir, 'scripts/');


% subject directories
if ~notDefined('subject')
    p.subj = fullfile(p.data, subject);             % subject directory
    p.dti_proc   = fullfile(p.subj, 'dti96trilin/');  % processed dti files
    p.fibers   = fullfile(p.subj, 'fibers/');           
    p.fg_densities   = fullfile(p.subj, 'fg_densities/');
    p.raw         = fullfile(p.subj, 'raw_dti/');
    p.ROIs        = fullfile(p.subj, 'ROIs/');
    p.sn        = fullfile(p.subj, 'sn/');          % spatial normalization info
    p.t1          = fullfile(p.subj, 't1/');
end

end


