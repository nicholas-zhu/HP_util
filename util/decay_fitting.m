function [b, R2] = decay_fitting(x,y,weight)
% decay rate fitting/ ADC fitting

addpath(genpath('/Users/xuchengzhu/Documents/Graduate/Research/Projects/HyperpolarizedMRI/HP_util/'))

if nargin<3
    weight = ones(numel(x));
end
b0 = [1,0];

[bt, ~, RSS, RMSE] = expfitw(x(:),y(:),b0,weight(:));
R2 = 1 - RSS/sum(y(:).^2);
b = bt(2);