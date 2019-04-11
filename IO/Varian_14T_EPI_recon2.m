function [img_data, header] = Varian_14T_EPI_recon2(folder_name, recon_params)
% load k-space data/img data and header
%
% outputs:
%  data:    [x, y, echos, b val, metabolites, dyns]
%  header:  structure
%
% Xucheng Zhu Dec/2017

tmp_dir = pwd;
fid_name = [folder_name,'/fid'];
header_name = [folder_name,'/procpar'];
fid = load_echoes(fid_name);
header = load_procpar(header_name);

X = header.np./2;
Y = header.nv;
F = header.slice;
T = length(header.garray);

% b values
nb = recon_params.nb;

% number of metabolites
ncomp = recon_params.ncomp;

% dynamic values
dyn = recon_params.dyn;

if header.gre_dse == 1
    data = reshape(fid,[X,Y,F,T]);
    data = permute(data,[1 2 4 3]);
else
    data =  fid;
    F = 1;
end

if ~(isempty(recon_params.nfreq))
    data = reshape(data,[X,Y,F,nb,ncomp,dyn]);
    for i = 1:ncomp
        data(:,:,:,:,i,:) = data(:,:,:,:,i,:).*repmat(exp(-1i*2*pi*(-Y/2:Y/2-1)/Y*...
            recon_params.nfreq(i)*recon_params.dT),X,1,F,nb,1,dyn);
    end
    data = reshape(data,X,Y,F,T);
end

data = padarray(data,recon_params.psize);
[X,Y] = size(data(:,:,1));
img_data = ifft2c(data);

crop_ratio = recon_params.crop_ratio;
crop_size = floor([X,Y])*crop_ratio;
img_data = crop2c(img_data,crop_size);

img_data = reshape(img_data,[crop_size,F,nb,ncomp,dyn]);

cd(tmp_dir);
