%����Ҷ�任
f = zeros(30,30);        % ����Ԫ��ֵΪ0�ľ��󣬶�Ӧͼ���ɫ
f(5:24,13:17) = 1;                  % �ھ�����м䲿λ����Ԫ��ֵΪ1����Ӧͼ���ɫ
imshow(f,'InitialMagnification','fit')    % ��������ͼ���ʾ
F = fft2(f);                        % �����ά����Ҷ�任
F2 = log(abs(F));                   % �Ը���Ҷ�任���ȡ����ֵ��Ȼ��ȡ����
imshow(F2,[-1 5],'InitialMagnification','fit'); % �������ľ�����ͼ���ʾ
colormap(jet);                      % ����ɫ������ͼ
colorbar                           % ��ʾɫ��������
F = fft2(f,256,256);             % ���0�������ά����Ҷ�任
imshow(log(abs(F)),[-1 5]);      % ��ʾ�任���
colormap(jet);                   % ����ɫ������ͼ
colorbar                         % ��ʾɫ��������
F = fft2(f,256,256);                 % �����ά����Ҷ�任
F2 = fftshift(F);                    % ����F������
imshow(log(abs(F2)),[-1 5]);         % ��ʾ�任���
colormap(jet);                       % ����ɫ������ͼ
colorbar                             % ��ʾɫ��������
