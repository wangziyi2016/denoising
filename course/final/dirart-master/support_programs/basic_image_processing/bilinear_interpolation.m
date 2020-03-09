function temp=bilinear_interpolation(im,xd,yd)
% bilinear interpolation routine
xdsave = xd;
ydsave = yd;
[w,h]=size(im);
% check boundary...
xd=max(min(xd,w),1);
yd=max(min(yd,h),1);
i  =max(floor(xd),1);
j  =max(floor(yd),1);
dx = xd - i;
dy = yd - j;
ul = im(sub2ind([w,h],i,j));
ur = im(sub2ind([w,h],min(i+1,w),j));
ll = im(sub2ind([w,h],i,min(j+1,h)));
lr = im(sub2ind([w,h],min(i+1,w),min(j+1,h)));
temp = ul.*(1.-dx).*(1.-dy) + ur.*(1.-dy).*dx + ll.*dy.*(1.-dx) + lr.*dx.*dy;

temp(xdsave>w)=nan;
temp(xdsave<1)=nan;
temp(ydsave>h)=nan;
temp(ydsave<1)=nan;
return