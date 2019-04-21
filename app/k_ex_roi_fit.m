function [ eval, kmap] =  k_ex_roi_fit(HImg,img_arr,b_arr,dT_arr,T1)
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

dSin = squeeze(diff(sum(sum(lac_in_img,1),2),[],3))./dT_arr;
dSout = squeeze(diff(sum(sum(lac_out_img,1),2),[],3))./dT_arr;
Sin = squeeze(sum(sum(lac_in_img(:,:,1:end-1),1),2));
Sout = squeeze(sum(sum(lac_out_img(:,:,1:end-1),1),2));
dSpyr = squeeze(diff(sum(sum(pyr_img(:,:,1:end),1),2),[],3))./dT_arr;

%use CVX toolbox 
cvx_begin  
    variables k_inex F_lac; 
    minimize(sum((FAC_t1(1:end-1)'.*(dSin + k_inex*Sin + dSpyr)).^2)+...
        sum((FAC_t1(1:end-1)'.*(dSout - k_inex*Sin + F_lac*Sout)).^2)); 
cvx_end 


kmap.F = F_lac;
kmap.kex = k_inex;
% evaluation
eval.Sin = Sin.*(FAC_t1(1:length(dT_arr))');
eval.Sout = Sout.*(FAC_t1(1:length(dT_arr))');
eval.Spyr = dSpyr.*(FAC_t2(1:length(dT_arr))');
[Sin_e,Sout_e] = evalx(Sin,Sout,k_inex,F_lac,dSpyr,dT_arr);
eval.Sin_e = Sin_e.*(FAC_t1(1:length(dT_arr))');
eval.Sout_e = Sout_e.*(FAC_t1(1:length(dT_arr))');
% plot
figure;hold on;
plot([eval.Sin,eval.Sout],'-','LineWidth',1);
plot([eval.Sin_e,eval.Sout_e],'--','LineWidth',1);

end

function [Sin_e,Sout_e] = evalx(Sin,Sout,k_inex,F_lac,dSpyr,T_arr)

Iter = 30;
iter = 0;
Sin_e = zeros(length(T_arr),1);
Sout_e = zeros(length(T_arr),1);
Sin_e(1) = Sin(1);
Sout_e(1) = Sout(1);
while iter<=Iter
    iter = iter + 1;
    for i = 1:length(T_arr)-1
        Sin_e(i+1) = -k_inex*T_arr(i)*Sin_e(i)-dSpyr(i)*T_arr(i);
        Sout_e(i+1) = k_inex*T_arr(i)*Sin_e(i) - F_lac*T_arr(i)*Sout_e(i);
    end
    Sin_e(1) = Sin_e(1) - mean(Sin_e(1:3)-Sin(1:3));
    Sout_e(1) = Sout_e(1) - mean(Sout_e(1:3)-Sout(1:3));
end

end