%% Parse striatum into X new ROIs according to nearpoints function roughly
% along the internal capsule axis

% here's the general procedure:

% - take the absolute value of x coordinates to collapse over right & left
% sides of the ROI
% - define an axis similar to the internal capsule and define evenly spaced
% points along it
% - use nearest neighbor function on the points to define N new Rois
% - save new Rois as separate files

% kjh 9/2011

%% Define base directory, subject folders, freesurfer labels, and Roi names

clear all

% define number of resulting ROIs
nRois = 6;

subjects = {'sa22'};

roiFName = 'striatum.mat';

%%

i = 1;
expPaths = getSAPaths(subjects{i});
cd(expPaths.ROIs)
load(roiFName);

absXcoords = roi.coords;
absXcoords(:,1) = abs(absXcoords(:,1)); % use the absolute value of x coordinates

xRange = linspace(0,max(absXcoords(:,1)),4); % use middle half range of xcoords
xVals = linspace(xRange(2),xRange(3),nRois);

zVals = linspace(min(absXcoords(:,3)),max(absXcoords(:,3)),nRois+5); %
zVals = zVals(3:nRois+2);

yVals = zeros(1,nRois); % zero for y-coordinate is in the same coronal plane as the anterior commissure

axisPoints = [xVals; yVals; zVals];

[roiIndx] = nearpoints(absXcoords',axisPoints);

%% save each bin (index entry) as new Roi


for j = 1:nRois
    outRoi = roi;
    outRoi.name = [roi.name, '_ind', num2str(j), '_of_', num2str(nRois)];
    outRoi.coords = outRoi.coords(roiIndx==j,:);
    if isempty(outRoi.coords)
        fprintf('\n no voxels for bin %d\n', j);
    else
        fprintf(['\nroi ',num2str(j),' contains ',num2str(length(outRoi.coords)),' voxels, which is ',...
            num2str(round(100.*(length(outRoi.coords)./length(roiIndx)))),...
            ' percent of striatal voxels\n\n']);
        dtiWriteRoi(outRoi,[outRoi.name,'.mat']);
    end
end
fprintf('\n done with subject %s \n\n', subjects{i});
