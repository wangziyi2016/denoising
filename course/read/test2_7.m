I=imread('bag.png');         % ����ͼ��

I=double(I);
[M,N]=size(I);
rL=0.5;
rH=4.7;%�ɸ�����ҪЧ����������
c=2;
d0=10;
I1=log(I+1);%ȡ����
FI=fft2(I1);%����Ҷ�任
n1=floor(M/2);
n2=floor(N/2);
H = ones(M, N);
for i=1:M
    for j=1:N
        D(i,j)=((i-n1).^2+(j-n2).^2);
        H(i,j)=(rH-rL).*(exp(c*(-D(i,j)./(d0^2))))+rL;%��˹̬ͬ�˲�
    end
end
I2=ifft2(H.*FI);%����Ҷ��任
I3=real(exp(I2));
subplot(1,2,1),imshow(I,[]);title('̬ͬ�˲���ǿ��');
subplot(1,2,2),imshow(I3,[]);title('̬ͬ�˲���ǿ��');
