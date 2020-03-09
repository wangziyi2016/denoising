% 导入人脸图像集合
k=1;
for i=1:1:40
    for j=1:1:10
        filename  = sprintf('/Users/wzy/Documents/MATLAB/IP/face/att_faces/s%d/%d.pgm',i,j);
        image_data = imread(filename);
        k = k + 1;
        x(:,k) = image_data(:); 
        anot_name(k,:) = sprintf('%2d:%2d',i,j);   
     end;
end;
nImages = k;              %图像总共的数量
imsize = size(image_data); %图像尺寸
nPixels = imsize(1)*imsize(2);   %图像中的像素数
x = double(x)/255;  %转换成双精度型并进行归一化处理
%计算图像均值
avrgx = mean(x')';
for i=1:1:nImages
    x(:,i) = x(:,i) - avrgx; 
end;
subplot(2,2,1); imshow(reshape(avrgx, imsize)); title('mean face')
cov_mat = x'*x; %计算协方差矩阵
%计算协方差矩阵的奇异值
[V,D] = eig(cov_mat);         
V = x*V*(abs(D))^-0.5;               
subplot(2,2,2); imshow(ScaleImage(reshape(V(:,nImages  ),imsize))); title('1st eigen face');
subplot(2,2,3); imshow(ScaleImage(reshape(V(:,nImages-1),imsize))); title('2st eigen face');
subplot(2,2,4); plot(diag(D)); title('Eigen values');
KLCoef =  x'*V; %图像分解系数
%重构图像 
image_index = 12;  reconst = V*KLCoef';
diff = abs(reconst(:,image_index) - x(:,image_index));
strdiff_sum = sprintf('delta per pixel: %e',sum(sum(diff))/nPixels);
figure;
subplot(2,2,1); imshow((reshape(avrgx+reconst(:,image_index), imsize))); title('Reconstructed');
subplot(2,2,2); imshow((reshape(avrgx+x(:,image_index), imsize)));title('original');
subplot(2,2,3); imshow(ScaleImage(reshape(diff, imsize))); title(strdiff_sum);
for i=1:1:nImages
%计算欧式距离
dist(i) = sqrt(dot(KLCoef(1,:)-KLCoef(i,:), KLCoef(1,:)-KLCoef(i,:))); 
end;
subplot(2,2,4); plot(dist,'.-'); title('euclidean distance from the first face');
figure;
show_faces = 1:1:nImages/2;
plot(KLCoef(show_faces,nImages), KLCoef(show_faces,nImages-1),'.'); title('Desomposition: Numbers indicate (Face:Expression)');
for i=show_faces
    name = anot_name(i,:);
    text(KLCoef(i,nImages), KLCoef(i,nImages-1),name,'FontSize',8);
end;
% 查找相似图像
image_index = 78;
for i=1:1:nImages
dist_comp(i)=sqrt(dot(KLCoef(image_index,:)-KLCoef(i,:),KLCoef(image_index,:)-KLCoef(i,:))); 
    strDist(i) = cellstr(sprintf('%2.2f\n',dist_comp(i)));
end;
[sorted, sorted_index] = sort(dist_comp); 
figure; 
for i=1:1:9
subplot(3,3,i); imshow((reshape(avrgx+x(:,sorted_index(i)),imsize)));title(strDist(sorted_index(i)));
end