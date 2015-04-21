function updateGUI(f,x0,caller,varargin) %jgo

% reset "show trail" checkbox
showtr = findobj(f,'style','checkbox','tag','show_trail');
if ~strcmpi(caller,'panner') && ~isempty(showtr)
    set(showtr,'value',0);
end

if get(showtr,'val')
    N = 15; % controls gridding of ellipsoids
    con_fact = 0; % controls color of control ellipses on shadow plots
elseif nargin<4
    N = 24;
    con_fact = 0.4;
elseif nargin==4
    N = 50;
    con_fact = 0.4;
end


global ii P Q R Colmat1 ctr_data
set(0,'CurrentFigure',f);
cameratoolbar('setmode','nom')
createpanner(f,'reset');

userd = get(f,'userdata');
c1 = userd{1};
m1 = userd{2};
ind = userd{3};
ax_list = userd{4};
cc = userd{5};
cm = userd{6};

ax = ax_list(1);
ax_right = ax_list(2); posr = get(ax_right,'pos');
ax_left = ax_list(3); posl = get(ax_left,'pos');
ax_down = ax_list(4); posd = get(ax_down,'pos');
ax_panner = ax_list(5); posp = get(ax_panner,'pos');

xpan = findobj(f,'type','uicontrol','tag','xpan');
ypan = findobj(f,'type','uicontrol','tag','ypan');

col = {'autumn','bone','colorcube','cool','copper',...
        'flag','gray','hot','hsv','jet','pink','prism',...
        'spring','summer','white','winter','vga','lines'} ;

mymap = hsv;

%alp = logspace(-1.5,0,19); %REVISIT to decide length of alp
alp = round(linspace(1,64,19));
%N = 24;
%n = [];

if norm(c1)<100*eps
    c1 = 1e-9*eye(size(c1));
end
m1 = m1(:);

%pre-analysis
[pan_ellipse,center_pan] = panner_ellipse(c1,m1,ind);


if strcmpi(caller,'mpcagui') || strcmpi(caller,'pannerUI')
    % set panner
    set(f,'CurrentAxes',ax_panner);
    hpan = findobj(ax_panner,'type','line','tag','ellip');
    if isempty(hpan)
        hpan = plot(pan_ellipse(1,:),pan_ellipse(2,:),'k','tag','ellip');
    else
        set(hpan,'Xdata',pan_ellipse(1,:),'Ydata',pan_ellipse(2,:));
    end
    ind0 = setdiff([1:5],ind);
    xlabel(['S_',num2str(ind0(1))],'fontweight','bold');
    ylabel(['S_',num2str(ind0(2))],'fontweight','bold');
    title('Panner for 4th & 5th scores')
    
    d = findobj(get(ax_panner,'children'),'type','line','tag','pannerbtn');
    set(d,'Xdata',center_pan(1),'Ydata',center_pan(2));
    x0 = center_pan; %default
    
    axis([floor(min(pan_ellipse(1,:))),ceil(max(pan_ellipse(1,:))),...
            floor(min(pan_ellipse(2,:))),ceil(max(pan_ellipse(2,:)))]);
    set(xpan,'string',get(d,'Xdata'));
    set(ypan,'string',get(d,'Ydata'));
    set(ax_panner,'tag','ax_panner');
    
end

[C3,del_M3] = choosepc(c1,m1,ind,x0-center_pan);
% control ellispe
[Cc,del_Mc] = choosepc(cc,cm,ind,x0-center_pan);

%-------3D plot creation-------------------
[U,L] = eig(C3);
[Uc,Lc] = eig(Cc);

if (any(diag(L)<=0))&&(strcmpi(caller,'panner'))
    disp('invalid region')
    return;
end
fl = true;
if (any(diag(Lc)<=0))&&(strcmpi(caller,'panner'))
    fl = false;
    %disp('control ellipse doesn''t exist')
end

M3 = m1(ind)+del_M3;
Mc = cm(ind)+del_Mc;
[x,y,z] = ellipsoid(0,0,0,2*sqrt(L(1,1)),2*sqrt(L(2,2)),2*sqrt(L(3,3)),N);
if fl || nargin==4 %jgo
    f2 = 2;
    %f2=0.75;
    [xc,yc,zc] = ellipsoid(0,0,0,f2*sqrt(Lc(1,1)),f2*sqrt(Lc(2,2)),f2*sqrt(Lc(3,3)),N);
