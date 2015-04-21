function [apan,ux,uy,d] = createPanner(f,varargin)

if nargin>1
    d = findobj(f,'type','line','tag','pannerbtn');
    ux = findobj(f,'type','uicontrol','tag','xpan');
    uy = findobj(f,'type','uicontrol','tag','ypan');
    apan = [];
    draglocation(f,ux,uy,d);
    return;
end

p1 = get(f,'position');
%delete(findobj(f,'type','uicontrol'))
afr = axes('parent',f,'color',[0.996,0.953,0.996],...
    'pos',[0.73 0.15 0.263 0.8],'box','on',...
    'xtick',[-100 100],'ytick',[-100 100]);

apan =  axes('parent',f,'pos',[0.78,0.6,0.2,0.25],'box','on','tag','ax_panner');

set(f,'currentaxes',apan);
d = line(0.5,0.5,'marker','*','markersize',12); grid on; hold on
set(d,'erasemode','xor','tag','pannerbtn');
set(apan,'color',[1 0.9 0.9]);

ux = uicontrol('style','edit','pos',[0.7873,0.4945,0.0622,0.0296],...
    'back',0.99*[1 1 1],'horizontalAlignment','left','tag','xpan',...
    'callback',{@setPCA d});
uy = uicontrol('style','edit','pos',[0.9056,0.4945,0.0622,0.0296],...
    'back',0.99*[1 1 1],'horizontalAlignment','left','tag','ypan',...
    'callback',{@setPCA d});

draglocation(f,ux,uy,d);
%set(apan,'tag','ax_panner');
%------------------------------------------------

popX = uicontrol('style','popup','pos',[0.7676,0.2052,0.0622,0.0296],...
    'string',{'S_1','S_2','S_3','S_4','S_5'},'value',1,...
    'callback',{@selectPCAs d},'tag','pcx');
xlab = uicontrol('style','text','string','X','pos',...
    [0.7834,0.2383,0.0207,0.0296],'backgroundcolor',[0.996,0.953,0.996]);

popY = uicontrol('style','popup','pos',[0.8465,0.2052,0.0622,0.0296],...
    'string',{'S_1','S_2','S_3','S_4','S_5'},'value',2,...
    'callback',{@selectPCAs d},'tag','pcy');

ylab = uicontrol('style','text','string','Y','pos',...
    [0.8622,0.2383,0.0207,0.0296],'backgroundcolor',[0.996,0.953,0.996]);

popZ = uicontrol('style','popup','pos',[0.9253,0.2052,0.0622,0.0296],...
    'string',{'S_1','S_2','S_3','S_4','S_5'},'value',3,...
    'callback',{@selectPCAs d},'tag','pcz');

zlab = uicontrol('style','text','string','Z','pos',...
    [0.9411,0.2383,0.0207,0.0296],'backgroundcolor',[0.996,0.953,0.996]);

%----------------------------------------------------------------------
logdata1 = uicontrol('pos',[0.7873,0.3085,0.068,0.0296],...
    'string','Log Data','callback',@logdata,'tag','logdata');

animate1 = uicontrol('pos',[0.8859,0.3085,0.068,0.0296],...
    'string','Automate','callback',{@animate,logdata1},'tag','Automate');

showall = uicontrol('pos',[0.8366,0.3705,0.068,0.0296],...
    'string','Show All','callback',@showall_ellipse,'tag','showall');

%------------------------------------------------------------------------
slide1 = uicontrol('style','slider','pos',[0.1961,0.3085,0.1037,0.0296],...
    'backgroundcolor',0.7*[1 1 1],'callback',@setalpha,...
    'tag','slide_con','value',0.4);
sl1_label = uicontrol('style','text','string','Control Ellipsoid','pos',...
    [0.1976,0.3416,0.1037,0.0296],'backgroundcolor','w');


slide2 = uicontrol('style','slider','pos',[0.3932,0.3085,0.1037,0.0296],...
    'backgroundcolor',[0.647,0.855,0.851],'callback',@setalpha,...
    'tag','slide_main','value',0.1);

sl2_label = uicontrol('style','text','string','Current Data Ellipsoid','pos',...
    [0.3853,0.3416,0.1245,0.0296],'backgroundcolor','w');


%------------------------------------------------------
ut = uicontrol('pos',[0.8496,0.0281,0.135,0.0444],...
    'string','Show Time Evolution','callback',@local_time_evol);
% jgo
ut = uicontrol('pos',[0.6496,0.0281,0.135,0.0444],...
    'string','View exterior','callback',{@show_ellsipse_diffs f});
%-------------------------------------------------------

