%% overlay ROIs on subjects T1

% set parameters

overlayClipRng = [.01 10];  % range of density values to display for all ROIs
acpcSliceStr = 'Y';  % X is sagittal slice, Y is coronal slice, Z is axial slice
acpcSlice = [18];  % just do one slice at a time for multiple roi display
saveFigs = 0;  % set to zero to not save new figures
figPrefix = 'gmm'; % prefix for the filenames of saved figures

baseDir = '/home/kelly/data/DTI/';

figDir = fullfile(baseDir, 'ROI_figs');
%
% subjects = {'ak090724'};
%
subjects = {'ak090724','am090121','db061209','er100302','hh100622',...
    'ka040923','ns090526','rb080930','rfd100302','sr090327'};

%ROIs = {'NAcc_fs_null.nii.gz', 'Caudate_fs_null.nii.gz','Putamen_fs_null.nii.gz'};
% ROIs = {'NAcc_fs.nii.gz', 'Caudate_fs.nii.gz','Putamen_fs.nii.gz'};
% ROIs = {'DA.nii.gz'};

colors = getDTIColors();
% % returns rgb values for the following:
% 1) NAcc pathways
% 2) Caudate "
% 3) Putamen "
% 4) Dorsal Tier
% 5) Ventral Tier
% 6) DA ROI


% what the ROI color will be

red_flipped(1,1,:) = colors{1};
yellow_flipped(1,1,:) = colors{2};
blue_flipped(1,1,:) = colors{3};

orange_flipped(1,1,:) = [255 98 0]./255;
violet_flipped(1,1,:) = [136 22 112]./255;
green_flipped(1,1,:) = [94 154 4]./255;


roiColorsFlipped = {violet_flipped; red_flipped; orange_flipped; ...
    yellow_flipped; green_flipped; blue_flipped};

% DA_flipped(1,1,:) = colors{6};
%
% roiColorsFlipped = {DA_flipped};
% roiColorsFlipped = {DA_flipped};

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
    
%     for i = 1:length(subjects)
        for i = 6:10
        subjDir = fullfile(baseDir, subjects{i});
        cd(subjDir);
        t1 = readFileNifti('t1.nii.gz');
        t1xform = t1.qto_xyz;
        roiDir = fullfile(subjDir, 'ROIs');
        cd(roiDir);
        
        for j = 1:6
            fileName = ['Striatum_fs_ind', num2str(j), '_of_6.nii.gz'];
            roi = readFileNifti(fileName);
            
            %         for j = 1:length(ROIs)
            %             roi = readFileNifti(ROIs{j});
            roixform = roi.qto_xyz;
            if (i ~= 6)
                roixform(1,4) = -90;
            end
            %  [imgRgb, overlayMasks] = mrAnatOverlayMontage_kh(overlayImg, xform, anatImg, anatXform, ...
            % cmap, overlayClipRng, acpcSlices, fname, plane, alpha, labelFlag, upsamp, numAcross, clusterThresh, autoCropBorder)
          
%             [imgsRgb{j}, overlayMasks{j}, slLabel, numColsRows] = mrAnatOverlayMontage_kh(double(roi.data), roixform, double(t1.data), t1xform,...
%                 rgb2gray(autumn(256)), overlayClipRng, acpcSlice(k), [], plane);
%             
[imgsRgb{j}, overlayMasks{j}, slLabel, numColsRows] = mrAnatOverlayMontage_kh(double(roi.data), roixform, double(t1.data), t1xform,...
                autumn(256), overlayClipRng, acpcSlice(k), [], plane);
            
            clear roi roixform
        end
        
        %% Combine the rgb images
        
        newImg = imgsRgb{1};
        for m = 1:length(overlayMasks)
            [a b] = find(overlayMasks{m});
            for ab = 1:length(a)
                newImg(a(ab),b(ab),:) = roiColorsFlipped{m};
            end
        end
        
        %% plot all fiber groups and save new figure
        
        figure;
        image(newImg); axis equal; axis off;
        set(gca,'Position',[0,0,1,1]);
        mrUtilLabelMontage(slLabel, numColsRows, gcf, gca);
        if saveFigs==1
            cd(figDir)
            figName = sprintf('%s_%s%d_subj%d', figPrefix, acpcSliceStr, acpcSlice(k), i);
            mrUtilPrintFigure(figName);
        end
        
        clear t1 t1xform subjDir roiDir imgsRgb overlayMasks newImg
    end % subjects
end % acpcSlices