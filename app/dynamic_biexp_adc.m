function [roi_fit, roi_SNR] = dynamic_biexp_adc(img_ref,img_arr,b_arr,FAC_arr,adc_range,noise_level,reg_flag)
% interactive selection of ROI
% input:
%     img_ref: reference image [Nx,Ny]
%     img_arr: C13 img array [nx,ny,b_arr,T]
%     b_arr: b_value_array [nb,1]
%     FAC_arr: FA correction [nb,1]
%     adc_range: fit range [4,2]
%     noise_level: noise level
% output:
%     roi_fit result:   adc{S_L,S_H,ADC_L,ADC_H estimation [nx,ny,4,T]}
%                       R2{[nx,ny,1,T]}
%
% Xucheng Zhu, Apr 2019

if nargin < 5
    adc_range(:,1) = [0,0,1.8e-4,6e-4];
    adc_range(:,2) = [inf,inf,2.2e-4,8e-4];
end
if nargin < 6
    noise_level = std(vec(img_arr(:,1,end)));
end
if nargin < 7
    reg_flag = 1;
end

% structure reference scan
HImg = abs(img_ref)./max(abs(img_ref(:)));

% dynamic dwi data
nsize = size(img_arr);
im_size = nsize(1:2);
nb = nsize(3);
Dyn_N = nsize(4);
assert(nb==length(b_arr),'b-vals cannot match DWI images!');

% mask
figure;
mask1 = roipoly(HImg);
mask = imresize(mask1,im_size);
img_arr = abs(img_arr);
m_img = mask.*img_arr;
roi_adc = zeros([im_size,4,Dyn_N]);

roi_r2 = zeros([im_size,1,Dyn_N]);
roi_SNR = m_img/(noise_level+eps);

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
        dwi_pixel = vec(img_arr(ind_x(k),ind_y(k),:,i))./vec(FAC_arr);%./correction.^(1:4)';
        [x, R2t] =biexp_fit(b_arr,dwi_pixel,vec(FAC_arr),adc_range);
        roi_adc(ind_x(k),ind_y(k),:,i) = x;
        roi_r2(ind_x(k),ind_y(k),1,i) = R2t;        
    end
end

roi_fit.adc = roi_adc;
roi_fit.R2 = roi_r2;
roi_fit.SNR_map = roi_SNR;
end

function [x, R2] = biexp_fit(bval,dwi,noise,bound,power_flag)
% bi-exponential fitting
%   S_i = S1*exp(-b*ADC1)+S2*exp(-b*ADC2)
% Input:
%   bval:   b-val [N,1]
%   dwi:    diffusion signal [N,1]
%   noise:  noise [N,1]
%   bound:  bound of Variables x [4,2] S1,S2,ADC1,ADC2
%   power_flag: power method
% Output:
%   x:      fitting result
%   R2:     R square for fitting

if nargin < 4
    bound(:,1) = [0,0,1.8e-4,6e-4];
    bound(:,2) = [inf,inf,2.2e-4,8e-4];
end

if nargin < 5
    power_flag = 1;
end

bval = bval(:);
S = dwi(:);

if power_flag == 1
    S = S.^2-noise.^2;
    afun = @(x,b)(x(1)*exp(-b*x(3))+x(2)*exp(-b*x(4))).^2;
else
    afun = @(x,b)(x(1)*exp(-b*x(3))+x(2)*exp(-b*x(4)));
end
x0 = [S(1)/2,S(1)/2,1e-3,1e-3];
[x,rss] = lsqcurvefit(afun,double(x0),double(bval),double(S),double(bound(:,1)),double(bound(:,2)));

R2 = 1-rss/sum((S-mean(S(:))).^2);
end