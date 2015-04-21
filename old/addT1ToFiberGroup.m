%%%%%%%%%%%%%%
%
% add t1 (or t1-weighted) values and variance to .pdb fibers file
%
%%%%%%%%%%%%%%

%% define directories and file names, load files

baseDir = '/home/kelly/data/DTI';
% baseDir = '/home/kelly/data/DTI';

subjects = {'kh001'};
% subjects = {'ak090724','am090121','db061209','er100302',...
% 'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};

%string in fiber file name
% fgFileStr = {'NAcc','Caud','Putamen'};

% % % string in fiber file name
% fgFileStr = {'amygdala','caudalanteriorcingulate','caudalmiddlefrontal',...
%     'frontalpole','hipp','lateralorbitofrontal','medialorbitofrontal','parsopercularis',...
%     'parsorbitalis','parstriangularis','precentral','rostralanteriorcingulate',...
%     'rostralmiddlefrontal','superiorfrontal'};

%% get to it

for i = 1:length(subjects)
    subjDir = fullfile(baseDir, subjects{i});
%     t1Path = fullfile(subjDir, 't1.nii.gz');
%     t1 = readFileNifti(t1Path);
    t1Path = fullfile(subjDir, 't1','rqT1.nii.gz');
    t1 = readFileNifti(t1Path);
    fgDir = fullfile(subjDir, 'fibers', 'conTrack');
    cd(fgDir);
    
    %     for j = 2:length(fgFileStr)
    %         fg_file = dir(['scoredFG_100000_', fgFileStr{j}, '*.pdb']);
    fg_file = 'scoredFG_qt1_NAcc_fs_DA_topৄ.pdb';
    
    %     fg_file = dir(['scoredFG_PFC_', fgFileStr{j}, '*.pdb']);
    %     if (numel(fg_file)==2)
    %         fgPath = fullfile(fgDir, fg_file(2).name);
    %     else
    %         fgPath = fullfile(fgDir, fg_file.name);
    %     end
    %         fg = mtrImportFibers(fgPath);
    fg = mtrImportFibers(fg_file);
    
    for k = 1:length(fg.fibers)
        %             aveScores(k) = fg.params{3}.stat(k);
        %             fgAcpcCoords = round(fg.fibers{k});     % round fiber coordinates
        fgAcpcCoords = fg.fibers{k};
        fgCoords = mrAnatXformCoords(t1.qto_ijk, fgAcpcCoords);  %convert to img coords
        fgCoords = round(fgCoords);
        coordIndx = sub2ind(size(t1.data),fgCoords(:,1), fgCoords(:,2), fgCoords(:,3));  % convert subscripts to an index
        t1Vals = double(t1.data(coordIndx));            % get t1 value at each voxel in the pathway
        meanT1(k) = mean(t1Vals);
        varT1(k) = var(t1Vals);
    end % k = fg.fibers
    
    % get z scores
    %         zaveScores = (aveScores - mean(aveScores))./std(aveScores);
    zmeanT1 = (meanT1 - mean(meanT1))./std(meanT1);
    zvarT1 = (varT1 - mean(varT1))./std(varT1);
    
    meanT1_pnum = numel(fg.params) + 1;
    fg = addFGParam(fg, meanT1_pnum, 'z T1', zmeanT1); % add mean T1 value param
    
    varT1_pnum = numel(fg.params) + 1;
    fg = addFGParam(fg, varT1_pnum, 'z T1 variance', zvarT1); % add T1 variance param
    
    % param with average score, mean t1 value, and var of t1 all
    % included
    % ** make a function to threshold and retain top scoring pathways
    %         % according to this metric**
    %         indScoreT1 = (zaveScores + (zmeanT1 + zvarT1)./-2)./2; % negative 2 so bc we want low mean and var scores
    %         indScoreT1_pnum = numel(fg.params) + 1;
    %         fg = addFGParam(fg, indScoreT1_pnum, 'ave score with T1', indScoreT1); % add score w/T1 measures param
    %
%     strIndx = strfind(fg.name, '.pdb');
%     if isempty(strIndx)
%         outName = [fg.name, '_wT1param.pdb'];
%     else
%         outName = [fg.name(1:strIndx - 1), '_wT1param.pdb'];
%     end
outName = 'scoredFG_qt1_NAcc_fs_DA_wT1param.pdb';
fg.name = outName;
    mtrExportFibers(fg, outName);        % save fibers w/new params added
    
% end % j = fgFiles
end % i = subjects

