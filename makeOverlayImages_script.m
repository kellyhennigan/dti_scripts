%% overlay fiber densities onto subject's T1

subjects = getSASubjects('dti');
subjects = {'sa26'};
% set parameters for fiber density images

% clip range is for log() values; assuming values in fg file are
% normalized to 1; normalize them to 100 then take the log,
% bc log(5+1) = 1.7918, clipping at that value means only voxels
% containing more than 5% of the fiber group's voxels will be
% displayed; log(15+1) = 2.7726, so these values are for 5-15% of all the
% fibers in a fiber group/vox
            
overlayClipRng = [1.79 2.7726];  % range of density values to display for all fgs
acpcSliceStr = 'Y';         % X for sagittal, Y for coronal, Z for axial slice
acpcSlice = [-18];   % set the coordinate for the slice
halfmm_res = 1;             % set to 1 to use halfmm resolution files
saveFigs = 0;               % set to zero to not save new figures
figPrefix = 'null_rois';         % prefix for the filenames of saved figures

baseDir = '/Users/Kelly/ShockAwe/';
figDir = fullfile(baseDir,'figs','CNP_fd');
if (~exist(figDir, 'dir'))
    mkdir(figDir)
end

FGs = {'caudate_DAendpts_fd_halfmm_S5.nii.gz','nacc_DAendpts_fd_halfmm_S5.nii.gz',...
    'putamen_DAendpts_fd_halfmm_S5.nii.gz'};


% FGs = {'caudate_DAendpts_fd.nii.gz','nacc_DAendpts_fd.nii.gz',...
%     'putamen_DAendpts_fd.nii.gz'};


colors = getFDColors();

% specify plane
if strcmpi(acpcSliceStr, 'X')
    plane = 1;
elseif strcmpi(acpcSliceStr, 'Y')
    plane = 2;
elseif strcmpi(acpcSliceStr, 'Z')
    plane = 3;
else
    fprintf('/n need to specify slice orientation /n');
end


%% make overlay images for each fiber group

for k = 1:length(acpcSlice)
    
    for i = 1:length(subjects)
        
        subject = subjects{i};
        expPaths = getSAPaths(subject);
        
        cd(expPaths.subj);
        if (halfmm_res == 1)
            t1 = readFileNifti('t1/t1_halfmm.nii.gz');
        else
            t1 = readFileNifti('t1.nii.gz');
        end
        t1xform = t1.qto_xyz;
        
        cd(expPaths.fibers); cd fg_densities;
        
        for j = 1:length(FGs)
            
            fg = readFileNifti(FGs{j});
          
            fg.data = fg.data * 100;
            fg.data = log(fg.data+1);
            fgxform = fg.qto_xyz;
            
            %  [imgRgb, overlayMasks] = mrAnatOverlayMontage_kh(overlayImg, xform, anatImg, anatXform, ...
            % cmap, overlayClipRng, acpcSlices, fname, plane, alpha, labelFlag, upsamp, numAcross, clusterThresh, autoCropBorder)
            [imgsRgb{j}, overlayMasks{j}, slLabel, numColsRows] = mrAnatOverlayMontage_kh(fg.data, fgxform, double(t1.data), t1xform,...
                colors{j}, overlayClipRng, acpcSlice(k), [], plane);
            allImgsRgb(:,:,:,j) = overlayMasks{j}.*imgsRgb{j};
            clear fg fgxform
        end
        
        %% Combine the rgb images
        
        allImgsRgb(allImgsRgb==0)=nan;
        overlapImg = nanmean(allImgsRgb,4);
        fdIndx = find(~isnan(overlapImg));
        
        newImg = imgsRgb{1};
        newImg(fdIndx) = overlapImg(fdIndx);
        
        %% plot all fiber groups and save new figure
        
        figure
        image(newImg); axis equal; axis off;
        set(gca,'Position',[0,0,1,1]);
        mrUtilLabelMontage(slLabel, numColsRows, gcf, gca);
        if saveFigs==1
            cd(figDir)
            figName = [figPrefix,'_',acpcSliceStr,num2str(acpcSlice(k)),'_',subject];
            mrUtilPrintFigure(figName);
        end
        
        clear t1 t1xform subjDir fdDir imgsRgb overlayMasks newImg allImgsRgb
        
    end % subjects
    
end % acpcSlices

