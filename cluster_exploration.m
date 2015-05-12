% clustering analysis on dti data

%% define directories and file names, load files

clear all
close all


% get experiment-specific paths & cd to main data dir
p = getDTIPaths; cd(p.data);


% load sample data from subject 'sa01' of caud, nacc, and put R fibers
load('CNP_endpts_ex.mat');
X= endpts;

cols = getDTIColors([1,4,5]);

ci=ones(length(labs),1); ci(labs=='n')=2; ci(labs=='p')=3;
ci=getRgbVec(ci,cols);


%% for reference, plot this subj's fibers:

% figure;
AFQ_RenderFibers(fg_caud,'tubes',0,'numfibers',500,'color',cols(1,:));
AFQ_RenderFibers(fg_nacc,'tubes',0,'numfibers',500,'color',cols(2,:),'newfig',0);
AFQ_RenderFibers(fg_put,'tubes',0,'numfibers',500,'color',cols(3,:),'newfig',0);


figure;
subplot(1,2,1) 
 hold on
    scatter3(X(:,1),X(:,2),X(:,3),10,ci,'filled'); 
xlabel('x'), ylabel('y'), zlabel('z')
title('DA endpoints');
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
hold off

subplot(1,2,2) 
 hold on
 scatter3(X(:,4),X(:,5),X(:,6),10,ci,'filled');
xlabel('x'), ylabel('y'), zlabel('z')
title('Striatum endpoints');
cameratoolbar('Show');  cameratoolbar('SetMode','orbit');
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% how many clusters?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% method 1: visual exploration w/pca 

%     matlab suggests reducing dimensions in data to 2 for visualization
%     purposes


[~,score]=pca(X,'NumComponents',2);
GMModels = cell(3,1); % Preallocation
options = statset('MaxIter',1000,'Display','final');
rng(1); % For reproducibility
for j = 1:3
    GMModels{j} = fitgmdist(score,j,'Options',options);
    fprintf('\n GM Mean for %i Component(s)\n',j)
    Mu = GMModels{j}.mu
end

% the model distinguishes amongst the different fiber groups if the means
% in the three component model are different 

figure
for j = 1:3
    subplot(2,2,j)
    gscatter(score(:,1),score(:,2),labs,cols)
    
    hold on
    ezcontour(@(x1,x2)pdf(GMModels{j},[x1 x2]),...
        cell2mat(get(gca,{'XLim','YLim'})),100)
    title(sprintf('GM Model - %i Component(s)',j));
    xlabel('1st principal component');
    ylabel('2nd principal component');
    if(j ~= 3)
        legend off;
    end
    hold off
end
g = legend;
set(g,'Position',[0.7,0.25,0.1,0.1])


% cameratoolbar('Show');  cameratoolbar('SetMode','orbit');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% method 2: use AIC or BIC

[n,d] = size(X); % number of samples
nC = 4;  % number of clusters to try

nll = zeros(1,nC);  % negative log-likelihood
m = zeros(1,nC);    % number of estimated parameters for model w/k-components
AIC = zeros(1,nC);  % 2*nll + 2*m (where m is the # of estimated params)
BIC = zeros(1,nC);  % 2*nll + m*(log(n))

GMModels = cell(1,nC);
options = statset('MaxIter',500);
for c = 1:nC
    GMModels{c} = fitgmdist(X,c,'Options',options);
    nll(c) = GMModels{c}.NegativeLogLikelihood;
    m(c) = (c-1) + c.* (d + d.* (d+1)./2);
    AIC(c)= GMModels{c}.AIC;
    BIC(c)= GMModels{c}.BIC;
end


% find the number of components that minimizes AIC/BIC
[minAIC,numComponents] = min(AIC);
BestModel_AIC = GMModels{numComponents};


[minBIC,numComponents] = min(BIC);
BestModel_BIC = GMModels{numComponents};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% method 3: use evalclusters

maxK = 10;

% use evalclusters w/gmm 
eva = evalclusters(d,'gmdistribution','CalinskiHarabasz','KList',[1:10]);
eva 

% or try it with k-means
eva = evalclusters(d,'kmeans','CalinskiHarabasz','KList',[1:maxK]);
eva


% or specify a clustering function handle to use of the form, C =
% clustfun(DATA,K): 
myfunc = @(X,K)(kmeans(X, K, 'emptyaction','singleton',...
    'replicate',5));

eva = evalclusters(d,myfunc,'CalinskiHarabasz',...
    'klist',1:maxK)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% method 4: using kmeans 


% compare silhouette plots/values of 3-5 clusters

% get 2-7 cluster indices
nC = 2:7;
for i = 1:numel(nC)
    idx = kmeans(X,nC(i));
    figure;
[silh{i},h]=silhouette(X,idx);
h = gca;
h.Children.EdgeColor = [.8 .8 1];
xlabel 'Silhouette Value';
ylabel 'Cluster';
title([num2str(nC(i)) ' clusters']);
end

% higher mean silhouette value means better fit - looks like 3 clusters is
% best
mean(silh{1})
mean(silh{2})
mean(silh{3})
mean(silh{4})
mean(silh{5})


idx3 = kmeans(X,3);
idx4 = kmeans(X,4);
idx5 = kmeans(X,5);

% silhouette plot to determine how separated the clusters are (low/neg
% values are bad)


% try 4 cluster numbers
idx4 = kmeans(X,4,'Display','iter');
figure;
[silh4,h] = silhouette(X,idx4);
h = gca;
h.Children.EdgeColor = [.8 .8 1];
xlabel 'Silhouette Value';
ylabel 'Cluster';

mean(silh3)
mean(silh4)

X2 = [X(:,1),X(:,3)];  % 2-dimensional X
[idx,C] = kmeans(X2,3);

% create a mesh grid 
x1 = min(X2(:,1)):0.01:max(X2(:,1));
x2 = min(X2(:,2)):0.01:max(X2(:,2));

[x1G,x2G] = meshgrid(x1,x2);
XGrid = [x1G(:),x2G(:)]; % Defines a fine grid on the plot
idx2Region = kmeans(XGrid,3,'MaxIter',1,'Start',C);


figure;
gscatter(XGrid(:,1),XGrid(:,2),idx2Region,...
    [0,0.75,0.75;0.75,0,0.75;0.75,0.75,0],'..');
hold on;
plot(X2(:,1),X2(:,2),'k*','MarkerSize',2);
title 'DA pathway endpts';
xlabel 'x-coords'
ylabel 'z-coords'
legend('Region 1','Region 2','Region 3','Data','Location','Best');
hold off;


figure;

