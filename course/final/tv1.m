function [J,psnr_list,snr_list]=tv1(I,iter,dt,ep,lam,I0,C,II)

I=double(I);
I0=double(I0);
[ny,nx]=size(I); ep2=ep^2;
for i=1:iter,  %% do iterations
   % estimate derivatives
       I_x = (I(:,[2:nx nx])-I(:,[1 1:nx-1]))/2;
 
       I_y = (I([2:ny ny],:)-I([1 1:ny-1],:))/2;
 
       I_xx = I(:,[2:nx nx])+I(:,[1 1:nx-1])-2*I;
 
       I_yy = I([2:ny ny],:)+I([1 1:ny-1],:)-2*I;
 
       Dp = I([2:ny ny],[2:nx nx])+I([1 1:ny-1],[1 1:nx-1]);
 
       Dm = I([1 1:ny-1],[2:nx nx])+I([2:ny ny],[1 1:nx-1]);
 
       I_xy = (Dp-Dm)/4;
 
   % compute flow
 
   Num = I_xx.*(ep2+I_y.^2)-2*I_x.*I_y.*I_xy+I_yy.*(ep2+I_x.^2);
 
   Den = (ep2+I_x.^2+I_y.^2).^(3/2);
 
   I_t = Num./Den + lam.*(I0-I+C);
 
   I=I+dt*I_t;  
   [psnr_list(i),snr_list(i)]=psnr(uint8(I),II);
end 
J=I; 
return 

