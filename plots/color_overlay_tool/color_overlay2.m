function [handle cmap] = color_overlay2(imBack,imFront,climFront,climBack,cMapName,alpha)

ALPHADEFAULT = 0.4;

% check arguments
if nargin < 3
    climBack = [min(min(imBack)) max(max(imBack))];
    climFront = [min(min(imFront)) max(max(imFront))];
    alpha = ALPHADEFAULT;
    cMapName = 'green';
elseif nargin < 5
    alpha = ALPHADEFAULT;
    cMapName = 'green';
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
%     IMBack = fft2(imBack);
%     IMFront = fft2(imFront);
%     imBack = abs(ifft2(IMBack,rows,cols));
%     imFront = abs(ifft2(IMFront,rows,cols));
    clear IMFront IMBack;
end
clear imBackX imFrontX imBackY imFrontY;

% confirm BACK and FRONT images are indexed
imFront = mat2gray(imFront,climFront);
imBack = mat2gray(imBack,climBack);

% rescale FRONT so scaling matches climBack
% imFront = mat2gray(imFront,climFront);
tmp = imFront.*(climBack(2)-climBack(1)) + climBack(1);


    
% set appropriate size of colormap
cmapSize = 120;
cmap = eval([cMapName '(' num2str(cmapSize) ');']);
cmapSize = size(cmap,1);

rgb = zeros(rows,cols,3);

for i = 1:rows
    for j = 1:cols
        idx = round(imFront(i,j).*cmapSize);
        if idx == 0
            idx = 1;
        end
        rgb(i,j,:) = cmap(idx,:);
    end
end

figure;set(gcf,'Color','k','Units','pixels',...
    'Position',[300 500 size(imBack,1)*3 size(imBack,2)*3]);
imagesc(imBack);colormap('gray');axis image off;
set(gca,'Position',[0 0 1 1]);
hold on
handle = imagesc(rgb);
hold off

alphadata = zeros(size(imFront));
alphadata = (tmp > climBack(1)).*alpha;
set(handle,'AlphaData',alphadata);


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