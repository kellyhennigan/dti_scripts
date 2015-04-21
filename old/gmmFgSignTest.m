%% sign test to see if the two fiber clusters defined by the gmm 
%% switch their relative position along the inferior-superior axis (z-coord)

%% define directories and file names, load files

subjects = {'ak090724','am090121','db061209','er100302','hh100622','ka040923','ns090526' ,'rb080930','rfd100302','sr090327'};
% subjects = {'ak090724'};

baseDir = '/home/kelly/data/DTI';

fiberFiles = {'gmm_1_of_2_clusters.pdb','gmm_2_of_2_clusters.pdb'};
fiberFiles2 = {'gmm_2_of_2_clusters.pdb','gmm_1_of_2_clusters.pdb'};

vFirstSubs = [2 5 6 7 8]; % subjects with ventral tier as first group

%% get to it

z_flip = nan(1,length(subjects));

for i = 1:length(subjects) % for each subject    
    subjDir = fullfile(baseDir, subjects{i});
    fibersDir = fullfile(subjDir, 'fibers', 'conTrack');
    cd(fibersDir);
    
    for j = 1:length(fiberFiles)                % load fibers
        if (ismember(i, vFirstSubs))
          fg = mtrImportFibers(fiberFiles2{j});
        else
        fg = mtrImportFibers(fiberFiles{j});
        end
        [fg, da_endpts, str_endpts] = getDAEndpoints(fg);   
        da_endpts(1,:) = abs(da_endpts(1,:));
        str_endpts(1,:) = abs(str_endpts(1,:));
        clusterStrMeans{j}(:,i) = mean(str_endpts,2);
       
        % x-coords
        xDA{j} = da_endpts(1,:);
        mean_xDA{i}(j) = mean(xDA{j});
        xStr{j} = str_endpts(1,:);
        mean_xStr{i}(j) = mean(xStr{j});
        
        % y-coords
        yDA{j} = da_endpts(2,:);
        mean_yDA{i}(j) = mean(yDA{j});
         yStr{j} = str_endpts(2,:);
        mean_yStr{i}(j) = mean(yStr{j});
        
        % z-coords
        zDA{j} = da_endpts(3,:);
        mean_zDA{i}(j) = mean(zDA{j});
        zStr{j} = str_endpts(3,:);
        mean_zStr{i}(j) = mean(zStr{j});
        
        clear da_endpts str_endpts
    end
 
    if ((mean_zDA{i}(1) > mean_zDA{i}(2)) && (mean_zStr{i}(1) <= mean_zStr{i}(2)))
        z_flip(i) = 1;
    elseif ((mean_zDA{i}(1) < mean_zDA{i}(2)) && (mean_zStr{i}(1) >= mean_zStr{i}(2)))
        z_flip(i) = 1;
    else 
        z_flip(i) = 0;
    end
    
   % within subject t-tests of cluster 1 vs cluster 2 x,y,z coords
    [h_xDA(i),p_xDA(i)] = ttest2(xDA{1},xDA{2});  
    [h_xStr(i),p_xStr(i)] = ttest2(xStr{1},xStr{2});   
    
     [h_yDA(i),p_yDA(i)] = ttest2(yDA{1},yDA{2});   
     [h_yStr(i),p_yStr(i)] = ttest2(yStr{1},yStr{2});
     
    % within subject t-tests of cluster 1 vs cluster 2 z-coord endpoints
    [h_zDA(i),p_zDA(i)] = ttest2(zDA{1},zDA{2});   % DA z-coords
    [h_zStr(i),p_zStr(i)] = ttest2(zStr{1},zStr{2});   % Str z-coords
    

    clear zDA zStr yDA yStr xDA xStr
  
end  % subjects

% across subjects sign-tests of fiber clusters' endpoint z-coords
[pz, hz] = signtest(z_flip); 


% plotMeanFGCoords(meanCoords, seCoords);
% 

