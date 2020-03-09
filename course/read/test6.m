%线形滤波
I=imread('car.jpg');         % 读入图像
X=double(rgb2gray(I));  
h1=[1,2,1;0,0,0;-1,-2,-1];
%conv2滤波
h2=[1,1,1;1,1,1;1,1,1]/9;
h3=[1,2,1;0,0,0;-1,-2,-1];%Sobel算子
h4=[0,1,0;1,-4,0;0,1,0];%拉氏算子




j1=conv2(X,h1);
j2=filter2(h2,X);
j3=filter2(h3,X);
j4=X-conv2(X,h4,'same');
j5=medfilt2(X);
imshow(uint8(j5))

%
