function imout = resample_image_by_coordinates(imin,ys,xs,zs,y,x,z)
% Resample the images using coordinate values
% imout = resample_image_by_coordinates(imin,ys,xs,zs,newys,newxs,newzs)
%

[xx,yy,zz] = meshgrid(x,y,z);

minxidx = find(xs<min(x),1,'last');
maxxidx = find(xs>max(x),1,'first');

minyidx = find(ys<min(y),1,'last');
maxyidx = find(ys>max(y),1,'first');

minzidx = find(zs<min(z),1,'last');
maxzidx = find(zs>max(z),1,'first');

tempimin = single(imin(minyidx:maxyidx,minxidx:maxxidx,minzidx:maxzidx));

imout = interp3(xs(minxidx:maxxidx),ys(minyidx:maxyidx),zs(minzidx:maxzidx),tempimin,xx,yy,zz,'linear');
imout = cast(imout,class(imin));

