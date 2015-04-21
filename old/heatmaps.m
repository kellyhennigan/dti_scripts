%%  get fibers coordinates from .pdb files and use it to create heatmaps

% notes:
% fg.fibers stores an n x 1 cell array storing the coordinates for n fibers
% each cell contains the coordinates for a single fiber; the first and last
% coordinates are that fibers endpoints (though to which of the two seed
% ROIs they belong is random)

%
% mtrImportFibers to import .pdb fibers
% dtiReadFibers to import .mat fibers
%
% mtrExportFibers to export .pdb fiber groups
% dtiWriteFibers to export .mat fiber groups
%
%
% nearpoints function -- read help file
% gives the closest point in array 1 to array 2
% note: distances come out as square root
%
% for Heatmaps:
%
% dtiReorientFibers to make sure the endpoints are correct (eg, correspond to the correct ROI)
%
% dtiComputeFiberDensity (or qqc c c)
% gives you a heat mapped image of the fiber count in each voxel

cd '/home/kelly/data/DTI/am090121/fibers/conTrack';
fg_Caud = mtrImportFibers('DA_Caud_top2.5per_clean.pdb');
fg_NAcc= mtrImportFibers('DA_NAcc_top2.5per_clean.pdb');
fg_Put = mtrImportFibers('DA_Putamen_top2.5per.pdb');

%% since all the DA ROI z coords are -17 < zcoord < -7, use this to
% reorient fibers

caudFlipIndx = nan;
for c = 1:length(fg_Caud.fibers)
    if fg_Caud.fibers{c}(3,1) > -5  % if z coordinate of first endpt isnt in the range of the DA roi
        caudFlipIndx(end+1) = c;
        fg_Caud.fibers{c} = fliplr(fg_Caud.fibers{c});   % flip the fiber coordinates
        
    end
end


naccFlipIndx = nan;
for c = 1:length(fg_NAcc.fibers)
    if fg_NAcc.fibers{c}(3,1) > -5  % if z coordinate of first endpt isnt in the range of the DA roi
        naccFlipIndx(end+1) = c;
        fg_NAcc.fibers{c} = fliplr(fg_NAcc.fibers{c});   % flip the fiber coordinates
        
    end
end


putFlipIndx = nan;
for c = 1:length(fg_Put.fibers)
    if fg_Put.fibers{c}(3,1) > -5  % if z coordinate of first endpt isnt in the range of the DA roi
        putFlipIndx(end+1) = c;
        fg_Put.fibers{c} = fliplr(fg_Put.fibers{c});   % flip the fiber coordinates
    end
end

%% use dtiReorientFibers (or qqccc) to reorient endpts to the correct ROI
%
% % gives reoriented fiber groups all tracking from DA ROI > Striatum
% [fg_Caud_reoriented, caud_startCoords, caud_endCoords]=dtiReorientFibers(fg_Caud);
% [fg_NAcc_reoriented, nacc_startCoords, nacc_endCoords]=dtiReorientFibers(fg_NAcc);
% [fg_Put_reoriented, put_startCoords, put_endCoords]=dtiReorientFibers(fg_Put);
%
% % reassign fiber groups to their reoriented version
% fg_Caud = fg_Caud_reoriented;
% fg_NAcc = fg_NAcc_reoriented;
% fg_Put = fg_Put_reoriented;


%% combine Caudate, NAcc, and Putamen fiber groups

fg_striatum = fg_Put;   % use the other fiber groups general structure/some values
fg_striatum.name = 'DA_CaudNAccPut_top2.5per_clean';
fg_striatum.fibers = [fg_Caud.fibers; fg_NAcc.fibers; fg_Put.fibers;];
fg_striatum.pathwayInfo = [fg_Caud.pathwayInfo,fg_NAcc.pathwayInfo, fg_Put.pathwayInfo];

for h = 1:length(fg_striatum.params)
    fg_striatum.params{h}.stat = [fg_Caud.params{h}.stat, fg_NAcc.params{h}.stat, fg_Put.params{h}.stat];
end

%% create an array that contains only the coordinate of the fibers' striatum endpt

striatumEndpts = [];

for i = 1:length(fg_striatum.fibers)
    endptIndx = length(fg_striatum.fibers{i});
    striatumEndpts(:,i) = fg_striatum.fibers{i}(:,endptIndx);
    
end

%% which are right/left fibers?

rStrIndx = find(striatumEndpts(1,:) > 0); % rt if x-coord is greater than 0
lStrIndx = find(striatumEndpts(1,:) <= 0); % lft if x-coord is less than 0


%% Define points along subject's internal capsule

% intCapL = [-18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7; 6 6 6 6 6 6 6 6 6 6 6 6; 18 16 14 12 10 8 6 4 2 0 -2 -4];
% intCapR = [20 19 18 17 16 15 14 13 12 11 10 9; 6 6 6 6 6 6 6 6 6 6 6 6; 18 16 14 12 10 8 6 4 2 0 -2 -4];

