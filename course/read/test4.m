%傅立叶变换
f = zeros(30,30);        % 构建元素值为0的矩阵，对应图像黑色
f(5:24,13:17) = 1;                  % 在矩阵的中间部位设置元素值为1，对应图像白色
imshow(f,'InitialMagnification','fit')    % 将矩阵用图像表示
F = fft2(f);                        % 矩阵二维傅立叶变换
F2 = log(abs(F));                   % 对傅立叶变换结果取绝对值，然后取对数
imshow(F2,[-1 5],'InitialMagnification','fit'); % 将计算后的矩阵用图像表示
colormap(jet);                      % 设置色彩索引图
colorbar                           % 显示色彩索引条
F = fft2(f,256,256);             % 填充0，矩阵二维傅立叶变换
imshow(log(abs(F)),[-1 5]);      % 显示变换结果
colormap(jet);                   % 设置色彩索引图
colorbar                         % 显示色彩索引条
F = fft2(f,256,256);                 % 矩阵二维傅立叶变换
F2 = fftshift(F);                    % 交换F的象限
imshow(log(abs(F2)),[-1 5]);         % 显示变换结果
colormap(jet);                       % 设置色彩索引图
colorbar                             % 显示色彩索引条
