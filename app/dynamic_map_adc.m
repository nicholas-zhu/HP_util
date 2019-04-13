function [roi_fit, roi_r2, roi_SNR] = dynamic_map_adc(img_ref,img_arr,b_arr,FAC_arr,noise_level,reg_flag)
% interactive selection of ROI
% input:
%     img_ref: reference image [Nx,Ny]
%     img_arr: C13 img array [nx,ny,b_arr,T]
%     b_arr: b_value_array [nb,1]
%     FAC_arr: FA correction [nb,1]
%     noise_level: noise level
% output:
%     roi_fit result: adc and S0 estimation [nx,ny,1,T]
%     roi_SNR: roi SNR calculation [nx,ny,b_arr,T]
%
% Xucheng Zhu, Apr 2019

if nargin < 5
    noise_level = std(vec(img_arr(:,1,end)));
end
if nargin < 6
    reg_flag = 1;
end


HImg = abs(img_ref)./max(abs(img_ref(:)));
nsize = size(img_arr);
im_size = nsize(1:2);
nb = nsize(3);
Dyn_N = nsize(4);

figure;
mask1 = roipoly(HImg);
mask = imresize(mask1,im_size);

m_img = mask.*img_arr;
roi_adc = zeros([im_size,1,Dyn_N]);
roi_S0 = zeros([im_size,1,Dyn_N]);
roi_r2 = zeros([im_size,1,Dyn_N]);
roi_SNR = squeeze(abs(sum(sum(m_img,1),2))/(noise_level+eps));

img_arr = abs(img_arr);
if reg_flag ==1
    [optimizer, metric] = imregconfig('monomodal');
    for i = 1:Dyn_N
        for j = 2:nb
          img_arr(:,:,j,i) =imregister(img_arr(:,:,j,i),img_arr(:,:,1,i)*FAC_arr(j),'translation',optimizer, metric);
        end
    end
    
end


[ind_x,ind_y] = find(mask==1);
for i = 1:Dyn_N
    for k = 1:length(ind_x)
        x = [1;0];
        dwi_pixel = vec(img_arr(ind_x(k),ind_y(k),:,i))./vec(FAC_arr);%./correction.^(1:4)';
        [x, ~, SSE, RMSE] = expfitw(b_arr,dwi_pixel',x,FAC_arr(:)');
        roi_adc(ind_x(k),ind_y(k),1,i) = x(2);
        roi_S0(ind_x(k),ind_y(k),1,i) = x(1);
        
        roi_r2(ind_x(k),ind_y(k),1,i) = 1 - SSE/sum((FAC_arr(:).*(dwi_pixel-mean(dwi_pixel))).^2+eps);        
    end
end

roi_fit.adc = roi_adc;
roi_fit.S0 = roi_S0;
end