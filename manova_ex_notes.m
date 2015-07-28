% manova notes/ example




%% get some sample data: 

rng default;  % For reproducibility
mu1 = [1 2];
sigma1 = [3 .2;.2 2];
mu2 = [-1 -2];
sigma2 = [2 0; 0 1];
n1 = 100; n2= 100;
X = [mvnrnd(mu1,sigma1,n1);mvnrnd(mu2,sigma2,n2)];
gi = [ones(n1,1);ones(n2,1).*2];  % group index 

% plot it
figure
scatter(X(gi==1,1),X(gi==1,2),20,'r+')
hold on 
scatter(X(gi==2,1),X(gi==2,2),20,'bo')
legend('group 1','group 2','Location','NW')
 
% 
X1 = randn(10,3);
n1=size(X1,1);
X2 = X1;  X2(:,1)=X2(:,1)+2;
n2=size(X2,1);
X=[X1;X2]
gi=[ones(n1,1);ones(n2,1).*2];

% plot it
figure
scatter(X(gi==1,1),X(gi==1,2),20,'r+')
hold on 
scatter(X(gi==2,1),X(gi==2,2),20,'bo')
legend('group 1','group 2','Location','NW')


    %% do manova 
    
[d,p,st] = manova1(X,gi)
    
% manova1 outputs:

    % d - is an estimate of the dimension of the group means. If the means
    % were all the same, the dimension would be 0, indicating that
    % the means are at the same point. If the means differed but fell along a
    % line, the dimension would be 1. If they differed along a plane, the
    % dimension would be 2, etc. 2 is the largest possible dimension for 3-d
    % data.

    % p - the first p value tests whether the dimension is 0, the next whether
    % the dimension is 1, etc. 
    
% stats - structure w/several fields: 
%     W - matrix analog to within SS 
%     B - between SS
%     T - total SS
%     dfW, dfB, dfT - degrees of freedom for W,B and T
%     lambda, chisq, chisqdf - "ingredients" for the dimensionality test
    
% The next three fields are used to do a canonical analysis. Recall that in
% principal components analysis (Principal Component Analysis (PCA)) you
% look for the combination of the original variables that has the largest
% possible variation. In multivariate analysis of variance, you instead
% look for the linear combination of the original variables that has the
% largest separation between groups. It is the single variable that would
% give the most significant result in a univariate one-way analysis of
% variance. Having found that combination, you next look for the
% combination with the second highest separation, and so on.
% 
% The eigenvec field is a matrix that defines the coefficients of the
% linear combinations of the original variables. The eigenval field is a
% vector measuring the ratio of the between-group variance to the
% within-group variance for the corresponding linear combination. The canon
% field is a matrix of the canonical variable values. Each column is a
% linear combination of the mean-centered original variables, using
% coefficients from the eigenvec matrix.
% 
c1 = st.canon(:,1);
c2 = st.canon(:,2);
figure()
gscatter(c2,c1,gi)






%%

% f-stat check 

% define some random data
y0= randn(50,2); % 2 columns of random data
n = size(y0,1);  % sample size



y=y0(:,1)-y0(:,2);
my=sum(y)./n;

vary=sum((y-repmat(my,n,1)).^2)./(n-1);
sdy=sqrt(vary);

repmat(my,1,n)
ssy=sum((y-repmat(my,n,1)).^2)


%% get t-stat

% method 1: manual calculation
t=my./(sdy./sqrt(n));
p=(1-tcdf(t,n-1)).*2;

% method 2: my glm_fmri_fit function
X= ones(n,1);
stats2= glm_fmri_fit(y,X,ones(50,1));

% method 3: matlab's built-in ttest function
[h,p3,~,stats3]=ttest(y);

% check if the t-stats from different methods are the same 
isequal(t,stats2.tB,stats3.tstat)

% check if p values from different methods are the same 
isequal(p,stats2.pB,p3)


%% now compare f statistics to t2: 

[pF,tabF,statsF]=anova2(y0);

pF2 = 1-fcdf(4.1434,1,49);
isequal(t.^2,tabF{2,5})


%% unequal variances: univariate case 


%  Example 2: Generate values from a bivariate normal distribution with
%        specified mean vector and covariance matrix.
mu = [2 1];
Sigma = [1 .5; .5 2]; R = chol(Sigma);
n=100;

z = repmat(mu,n,1) + randn(n,2)*R;

x1=z(:,1); x2=z(:,2);
n1 = length(x1); n2 = length(x2);

