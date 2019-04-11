function handle = color_overlay3(imBack,imFront,climFront,climBack,cMapName,alpha)
% COLOR_OVERLAY Color image of data with grayscale background
%    I = COLOR_OVERLAY(B, D) displays an RGB image with a
%    grayscale background image B with a color overlay of the data D and 
%    returns the handle to the figure.
%
%    I = COLOR_OVERLAY(B, D, Dlim, Blim) is the same but uses the
%    data limits Dlim and background limits Blim to display.
%
%    I = COLOR_OVERLAY(B, D, Dlim, Blim, M) is the same but uses the
%    colormap M.
%    
%    I = COLOR_OVERLAY(B, D, Dlim, Blim, M, flag_view) is the same but uses
%    flag_view to determine whether or not to display the final image.
%
%    Example:
%         
%         load mri
%         D = squeeze(D);
%         ph = 256.*phantom(128);
%         color_overlay(D(:,:,8),ph,[10 88],[0 256],'jet');
%
%    Note: This is an update that creates the overlay with a different method.
%    This allows easy generation of the colormap.
%         
%
%    Copyright (R) Matt Smith 06.13.2012
%

% FUTURE WORK: 
%    Color limits above max of data is inaccurate


ALPHADEFAULT = 0.6;

% check arguments
if nargin < 3
    climBack = [min(min(imBack)) max(max(imBack))];
    climFront = [min(min(imFront)) max(max(imFront))];
    alpha = ALPHADEFAULT;
    cMapName = 'jet';
elseif nargin < 5
    alpha = ALPHADEFAULT;
    cMapName = 'jet';
elseif nargin < 6
    alpha = ALPHADEFAULT;
end


% confirm images are same size
[imBackX imBackY] = size(imBack);
[imFrontX imFrontY] = size(imFront);
rows = max(imBackX,imFrontX); 
cols = max(imBackY,imFrontY);
if imBackX ~= imFrontX || imBackY ~= imFrontY
    disp(['Image sizes unequal! Will zero fill to [' num2str(rows) ' ' num2str(cols) ']']);
    imBack = imresize(imBack,[rows cols]);
    imFront = imresize(imFront,[rows cols]);
    clear IMFront IMBack;
end
clear imBackX imFrontX imBackY imFrontY;

% Make imBack RGB
imBack = repmat(mat2gray(double(imBack),double(climBack)),[1 1 3]);

figure;
set(gcf,'Color','k','Units','pixels');%,'Position',[300 500 size(imBack,1)*3 size(imBack,2)*3]);

% Back Image
imagesc(imBack);axis image off;

% Front Image
hold on
handle = imagesc(imFront,climFront);
hold off

alphadata = ones(size(imFront)).*alpha;
alphadata(imFront < climFront(1)) = 0;
set(handle,'AlphaData',alphadata);

% set appropriate colormap
cmapSize = 120;
cmap = eval([cMapName '(' num2str(cmapSize) ');']);
colormap(cmap);

% Colorbar
cbar = colorbar('Location','EastOutside');
% set(cbar,'XColor','w','YColor','w','ZColor','w');
set(cbar,'XColor','w','YColor','w');
% set(cbar,'XTick',[],'YTick',[],'ZTick',[]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Novel colormaps
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% JET2 is the same as jet but with black base
function J = jet2(m)
if nargin < 1
    m = size(get(gcf,'colormap'),1);
    J = jet; J(1,:) = [0 0 0];
end
J = jet(m); J(1,:) = [0 0 0];

% JET3 is the same as jet but with white base
function J = jet3(m)
if nargin < 1
    m = size(get(gcf,'colormap'),1);
    J = jet; J(1,:) = [1 1 1];
end
J = jet(m); J(1,:) = [1 1 1];


% HSV2    is the same as HSV but with black base
function map = hsv2(m)
map =hsv;
map(1,:) = [0 0 0];

% HSV3     is the same as HSV but with white base
function map = hsv3(m)
map =hsv;
map(1,:) = [1 1 1];

% HSV4    a slight modification of hsv (Hue-saturation-value color map)
function map = hsv4(m)
if nargin < 1, m = size(get(gcf,'colormap'),1); end
h = (0:m-1)'/max(m,1);
if isempty(h)
  map = [];
else
  map = hsv2rgb([h h ones(m,1)]);
end


function map = red(m)
map = makeColorMap([0 0 0],[.7 0 0],[1 0 0]);
map(1,:) = [0 0 0];
        
        
function map = green(m)
map = makeColorMap([0 0 0],[0 .7 0],[0 1 0]);
map(1,:) = [0 0 0];
            
            
function map = blue(m)
map = makeColorMap([0 0 0],[0 0 .7],[0 0 1]);
map(1,:) = [0 0 0];