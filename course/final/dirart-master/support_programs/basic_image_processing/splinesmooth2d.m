function  im2=splinesmooth2d(im,gridsizes)
% Function: im = im2=splinesmooth2d(im,gridsize)
%
dim=size(im);

x0 = 1:dim(2);y0=1:dim(1);
[xx,yy]=meshgrid(x0,y0);

w = [1:gridsizes(2):dim(2)]; w = w + round((dim(2)-max(w))/2);
h = [1:gridsizes(1):dim(1)]; h = h + round((dim(1)-max(h))/2);
[ww,hh]=meshgrid(w,h);

im1 = im(h,w);

im2 = interp2(ww,hh,im1,xx,yy,'spline');
