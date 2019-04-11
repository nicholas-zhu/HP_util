function plot_overlay_img(ref_img,o_img,o_range)
% overlay image
% input:
%    ref_img: background image
%    o_img: overlay image
%    o_range: 

ref_size = size(ref_img);
o_img = imresize(o_img,ref_size);
figure;
ax1 = subplot(1,2,1);
imshow(abs(ref_img),[]);colormap(ax1,'gray');colorbar;
ax2 = subplot(1,2,2);
h = imshow(abs(o_img),o_range);colormap(ax2,'hot');colorbar;
h.AlphaData = .8;
%set(layer2,'AlphaData',.8)
