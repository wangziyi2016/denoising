
%--------------------------------------------------------------------------
clc;
clear;
randn('seed',0);
addpath /Users/wzy/Documents/MATLAB/IP/combined/Utilities
% add path to model repositories
addpath /Users/wzy/Documents/MATLAB/IP/sc_denoise/PGPD-ICCV2015-master/PGPD_ICCV2015Code/model

im_name={'Monarch_full.tif','cameraman.tif','barbara.tif','boat.tif','couple.tif','fingerprint.tif',...
    'house.tif','lena512.tif','man.tif','pepers256.tif','straw.tif'};
im_name=im_name{11};
fname            =    '/Users/wzy/Documents/MATLAB/IP/SSC_GSM_Denoising/Data/Denoising_test_images/';
fn               =    strcat(fname,im_name);
L                =    [5, 10, 15, 20, 50, 80];
idx              =    6;
nSig             =    L(idx);
[par,model]      =    self_setting( nSig, idx )
par.I            =    double( imread( fn ) );
par.nim          =    par.I + nSig*randn(size( par.I ));
%% learning method
%[ cim1 ] = learning_method(par.I,nSig,par.nim );
%% GMM method
%[ cim2 ] = GMM_method( par.I,nSig,par.nim,idx );
%% combined method
 % dictionary and regularization parameter
 
[cim3, PSNR, SSIM]   =    combined_Denoising1( par, model ); 
%[cim4, PSNR, SSIM]   =    combined_Denoising2( par, model );    

subplot(2,2,1)
imshow(uint8(cim1*255))
subplot(2,2,2)
imshow(uint8(cim2))
subplot(2,2,3)
imshow(uint8(cim3))
subplot(2,2,4)
imshow(uint8(cim4))
%imwrite(im./255, 'Results\SSCGSM_den_Monarch.tif');
disp( sprintf('%s: PSNR = %3.2f  SSIM = %f\n', 'House', PSNR, SSIM) );



  