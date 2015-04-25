% combine fd plots in normed space across subjects


%%

clear all
close all

% define main data directory
dataDir = '/Users/Kelly/dti/data';


% define subjects to process
subjects=getDTISubjects;


% specify directory & files to xform, relative to subject's dir
method = 'mrtrix';


% strings specifying left and right fiber density files
% roiStrsLR = {'naccL','naccR'};
% roiStrsLR = {'caudateL','caudateR'};
roiStrsLR = {'putamenL','putamenR'};
fdStr = '_da_endpts_S3_sn.nii.gz';


% name for outfile once left and right fiber files have been merged
% (comment out or set to zero to not merge)
mergeLR = 1;


outDir = fullfile(dataDir,'group_sn','fg_densities',method);



%% do it


for j = 1:2
    
    cd(dataDir);
    
    
    fd_file = [roiStrsLR{j} fdStr];
    
    
    fprintf(['\n\n Working on fd_file ' fd_file '...']);
    
    % load fiber density files
    FDs=cellfun(@(x) readFileNifti(fullfile(x,'fg_densities',method,fd_file)), subjects);
    
    
    % concatenate data from all subjects
    d = [{FDs(:).data}];
    
    
    % threshold and log-transform data
    d = cellfun(@(x) scaleFiberCounts(x), d, 'UniformOutput',0);
    
    
    % now put overlays into a matrix w/subs in the 4th dim
    d=cell2mat(reshape(d,1,1,1,numel(subjects)));
    
    
    % save out a nifti file w/all subjects' fiber density values
    nii=createNewNii(FDs(1),d,fd_file);
    cd(outDir);   writeFileNifti(nii);
    
    
    fprintf(' done.\n\n');
    
    
end % fd_files


%% now merge left and right files and create a tmap


if ~notDefined('mergeLR') && mergeLR==1
    
    cd(outDir);
    mergedOutName = [roiStrsLR{1}(1:end-1) fdStr]; 
    
    % load newly created left and right fiber density files
    FDs=cellfun(@(x) readFileNifti([x fdStr]), roiStrsLR);
    
    
    % save out merged L R fiber density file
    d = FDs(1).data+FDs(2).data;
    nii=createNewNii(FDs(1),d,mergedOutName);
    writeFileNifti(nii);
    
    
    %  also create and save a t-stat map of fiber densities
    dR=reshape(d,prod(nii.dim(1:3)),[])';
    [~,p,~,stats]=ttest(dR);
    tMap = reshape(stats.tstat,[nii.dim(1:3)]); tMap(isnan(tMap)) = 0;
    nii=createNewNii(FDs(1),tMap,[strrep(strrep(mergedOutName,'.nii',''),'.gz','') '_T.nii.gz']);
    writeFileNifti(nii);
    
end




