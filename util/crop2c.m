function img_c = crop2c(img, crop_size)
% crop img center out
% inputs:
%   img:    original image
%   crop_size:  output image size [X,Y]
% outputs:
%   img_c:  output image
% Xucheng Zhu Dec.2017

I_size = size(img);
I_size1 = I_size(1:2);
crop_size = min(crop_size, I_size1);
crop_size = max(crop_size,1);
I_size(1:2) = crop_size;

I_center = floor(I_size1/2);
X_ind = round(I_center(1) - crop_size(1)/2)+1 :...
    round(I_center(1) + crop_size(1)/2);
Y_ind = round(I_center(2) - crop_size(2)/2)+1 :...
    round(I_center(2) + crop_size(2)/2);

if(length(I_size)>2)
    img_c = img(X_ind,Y_ind,:);
    img_c = reshape(img_c,I_size);
else
    img_c = img(X_ind,Y_ind);
end
