function [img_data, header] = Varian_14T_EPI_img(folder_name)
% load img data and header
%
% outputs:
%  img: img data
%  header:  structure
%
% Xucheng Zhu Dec/2017

tmp_dir = pwd;
header_name = [folder_name,'/procpar'];

header = load_procpar(header_name);
img_data = fdf_3d('all',folder_name);

cd(tmp_dir);