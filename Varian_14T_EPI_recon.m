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

X = params.np./2;
Y = params.nv;
F = params.slice;
T = length(params.garray);

data =  reshape(fid,[X,Y,F,T]);


img_data = ifft2c(data);

if ~exist(recon_params.crop_ratio,'var')
    crop_size = floor([X,Y]/2);
else
    crop_size = floor([X,Y])*crop_ratio;
end

img_data = crop2c(img_data,crop_size);

% b values
if ~exist(recon_params.nb,'var')
    nb = 3;
else
    nb = recon_params.nb;
end

% number of metabolites
if ~exist(recon_params.ncomp,'var')
    ncomp = 2;
else
    ncomp = recon_params.ncomp;
end

% dynamic values
if ~exist(recon_params.dyn,'var')
    dyn = 8;
else
    dyn = recon_params.dyn;
end

img_data = reshape(img_data,[crop_size,F,ncomp,nb,dyn]);

cd(tmp_dir);
