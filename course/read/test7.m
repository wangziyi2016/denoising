%Êı×ÖÊı×ÖÍ¼Ïñ±ßÔµ¼ì²â
clear all
close all
I=imread('test1.png');         % ¶ÁÈëÍ¼Ïñ
X=double(rgb2gray(I));  
j1 =edge(X,'sobel');
j2 =edge(X,'prewitt');
j3 =edge(X,'roberts');
j4 =edge(X,'log');
j5 =edge(X,'canny');
j6 =edge(X,'zerocross');
imshow(j2)
