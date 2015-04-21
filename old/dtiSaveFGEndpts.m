% save FG DA endpoints

% plots fiber group endpoints as 3d ellipsoids normalized to the first
% fiber group given

%% files, subjects, etc.

clear all
close all

FG_fnames = {'scoredFG__caudate_DA_top2500_clean.pdb',...
    'scoredFG__nacc_DA_top2500_clean.pdb',...
    'scoredFG__putamen_DA_top2500_clean.pdb'};

nNodes = [32 16 32];

subjects = getSASubjects('dti');


%% get FGs

rFGs = struct();
lFGs = struct();

for i = 1:numel(subjects)
    % i=1;
    
    subject = subjects{i};
    expPaths = getSAPaths(subject);
    
    fprintf(['\n\nworking on subject ',subject,'\n\n']);
    
    rFGs(i).subject = subject;
    lFGs(i).subject = subject;
    
    cd(expPaths.fibers); cd conTrack;
    
    for j = 1:length(FG_fnames)                % load fibers
        %     j=1
        fg = mtrImportFibers(FG_fnames{j});
        
        rFGs(i).fgFile{j} = FG_fnames{j};
        lFGs(i).fgFile{j} = FG_fnames{j};
        
        % get index for fibers on right side
        for c = 1:length(fg.fibers)
            rIndx(c) = fg.fibers{c}(1,1) >= 0;
        end
        
        if (i==4)
            if (j==1 || j==3)
                rIndx = ~rIndx;
            end
        end
        
        % reorient, get superfiber, get DA endpts
        r_fg = getSubFG(fg, rIndx);
        [rSuperFiber, rSFg] = dtiComputeSuperFiberRepresentation(r_fg, [], nNodes(j));
        [rSFg, da_endpts] = getDAEndpoints(rSFg);
        rFGs(i).da_endpts{j} = da_endpts';
        
         if (i==4)
            if (j==1 || j==3)
                rIndx = ~rIndx;
            end
         end
        
        % reorient, get superfiber, get DA endpts
        l_fg = getSubFG(fg, ~rIndx);
        [lSuperFiber, lSFg] = dtiComputeSuperFiberRepresentation(l_fg, [], nNodes(j));
        [lSFg, da_endpts] = getDAEndpoints(lSFg);
        lFGs(i).da_endpts{j} = da_endpts';
        
        clear fg rIndx
        
    end % fgs
    
end % subjects
    
 cd(expPaths.baseDir); cd FGs
 
 save('rFGs_da_endpts.mat','rFGs')
 save('lFGs_da_endpts.mat','lFGs')
 
 
