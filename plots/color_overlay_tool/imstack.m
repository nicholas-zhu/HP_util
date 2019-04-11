imstfunction Y = imstack(X, side)

% IMSTACK Converts a 2D image to a 3D stack of images.  It is the
% converse of IMFLATTEN.
%
% Syntax:
%   Y = IMSTACK(X, SIDE)
%
% Inputs:
%   X : 2D image
%   SIDE : (square) matrix size of the output image (default = 128)
%
% Outputs:
%   Y : 3D stack of images
%
% Example:
%     % Create a 2D image (768 x 1024)
%     I = [1.*phantom(256) 2.*phantom(256) 3.*phantom(256) 4.*phantom(256); 
%          5.*phantom(256) 6.*phantom(256) 7.*phantom(256) 8.*phantom(256);
%          9.*phantom(256) 10.*phantom(256) 11.*phantom(256) 12.*phantom(256)];
%     figure('Name','Single Image'); 
%     set(gca,'position',[0 0 1 1]);
%     imagesc(I); axis image off; colormap jet
%    
%
% See also:  imflatten montage4real
%
% 09/27/12, Dave J. Niles, University of Wisconsin, djniles@wisc.edu

if nargin < 2,  side = 128; end
if nargin < 1,  error('Not enough input arguments.');   end

arraydim = size(X)./side;
if length(arraydim)~=2, error('Image array must be 2-dimensional.');    end
Y = zeros(side, side, prod(arraydim));

for ii = 1:arraydim(1)
    for jj = 1:arraydim(2)
        Y(:,:,(ii-1)*arraydim(2)+jj) = ...
            X([1:side]+(ii-1)*side, [1:side]+(jj-1)*side); 
    end
end

        
end % eof