intCapL = [-18 -16 -14 -12 -10 -8; 6 6 6 6 6 6; 18 14 10 6 2 -2];
intCapR = [20 18 16 14 12 10; 6 6 6 6 6 6; 18 14 10 6 2 -2];

%% use nearpoints function to find nearest neighbor

[indicesL, bestSqDistL] = nearpoints(striatumEndpts, intCapL);
[indicesR, bestSqDistR] = nearpoints(striatumEndpts, intCapR);

% set index to zero if on the other side
indicesL(rStrIndx) = 0;
indicesR(lStrIndx) = 0;

% combine the left and right indices
binIndx = zeros(1,length(indicesL)); % vector of zeros the length of L & R indices
binIndx(lStrIndx) = indicesL(lStrIndx);
binIndx(rStrIndx) = indicesR(rStrIndx);


%% save each bin (index entry) as new fiber group
% there's got to be a better way to do this...

fiberGroups = {};

for i = 1:length(intCapL)
    fiberGroups{i} = fg_striatum;   % use the other fiber groups general structure/some values
    fiberGroups{i}.name = ['DA_CaudNAccPut_top2.5per_clean_ind', num2str(i),'.pdb'];
    fiberIndx = find(binIndx==i);
    if isempty(fiberIndx)
        fprintf('\nno fibers for bin %d\n', i);
    else
        fiberGroups{i}.fibers = fg_striatum.fibers(fiberIndx);
        fiberGroups{i}.pathwayInfo = fg_striatum.pathwayInfo(fiberIndx);
        for h = 1:length(fg_striatum.params)
            fiberGroups{i}.params{h}.stat = fg_striatum.params{h}.stat(fiberIndx);
        end
        mtrExportFibers(fiberGroups{i}, fiberGroups{i}.name);
    end
end    
    
    %% dtiComputeFiberDensity
    
    
    cd '/home/kelly/data/DTI/ak090724/';
    [dt,t1] = dtiLoadDt6('dti06trilin/dt6.mat');
    
    % function [fdImg] = dtiComputeFiberDensityNoGUI(fiberGroups, xformImgToAcpc,...
    %     imSize, normalize, fiberGroupNum, endptFlag, fgCountFlag, weightVec, weightBins);
    
    % gives a heatmapped image of the fiber count in each voxel
    
    % Input
    %   fiberGroups: an array of fiber groups
    %   xformToAcpc: transformation matrix for img to acpc, i.e. dt.xformToAcpc
    %   imSize: i.e. size(dt.b0)
    %   normalize: 1 if you want fiber density normalized to one, 0 for fiber
    %       counts. Default is fiber counts.
    %   fiberGroupNum: list (vector) of indices pointing to the array elements in the
    %                  fiberGroups for fg(s) whose density you want to compute.
    %                  E.g.: if fiberGroups array contains 10 fiber groups and
    %                  you want to look at first two, use fiberGroupNum=[1 2].
    %   endptFlag: 1 if you'd just like to use fiber endpoints
    %   fgCountFlag: 1 if you input >1 FG and you'd like the function to return
    %       the number of fiber groups passing through each voxel
    %   weightVec: ??
    %   weightBins: column 1 is lower bound, column 2 is upper bound, creates a
    %       density image for each weight bin based on weightVec value for each
    %       fiber, ignores weights that are not within the bins.
    %
    
    % Example:
    % [dt,t1] = dtiLoadDt6('dti30/dt6');
    % fg = dtiReadFibers('dti30/fibers/someFibers.mat');
    % fd =  dtiComputeFiberDensityNoGUI(fg, dt.xformToAcpc, size(dt.b0), 1, 1);
    % fdT1 = mrAnatOverlayMontage(fd, dt.xformToAcpc, double(t1.img), t1.xformToAcpc, autumn(256), [1 10], [-20:2:50]);
    % fdB0 = mrAnatOverlayMontage(fd, dt.xformToAcpc,
    % mrAnatHistogramClip(double(dt.b0),.4,.98), dt.xformToAcpc, autumn(256),
    % [1 10], [-20:2:50]);
    
    fiberGroupNum = [1 2 3 4 5 6];
    
    fd = dtiComputeFiberDensityNoGUI_kh(fiberGroups, dt.xformToAcpc, size(dt.b0),...
        0, fiberGroupNum, 1, 0);
    
    fdT1 = mrAnatOverlayMontage(fd, dt.xformToAcpc, double(t1.img), t1.xformToAcpc, autumn(256), [1 10], [-20:2:50]);
    
    [dt, t1] = dtiLoadDt6('dt6.mat');
    cd '../fibers/conTrack/';
    fg = mtrImportFibers('DA_Putamen_top2.5per.pdb');
    fd = dtiComputeFiberDensityNoGUI(fg, dt.xformToAcpc, size(dt.b0), 0, 1);
    fdT1 = mrAnatOverlayMontage(fd, dt.xformToAcpc, double(t1.img), t1.xformToAcpc, autumn(256), [1 10], [-20:2:50]);
    
    % % To save the fiber density map in a NIFTI file:
    dtiWriteNiftiWrapper(single(fd./max(fd(:))),dt.xformToAcpc,'someFibers');
    
