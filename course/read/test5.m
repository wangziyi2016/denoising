%傅立叶变换
I=imread('car.jpg');         % 读入图像
X=rgb2gray(I);                  % 图像灰度转换
figure;                          % 新窗口
imshow(X);                     % 显示灰度图像
Y = fft2(X);                     % 灰度图像傅立叶变换
figure;                         % 新窗口
imshow(log(abs(Y)),[]);           % 显示变换结果
colormap(jet);                  % 设置色彩索引图
colorbar                        % 显示色彩索引条
Z = fftshift(Y);                   % 傅立叶变换结果平移
figure;                         % 新窗口
imshow(log(abs(Z)),[]);         % 显示变换结果
colormap(jet);                 % 设置色彩索引图
colorbar                      % 显示色彩索引条
