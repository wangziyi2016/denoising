function [img2dout,xsout,ysout] = Get_Image_Slice_By_Coordinate(ys,xs,zs,img3d,viewdir,coord)
%
%	[img2dout,xsout,ysout] = Get_Image_Slice_By_Coordinate(ys,xs,zs,img3d,viewdir,coord)
%
vecs{1} = ys;
vecs{2} = xs;
vecs{3} = zs;

vs = vecs{viewdir};
if viewdir == 3 && length(vs) == 1
    xsout = xs;
    ysout = ys;
    img2dout = img3d;
    return;
else
    voxelsize = abs(vs(2)-vs(1));
end

img2dout = [];
xsout = [];
ysout = [];

if min(vs)-coord > voxelsize || coord - max(vs) > voxelsize
	% the coordinates is out of the image volume
	return;
end

dist = abs(vs-coord);
[dist,idxes] = sort(dist);

d1 = vs(idxes(1));
d2 = vs(idxes(2));

f1 = (coord-d2)/(d2-d1);
f2 = 1-f1;

switch viewdir
	case 1
		img2d1 = img3d(idxes(1),:,:);
		img2d2 = img3d(idxes(2),:,:);
		xsout = vecs{2};
		ysout = vecs{3};
	case 2
		img2d1 = img3d(:,idxes(1),:);
		img2d2 = img3d(:,idxes(2),:);
		xsout = vecs{1};
		ysout = vecs{3};
	case 3
		img2d1 = img3d(:,:,idxes(1));
		img2d2 = img3d(:,:,idxes(2));
		xsout = vecs{2};
		ysout = vecs{1};
end

img2d1 = squeeze(img2d1);
img2d2 = squeeze(img2d2);
if dist(1)<1e-4
	% exactly on the slice
	img2dout = img2d1;	% no interpolation
else
	img2dout = single(img2d1)*f1+single(img2d2)*f2;	% interpolation
end
img2dout = cast(img2dout,class(img2d1));

if viewdir ~= 3
	img2dout = img2dout';
end


