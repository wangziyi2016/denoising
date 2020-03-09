%test cameraman
clear all
close all
addpath /Users/wzy/Documents/MATLAB/IP/course/final/AnisotropicDiffusion-master
addpath /Users/wzy/Documents/MATLAB/IP/course/final/dirart-master/support_programs/edge_perserving_filters
set(0,'defaultfigurecolor','w') 
% I=imread('logo.png');
% I=rgb2gray(I);
% G=imnoise(I,'gaussian',0,0.005);

I=imread('cameraman.tif');
G=imnoise(I,'salt & pepper',0.005);
imshow(G)
title('ԭ����ͼ��','fontsize',25);
imshow(I)
title('ԭͼ��','fontsize',25);
%������ɢ��
TV2_iter=1000;
ep=0.5;
dt2=0.005;
C=0;
lam2=0;
[TV2_I,TV2_snr,TV2_psnr]=tv2(G,TV2_iter,dt2,lam2,I);
TV2_I=uint8(TV2_I);
figure
imshow(TV2_I)
title('������ɢ��������100�εĽ��','fontsize',25);
figure;plot(TV2_snr);hold on ;plot(TV2_psnr);
title('PSNR��SNR�仯ͼ','fontsize',25);
ll=legend('SNR','PSNR');
set(ll,'Fontsize',15);
xlabel('��������','FontSize',20);
ylabel('PSNR��SNR','FontSize',20);
max(TV2_snr)
max(TV2_psnr)

%PM ��
PM_iter=300;
dt=0.01;
PM_k=300;
[ PM_I,PM_psnr,PM_snr ] = anisotropic_diffusion( G,dt, PM_iter,PM_k,I);
figure
imshow(PM_I)
title('PM������50�εĽ��','fontsize',25);
figure;plot(PM_snr);hold on ;plot(PM_psnr);
title('PSNR��SNR�仯ͼ','fontsize',25);
ll=legend('SNR','PSNR');
set(ll,'Fontsize',15);
xlabel('��������','FontSize',20);
ylabel('PSNR��SNR','FontSize',20);
max(PM_snr)
max(PM_psnr)
%YK ��
YK_iter=50;
[YK_I,YK_psnr,YK_snr]=fpdepyou(G,YK_iter,I);
YK_I=uint8(YK_I);
figure
imshow(YK_I)
title('YK������50�εĽ��','fontsize',25);
figure;plot(YK_snr);hold on ;plot(YK_psnr);
title('PSNR��SNR�仯ͼ','fontsize',25);
ll=legend('SNR','PSNR');
set(ll,'Fontsize',15);
xlabel('��������','FontSize',20);
ylabel('PSNR��SNR','FontSize',20);
max(YK_snr)
max(YK_psnr)
%TV �� l1
TV1_iter=200;
ep=0.5;
dt1=0.2;
C=0;
lam1=0.1;
[TV1_I,TV1_psnr,TV1_snr]=tv1(G,TV1_iter,dt1,ep,lam1,G,C,I);
TV1_I=uint8(TV1_I);
figure
imshow(TV1_I)
title('����L1������TV������200�εĽ��','fontsize',25);
figure;plot(TV1_snr);hold on ;plot(TV1_psnr);
title('PSNR��SNR�仯ͼ','fontsize',25);
ll=legend('SNR','PSNR');
set(ll,'Fontsize',15);
xlabel('��������','FontSize',20);
ylabel('PSNR��SNR','FontSize',20);
max(TV1_snr)
max(TV1_psnr)
%TV �� l2
TV2_iter=400;
ep=0.5;
dt2=0.001;
C=0;
lam2=0.1;
[TV2_I,TV2_snr,TV2_psnr]=tv2(G,TV2_iter,dt2,lam2,I);
TV2_I=uint8(TV2_I);
figure
imshow(TV2_I)
title('����L2������TV������60�εĽ��','fontsize',25);
figure;plot(TV2_snr);hold on ;plot(TV2_psnr);
title('PSNR��SNR�仯ͼ','fontsize',25);
ll=legend('SNR','PSNR');
set(ll,'Fontsize',15);
xlabel('��������','FontSize',20);
ylabel('PSNR��SNR','FontSize',20);
max(TV2_snr)
max(TV2_psnr)

figure
subplot(2,3,1)
imshow(G)
subplot(2,3,2)
imshow(PM_I)
subplot(2,3,3)
imshow(YK_I)
subplot(2,3,4)
imshow(TV1_I)







