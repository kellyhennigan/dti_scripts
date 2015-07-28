function [T2,stats]=getHT2(X)
% -------------------------------------------------------------------------
% usage: compute a Hotelling T-squared value & its associated p value for a
% one sample t-test on multivariate data. 
% 
% a hotelling's t2 test is the multivariate equivalent of the t-test.
% Whereas the t-test is designed to assess whether two groups come from the
% same sampling distribution by comparing their means, the hotelling's t2
% assesses does this by comparing their mean *vectors* of multivariate
% data.
% 
% 
% INPUT:
%   X - n x p matrix of data with observations of each variable in columns
%   
% 
% OUTPUT:
%   T2 - hotelling t-squared 
%   stats - F,p value of t2, and df
% 
% NOTES:
% 
% author: Kelly, kelhennigan@gmail.com, 25-Apr-2015
% 
% see here for more info:
% http://www.public.iastate.edu/~maitra/stat501/lectures/InferenceForMeans-Hotelling.pdf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% H0: the mean vector of X is [0,0,0]
% Ha: the mean vector of X is different than [0,0,0]

[n,p] = size(X); % n = # of observations & p= # of variables/dimensions

T2 = n * mean(X) * inv(cov(X)) * mean(X)'; % compute Hotelling T2 stat


% sampling distribution of T2 when H0 is true: 
    
%            p(n-1)
%  T2  ?    --------  F(p,n-p)
%            (n-p)


F = T2 .* (n-p)./ (p*(n-1)); % get associated F-stat

df = [p,n-p];  % degrees of freedom

p = fpdf(F,df(1),df(2)); % p-value for F with (p,n-p) df


%% put stats into a struct

stats = struct();

stats.F = F;
stats.p = p;
stats.df = df; 
stats.p = p;




