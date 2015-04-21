%% Make fiber density maps

%% define directories and file names, load files

% subjects = getSASubjects('dti');
subjects = {'sa28'};

fiberFiles = {'scoredFG__caudate_DA_top2500_clean.pdb',...
    'scoredFG__nacc_DA_top2500_clean.pdb','scoredFG__putamen_DA_top2500_clean.pdb'};

outFGNames = {'caudate_endpts','nacc_endpts','putamen_endpts'};
% outFGNames = {'caudate_DAendpts','nacc_DAendpts','putamen_DAendpts'};

% some options
saveAsStruct = 0;   % save all data in a matlab structural array?
smooth = 0;         % smoothing kernel size (if set to zero than no smoothing)
halfmm_res = 0;     % resample at half mm res?
smooth_halfmm = 0;  % " " for halfmm (use something like .5)


%% save all data in a structural array?
if (saveAsStruct == 1)
    fdStruct = struct('subj', {},...
        'fiberFiles', {},...
        'fdGroups', {});
end

%% get to it

for i = 1:length(subjects) % for each subject
    subject = subjects{i};
    expPaths = getSAPaths(subject);
    fprintf(['\n\n Working on subject ',subject,'...\n\n']);
    dt6 = fullfile(expPaths.dti96trilin,'dt6.mat');
    fdDir = fullfile(expPaths.fibers, 'fg_densities');
    if (~exist(fdDir, 'dir'))
        mkdir(fdDir)
    end
    [dt, t1] = dtiLoadDt6(dt6);  % load dt6.mat and t1
    
    for j = 1:length(fiberFiles)    % load and reorient fibers (reorient function retains only endpts)
       
        cd(expPaths.fibers); cd conTrack;
        fiberGroups(j) = mtrImportFibers(fiberFiles{j});
        [~,~,fiberGroups(j),~] = getDAEndpoints(fiberGroups(j));
%          [fiberGroups(j),~,~,~] = getDAEndpoints(fiberGroups(j));
           
        % make fiber density maps
        fdGroups{j} =  dtiComputeFiberDensityNoGUI(fiberGroups, dt.xformToAcpc, size(dt.b0),1,j,1);
        
        % save new fiber density file
        cd(fdDir);

        outName = [outFGNames{j}, '_fd.nii.gz'];
         dtiWriteNiftiWrapper(fdGroups{j}, dt.xformToAcpc, outName);
        
        if (smooth ~= 0)        % smooth w/kernel defined by "smooth" variable
            fdGroups_smoothed{j} = smooth3(fdGroups{j},'gaussian',smooth);
            outName_smooth = [outFGNames{j}, '_fd_S', num2str(smooth),'.nii.gz'];
            dtiWriteNiftiWrapper(fdGroups_smoothed{j}, dt.xformToAcpc, outName_smooth);
        end
        
        if (halfmm_res == 1)    % reslice fiber density images to .5mm isotropic res
            [fdGroups_halfmm{j}, fd_halfmm_xform] = mrAnatResliceSpm(fdGroups{j}, inv(dt.xformToAcpc),[], [.5 .5 .5], [1 1 1 0 0 0]);
            outName_halfmm = [outFGNames{j}, '_fd_halfmm.nii.gz'];
            dtiWriteNiftiWrapper(fdGroups_halfmm{j}, fd_halfmm_xform, outName_halfmm);
        end
        
        if (smooth_halfmm ~= 0) % smooth w/kernel defined by "smooth_halfmm" variable
            fdGroups_halfmm_smoothed{j} = smooth3(fdGroups_halfmm{j},'gaussian',[smooth_halfmm smooth_halfmm smooth_halfmm]);
            outName_halfmm_smooth = [outFGNames{j}, '_fd_halfmm_S', num2str(smooth_halfmm),'.nii.gz'];
            dtiWriteNiftiWrapper(fdGroups_halfmm_smoothed{j}, fd_halfmm_xform, outName_halfmm_smooth);
        end
        
        clear outName
        
        % put subject specific data into fd struct()
        if (saveAsStruct==1)
            fdStruct(i).subj = subjects{i};
            fdStruct(i).fiberFiles = fiberFiles;
            fdStruct(i).fdGroups = fdGroups;
            %     fdStruct(i).fdGroups_smooth = fdGroups_smooth;
            %     fdStruct(i).fdGroups_halfmm = fdGroups_halfmm;
            %     fdStruct(i).fdGroups_halfmm_smooth = fdGroups_halfmm_smooth;
        end
        
    end % fiberFiles
    
    fprintf(['done.\n\n']);
    
end % subjects

if (saveAsStruct == 1)
    outMatFile = 'fdStruct.mat';
    cd(baseDir);
    save(outMatFile, 'fdStruct');
end
    





















