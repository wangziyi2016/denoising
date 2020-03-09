function [J,psnr_list,snr_list]=tv2(I,iter,dt,lam,II)
I=double(I);
I0=double(I);
[ny,nx]=size(I); 
for i=1:iter,  %% do iterations
   % estimate derivatives
   I_xx = I(:,[2:nx nx])+I(:,[1 1:nx-1])-2*I;
   I_yy = I([2:ny ny],:)+I([1 1:ny-1],:)-2*I;
   % compute flow
   I_t =  I_xx+I_yy+ lam.*(I0-I); 
   I=I+dt*I_t;  %% evolve image by dt
   %psnr_list(i)=my_snr(double(I),double(II));
   [psnr_list(i),snr_list(i)]=psnr(uint8(I),II);
end % for i
J=I; % normalize to original mean
return 

