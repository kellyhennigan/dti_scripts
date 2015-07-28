% stats to report 

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);

  targets = {'null_caudateL', 'null_caudateR';
        'null_naccL', 'null_naccR';
        'null_putamenL', 'null_putamenR'};
    
space = 'ns';
fdStr = '_da_endpts';

%% do it 

cd(p.data);

cd CoMs
load('CoM_null_CNP_LR_ns_S3.mat')


%% can I collapse across left and right groups? use a hotelling t2 test
% to check for differences in x,y,z coords for each left and rig tgroup

cL = coords(:,1);
cR = coords(:,2);

for t=1:3

    coords{t,1}(:,1)=abs(coords{t,1}(:,1)); % get abs() of x-coords on left side
    [T2,stats]=getHT2(coords{t,1}-coords{t,2});
    if stats.p<.05
        fprintf(['\nthere''s a sig diff between L and R ' targets{t,1}(1:end-1) '!\n']);
    else
        fprintf(['\nthere''s no diff between L and R ' targets{t,1}(1:end-1) '\n']);
    end

    coords{t,1} = (coords{t,1}+coords{t,2})./2; % combine L and R sides
end

coords(:,2)=[];

ca = coords{1};
na = coords{2};
pu = coords{3};






%% do pairwise-hotelling t2 tests to evaluate distance between fiber groups

[T2,stats]=getHT2(ca-na)
[T2,stats]=getHT2(pu-ca)
[T2,stats]=getHT2(pu-na)




%% 


% put in N,C,P order
x = [na(:,1),ca(:,1),pu(:,1)];
y = [na(:,2),ca(:,2),pu(:,2)];
z = [na(:,3),ca(:,3),pu(:,3)];






%% test for laterality 


[p,tab]=anova_rm(x);
px = p(1);
Fx = tab{2,5};
dfFx = [tab{2,3} tab{3,3}];

fprintf('\n\n laterality result: \n');  %
fprintf(['F(' num2str(dfFx) ') = ' num2str(Fx) ', p=' num2str(px) '\n'])


[h,p,ci,stats]=ttest(x(:,3)-x(:,1))   
[h,p,ci,stats]=ttest(x(:,2)-x(:,1))   
[h,p,ci,stats]=ttest(x(:,3)-x(:,2))   


fprintf('\n\n caud vs nacc lateriality: \n');  %




% [py, hy] = signtest(signtest_vals(2,:))

% medial-lateral: nacc > caudate > putamen




%% test for y-position

[p,tab]=anova_rm(y);
py = p(1);
Fy = tab{2,5};
dfFy = [tab{2,3} tab{3,3}];

fprintf('\n\n y result: \n');  %
fprintf(['F(' num2str(dfFy) ') = ' num2str(Fy) ', p=' num2str(py) '\n'])

[h,p,ci,stats]=ttest(y(:,3)-y(:,1))
[h,p,ci,stats]=ttest(y(:,2)-y(:,1))  
[h,p,ci,stats]=ttest(y(:,3)-y(:,2))  




%% test for z-position

[p,tab]=anova_rm(z);
pz = p(1);
Fz = tab{2,5};
dfFz = [tab{2,3} tab{3,3}];

fprintf('\n\n z result: \n');  %
fprintf(['F(' num2str(dfFz) ') = ' num2str(Fz) ', p=' num2str(pz) '\n'])

[h,p,ci,stats]=ttest(z(:,3)-z(:,1))   
[h,p,ci,stats]=ttest(z(:,2)-z(:,1))   
[h,p,ci,stats]=ttest(z(:,3)-z(:,2))   



%% 

%% long form

N=size(coords{1},1);
g = [ones(N,1);ones(N,1).*2;ones(N,1).*3]
all_c = [ca;na;pu];

[d,p,stats]=manova1(all_c,g)

% shows that there is evidence to support 2 dimensions for 
% these fiber groups


% % long form: 
% n=numel(subjects);
% xl = [x(:,1);x(:,2);x(:,3)];
% yl = [y(:,1);y(:,2);y(:,3)];
% zl = [z(:,1);z(:,2);z(:,3)];
% fg = [repmat({'nacc'},n,1);repmat({'caud'},n,1);repmat({'put'},n,1)];
% 
% 
% t = table(fg,xl,yl,zl,'VariableNames',{'fg','x','y','z'});
% Meas = table([1 2 3]','VariableNames',{'Measurements'});
% 
% rm = fitrm(t,'x-z~fg','WithinDesign',Meas)

%%

rois = {'nacc','caud','put'};
acpcCoords(:,:,1) = na;
acpcCoords(:,:,2) = ca;
acpcCoords(:,:,3) = pu;

[N,nd,ng]=size(acpcCoords);

strs = {}; % strings to keep track of fiber density stats
pT2=[];

for r = 1:numel(rois)
    
    rois2 = rois; rois2(r) = []; % rois2 now has the rois to be compared
    
    coords2 = acpcCoords;
    coords2(:,:,r) = [];
    
    d = diff(coords2,1,3);  % distances 
    
    mean_d = mean(d);       % mean
    se_d = std(d)./sqrt(N); % se

    
    % do Hotelling's t-squared test
    [t2,stats] = getHT2(d); 
    pT2(end+1) = stats.p;
    
     strs{end+1} = sprintf(['\nmean +/- se of distance between ' rois2{1} ' and ' rois2{2} ':\n']); 
      
    if ~(stats.p < .001)
    
        strs{end} = [strs{end} ' ***NOT SIG***'];  
      
    end
    
   strs{end} =  [strs{end} sprintf('%s%4.2f%s%4.2f\n', 'x: ',mean_d(1),' +/- ', se_d(1))]; 
   strs{end} =  [strs{end} sprintf('%s%4.2f%s%4.2f\n', 'y: ',mean_d(2),' +/- ', se_d(2))]; 
   strs{end} =  [strs{end} sprintf('%s%4.2f%s%4.2f\n', 'z: ',mean_d(3),' +/- ', se_d(3))]; 
   disp(strs{end});
    
end


%% get distances from each roi
    

nc_dist = sqrt(sum([na-ca].^2,2));
np_dist = sqrt(sum([na-pu].^2,2));
cp_dist = sqrt(sum([ca-pu].^2,2));



%% 





