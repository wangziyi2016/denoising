function show_values(im1,im2,i1vx,mvx,mvy,mvz,x,y,z)

dim = size(im1);

x0 = single([1:dim(2)]);
y0 = single([1:dim(1)]);
z0 = single([1:dim(3)]);
[xx,yy,zz] = meshgrid(x0,y0,z0);	% xx, yy and zz are the original coordinates of image pixels

im1vals = interpn(yy,xx,zz,im1,y,x,z,'linear',0);
im2vals = interpn(yy,xx,zz,im2,y,x,z,'linear',0);
i1vxvals = interpn(yy,xx,zz,i1vx,y,x,z,'linear',0);

mvxvals = interpn(yy,xx,zz,mvx,y,x,z,'linear',0);
mvyvals = interpn(yy,xx,zz,mvy,y,x,z,'linear',0);
mvzvals = interpn(yy,xx,zz,mvz,y,x,z,'linear',0);

disp('im1 - im2 - i1vx values');
[im1vals im2vals i1vxvals]

disp('mvx mvy mvz values');
[mvxvals mvyvals mvzvals]
