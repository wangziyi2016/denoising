function disp_motion(im1,im2,mvx,mvy,n,d)
%
% disp_motion(im1,im2,mvx,mvy,n,d)
%

if( ~exist('n') )
	n = 1;
end

if( ~exist('d') ) 
	d = 6;
end

x0 = [1:size(im1,2)];
y0 = [1:size(im1,1)];
[xx0,yy0] = meshgrid(x0,y0);	% xx, yy are the original coordinates of image pixels


figure;
im(:,:,1) = im1;% * 255;
im(:,:,2) = im2;% * 255;
i1vx = interp2(im1,xx0-mvx,yy0-mvy,'linear',0);
%im(:,:,3) = i1vx;%zeros(size(im1));
im(:,:,3) = zeros(size(im1));

image(im);
daspect([1 1 1]);

hold on;

x = 1:d:size(im1,2);
y = 1:d:size(im1,1);

[xx,yy] = meshgrid(x,y);

quiver(xx,yy,mvx(1:d:end,1:d:end),mvy(1:d:end,1:d:end),n,'Color','w');


