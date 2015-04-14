%% Make fiber density maps

%% define directories and file names, load files

dataDir = '/Users/Kelly/dti/data';

subjects = getDTISubjects();
subjects = {'sa01'};


method = 'conTrack';
fiberFiles = {'caudateR_autoclean.pdb'};

outFGNames = {'caudateR_fd'};




%% get to it

cd(dataDir);

i=1
for i = 1:length(subjects) % for each subject
    
    
    fprintf(['\n\n Working on subject ',subjects{i},'...\n\n']);
   
    fdDir = fullfile(dataDir,subjects{i}, 'fd',method);
    if (~exist(fdDir, 'dir'))
        mkdir(fdDir)
    end
    
    [dt,t1] = dtiLoadDt6(fullfile(subjects{i},'dti96trilin','dt6.mat'));
    
    for j = 1:length(fiberFiles)    % load and reorient fibers (reorient function retains only endpts)
       
        fg = mtrImportFibers(fullfile(subjects{i},'fibers',method,fiberFiles{j}));
        fg_da_endpts = cellfun(@(x) x(
        len=cellfun(@(x) length(x), fg.fibers)
        
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
    





















