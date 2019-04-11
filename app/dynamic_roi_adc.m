function [roi_adc, roi_rmse, roi_SNR] = dynamic_roi_adc(img_ref,img_arr,b_arr,FAC_arr,noise_level)
% interactive selection of ROI
% input:
%     img_ref: reference image [Nx,Ny]
%     img_arr: C13 img array [nx,ny,b_arr,T]
%     b_arr: b_value_array [3,1]
%     FAC_arr: FA correction [3,1]
%     noise_level: noise level
% output:
%     roi_adc: adc estimation [1,T]
%     roi_SNR: roi SNR calculation [3,T]

figure;
HImg = abs(img_ref)./max(abs(img_ref(:)));
nsize = size(img_arr);

mask1 = roipoly(HImg);
mask = imresize(mask1,nsize(1:2));
mask = repmat(mask,1,1,nsize(3),nsize(4));
m_img = mask.*img_arr;
roi_adc = zeros(1,nsize(4));
roi_rmse = zeros(1,nsize(4));
roi_SNR = squeeze(abs(sum(sum(m_img,1),2))/(noise_level+eps));
for i = 1:nsize(4)
    x0 = [1;0];
    [x, ~, ~, RMSE] = expfitw(b_arr,roi_SNR(:,i)./FAC_arr,x0,FAC_arr);
    roi_adc(i) = x(2);
    roi_rmse(i) = RMSE;
end

