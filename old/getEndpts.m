%% define directories and file names, load files

subjects = {'ak090724','am090121','db061209','er100302',...
'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};

% subjects = {'ak090724','am090121','db061209','er100302',...
%     'ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};
% subjects = {'er100302'};
% subjects = {'ak090724','er100302'};

baseDir = '/home/kelly/data/DTI';

fiberFiles = {'gmm_1_of_2_clusters_30_70.pdb','gmm_2_of_2_clusters_30_70.pdb','gmm_uncertain_cluster_30_70.pdb'};

for i = 1:length(subjects) % for each subject
    subjDir = fullfile(baseDir, subjects{i});
    fibersDir = fullfile(subjDir, 'fibers', 'conTrack');
    
    % load and reorient fibers (reorient function retains only endpts)
    for j = 1:length(fiberFiles)
        cd(fibersDir);
        fg = mtrImportFibers(fiberFiles{j});
        new_fg = fg;
        % reorient fibers, get endpts, and get a flipIndx
        [new_fg_endpts, startC,endC, numFlippedFibers, flipIndx] = dtiReorientFibers_kh(fg, 2);
        % reorient fibers according to the flipIndx
        for f = 1:length(flipIndx)
            new_fg.fibers{flipIndx(f)} = fliplr(new_fg.fibers{flipIndx(f)});
        end
        new_fg_last = new_fg;
        for k = 1:length(new_fg.fibers)
            % first 3 endpts
            new_fg.fibers{k} = new_fg.fibers{k}(:,1:3);
            new_fg.params{1}.stat(k) = 2.000;     % make length stat = 2.000
            new_fg.pathwayInfo(k).point_stat_array = fg.pathwayInfo(k).point_stat_array(:,1:3);
            % last 3 endpts
            new_fg_last.fibers{k} = new_fg_last.fibers{k}(:,end-2:end);
            new_fg_last.params{1}.stat(k) = 2.000;     % make length stat = 2.000
            new_fg_last.pathwayInfo(k).point_stat_array = new_fg_last.pathwayInfo(k).point_stat_array(:,end-2:end);
%             xs(k) = new_fg.fibers{k}(1,1);
%             ys(k) = new_fg.fibers{k}(2,1);
%             zs(k) = new_fg.fibers{k}(3,1);
%             xs_last(k) = new_fg_last.fibers{k}(1,end);
%             ys_last(k) = new_fg_last.fibers{k}(2,end);
%             zs_last(k) = new_fg_last.fibers{k}(3,end);  
%              
        end     % fibers
        
%                  % take out wrong endpts
%              % ak: -8; am: -5; db: > -7/ < -10; er: 
%              r = 1;
%              r2 = 1;
%        for h = 1:length(new_fg.fibers)
%            if new_fg.fibers{h}(3,1) > -5
%                remIndx(r) = h;
%                r = r+1;
%            end
%            if new_fg_last.fibers{h}(3,end) < -10
%              remIndx2(r2) = h;
%              r2 = r2 + 1;
%            end
%        end
%            
 
%             %% remove erroneous endpts
%             new_fg.fibers(remIndx) = [];
%             new_fg.pathwayInfo(remIndx) = [];
%             new_fg_last.fibers(remIndx2) = [];
%             new_fg_last.pathwayInfo(remIndx2) = [];
%             for m = 1:4
%                 new_fg.params{m}.stat(remIndx) = [];
%                 new_fg_last.params{m}.stat(remIndx2) = [];
%             end
% %         
        strIndx = strfind(fiberFiles{j},'.pdb');
        baseOutName = fiberFiles{j}(1:strIndx-1);
        outName = strcat(baseOutName, 'endpts_first.pdb');
         outName_last = strcat(baseOutName, 'endpts_last.pdb');

        % save new files
        mtrExportFibers(new_fg, outName);
        mtrExportFibers(new_fg_last, outName_last);

        clear fg new_fg new_fg_last new_fg_endpts strIndx baseOutName outName outName_last remIndx remIndx2 r r2 
        
    end     % fiberFiles
    
end     % subjects











