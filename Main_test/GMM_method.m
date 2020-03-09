function [ cim ] = GMM_method( im,nSig,nim,idx )
addpath Main_Utilities/SSC_GSM_Denoising/Utilities
% add path to model repositories

par              =    Parameters_setting( nSig, idx );
par.I            =    double(im);
par.nim          =   nim;
disp('GMM method begin')

[cim,PSNR SSIM]   =    SSC_GSM_Denoising( par );    
%imwrite(im./255, 'Results\SSCGSM_den_Monarch.tif');
disp( sprintf('%s: PSNR = %3.2f  SSIM = %f\n', 'House', PSNR, SSIM) );
end

