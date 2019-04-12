function [img_data, header] = Varian_14T_EPI_recon(folder_name, recon_params)
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
% nb = recon_params.nb;
% from header
b_val = header.bval_array;
nb = length(b_val);

% number of metabolites
% ncomp = recon_params.ncomp;
ncomp = header.cs;

% dynamic values
% dyn = recon_params.dyn;
dyn = header.celem/(ncomp*nb);

if header.gre_dse == 1
    data = reshape(fid,[X,Y,F,T]);
    data = permute(data,[1 2 4 3]);
else
    data =  fid;
    F = 1;
end

data = padarray(data,recon_params.psize);
[X,Y] = size(data(:,:,1));
img_data = ifft2c(data);

crop_ratio = recon_params.crop_ratio;
crop_size = floor([X,Y]*crop_ratio);
img_data = crop2c(img_data,crop_size);

img_data = reshape(img_data,[crop_size,F,nb,ncomp,dyn]);

cd(tmp_dir);
