function [b, interval] = decay_fitting2(x,y,weight)
% decay rate fitting/ ADC fitting

addpath(genpath('/Users/xuchengzhu/Documents/Graduate/Research/Projects/HyperpolarizedMRI/HP_util/'))

if nargin<3
    weight = ones(numel(x),1);
end
b0 = [1,0];

res = fit(x(:),y(:),'exp1','Start',b0,'Weight',weight);
bt = coeffvalues(res);
intervalt = confint(res);
b = bt(2);
interval = intervalt(:,2);