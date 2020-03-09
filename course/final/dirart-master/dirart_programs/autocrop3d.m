function imout = autocrop3d(imin,val)
% This function crops out the boundary of the image
%
% Copyrighted by: Deshan Yang, WUSTL, 10/2006, dyang@radonc.wustl.edu
%
%

imxy=mean(imin,3);
imx=mean(imxy,1);
x1=min(find(imx~=val));
x2=max(find(imx~=val));
imy=mean(imxy,2);
y1=min(find(imy~=val));
y2=max(find(imy~=val));

imxz = squeeze(mean(imin,1));
imz = mean(imxz,1);

z1 = min(find(imz~=val));
z2 = max(find(imz~=val));


imout=imin(y1:y2,x1:x2,z1:z2);

