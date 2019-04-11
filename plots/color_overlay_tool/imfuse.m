function h = imfuse(gray_img, color_img, ALPHA, THRESHOLD)

% IMFUSE overlays a color image series onto a grayscale image series.  
% The function is similar to Matt Smith's color_overlay_tool, except that 
% IMFUSE does not involve a GUI, so large image series can be overlaid
% quickly.
%
% Syntax:
%   h = IMFUSE(GRAY_IMG, COLOR_IMG, ALPHA, THRESHOLD)
%
% Inputs:
%   GRAY_IMG : grayscale image series (2D or 3D)
%   COLOR_IMG : color image series (2D or 3D)
%   ALPHA : transparency (0 - 1; default = 0.6)
%   THRESHOLD : global fractional threshold for color image series 
%               ([LOWER UPPER]; default = [0.2 1.0])
%
% Outputs:
%   H : matrix of figure handles created (GRAY_IMG length x COLOR_IMG
%       length)
%
% Notes:
%   If both GRAY_IMG and COLOR_IMG have 3 dimensions, every possible
%     combination of overlays will be generated.
%
%   If the in-plane dimensions differ between GRAY_IMG and COLOR_IMG, the
%   smaller image series will be resized.
%
% Example:
%     MRI = load('mri');
%     COLOR = squeeze(MRI.D(:,:,:,13:18));
%     for ii = 1:size(COLOR,3),
%         COLOR(:,:,ii) = flipud(COLOR(:,:,ii));
%     end
%     GRAY = phantom(256);
%     h = imfuse(GRAY, COLOR, 0.6, [0.6 1]);
%
% 
% See also:  imnorm
%
% 9/27/12, Dave J. Niles, University of Wisconsin, djniles@wisc.edu

h = [];

% Check the arguments
if nargin < 4,  THRESHOLD = [0.2 1];  end
if nargin < 3,  ALPHA = 0.6;    end
if nargin < 2,  error('Not enough input arguments.');   end

gray_img = double(squeeze(gray_img));
color_img = double(squeeze(color_img));

gray_dim = size(gray_img);
color_dim = size(color_img);

if numel(gray_dim) > 3,
    error('Gray image must be 2D or 3D array.');
end

if numel(color_dim) > 3,
    error('Color image must be 2D or 3D array.');
end

if numel(gray_dim) < 3,     gray_dim  = [gray_dim 1];   end
if numel(color_dim) < 3,    color_dim = [color_dim 1];  end

% Match the in-plane image dimensions
side = [gray_dim(1:2) color_dim(1:2)];
if any(side(1:2) - side(3:4) ~= 0)
    [~, index] = max(side);
    switch index
        case {1,2}
            color_img = imresize(color_img, gray_dim(1:2));
        case {3,4}
            gray_img = imresize(gray_img, color_dim(1:2));
    end
end

% Set the threshold
LIMITS = [min(color_img(:)) max(color_img(:))];
RANGE = diff(LIMITS);
THRESHOLD = THRESHOLD.*RANGE + LIMITS(1);

% Make a nice colormap
jet2 = jet;
jet2(1,:) = 0;

% Perform the overlay
for ii= 1:gray_dim(3)
    for jj = 1:color_dim(3)
        base = repmat(imnorm(gray_img(:,:,ii)), [1 1 3]);
        overlay = color_img(:,:,jj);
        h(ii,jj) = figure('colormap',jet2);
        imagesc(base);
        hold on;
        imagesc(overlay, 'AlphaData', ALPHA);
        axis image off
        colorbar
        set(gca,'clim',THRESHOLD);
        title(['Gray slice=' num2str(ii) ', Color slice=' num2str(jj)]);
    end
end

end % eof