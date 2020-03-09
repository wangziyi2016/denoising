function imout = imdownsample2d(imin)

dim = size(imin);
dimout = dim;
dimout(1) = floor(dimout(1)/2);
dimout(2) = floor(dimout(2)/2);

imout = zeros(dimout,class(imin));

x0 = 1:dim(2);
y0 = 1:dim(1);

x1 = (1:2:dim(2))+0.5;
y1 = (1:2:dim(1))+0.5;
[xx,yy] = meshgrid(x1,y1);

N = 1;
if length(dim) > 2
	N = dim(3);
end


for k = 1:N
	imout(:,:,k) = interp2(imin(:,:,k),xx,yy,'linear');
end


