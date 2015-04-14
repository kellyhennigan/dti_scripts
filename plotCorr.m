
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

fig = setupFig;
hold on;

plot(x,y,'.','MarkerSize',20,'color','k');


% x and y coords for plotting a line
xl = [min(x)+.25, max(y)-.25];
yl = [min(x) max(x)].*corr(x,y);
plot(xl,yl,'LineWidth',2.5,'color','k')

xlim([min(x)-.25 max(x)+.25])

xlabel(xlab)
ylabel(ylab)

title(titleStr)

hold off

