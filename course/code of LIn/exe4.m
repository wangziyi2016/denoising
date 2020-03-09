radiation=xlsread('数据附件.xls','附件2');
real_phi=xlsread('phi.xlsx'); 
=linspace(-256,255,512); 
filt=0.0625*(sinc(d)/2-sinc(d/2).^2/4); 
shade_temp = zeros(1536,180); shade_temp(513:1024,:) = radiation;
for n = 1:180;
    shade1_temp(:,n) = conv(shade_temp(:,n),filt');
end
shade1 = shade1_temp(769:1280,:); shade1=radiation;
phi=270+real_phi; d_phi=zeros(180,1); 
for i=1:179
    d_phi(i)=phi(i+1)-phi(i);
end
d_phi(180)=1;
re = zeros(256,256); 
for view=1:180
    for x = 1:256
        x_real=-(40.6960-100/512-(x-1)*100/256);
        for y = 1:256
            y_real=43.7851-100/512-100/256*(y-1);
            xr = x_real*cosd(phi(view))+y_real*sind(phi(view));
            n=256.5-xr/t;
            if (n>1)&&(n<512) num = floor(n); inter = n-num; re(y,x) = re(y,x)+((1-inter)*shade1(num,view)+inter*shade1(num+1,vi ew))*d_phi(view);
            end
        end
    end
end
%re(abs(re)<abs(min(min(re))-1e-4))=0; imshow(0.3*re);