data_txt = uicontrol('style','text','string','Analysis Data','pos',...
    [0.0197,0.0578,0.135,0.0444],'backgroundcolor','w','fontweight','bold',...
    'fontsize',10);
udstr{1} = 'In-control Batch';
udstr{2}='Faulty Batch: 1';
udstr{3}='Faulty Batch: 10';
udstr{4} = 'Modified Batch (fault1)';

ud = uicontrol('style','popup','pos',[0.0197,0.0281,0.1245,0.0444],...
    'string',udstr,'callback',@change_database);

%------------------------------------------------------
showtr = uicontrol('style','checkbox','pos',[0.55,0.3085,0.107,0.04],...
    'tag','show_trail','string','Show Trail');

%------------------------------------------------------
function draglocation(f,ux,uy,d)

%set(f,'WindowButtonUpFcn',{@local_btnup d});
set(f,'WindowButtonDownFcn',{@local_btndown d ux uy});
set(f,'WindowButtonMotionFcn',@local_btnmotion);

set(ux,'string',get(d,'Xdata'));
set(uy,'string',get(d,'Ydata'));
%------------------------------------------------
function local_btndown(varargin)

f = varargin{1};
d = varargin{end-2};  
ux = varargin{end-1};
uy = varargin{end};

% ax = get(f,'CurrentAxes');
% if ~strcmp(get(ax,'tag'),'panneraxes')
%     return;
% end

hoverobj = handle(hittest(f));
objtype = get(hoverobj,'type');
objtag  = get(hoverobj,'tag');

if strcmpi(objtype,'line') &&  strcmp(objtag,'pannerbtn')
    setptr(f,'closedhand');
    set(f,'WindowButtonMotionFcn',{@local_dragfcn d ux uy});
    set(f,'WindowButtonUpFcn',{@local_btnup d});
else
    set(f,'WindowButtonUpFcn','');
end

%------------------------------------------------
function local_btnmotion(varargin)

f = varargin{1}; 
hoverobj = handle(hittest(f));
objtype = get(hoverobj,'type');
objtag  = get(hoverobj,'tag');

if strcmpi(objtype,'line') &&  strcmp(objtag,'pannerbtn')
    setptr(f,'hand');
else
    setptr(f,'arrow');
end


%------------------------------------------------
function local_btnup(varargin)

f = varargin{1}; 
d = varargin{end};

hoverobj = handle(hittest(f));
objtype = get(hoverobj,'type');
objtag  = get(hoverobj,'tag');

if strcmpi(objtype,'line') && strcmp(objtag,'pannerbtn')
    setptr(f,'hand');
else
    setptr(f,'arrow');
end

set(f,'WindowButtonMotionFcn',@local_btnmotion);

x0 = [get(d,'Xdata');get(d,'Ydata')];
updateGUI(f,x0,'panner')

%------------------------------------------------
function local_dragfcn(varargin)

f = varargin{1}; 
d = varargin{end-2}; 
ux = varargin{end-1};
uy = varargin{end};

% hoverobj = handle(hittest(f));
% objtype = get(hoverobj,'type');
% objtag  = get(hoverobj,'tag');

pt = get(gca,'CurrentPoint');
set(d,'Xdata',pt(1,1),'Ydata',pt(1,2));
drawnow;
set(ux,'String',pt(1,1));
set(uy,'String',pt(1,2));

%--------------------------------------------------
function selectPCAs(varargin)

f = gcbf;
d = varargin{end};

uic = varargin{1};
userd = get(f,'userdata');
ind = userd{3};
switch get(uic,'tag')
    case 'pcx'
        ind(1) = get(uic,'value');
    case 'pcy'
        ind(2) = get(uic,'value');
    case 'pcz'
        ind(3) = get(uic,'value');
    otherwise
        error('tag not found')
end
userd{3} = ind;
set(f,'userdata',userd);
x0 = [get(d,'Xdata');get(d,'Ydata')];
updateGUI(f,x0,'pannerUI');

%---------------------------------------------------------
function setPCA(varargin)

f = gcbf;
ui = varargin{1};
d = varargin{end};

switch get(ui,'tag')
    case 'xpan'
        set(d,'Xdata',str2num(get(ui,'string')));
    case 'ypan'
        set(d,'Ydata',str2num(get(ui,'string')));
end

x0 = [get(d,'Xdata');get(d,'Ydata')];
updateGUI(f,x0,'panner');

%-----------------------------------------------------------
function logdata(varargin)

ui = varargin{1};
f = gcbf;
userd = get(f,'userdata');
global ii

