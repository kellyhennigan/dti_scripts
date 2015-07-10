
function fig = plotCorr(x,y,xlab,ylab,titleStr)
% -------------------------------------------------------------------------
% usage: function to nicely plot a correlation. that't it. 
% 
% INPUT:
%   x - var1
%   y - var2
%   xlab - label for x-axis 
%   ylab - label for y-axis
%   titleStr - string for plot title

% OUTPUT:
%   fig - figure handle 
% 
% 
% author: Kelly, kelhennigan@gmail.com, 11-Apr-2015

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check input variables

if notDefined('x')
    x=randn(20,1);
end
if notDefined('y')
    y=randn(20,1);
end
if notDefined('xlab')
    xlab = '';
end
if notDefined('ylab')
    ylab = '';
end
if notDefined('titleStr')
    titleStr = 'title';
end


%% do it

% figure
scSize = get(0,'ScreenSize'); % get screensize for pleasant figure viewing :)

fig = setupFig;

% place figure in top right of monitor for more convenient viewing
pos = get(gcf,'Position');
set(gcf,'Position',[scSize(3)-pos(3), scSize(4)-pos(4), pos(3), pos(4)])

hold on;

plot(x,y,'.','MarkerSize',20,'color','k');


% x and y coords for plotting a line
xl = [min(x)+.25, max(x)-.25];
b=regress(y,[ones(numel(x),1),x]);
yl=xl*b(2)+b(1);
plot(xl,yl,'LineWidth',2.5,'color','k')

xlim([min(x)-.25 max(x)+.25])

xlabel(xlab)
ylabel(ylab)

title(titleStr)

hold off

