%抖动计算
I = imread('cameraman.tif');            % 读入图像
BW = dither(I);                         % 对图像进行抖动计算，将图像转换为二值图像
imshow(I), figure, imshow(BW)           % 显示原图和转换后的二值图像
