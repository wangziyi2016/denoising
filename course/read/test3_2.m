%��������
I = imread('cameraman.tif');            % ����ͼ��
BW = dither(I);                         % ��ͼ����ж������㣬��ͼ��ת��Ϊ��ֵͼ��
imshow(I), figure, imshow(BW)           % ��ʾԭͼ��ת����Ķ�ֵͼ��
