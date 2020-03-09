% generate an image with differen shapes...
clear
x=imread('shapes.bmp');
x1=x(1:50,:);
x2=x(51:90,:);
x3=x(91:end,:);
g1=fspecial('gaussian',[5 5],1);
g2=fspecial('gaussian',[5 5],1.5);
g3=fspecial('gaussian',[5 5],2);
y1=filter2(g1,x1);
y2=filter2(g2,x2);
y3=filter2(g3,x3);
y=[y1;y2;y3];
dispimage(y','original image',2,1,1);
ypower=sum(y(:).^2)/prod(size(y));
ystd=0.1;
SNR=10*log10(ypower/ystd^2);
yn=y+ystd*randn(size(y));
dispimage(yn','noisy image',2,1,2);
x=y;
save  image_shape_file x