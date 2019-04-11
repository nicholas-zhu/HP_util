function Y = imflatten(X)

% IMFLATTEN Converts a 3D stack of images to a single 2D image, similar to
% the display produced by MONTAGE.
%
% Syntax:
%   Y = IMFLATTEN(X)
%
% Inputs:
%   X : 3D stack of images
%
% Outputs:
%   Y : 2D array of images
%
% Example:
%     % Create some images (256 x 256 x 12)
%     I = permute(repmat(phantom(256)',[1 1 12]),[2 3 1]);
%     I = permute(I.*repmat([1:12],[256, 1, 256]), [1,3,2]);
%     figure('Name','Montage');
%     montage(permute(mat2gray(I), [1 2 4 3])); colormap jet
% 
%     % Convert to a single image (768 x 1024)
%     J = imflatten(I);
%     figure('Name','Single Image'); set(gca,'position',[0 0 1 1]);
%     imagesc(J); axis image off; colormap jet
%    
%    
% See also:  imstack montage4real
%
% 09/27/12, Dave J. Niles, University of Wisconsin, djniles@wisc.edu

if nargin < 1,  error('Not enough input arguments.');   end

X = squeeze(X);

dim = size(X);
if length(dim) > 2
    datalim = limits(X);
    montage4real(X);
    f = gcf;
    set(f,'Visible','off');
    kid = get(gca,'Children');
    data = get(kid,'CData');
    Y = data.*diff(datalim) + datalim(1);
    delete(f);
else
    Y = X;
end

end % eof