end
if nargin == 4 %jgo
        r = [2*sqrt(L(1,1));2*sqrt(L(2,2));2*sqrt(L(3,3))];
        rc = [2*sqrt(Lc(1,1));2*sqrt(Lc(2,2));2*sqrt(Lc(3,3))];
        [x,y,z] = ellipsediff((Mc-M3),r',rc',N);
        fl = 0;
end     

for k=1:size(x,1) %jgo
    for i=1:size(x,2) %jgo
        temp = U*[x(k,i),y(k,i),z(k,i)]';
        p(k,i) = temp(1)+M3(1);
        q(k,i) = temp(2)+M3(2);
        r(k,i) = temp(3)+M3(3);
        
        if fl
            tempc = U*[xc(k,i),yc(k,i),zc(k,i)]';
            pc(k,i) = tempc(1)+Mc(1);
            qc(k,i) = tempc(2)+Mc(2);
            rc(k,i) = tempc(3)+Mc(3);
        end            
    end
end
% Cost function value (F0):
% F0 is constant on surface of ellipsoid: 1/2*x'*A0*x, where A0=U*D0*U';
p0 = [2*sqrt(L(1,1));0;0];
D0 = 1/4*diag([1/L(1,1),1/L(2,2),1/L(3,3)]);
F0 = 1/2*p0'*D0*p0; %0.5 for c(1,:,:)
A0 = U*D0*U';