pooledSe = sqrt(var(x1)./n1 + var(x2)./n2)

t = (mean(x1)-mean(x2))./pooledSe

df = ((var(x1)./n1 + var(x2)./n2).^2.)/((var(x1)./n1).^2 ./ (n1-1) + (var(x2)./n2).^2 ./ (n2-1)); 

p = 1-fcdf(t.^2,1,df)

[h,p2,~,stats] = ttest2(x1,x2,'Vartype','unequal')


isequal(t,stats.tstat)
isequal(p,p2)
isequal(df,stats.df)

%% now compare f statistics to t2: 

[pF,tabF,statsF]=anova1([x1,x2])

isequal(t.^2,tabF{2,5}) % slightly different dfs


%% next example: multivariate case w/unequal variances


%  Generate values from a bivariate normal distribution with
%        specified mean vector and covariance matrix.
mu1 = [0 0];
Sigma1 = [1 .5; .5 2]; R1 = chol(Sigma1);
n1=100;

y1 = repmat(mu1,n1,1) + randn(n1,2)*R1;

mu2 = [3 2];
Sigma2 = [3 .8; .7 1]; R2 = chol(Sigma2);
n2=100;

y2 = repmat(mu2,n2,1) + randn(n2,2)*R1;



%% compare location of 2 fiber groups

rmIdx = 3;

coords2 = acpcCoords;
coords2(:,:,rmIdx) = [];
gL(gi==rmIdx)=[];
gi(gi==rmIdx)=[];


% reshape coords to be in long form
X=reshape(permute(coords2,[1 3 2]),N*2,p);

[d,p,stats]=manova1(X,gL);

[MAOV2] = MAOV2(X,alpha)


X1 = [[1:N]';[1:N]'];           % subject
X2 = [ones(N,1); ones(N,1).*2]; % fiber group



X = [X1 X2 coords2R];

maov2(X)



%% use manova for two-sample





%% use hotelling ttest

% x,y,z distance 
coords2_diff = diff(coords2,1,3);

% get stats
[t2,stats]=getHT2(coords2_diff)

HotellingT2(coords2_diff)


x=[acpcCoords(:,1,1),acpcCoords(:,1,2)];
y=[acpcCoords(:,2,1),acpcCoords(:,2,2)];
z=[acpcCoords(:,3,1),acpcCoords(:,3,2)];

% acpcCoords = reshape(permute(acpcCoords,[1 3 2]),length(gi),3);



acpcCoords=acpcCoords-repmat(acpcCoords(:,:,refFG),1,1,3);
acpcCoords=reshape(acpcCoords

acpcCoords = acpcCoords - repmat(mean(acpcCoords),N,1); % mean centered coords


%% do manova test


% The function returns d, an estimate of the dimension of the space
% containing the group means. manova1 tests the null hypothesis that the
% means of each group are the same n-dimensional multivariate vector, and
% that any difference observed in the sample X is due to random chance. If
% d = 0, there is no evidence to reject that hypothesis. If d = 1, then you
% can reject the null hypothesis at the 5% level, but you cannot reject the
% hypothesis that the multivariate means lie on the same line. Similarly,
% if d = 2 the multivariate means may lie on the same plane in
% n-dimensional space, but not on the same line.


fprintf(['\n\n MANOVA test to determine whether there are differences\n' ...
    'in the location of fiber groups'' midbrain endpoints:\n\n']);


[d,p,stats]=manova1(acpcCoords,gL);

fprintf(['\nH0: the fiber groups arise from the same location within the midbrain.\n' ...
    'i.e., the dimension of the space containing the group means is 0.\n\n']);

fprintf(['\nprob of H0: ' num2str(p(1)) '\n'])

% The eigenvec field is a matrix that defines the coefficients of the
% linear combinations of the original variables.
stats.eigvec

% The eigenval field is a vector measuring the ratio of the between-group
% variance to the within-group variance for the corresponding linear
% combination. 
stats.eigenval

% The canon field is a matrix of the canonical variable values. Each column
% is a linear combination of the mean-centered original variables, using
% coefficients from the eigenvec matrix.
if (stats.canon-acpcCoords*stats.eigenvec) < .001
    disp('they are equal!')
end


% A grouped scatter plot of the first two canonical variables shows more
% separation between groups then a grouped scatter plot of any pair of
% original variables. 
c1 = stats.canon(:,1);
c2 = stats.canon(:,2);
figure()
gscatter(c2,c1,gL,[],'oxs')

