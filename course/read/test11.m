clear all
I=imread('test2.jpg');
I_zeng=zeros(size(I));
avgModel=fspecial('average',3);

for i =1:3
    I1=I(:,:,i);
    I2=filter2(avgModel,I1);
    I_zeng(:,:,i)=I2;
end
subplot(1,2,1),imshow(I);
subplot(1,2,2),imshow(uint8(I_zeng));
figure;imhist(I2);