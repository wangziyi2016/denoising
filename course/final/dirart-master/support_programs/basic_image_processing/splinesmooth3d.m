function  im2=splinesmooth3d(im,gridsizes)
% Function: newval = splinesmooth3d(val,gridsizes)
%
dim=size(im);

if ndims(im) == 2
	im2 = splinesmooth2d(im,gridsizes(1:2));
else
	x0 = 1:dim(2);y0=1:dim(1);z0=1:dim(3);
	[xx,yy,zz]=meshgrid(x0,y0,z0);

	h = [1:gridsizes(1):dim(1)]; h = h + round((dim(1)-max(h))/2);
	w = [1:gridsizes(2):dim(2)]; w = w + round((dim(2)-max(w))/2);
	d = [1:gridsizes(3):dim(3)]; d = d + round((dim(3)-max(d))/2);

	[ww,hh,dd]=meshgrid(w,h,d);

	im1 = im(h,w,d);

	im2 = interpn(hh,ww,dd,im1,yy,xx,zz,'spline');
end
