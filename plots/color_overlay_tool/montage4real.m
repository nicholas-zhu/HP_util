function montage4real(I, cmap)

% MONTAGE4REAL is the non-shitty version of montage.
%
% Syntax:
%   MONTAGE4REAL(I)
%   MONTAGE4REAL(I, CMAP)
%
% 7/19/11, Dave J. Niles, University of Wisconsin, djniles@wisc.edu

if nargin < 2,  cmap = jet;     end
figure;
montage(mat2gray(permute(I,[1,2,4,3])));%, 'Size',[2,5]);  % imnorm would be better!
colormap(cmap);

end

    