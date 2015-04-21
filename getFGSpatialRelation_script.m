% script to quantify the spatial relationship of DA-striatum pathways



%%%%%%%%%%%%%%%%% approach 1:

%     do a one-way ANOVA/t-tests on x,y, and z coordinates
% respectively of fiber groups within each subject;
% assign 1,0, or -1 depending on outcome of each test;
% do a sign test on these values to test for sig differences along the
%  med-lat (x-coord), ant-posterior (y-coord) and sup-inferior axes across
%  subjects

% use dtiFGSignTests for approach #1


%%%%%%%%%%%%%%%%% approach 2:

%     use dtiComputeDiffusionPropertiesAlongFG,
%         dtiFiberGroupPropertyWeightedAverage, &
%         dtiComputeSuperFiberRepresentation
%     to compute mean and var/covar matrices along fiber group pathway nodes

% this script is for approach #2


%% sign test of x,y,z coordinates of fiber pathway endpoints

% this script tests whether does within-subject one-way anova one DA endpoint coordinates for given fiber groups (if fgs > 3) paired t-tests for x coordinates
% of NAcc and putamen fiber groups, assigns a value of 1, 0, or -1 for each
% subject depending on the t-test, then does a sign test across subjects to
% test if the groups differ in laterality.  Does the same thing for y and z
% coordinates, too. 
% 
% About sign tests (from Meriaux et al., 2006):
% 
% The sign test [7] is designed to test the mean of a symmetric population (or, more generally, the median of an arbitrary population)
% and may be used in place of the one sample t-test when the normality assumption is questionable. The sign statistic is deﬁned as
% the proportion of positive effects in the sample:
% Ts = n+ / n
% Under the null hypothesis H0, positive and negative signs are
% equally likely, implying that n+ follows a binomial law Bn, 1/2
% whatever the input data. 


%%

% SuperFiber structure has the fiber groups mean coords & spread: 

%   SuperFiber.fibers: means (for every coordinate, every node)
%   SuperFiber.fibervarcovs: low diag var/cov matrix for coordinates
%                          (every node)): [var(x), cov(x, y),
%                          cov(x, z), var(y), cov(y, z), var(z)]

% cd '/Users/Kelly/dti/data/fgMeasures/mrtrix'
% load('DA_nacc_20nodesR.mat')
% SuperFibers{1}
% SuperFibers{1}.fibervarcovs
% SuperFibers{1}.fibervarcovs{1}

%% display fiber endpoints in 2d planes overlaid on anatomy

%% display fiber endpoint densities in 2d planes overlaid on anatomy

%% display fiber endpoints overlaid on 3d mesh of DA ROI

%% display fiber endpoint densities overlaid on 3d mesh of DA ROI


%% quantify the spatial relationship between pathways

%% group test for spatial relationship between pathways

% see dtiCompareFGEndpts

%% k-means clustering 












