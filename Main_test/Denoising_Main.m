
%% --------------------------------------------------------------------------
clc;
clear;
randn('seed',0);
im_name={'Monarch_full.tif','cameraman.tif','barbara.tif','boat.tif','couple.tif','fingerprint.tif',...
    'house.tif','lena512.tif','man.tif','pepers256.tif','straw.tif'};
im_name=im_name{1};
fname            =    'Denoising_test_images/';
fn               =    strcat(fname,im_name);
L                =    [5, 10, 15, 20, 50, 75];
idx              =    6;
nSig             =    L(idx);
I            =    double( imread( fn ) );
nim          =    I + nSig*randn(size( I ));

%% 
% learning method
[ cim1 ] = learning_method(I,nSig,nim );

% GMM method
%[ cim2 ] = GMM_method( I,nSig,nim,idx );

% combined method
[cim3, PSNR, SSIM]   =    combined_Denoising1( I,nim,nSig ); 
%[cim4, PSNR, SSIM]   =    combined_Denoising2( I,nim,nSig ); 

%% visuallize 
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



  