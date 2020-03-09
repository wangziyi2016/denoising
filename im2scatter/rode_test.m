I=imread('four_finger1.png');
SE=strel('arbitrary',eye(2)) ;
level=graythresh(I);
bw=im2bw(I,level);
bw=~bw;

I1=imerode(bw,SE);

subplot(1,2,1)
imshow(I) 
subplot(1,2,2)
imshow(I1)