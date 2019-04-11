% Raw data loading
close all, clear all, clc

% Add local path
addpath(pwd);

cd('/Users/xuchengzhu/Documents/Graduate/Research/rotation/s_20160219_01/epi_spsp_symse1_test_04.img');

%Load the images and header information
im = fdf_3d('all');
header = load_procpar('procpar');

%Note the SE shape and the SE refocus thickness
pshape = header.p2pat;
thk = header.thk2;

sprintf('RF pulse is %s\nSE Refocus thickness is %dmm',pshape, thk)
plot(squeeze(sum(sum(im,1),2)));
%save a .mat file based on the pulse name and refocus thk
filename = ['SE_' pshape '_thk_' num2str(thk) 'mm'];