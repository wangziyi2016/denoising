%����Ҷ�任
I=imread('car.jpg');         % ����ͼ��
X=rgb2gray(I);                  % ͼ��Ҷ�ת��
figure;                          % �´���
imshow(X);                     % ��ʾ�Ҷ�ͼ��
Y = fft2(X);                     % �Ҷ�ͼ����Ҷ�任
figure;                         % �´���
imshow(log(abs(Y)),[]);           % ��ʾ�任���
colormap(jet);                  % ����ɫ������ͼ
colorbar                        % ��ʾɫ��������
Z = fftshift(Y);                   % ����Ҷ�任���ƽ��
figure;                         % �´���
imshow(log(abs(Z)),[]);         % ��ʾ�任���
colormap(jet);                 % ����ɫ������ͼ
colorbar                      % ��ʾɫ��������
