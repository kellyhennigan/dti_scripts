function combineFGs()
%% Combine fiber groups

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% load fibers and combine to make one striatum ROI; export striatum fibers

for i = 1:length(subjects) % for each subject
    subjDir = fullfile(baseDir, subjects{i});
    fibersDir = fullfile(subjDir, 'fibers', 'conTrack');
    cd(fibersDir);
%       for j = 1:length(FGs)
%         strFGs(j) = mtrImportFibers(FGs{j});
%         strFGs(j).fibers = strFGs(j).fibers';  % flip cell array from row to column array to make it easier to concatanate all of them
%         strFGs_endpts(j) = dtiReorientFibers(strFGs(j),2); % reorient fibers (keeps only endpts)
%         strFGs_endpts(j).fibers = strFGs_endpts(j).fibers'; % flip cell array from row to column array to make it easier to concatanate all of them
%     end
    for j = 1:6
        fname = ['scoredFG_strROIs_Striatum_fs_ind' num2str(j) '_of_6_DA_top2000_clean.pdb'];
        strFGs(j) = mtrImportFibers(fname);
        strFGs(j).fibers = strFGs(j).fibers';  % flip cell array from row to column array to make it easier to concatanate all of them
        strFGs_endpts(j) = dtiReorientFibers(strFGs(j),2); % reorient fibers (keeps only endpts)
        strFGs_endpts(j).fibers = strFGs_endpts(j).fibers'; % flip cell array from row to column array to make it easier to concatanate all of them
    end
    
    % combine all fiber groups into one striatum fiber group
    fg_striatum = strFGs(1);   % use the other fiber groups general structure/some values
    fg_striatum.name = 'scoredFG_strROIs_all.pdb';
    fg_striatum.fibers = [strFGs(:).fibers];
    fg_striatum.fibers = fg_striatum.fibers'; % flip cell array back to original orientation
    fg_striatum.pathwayInfo = [strFGs(:).pathwayInfo];
    for k = 1:length(fg_striatum.params)
        fg_striatum.params{k}.stat = [strFGs(1).params{k}.stat strFGs(2).params{k}.stat strFGs(3).params{k}.stat ...
            strFGs(4).params{k}.stat strFGs(5).params{k}.stat strFGs(6).params{k}.stat];
    end
%  for k = 1:length(fg_striatum.params)
%         fg_striatum.params{k}.stat = [strFGs(1).params{k}.stat strFGs(2).params{k}.stat strFGs(3).params{k}.stat];
%     end
    % save striatum fiber group
    fprintf('\nsaving striatum fibers for %s...\n',subjects{i});
    mtrExportFibers(fg_striatum, fg_striatum.name);
%     clear strFGs fg_striatum
end