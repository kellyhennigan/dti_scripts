function h = plotFDMaps(rgbImg,plane,acpcSlice,saveFig,figDir,figPrefix,subjStr)
% -------------------------------------------------------------------------
% usage: this function handles all the desired formatting specific to
% plotting fiber density overlay images
%
% INPUT:
%   rgbImg - MxNx3 image w/rgb vals in the 3rd dim
% 	plane and acpcSlice are just used for labeling, etc.
%
%   saveFig - 1 to save fig, 0 to just plot. If saveFig=1, then figDir,
%             figPrefix, and subject must be provided, otherwise those
%             aren't necessary.
%
% OUTPUT:
%   hf - figure handle
%
% NOTES:
% h = plotFDMaps(rgbImg,plane,acpcSlice,
% author: Kelly, kelhennigan@gmail.com, 18-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


if notDefined('rgbImg') || size(rgbImg,3) ~=3
    error('must provide rgbImg w/rgb vals in the 3rd dim');
end

if notDefined('plane')
    plane = 0; % don't print any plane info
end

if notDefined('acpcSlice')
    acpcSlice = ''; % don't print any plane info
end

if notDefined('saveFig')
    saveFig = 0; % don't save by default
end

if saveFig
    % if saving figure is desired but figDir not given, save to current directory
    if notDefined('figDir'); figDir = pwd; end
    
    % if saving figure but figPrefix not given, define a 'newfig' string
    if notDefined('figDir'); figPrefix = 'newfig'; end
    
    % same for subject str but make it empty
    if notDefined('subject'); subject =''; end
end


% get string specifying plane
switch plane
    case 1              % sagittal
        planeStr = 'X=';
    case 2              % coronal
        planeStr = 'Y=';
    case 3              % axial
        planeStr = 'Z=';
    otherwise
        planeStr = ''; % don't print plane info
end


scSize = get(0,'ScreenSize'); % get screensize for pleasant viewing :)


%% plot it


h = figure;

pos = get(gcf,'Position');
set(gcf,'Position',[scSize(3)-pos(3), scSize(4)-pos(4), pos(3), pos(4)]) % put the figure in the upper right corner of the screen
image(rgbImg)
axis equal; axis off;
set(gca,'Position',[0,0,1,1]);

% text(size(rgbImg,2)-20,size(rgbImg,1)-20,[planeStr,num2str(acpcSlice)],'color',[1 1 1])



%% save figure?

if saveFig
    
    figName = [figPrefix '_' planeStr num2str(acpcSlice) '_' subjStr];
    
    fprintf(['\n\n saving out fig ' figName '...']);
    
    print(gcf, '-depsc', '-tiff', '-loose', '-r300', '-painters', fullfile(figDir,[figName '.eps']));    
%     saveas(h,fullfile(figDir,figName),'pdf');

    fprintf(['done ' figName '...\n\n']);
    
end



