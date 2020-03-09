function [frth,psnr_list,snr_list]=fpdepyou(I,T,II)

[x y z]=size(I);
I=double(I);
dt=0.9; % Time step
I1=I;
I2=I;
t=1;
k=0.5;
for  t=1:T
    [Ix,Iy]=gradient(I1); 
    [Ixx,Iyt]=gradient(Ix);
    [Ixt,Iyy]=gradient(Iy);
    c=1./(1.+sqrt(Ixx.^2+Iyy.^2)+0.0000001);
    [div1,divt1]=gradient(c.*Ixx);
    [divt2,div2]=gradient(c.*Iyy);
    [div11,divt3]=gradient(div1);
    [divt4,div22]=gradient(div2);
    div=div11+div22;
    I2=I1-(dt.*div);
    I1=I2;
    [psnr_list(t),snr_list(t)]=psnr(uint8(I1),II);

end;
frth=I1;
end

    