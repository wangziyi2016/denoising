function mask = create_MVCT_FOV_mask(img,xc,yc)
%
%	mask = create_MVCT_FOV_mask(img)
%

if ~exist('img','var')
	x = 512; y = 512;
% 	xs = 1:512;
% 	ys = 1:512;
% 	[xx,yy] = meshgrid(xs,ys);
% 	xc = 256.5;
% 	yc = 256.5;
% 
% 	dd = sqrt((xx-xc).^2+(yy-yc).^2);
% 	mask = (dd < 256);
else
	dim = size(img);
	y = dim(1);
	x = dim(2);
end

if ~exist('xc','var')
	xc = (1+x)/2;
	yc = (1+y)/2;
% 	maxd = max(y,x)/2;
% else
% 	maxd = max(max(abs(y-yc)),max(abs(x-xc)))+0.5;
end
xs = (1:x) - xc;
ys = (1:y) - yc;
% maxd = max(max(abs(ys)),max(abs(xs)))+0.5;
maxd = min(max(abs(ys)),max(abs(xs)))-1;
[xx,yy] = meshgrid(xs,ys);
dd = sqrt(xx.^2+yy.^2);
mask = dd < maxd;