%load batch3a % has 5 PC batches.
%load batch_fault
load mybatch

if strcmpi(get(ui,'enable'),'on')
    ii = ii+1;
    c1 = squeeze(c(ii,:,:));
    m1 = m(ii,:); m1 = m1(:);
    
    userd{1} = c1;
    userd{2} = m1;
    set(f,'Userdata',userd);
    updateGUI(f,[],'mpcagui');
end

if ii==19
    set(ui,'enable','off');
    if nargin>2
        set(varargin{end},'enable','off');
    end
end

%-----------------------------------------------------------
function showall_ellipse(varargin)

global ii P Q R Colmat1 %Colmat

ui = varargin{1};
f = gcbf;
ax = findobj(f,'type','axes','tag','ax');
set(f,'CurrentAxes',ax);

for k=1:ii
    mycol(25*k-24:25*k,:,1) = repmat(Colmat1(k,1),25,25);
    mycol(25*k-24:25*k,:,2) = repmat(Colmat1(k,2),25,25);
    mycol(25*k-24:25*k,:,3) = repmat(Colmat1(k,3),25,25);
    myalp(25*k-24:25*k,:) = repmat(0.5,25,25); %repmat((0.1+(k-1)*0.05),25,25);
    %repmat(1,25,25);
end
%keyboard
%colormap hsv;
%surf(P,Q,R,Colmat,'FaceColor','texturemap'); shading interp, alpha(0.1);
surf(P,Q,R,mycol);%,'alphadata',myalp,'AlphaDataMapping','none'); 
shading interp, alpha(0.1);
camlight headlight, lighting phong
hold on
surf(P(end-24:end,:),Q(end-24:end,:),R(end-24:end,:),...
    'facecolor','n','edgecolor','k','meshstyle','both')
hold off
set(ax,'tag','ax');

%-------------------------------------------------------------------------
function setalpha(varargin)

f = gcbf;
ui = varargin{1};

ax = findobj(f,'type','axes','tag','ax');
set(f,'CurrentAxes',ax);

switch get(ui,'tag')
    case 'slide_con'
        s = findobj(allchild(ax),'tag','s_con');
    case 'slide_main'
        s = findobj(allchild(ax),'tag','s_main');
end
if ~isempty(s)
    alpha(s,get(ui,'value'));
end

%--------------------------------------------------------------------------
function local_time_evol(varargin)

f = gcbf;
time_evol(f);

%--------------------------------------------------------------------------
function change_database(varargin)

ui = varargin{1};
f = gcbf;
global ii P Q R Colmat1
ii = 1; P = []; Q = []; R = []; Colmat1 = [];
s = [];
switch get(ui,'value')
    case 1
        load batch3a
        save mybatch c m t umat v 
        load udat
        save myudat md
    case 2
        load batch_fault1
        save mybatch c m t umat 
        load udat_fault1
        save myudat md       
    case 3
        load batch_fault10
        save mybatch c m t umat 
        load udat_fault10
        save myudat md  
    case 4
        load batch_fault1X
        save mybatch c m t umat
        load udat_fault1X
        save myudat md
    otherwise
       disp('File not found. Data file might be missing.' )
end

if isempty(s)
    c1 = squeeze(c(ii,:,:));
    m1 = m(ii,:); m1 = m1(:);
    userd = get(f,'userdata');
    userd{1} = c1;
    userd{2} = m1;
    set(f,'Userdata',userd);
    
    logd = findobj(f,'style','pushbutton','tag','logdata');
    ani = findobj(f,'style','pushbutton','tag','Automate');
    if ~isempty(logd)
        set(logd,'enable','on');
    end
    if ~isempty(ani)
        set(ani,'enable','on');
        set(ani,'str','Automate');
    end
    updateGUI(f,[],'mpcagui');
    close(findobj(0,'tag','f2'));
end

%------------------------------------------------------------------------
function animate(varargin)

ui = varargin{1};
logd = varargin{end};
global ii

if (ii==19)
    set(ui,'enable','off')
    return;
end

if strcmpi(get(ui,'str'),'automate')
    set(ui,'str','Stop')
    while ii<19
        logdata(logd,[],ui);
        pause(0.01)
        if ~strcmpi(get(ui,'str'),'Stop')
            return;
        end
    end
elseif strcmpi(get(ui,'str'),'stop')
    set(ui,'str','Automate')
end


% %--------------------------------------------------------------------------
% function showtrail(varargin)
% 
% ui = varargin{1};
% f = gcbf;

% jgo
function show_ellsipse_diffs(eventSrc, eventData, f)

updateGUI(f,[],'mpcagui','diff');