function [ kmap, roi_fit] =  k_ex_fit(HImg,img_arr,b_arr,dT_arr,T1)
% fit lactate efflux process
% Inputs:
%   HImg: anatomical referncereference image [Nx,Ny]
%   img_arr: C13 img array [nx,ny,b_arr,T]
%   b_arr: b_value_array [nb,1]
%   dT_arr: time array, [Tn,1];
% Outputs:
%   kmap: kex_map and F_map
%   roi_fit: biexp fit
%
%   Zijun Cui, August 2018
%   Xucheng Zhu, April 2019

if nargin<5
    T1 = 25;
end
T1C = exp(-cumsum(dT_arr(:))/T1);
T1C = [1;T1C];

% data definition
HImg = abs(HImg)./max(abs(HImg(:)));

% dynamic dwi data
% [nx, ny, nm, nb, Dyn]
nsize = size(img_arr);
im_size = nsize(1:2);
nm = nsize(3);% 1 for pyruvate, 2 for lactate
nb = nsize(4);
Dyn_N = nsize(5);
assert(nb==length(b_arr),'b-vals cannot match DWI images!');
FA_lac = cosd(30);
FA_pyr = cosd(10);
FAC_arr = FA_lac.^((0:nb-1)');

% mask
mask1 = roipoly(HImg);
mask = imresize(mask1,im_size);
lac_img = squeeze(img_arr(:,:,2,:,:));
roi_fit = dynamic_biexp_adc(HImg,lac_img,b_arr,FAC_arr,mask);
pyr_img = squeeze(img_arr(:,:,1,1,1:length(dT_arr)+1));% first b-val pyr
lac_in_img = squeeze(roi_fit.adc(:,:,1,1:length(dT_arr)+1));
lac_out_img = squeeze(roi_fit.adc(:,:,2,1:length(dT_arr)+1));
FAC_t1 = double(sqrt(1-FA_lac.^2)*FA_lac.^nb.^(0:length(dT_arr)).*(T1C'));
FAC_t2 = double(sqrt(1-FA_pyr.^2)*FA_pyr.^(0:length(dT_arr)).*(T1C'));
pyr_img = double(pyr_img./permute(FAC_t2,[1 3 2]));
lac_in_img = double(lac_in_img./permute(FAC_t1,[1 3 2]));
lac_out_img = double(lac_out_img./permute(FAC_t1,[1 3 2]));

kex = zeros(size(mask));
F = zeros(size(mask));
[ind_x,ind_y] = find(mask==1);
for k = 1:length(ind_x)
    dSin = squeeze(diff(lac_in_img(ind_x(k),ind_y(k),:),[],3))./dT_arr;
    dSout = squeeze(diff(lac_out_img(ind_x(k),ind_y(k),:),[],3))./dT_arr;
    Sin = squeeze(lac_in_img(ind_x(k),ind_y(k),1:end-1)+lac_in_img(ind_x(k),ind_y(k),2:end))/2;
    Sout = squeeze(lac_out_img(ind_x(k),ind_y(k),1:end-1)+lac_out_img(ind_x(k),ind_y(k),2:end))/2;
    dSpyr = squeeze(diff(sum(sum(pyr_img(ind_x(k),ind_y(k),1:end),1),2),[],3))./dT_arr;
    %use CVX toolbox 
    cvx_begin  
        variable k_inex;
        variable F_lac nonnegative; 
        minimize(sum((FAC_t1(1:end-1)'.*(dSin + k_inex*Sin + dSpyr)).^2)+...
            sum((FAC_t1(1:end-1)'.*(dSout - k_inex*Sin + F_lac*Sout)).^2)); 
    cvx_end 
    F(ind_x(k),ind_y(k)) = F_lac;
    kex(ind_x(k),ind_y(k)) = k_inex;
end

kmap.F = F;
kmap.kex = kex;
end