clear all
%»Ò¶È
I=imread('test2.jpg');
I_zeng=zeros(size(I));
for i =1:3
    I1=I(:,:,i);
    I2=imadjust(I1,[0.3 0.7],[0.1 0.9],1);
    I_zeng(:,:,i)=I2;
end
subplot(1,2,1),imshow(I);
subplot(1,2,2),imshow(uint8(I_zeng));
figure;imhist(I2);