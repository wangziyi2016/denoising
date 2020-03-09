%main of the tv method
clear all
iter=10;
I=imread('cameraman.tif');
G=imnoise(I,'salt & pepper',0.02);
ep=1;
dt=0.2;
C=0;
lam=0;
I0=G;
J=tv(G,iter,dt,ep,lam,I0,C);
J=uint8(J);
figure
subplot(2,1,1)
imshow(G)
subplot(2,1,2)
imshow(I)
imshow(J)