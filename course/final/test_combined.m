clear all
I=imread('cameraman.tif');
G=imnoise(I,'salt & pepper',0.02);
%×ÛºÏÀ©É¢·¨
lam=[0.02,0,1];
w1=0;
w2=1;
c_iter=60;
ep=0.5;
dt=0.1;
C=0;
c_I=combined_denoise(G,c_iter,dt,ep,lam,w1,w2,G,C);
c_snr=my_snr(I,c_I);
c_psnr= psnr(I,uint8(c_I));
figure
subplot(2,1,1)
imshow(G)
subplot(2,1,2)
imshow(uint8(c_I))

