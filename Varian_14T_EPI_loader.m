function [data, header] = Varian_14T_EPI_loader(folder_name, recon_params)
% load k-space data/img data and header
% xucheng zhu Dec/6/2017

fid_name = [folder_name,'/fid'];
header_name = [folder_name,'/procpar'];
fid = load_echoes(fid_name);
header = load_procpar(header_name);

X = params.np./2;
Y = params.nv;
F = params.slice;
T = length(params.garray);