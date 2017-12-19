function im = ifft2c(d)
% Function performs a centered fft2
im = fftshift(ifft2(fftshift(d)));