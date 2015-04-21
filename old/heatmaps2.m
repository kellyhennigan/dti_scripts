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

%cd '/home/kelly/data/DTI/am090121/fibers/conTrack';
cd '/home/kelly/data/DTI/ak090724/fibers/conTrack';

%% Import DA/Striatum fibers generated 
fg_striatum = mtrImportFibers('DA_Striatum_top2.5per_clean.pdb');

%%  get coordinates

DAEndpts =[];       %  coordinates for fiber endpoint in DA ROI 
StrEndpts = [];     %  " " in Striatum ROI

for f = 1:length(fg_striatum.fibers)
    DAEndpts(:,f) = fg_striatum.fibers{f}(:,1);
    StrEndpts(:,f) = fg_striatum.fibers{f}(:,end);
end

%% make some plots

mycolors = [255 0 51;  9 68 242; 247 101 2; 50 163 181;]./255;

figure(1);
s = scatter(abs(DAEndpts(1,:)), abs(StrEndpts(1,:)),[],mycolors(2,:));
xlabel('DA endpoint (medial - lateral)')
ylabel('Striatum endpoint (medial - lateral)')
title('X-coordinates of fiber endpoints (absolute values)');

figure(2);
s = scatter(DAEndpts(3,:), StrEndpts(3,:),[],mycolors(3,:));
% xlim([0.5 10.5])
% ylim([-2 2.5])
%set(gca,'XTick',1:1:10)
%set(gca,'XTickLabel',{'In lab','1','2','3','4','5','6','7','8','9'})
xlabel('DA endpoint (ventral - dorsal)')
ylabel('Striatum endpoint (ventral - dorsal)')
title('Z-coordinates of fiber endpoints');

% assign dorsal and ventral endpoints within Striatum ROI to diff groups

dStrIndex = find(StrEndpts(3,:) >= 10);
vStrIndex = find(StrEndpts(3,:) < 10);

figure(3);
s = scatter(DAEndpts(3,dStrIndex), StrEndpts(3,dStrIndex),[],mycolors(3,:));
hold on;
scatter(DAEndpts(3,vStrIndex), StrEndpts(3,vStrIndex),[],mycolors(2,:));
% xlim([0.5 10.5])
% ylim([-2 2.5])
%set(gca,'XTick',1:1:10)
%set(gca,'XTickLabel',{'In lab','1','2','3','4','5','6','7','8','9'})
xlabel('DA endpoint (ventral - dorsal)')
ylabel('Striatum endpoint (ventral - dorsal)')
title('Z-coordinates of fiber endpoints');



