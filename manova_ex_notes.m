% manova notes/ example


%% first load some example data: 

cd '/Users/Kelly/dti/data/sa01/fg_densities/conTrack'
fdl=readFileNifti('naccL_da_endpts_s3_sn.nii.gz')
fdr=readFileNifti('naccR_da_endpts_s3_sn.nii.gz')
imgs{1}=fdl.data; imgs{2}=fdr.data;

CoM = cell2mat(cellfun(@(x) centerofmass(x), imgs,'UniformOutput',0))'; %    get fiber density center of mass
    
    
% get img values, coordinates w/non-zero values, and make a group idx
D = [];  coords = [];  gi = [];
    for r=1:2
        idx=find(imgs{r});    
        D=[D;imgs{r}(idx)];
        [i j k]=ind2sub(size(imgs{r}),idx);
        coords = [coords; [i j k]];
        gi = [gi; r.* ones(length(idx),1)]; % group index 
    end
    
    acpcCoords = mrAnatXformCoords(fdl.qto_xyz,coords);
    acpcCoords(:,1) = abs(acpcCoords(:,1));  % get abs() of x-coords
    
    
    %% do manova 
    
    [d,p,stats] = manova1(acpcCoords,gi)
    
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
c1 = stats.canon(:,1);
c2 = stats.canon(:,2);
figure()
gscatter(c2,c1,,gi,'oxs')






%%

% f-stat check 

% define some random data
y0= randn(50,2); % 2 columns of random data
n = size(y0,1);  % sample size


repmat(my,1,n)
ssy=sum((y-repmat(my,n,1)).^2)

y=y0(:,1)-y0(:,2);
my=sum(y)./n;

vary=sum((y-repmat(my,n,1)).^2)./(n-1);
sdy=sqrt(vary);


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

