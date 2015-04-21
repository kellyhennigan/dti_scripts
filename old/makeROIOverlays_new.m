%% overlay ROIs on subjects T1

% set parameters
subject = 'sa10';
roiFNames = {'DA_b0_tensor_clust1_of_3.nii.gz','DA_b0_tensor_clust2_of_3.nii.gz',...
    'DA_b0_tensor_clust3_of_3.nii.gz'};

overlayClipRng = [.01 10];  % range of density values to display for all ROIs
acpcSliceStr = 'Y';  % X is sagittal slice, Y is coronal slice, Z is axial slice
acpcSlice = -20;  % just do one slice at a time for multiple roi display

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

expPaths = getSAPaths(subject);
cd(expPaths.subj);
t1 = readFileNifti('t1.nii.gz');
t1xform = t1.qto_xyz;

cd ROIs

for j = 1:length(roiFNames)
    
    roi = readFileNifti(roiFNames{j});
    roixform = roi.qto_xyz;
    [imgsRgb{j}, overlayMasks{j}, slLabel, numColsRows] = mrAnatOverlayMontage_kh(double(roi.data), roixform, double(t1.data), t1xform,...
        autumn(256), overlayClipRng, acpcSlice, [], plane);
    overlayMasks{j} = overlayMasks{j}(:,:,1);
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

clear t1 t1xform subjDir roiDir imgsRgb overlayMasks newImg
