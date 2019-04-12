function S = sums(arr,dims)
% sum through certain dimensions
% Inputs:
%   arr : N-d matrix
%   dims : dim arrays
% Outputs:
%   S : sum 
%
% Xucheng Zhu Apr,2019
dims = dims(:)';
S = arr;
for k = dims
    S = sum(S,k);
end
S = squeeze(S);
end