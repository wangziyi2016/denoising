% Learning method 
function [im_out]=learning_method(im,nSig,n_im)
addpath Main_Utilities/PGPD-ICCV2015-master/PGPD_ICCV2015Code
% set parameters
[par, model]  =  Parameters_Setting( nSig );

% read clean image
par.I = single( im )/255;
% generate noisy image
par.nim =n_im/255;
disp('The learning method begin')
fprintf('The initial value of PSNR = %2.4f, SSIM = %2.4f \n', csnr( par.nim*255, par.I*255, 0, 0 ),cal_ssim( par.nim*255, par.I*255, 0, 0 ));
% PGPD denoising
[im_out,par]  =  PGPD_Denoising(par,model);
%[im_out,par]  =  PGPD_Denoising_faster(par,model); % faster speed
%imwrite(im_out,'PGPD_Restored.png');
% calculate the PSNR and SSIM
PSNR = csnr( im_out*255, par.I*255, 0, 0 );
SSIM =  cal_ssim( im_out*255, par.I*255, 0, 0 );
fprintf('Cameraman : PSNR = %2.4f, SSIM = %2.4f \n', PSNR, SSIM );
end

