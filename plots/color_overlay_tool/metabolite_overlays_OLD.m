clear tmp im1 im2 tmp1
% load('D:\Data\C13\djn_20121004_01\_RESULTS\spatial_reg_0.1\dideal_kt_all_reconstructions.mat')
slices = 3:13;

% tmp = dideal_kt_reg_no_fc_no_fmap(:,:,slices,1,1)*1000;
tmp = squeeze(dideal(:,:,1,slices));
im1 = repmat(im(:,:,1),[1 1 size(tmp,3)]);

im2 = imflatten(abs(im1));
tmp1 = imflatten(abs(tmp));

%set lower/upper image limits
close all
image_low = 0.025;
image_high = 0.95;
h = imfuse(im2,tmp1,0.6,[image_low image_high]);
title('Pyruvate')

%% Now Lactate
clear tmp im1 im2 tmp1

tmp = dideal_kt_reg_no_fc_no_fmap(:,:,slices,2,1)*1000;
im1 = repmat(im(:,:,1),[1 1 size(tmp,3)]);

im2 = imflatten(abs(im1));
tmp1 = imflatten(abs(tmp));

%set lower/upper image limits
close all
image_low = 0.25;
image_high = 0.85;
h = imfuse(im2,tmp1,0.6,[image_low image_high]);
title('Lactate')