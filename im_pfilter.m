function im_f = im_pfilter(im,params)
% image zeropadding and filtering
% inputs:
%   im: image
%   params:
%       psize: pad size [x,y]
%       sigma: gaussian param
% output:
%   im_f: filtered image
%
% Xucheng Zhu Dec/2017

ksp = fft2c(im);
ksp = padarray(ksp,params.psize);
X = size(ksp,1);
Y = size(ksp,2);
Isize = size(ksp);
sig = params.sigma;
win = gausswin(X,X/sig)*(gausswin(Y,Y/sig)');
im_f = ifft2c(ksp.*repmat(win,[1,1,Isize(3:end)]));
