function [fg1, fg2] = getFiberEnds(fgIn)

% this function takes a fiber group and returns the first 3 endpoints as
% fg1 and the last 3 endpoints as fg2

%% define directories and file names, load files

% reorient fibers, get endpts, and get a flipIndx
[fg_endpts, startCoords, endCoords, numFlippedFibers, flipIndx] = dtiReorientFibers_kh(fgIn, 2);
% reorient fibers according to the flipIndx
if (flipIndx ~=0)
    for f = 1:length(flipIndx)
        fgIn.fibers{flipIndx(f)} = fliplr(fgIn.fibers{flipIndx(f)});
    end
end

fg1 = fgIn; % will be first 3 coords
fg2 = fgIn; % will be last 3 coords
for k = 1:length(fgIn.fibers)
    % first 3 endpts
    fg1.fibers{k} = fgIn.fibers{k}(:,1:3);
%     fg1.params{1}.stat(k) = 2.000;     % make length stat = 2.000
%     fg1.pathwayInfo(k).point_stat_array = fgIn.pathwayInfo(k).point_stat_array(:,1:3);
%     % last 3 endpts
    fg2.fibers{k} = fgIn.fibers{k}(:,end-2:end);
%     fg2.params{1}.stat(k) = 2.000;     % make length stat = 2.000
%     fg2.pathwayInfo(k).point_stat_array = fgIn.pathwayInfo(k).point_stat_array(:,end-2:end);
end     % fibers

% name them 
if (startCoords(2) < endCoords(2))
    fg1.name = [fgIn.name,'_DAEnds.pdb']; 
    fg2.name = [fgIn.name, '_StrEnds.pdb'];
else
    fg1.name = [fgIn.name,  '_StrEnds.pdb']; 
    fg2.name = [fgIn.name,  '_DAEnds.pdb'];
end












