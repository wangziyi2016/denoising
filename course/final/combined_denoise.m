function J=combined_denoise(I,iter,dt,ep,lam,w1,w2,I0,C)
I=double(I);
I0=double(I0);
ep2=ep^2;
la1=lam(1)
la2=lam(2)
la3=lam(3)
k=400;
I1=I;
I2=I;

[ny,nx]=size(I); ep2=ep^2;
for i=1:iter,  %% do iterations
   % compute flow
    [Ix,Iy]=gradient(I1); 
    [Ixx,Iyt]=gradient(Ix);
    [Ixt,Iyy]=gradient(Iy);
    c=1./(1.+sqrt(Ixx.^2+Iyy.^2)+0.0000001);
    [div1,divt1]=gradient(c.*Ixx);
    [divt2,div2]=gradient(c.*Iyy);
    [div11,divt3]=gradient(div1);
    [divt4,div22]=gradient(div2);
    div=div11+div22;
    I2=I1+la1.*ad( I1, k)*255-la2.*(dt.*div)+ la3.*dt.*dtv(I1,ep2);
    I1=I2;
    %I_t = -la1*(I_xx+I_yy)-la2*div + la3.*(I0-I+C);
    %I=I+dt*I_t;  %% evolve image by dt
end % for i

J=I1; % normalize to original mean
return 