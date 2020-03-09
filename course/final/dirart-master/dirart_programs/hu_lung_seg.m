function y=hu_lung_seg(x,T0)
% lung segmentation by optimal thresholding

T=auto_thresholding(x,T0);
se1 = strel('disk',1);
xbw=x<=T;
I1=imclearborder(xbw);
I2=imclose(I1,se1);
I3=imfill(I2,'holes');
% use convex hull
stats=imfeature(uint16(I3),'BoundingBox','ConvexImage');
I4=zeros(size(x));
box=stats.BoundingBox;
I4(floor(box(2))+[1:box(4)],floor(box(1))+[1:box(3)])=stats.ConvexImage;
y=uint16(double(I4).*double(x));
return




