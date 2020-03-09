clc;
clear all;
randn('seed',0);

addpath /Users/wzy/Documents/MATLAB/Image_denoising/SSC_GSM_Denoising/Utilities
% add path to model repositories
im_name='Lena512.tif'
fname            =    '/Users/wzy/Documents/MATLAB/Image_denoising/SSC_GSM_Denoising/Data/Denoising_test_images/';
fn               =    strcat(fname,im_name);
dict             =    2; 
L                =    [5, 10, 15, 20, 50, 100];
idx              =    6;

par              =    Parameters_setting( L(idx), idx );
par.I            =    double( imread( fn ) );
par.nim          =    par.I + L(idx)*randn(size( par.I ));
    
[im PSNR SSIM]   =    SSC_GSM_Denoising( par );    

%imwrite(im./255, 'Results\SSCGSM_den_Monarch.tif');
disp( sprintf('%s: PSNR = %3.2f  SSIM = %f\n', 'House', PSNR, SSIM) );



  