crpd = cross(A0(:,2),A0(:,3));
alp1 = sqrt(2*F0/abs(crpd'*A0(:,1)*crpd(1)));
yz = alp1*crpd;

crpd = cross(A0(:,3),A0(:,1));
alp1 = sqrt(2*F0/abs(crpd'*A0(:,2)*crpd(2)));
zx = alp1*crpd;

crpd = cross(A0(:,1),A0(:,2));
alp1 = sqrt(2*F0/abs(crpd'*A0(:,3)*crpd(3)));
xy = alp1*crpd;


%control ellipse calculation 
if fl
    p0c = [2*sqrt(Lc(1,1));0;0];
    D0c = 1/4*diag([1/Lc(1,1),1/Lc(2,2),1/Lc(3,3)]);
    F0c = 1/2*p0c'*D0c*p0c; %0.5 for c(1,:,:)
    A0c = Uc*D0c*Uc';
    
    crpdc = cross(A0c(:,2),A0c(:,3));
    alp1c = sqrt(2*F0c/abs(crpdc'*A0c(:,1)*crpdc(1)));
    yzc = alp1c*crpdc;
    
    crpdc = cross(A0c(:,3),A0c(:,1));
    alp1c = sqrt(2*F0c/abs(crpdc'*A0c(:,2)*crpdc(2)));
    zxc = alp1c*crpdc;
    
    crpdc = cross(A0c(:,1),A0c(:,2));
    alp1c = sqrt(2*F0c/abs(crpdc'*A0c(:,3)*crpdc(3)));
    xyc = alp1c*crpdc;
end
%----------------------------------------

%Note: 1/2*x'*U*D0*U'*x is same const for x = yz,zx,xy (0.5: first)
%cols = ones(size(p))*alp11(ii);
%cols = ones(size(p))/alp(ii); %[ii cols(1,1)]
%------------------------------------------

cols = mymap(alp(ii),:); map_ax = repmat(cols,size(mymap,1),1); 
if strcmpi(caller,'mpcagui') && nargin<=3 %jgo
    P = [P;p]; 
    Q = [Q;q];
    R = [R;r];
    Colmat1 = [Colmat1;cols];
end

%--------------------------------------------------------
set(f,'CurrentAxes',ax);
n = axis;
if get(showtr,'val')
    hold on
    s1 = findobj(ax,'type','surface','tag','s_main');
    alpha(s1,0.05);
else
    hold off
end
s = surf(p,q,r,'tag','s_main');
if nargin == 4 %jgo
    axis off
end

%Colmat = [Colmat;get(s,'Cdata')];
xlabel(['S_',num2str(ind(1))],'fontweight','bold');
ylabel(['S_',num2str(ind(2))],'fontweight','bold');
zlabel(['S_',num2str(ind(3))],'fontweight','bold');
set(gca,'color',1*[1 1 0.95]);
shading(ax,'interp')
slm = findobj(f,'type','uicontrol','tag','slide_main');
if ~isempty(slm)
    alpha(s,get(slm,'value'));
else
    alpha(s,0.1);
end
if get(showtr,'val')
    set(s,'edgecolor','k','tag','s_main');
end
%colormap default; 
%colormap(mymap), 
colormap(ax,map_ax);
%caxis([0.05 50]); 
%axis([-15 0 0 10 -10 -2]);

if strcmpi(caller,'mpcagui') || strcmpi(caller,'pannerUI')
    n = [get(ax,'Xlim'),get(ax,'Ylim'),get(ax,'Zlim')];
end
%axis(n);
hold on
% center (mean)
if ~get(showtr,'val')
    plot3(M3(1),M3(2),M3(3),'r.','markersize',8)
end
sc = [];
if fl && nargin<4 %jgo
    if get(showtr,'val')
        s1c = findobj(ax,'type','surface','tag','s_con');
        alpha(s1c,0.1);
    end
    sc = surf(pc,qc,rc,0.6*ones([size(rc),3]),'tag','s_con','edgecolor','n'); 
    %shading interp
    slc = findobj(f,'type','uicontrol','tag','slide_con');
    if ~isempty(slc)
        alpha(sc,get(slc,'value'));
    else
        alpha(sc,0.4);
    end
    axis auto
    n = axis;
end
if ~get(showtr,'val')
    plot3(Mc(1),Mc(2),Mc(3),'k.','markersize',8)
    shading interp
end
if ~get(showtr,'val')
    hold off
end
axis(n);
if ~get(showtr,'val')
    camlight headlight
    lighting(ax,'phong')
end
set(ax,'tag','ax');
%keyboard % for running nncreatefig
%------------------------------------------------------
% xy-plane contour
if nargin<4
	set(f,'CurrentAxes',ax_down);
	x1 = yz(1); y1 = yz(2);
	x2 = zx(1); y2 = zx(2);
	mat = [y1^2,x1*y1,1; y2^2,x2*y2,1; 2*y1,x1,0];
	ellip_par = mat\[-x1^2;-x2^2;0];
	%F02d = -1/2*ellip_par(3);
	A2d = [1 ellip_par(2)/2; ellip_par(2)/2 ellip_par(1)]*(-1/ellip_par(3));
	[U2d,L2d] = eig(A2d);
	thet = [0:51]/50*2*pi;
	cxy = U2d*[1/sqrt(L2d(1,1))*cos(thet);1/sqrt(L2d(2,2))*sin(thet)];
	cxy = cxy+repmat([M3(1);M3(2)],1,length(thet));
	
	% control ellipse
	if fl
        x1c = yzc(1); y1c = yzc(2);
        x2c = zxc(1); y2c = zxc(2);
        matc = [y1c^2,x1c*y1c,1; y2c^2,x2c*y2c,1; 2*y1c,x1c,0];
        ellip_parc = matc\[-x1c^2;-x2c^2;0];
        %F02d = -1/2*ellip_par(3);
        A2dc = [1 ellip_parc(2)/2; ellip_parc(2)/2 ellip_parc(1)]*(-1/ellip_parc(3));
        [U2dc,L2dc] = eig(A2dc);
        cxyc = U2dc*[1/sqrt(L2dc(1,1))*cos(thet);1/sqrt(L2dc(2,2))*sin(thet)];
        cxyc = cxyc+repmat([Mc(1);Mc(2)],1,length(thet));
	end
	if get(showtr,'val')
        hold on
	end
	hr = plot(cxy(1,:),cxy(2,:),'r','linewidth',1); 
	hold on
	if fl
        hr(end+1) = plot(cxyc(1,:),cxyc(2,:),'linewidth',1,'color',con_fact*[1 1 1]);
	end
	la = axis;
	nd = [min(la(1),n(1)),max(la(2),n(2)),min(la(3),n(3)),max(la(4),n(4)),n(5:6)];
	%hr(end+1) = fill([nd(1),nd(2),nd(2),nd(1),nd(1)],[nd(3),nd(3),nd(4),nd(4),nd(3)],'g'); 
	%alpha(hr(end),0.05);
	if ~get(showtr,'val')
        hr(end+1) = fill([nd(1),nd(2),nd(2),nd(1),nd(1)],[nd(3),nd(3),nd(4),nd(4),nd(3)],'g'); 
        set(hr(end),'tag','backgr','FaceAlpha',0.05);
        %alpha(hr(end),0.05);
        hr(end+1) = line(M3(1),M3(2),'color','r','marker','.');
        hr(end+1) = line(Mc(1),Mc(2),'color','k','marker','.');
	else
        hr1 = findobj(ax_down,'type','patch','tag','backgr');
        set(hr1,'Xdata',[nd(1),nd(2),nd(2),nd(1),nd(1)]','Ydata',[nd(3),nd(3),nd(4),nd(4),nd(3)]',...
            'FaceColor','g');
        %hr(end+1) = fill([nd(1),nd(2),nd(2),nd(1),nd(1)],[nd(3),nd(3),nd(4),nd(4),nd(3)],'g'); 
        %alpha(hr(end),0.05);
	end
	hold off
	for j = 1:length(hr)
        set(hr(j),'Zdata',ones(size(get(hr(j),'Ydata'))));
	end
	view(3)
	%%axis([n(1),n(2)+0.01,n(3),n(4)+0.01,0,1]);
	axis([nd(1),nd(2)+0.03,nd(3),nd(4),0,1]);
	set(ax_down,'tag','ax_down','pos',posd);
	axis off
	
	%--------------------------------------------------------
	% xz-plane contour
	set(f,'CurrentAxes',ax_left);
	x1 = yz(1); y1 = yz(3);
	x2 = xy(1); y2 = xy(3);
	mat = [y1^2,x1*y1,1; y2^2,x2*y2,1; 2*y1,x1,0];
	ellip_par = mat\[-x1^2;-x2^2;0];
	A2d = [1 ellip_par(2)/2; ellip_par(2)/2 ellip_par(1)]*(-1/ellip_par(3));
	[U2d,L2d] = eig(A2d);
	thet = [0:51]/50*2*pi;
	czx = U2d*[1/sqrt(L2d(1,1))*cos(thet);1/sqrt(L2d(2,2))*sin(thet)];
	czx = czx+repmat([M3(1);M3(3)],1,length(thet));
	
	if fl
        x1c = yzc(1); y1c = yzc(3);
        x2c = xyc(1); y2c = xyc(3);
        matc = [y1c^2,x1c*y1c,1; y2c^2,x2c*y2c,1; 2*y1c,x1c,0];
        ellip_parc = matc\[-x1c^2;-x2c^2;0];
        A2dc = [1 ellip_parc(2)/2; ellip_parc(2)/2 ellip_parc(1)]*(-1/ellip_parc(3));
        [U2dc,L2dc] = eig(A2dc);
        czxc = U2dc*[1/sqrt(L2dc(1,1))*cos(thet);1/sqrt(L2dc(2,2))*sin(thet)];
        czxc = czxc+repmat([Mc(1);Mc(3)],1,length(thet));
	end
	if get(showtr,'val')
        hold on
	end
	hq = plot(czx(1,:),czx(2,:),'r','linewidth',1); 
	hold on
	if fl
        hq(end+1) = plot(czxc(1,:),czxc(2,:),'linewidth',1,'color',con_fact*[1 1 1]); 
	end
	la = axis;
	nl = [min(la(1),n(1)),max(la(2),n(2)),min(la(3),n(3)),max(la(4),n(4)),n(5:6)];
	if ~get(showtr,'val')
        hq(end+1) = fill([nl(1),nl(2),nl(2),nl(1),nl(1)],[nl(5),nl(5),nl(6),nl(6),nl(5)],'g');
        set(hq(end),'tag','backgr_left','FaceAlpha',0.05);
        hq(end+1) = line(M3(1),M3(3),'color','r','marker','.');
        hq(end+1) = line(Mc(1),Mc(3),'color','k','marker','.');
	else
        hq(end+1) = findobj(ax_left,'type','patch','tag','backgr_left');
        set(hq(end),'Xdata',[nl(1),nl(2),nl(2),nl(1),nl(1)]','Ydata',[nl(5),nl(5),nl(6),nl(6),nl(5)]',...
            'Zdata',[],'FaceColor','g');
	end
	hold off
	view(3)
	for j = 1:length(hq)
        rotate(hq(j),[1 0 0],90,[nl(1) nl(5) 0]);
	end
	axis([nl(1),nl(2)+0.01,nl(5),nl(5)+5,0,nl(6)-nl(5)]); %[-20 0.1 -10 0 0 10.1]
	set(ax_left,'tag','ax_left','pos',posl);
	axis off
	
	%---------------------------------------------------------
	% yz-plane contour
	set(f,'CurrentAxes',ax_right);
	x1 = zx(2); y1 = zx(3);
	x2 = xy(2); y2 = xy(3);
	mat = [y1^2,x1*y1,1; y2^2,x2*y2,1; 2*y1,x1,0];
	ellip_par = mat\[-x1^2;-x2^2;0];
	A2d = [1 ellip_par(2)/2; ellip_par(2)/2 ellip_par(1)]*(-1/ellip_par(3));
	[U2d,L2d] = eig(A2d);
	thet = [0:51]/50*2*pi;
	cyz = U2d*[1/sqrt(L2d(1,1))*cos(thet);1/sqrt(L2d(2,2))*sin(thet)];
	cyz = cyz+repmat([M3(2);M3(3)],1,length(thet));
	
	if fl
        x1c = zxc(2); y1c = zxc(3);
        x2c = xyc(2); y2c = xyc(3);
        matc = [y1c^2,x1c*y1c,1; y2c^2,x2c*y2c,1; 2*y1c,x1c,0];
        ellip_parc = matc\[-x1c^2;-x2c^2;0];
        A2dc = [1 ellip_parc(2)/2; ellip_parc(2)/2 ellip_parc(1)]*(-1/ellip_parc(3));
        [U2dc,L2dc] = eig(A2dc);
        cyzc = U2dc*[1/sqrt(L2dc(1,1))*cos(thet);1/sqrt(L2dc(2,2))*sin(thet)];
        cyzc = cyzc+repmat([Mc(2);Mc(3)],1,length(thet));
	end
	if get(showtr,'val')
        hold on
	end
	hp = plot(cyz(2,:),cyz(1,:),'r','linewidth',1); 
	hold on
	if fl
        hp(end+1) = plot(cyzc(2,:),cyzc(1,:),'linewidth',1,'color',con_fact*[1 1 1]);
	end
	la = axis;
	nr = [min(la(1),n(1)),max(la(2),n(2)),min(la(3),n(3)),max(la(4),n(4)),n(5:6)];
	
	if ~get(showtr,'val')
        hp(end+1) = fill([nr(5),nr(5),nr(6),nr(6),nr(5)],[nr(3),nr(4),nr(4),nr(3),nr(3)],'g');
        set(hp(end),'tag','backgr_right','FaceAlpha',0.05);
        hp(end+1) = line(M3(3),M3(2),'color','r','marker','.');
        hp(end+1) = line(Mc(3),Mc(2),'color','k','marker','.');
	else
        hp(end+1) = findobj(ax_right,'type','patch','tag','backgr_right');
        set(hp(end),'Xdata',[nr(5),nr(5),nr(6),nr(6),nr(5)]','Ydata',[nr(3),nr(4),nr(4),nr(3),nr(3)]',...
            'Zdata',[],'FaceColor','g');
	end
	hold off
	
	for j = 1:length(hp)
        rotate(hp(j),[0 1 0],-90,[nr(5) 0 0]);
	end
	view(3)
	
	axis([nr(5),nr(5)+5,nr(3),nr(4)+0.01,0,nr(6)-nr(5)]);
	set(ax_right,'tag','ax_right','pos',posr);
	axis off
	
	
	%------------------------------------------------------------------
	
	if strcmpi(caller,'mpcagui') 
        ctr_data = {pc,qc,rc};
	end
	
	
	%------------------------------------------------------------------
else
    set(allchild(ax_right),'visible','off')
    set(allchild(ax_left),'visible','off')
    set(allchild(ax_down),'visible','off')
end
%keyboard % for running nncreatefig