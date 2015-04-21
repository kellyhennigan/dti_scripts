function f2 = time_evol(f)
% time plot and evolution of score-curves

f2 = findobj(0,'tag','f2');
if isempty(f2)
    f2 = figure('color',0.9*[1 1 1],'pos',[0.4688,0.0654,0.5133,0.8545],...
        'resize','on','tag','f2');
end
set(0,'CurrentFigure',f2);
clf;
figure(f2);
ax2 = axes('parent',f2,'color',0*[1 1 1],'tag','ax2',...
    'pos',[0.1 0.55 0.75 0.4]);

ax_time = axes('parent',f2,'color',0*[1 1 1],'tag','ax_time',...
    'pos',[0.2 0.05 0.8 0.45]);


uctrl = uicontrol('string','Show Control Region','pos',[0.0898,0.5131,0.23,0.0229],...
    'callback',{@showcontrol f ax2},'tag','controlbtn');


utxt = uicontrol('style','text','pos',[0.5464,0.5131,0.2588,0.0229],...
    'backgroundcolor',[0.996,0.953,0.996],'horizontalAlignment','left',...
    'string','Show last                        regions');

popC = uicontrol('style','popup','pos',[0.65,0.5131,0.0609,0.0229],...
    'string',{'1'},'callback',{@redraw_ellip,f,ax2},'tag','popc');


%----------------------------------------------------
slide1 = uicontrol('style','slider','pos',[0.8204,0.9589,0.1522,0.0229],...
    'backgroundcolor',0.7*[1 1 1],'callback',@setalpha,...
    'tag','slide_con','value',0.5);
slabel = uicontrol('style','text','string','Opacity Control','pos',...
    [0.8204,0.9840,0.1522,0.0171],'backgroundcolor','w');

slide2 = uicontrol('style','slider','pos',[0.8204,0.9326,0.1522,0.0229],...
    'backgroundcolor',[0.647,0.855,0.851],'callback',@setalpha,...
    'tag','slide_main','value',0.5);

set(f2,'toolbar','f')
cameratoolbar('show')

draw_evol(f2,ax2,ax_time);

%-----------------------------------------------------------------
function draw_evol(varargin)
% draws all the plots

global ii P Q R Colmat1
%load udat, md = md.';
%load udat_fault, md = md.';
load myudat, md = md.';

vari = {'Endpt A','He Press','Pressure','RF Tuner','RF Load',...
        'RF Phase Err','RF Pwr','RF Impedance','TCP Tuner','TCP Phase Err',...
        'TCP Impedance','TCP Load'};

f2 = varargin{1};
ax2 = varargin{2};
ax_time = varargin{3};

i1 = 19;

popC = findobj(f2,'type','uicontrol','tag','popc');
str = {};
for k = 1:ii
    str{k} = num2str(ii-k+1);
end
set(popC,'string',str);

% alp = linspace(0.05,1,19);
% alp = 0.1*ones(1,19);
alp = logspace(-1.301,0,19);

