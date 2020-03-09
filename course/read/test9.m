clear all
I=imread('car.jpg');
I_zeng=zeros(size(I));
for i =1:3
    I1=I(:,:,i);
    I2=histeq(I1);
    I_zeng(:,:,i)=I2;
end
subplot(1,2,1),imshow(I);
subplot(1,2,2),imshow(uint8(I_zeng));
figure;imhist(I2);