function mask = mask_manual_2d(ref_img, o_size, crop_ratio, num_roi)
% manually draw 2d roi on reference image
% August, 2018 Xucheng Zhu

ref_img1 = squeeze(abs(ref_img));
ref_img1 = ref_img1/max(ref_img1+eps);
assert(ndims(ref_img1)==2,'Invalid 2D input!');
i_size = size(ref_img1);

if nargin < 2
    o_size = i_size;
end

if nargin < 3
    crop_ratio = [1, 1];
end

if nargin < 4
    num_roi = 1;
end

mask = zeros(i_size);
for i = 1:num_roi
    mask_t = roipoly(ref_img1);
    mask = mask + mask_t;
end
mask = mask > 0;
mask = imresize(mask,o_size.*crop_ratio);
mask = crop2c(mask,o_size);