I=imread('cameraman.tif');
G=imnoise(I,'salt & pepper',0.02);
f=G;
subplot(1,2,1);
imshow(f);
f=double(f);
f=fft2(f);
f=fftshift(f);
[m,n]=size(f);  %
d0=50;
m1=fix(m/2);
n1=fix(n/2);
for i=1:m
    for j=1:n
        d=sqrt((i-m1)^2+(j-n1)^2);
        h(i,j)=exp(-d^2/2/d0^2);
    end
end
g=f.*h;
g=ifftshift(g);
g=ifft2(g);
g=mat2gray(real(g));
subplot(1,2,2);
imshow(g);
imwrite(img,'2.jpg');