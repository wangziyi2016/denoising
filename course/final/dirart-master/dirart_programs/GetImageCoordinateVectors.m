function vec = GetImageCoordinateVectors(handles,imgidx,viewdir,dst_imgidx)
%
%	vec = GetImageCoordinateVectors(handles,imgidx)
%	vec = GetImageCoordinateVectors(handles,imgidx,viewdir)
%	vec = GetImageCoordinateVectors(handles,imgidx,viewdir,dst_imgidx)
%
%	Output:	returns the coordinate vectors
%	
img = handles.images(imgidx);

[ys1,xs1,zs1] = get_image_XYZ_vectors(img);
if exist('dst_imgidx','var') && dst_imgidx ~= imgidx
	[xs1,ys1,zs1] = TranslateCoordinates(handles,imgidx,xs1,ys1,zs1);
end

if exist('viewdir','var')
	switch(viewdir)
		case 1
			vec.xs = xs1;
			vec.ys = zs1;
		case 2
			vec.xs = ys1;
			vec.ys = zs1;
		case 3
			vec.xs = xs1;
			vec.ys = ys1;
	end
else
	vec.ys = ys1;
	vec.xs = xs1;
	vec.zs = zs1;
end