for k = 1:ii
    set(0,'CurrentFigure',f2);
    mycol = [];
    mycol(:,:,1) = repmat(Colmat1(k,1),25,25);
    mycol(:,:,2) = repmat(Colmat1(k,2),25,25);
    mycol(:,:,3) = repmat(Colmat1(k,3),25,25);
    set(f2,'CurrentAxes',ax2);
    s(k) = surf(P(25*k-24:25*k,:),Q(25*k-24:25*k,:),...
        R(25*k-24:25*k,:),mycol);
    %set(ax2,'color',[0.929,0.996,0.945]);
    shading(ax2,'interp')
    alpha(s(k),alp(k));
    hold on
    if k==1
        title('Three Principal Scores view','fontweight','bold');
        %xlabel('S_1'); ylabel('S_2'); 
        zlabel('S_3');
        %,...'pos',[-11.0555,2.1606,0]);
        camlight headlight, %lighting phong
    end
    lighting(ax2,'phong')
    %hold on
    
    % time plot
    set(f2,'CurrentAxes',ax_time);
    delt = 1; % sampling interval
    yt = repmat([1:delt:k*5]',1,12);
    
    zt = md(1:k*5,:); 
    %zt = zt./repmat(abs(max(zt)),k*5,1); 
    zt = zt-repmat(mean(zt),k*5,1);
    zt = zt./repmat(max(zt)-min(zt),k*5,1); 
    
    xt = repmat([1:12],k*5,1);
    plot3(xt,yt,zt,'.-','linewidth',1);
    axis([0 12 0 i1*5 -1 1]);
    view([1 0.2 -3]); grid on
    set(ax_time,'ztick',[0],'xgrid','off','color',1*[1 1 0.95],...
        'xtick',[1:12],'xticklabel',vari);
    ti = title('Data');
    set(ti,'fontweight','bold','position',[12 45 1.2],'rotation',5,'FontSize',14);
    yl = ylabel('time');
    set(yl,'pos',[-1.5,50,-1],'fontweight','bold');
    if nargin<=6
        pause(0.1);
    end
end

hold off
set(ax2,'tag','ax2');
set(ax_time,'tag','ax_time');

%--------------------------------------------------------------------
function showcontrol(varargin)

global ctr_data
ui = varargin{1};
f = varargin{end-1};
ax2 = varargin{end};
f2 = gcbf;

warning off

%sc0 = findobj(f,'type','surface','tag','s_con');
opacity_con = findobj(f2,'style','slider','tag','slide_con');
if ~isempty(ctr_data)
    pc = ctr_data{1}; %get(sc0,'Xdata');
    qc = ctr_data{2};
    rc = ctr_data{3};
    set(f2,'currentaxes',ax2);
    hold on
    sc = surf(pc,qc,rc,0.6*ones([size(rc),3]),'tag','s_con2');
    shading(ax2,'interp')
    alpha(sc,get(opacity_con,'value'));
    lighting(ax2,'phong')
    hold off
    
    set(ui,'string','Hide Control Region','callback',{@hidecontrol sc f ax2})
    set(ax2,'tag','ax2');
end

%----------------------------------------------------------------------
function hidecontrol(varargin)

ui = varargin{1};
sc = varargin{end-2};
f = varargin{end-1};
ax2 = varargin{end};

set(sc,'Cdata',[],'Xdata',[],'Ydata',[],'Zdata',[]);
set(ui,'string','Show Control Region','callback',{@showcontrol f ax2})
set(ax2,'tag','ax2');

%-----------------------------------------------------------------------
function redraw_ellip(varargin)

global ii P Q R Colmat1
ui = varargin{1};
f2 = gcbf;
f = varargin{3};
ax2 = varargin{4};
ii2 = get(ui,'value');

set(f2,'CurrentAxes',ax2);
hold off
%alp = logspace(-1.301,0,19);

str = get(ui,'string');
val = get(ui,'value');
myval = str2num(str{val});
alp = logspace(-1.301,0,myval);

for k = ii2:ii
    mycol = [];
    mycol(:,:,1) = repmat(Colmat1(k,1),25,25);
    mycol(:,:,2) = repmat(Colmat1(k,2),25,25);
    mycol(:,:,3) = repmat(Colmat1(k,3),25,25);
    set(f2,'CurrentAxes',ax2);
    s1(k) = surf(P(25*k-24:25*k,:),Q(25*k-24:25*k,:),...
        R(25*k-24:25*k,:),mycol);
    %set(ax2,'color',[0.929,0.996,0.945]);
    shading(ax2,'interp')
    alpha(s1(k),alp(k-ii2+1));
    hold on
    if k==ii2
        title('Three Principal Scores view','fontweight','bold');
        %xlabel('S_1','pos',[0.7909,0.0633,0]); 
        %ylabel('S_2'); 
        zlabel('S_3');
        %,...'pos',[-11.0555,2.1606,0]);
        camlight headlight
    end
    lighting(ax2,'phong')
end

uc = findobj(f2,'type','uicontrol','tag','controlbtn');
if strcmp(get(uc,'string'),'Hide Control Region')
    showcontrol(uc,[],f,ax2);
end
hold off
set(ax2,'tag','ax2');
%-------------------------------------------------------------------------
function setalpha(varargin)

global ii
f2 = gcbf;
ui = varargin{1};

ax2 = findobj(f2,'type','axes','tag','ax2');
set(f2,'CurrentAxes',ax2);

sc = findobj(allchild(ax2),'tag','s_con2');

popC = findobj('style','popup','tag','popc');
if ~isempty(popC)
    str = get(popC,'string');
    val = get(popC,'value');
    myval = str2num(str{val});
    alp = logspace(-1.301,0,myval);
else
    alp = logspace(-1.301,0,19);
end

switch get(ui,'tag')
    case 'slide_con'
        if ~isempty(sc)
            alpha(sc,get(ui,'value'));
        end
    case 'slide_main'
        s = findobj(allchild(ax2),'type','surface');
        s = setdiff(s,sc);
        if ~isempty(s)
            len = length(s);
            for k = 1:len
                %alpha(s(k),exp(-alp(ii-len+k))*get(ui,'value'));
                alpha(s(k),get(ui,'value')*alp(k));
            end
        end
end