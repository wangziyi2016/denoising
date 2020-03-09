function [im2,im4,im8] = imdesample3d2(img)
% Function: im = imdesample3d2(img)
% down sample the image by 1/2
%
[h,w,d] = size(img);

y = 0:h-1;  y = y - round((h+1)/2); y = y / round((h+1)/2); y = single(y);
x = 0:w-1;  x = x - round((w+1)/2); x = x / round((w+1)/2); x = single(x);
z = 0:d-1;  z = z - round((d+1)/2); z = z / round((d+1)/2); z = single(z);

[xx,yy,zz] = meshgrid(x,y,z);

dd = sqrt(xx.^2+yy.^2+zz.^2);
clear x y z xx yy zz;

F = fftshift(fftn(single(img)));

% Down sample by 2
mask = dd <= 0.5;
F = F.*mask;
img2 = real(ifftn(fftshift(F)));

y = 1:2:h;
x = 1:2:w;
z = 1:2:d;

im2 = img2(y,x,z);

% Down sample by 4
mask = dd <= 1/4;
F = F.*mask;
img2 = real(ifftn(fftshift(F)));

y = 2:4:h;
x = 2:4:w;
z = 2:4:d;
im4 = img2(y,x,z);


% Down sample by 8
mask = dd <= 1/8;
F= F.*mask;
img2 = real(ifftn(fftshift(F)));

y = 4:8:h;
x = 4:8:w;
z = 4:8:d;
im8 = img2(y,x,z);





