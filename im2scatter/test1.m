clear all
close all
format long
I=imread('four_finger1.png');
%subplot(1,2,1)
imshow(I);
level=graythresh(I);
bw1=im2bw(I,level);
bw1=~bw1;
%subplot(1,2,2)
%lunkuo_I=bwperim(bw);
bw2=bwmorph(bw1,'skel',Inf); 
imshow(bw1);

