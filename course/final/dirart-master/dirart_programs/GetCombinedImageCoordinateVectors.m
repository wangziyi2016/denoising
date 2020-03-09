function vecs = GetCombinedImageCoordinateVectors(handles,viewdir)
%
% Output:	returns the coordinate vectors of the combined image
%			vecx1,vecy1 - in image 1 coordinates
%			vecx2,vecy2 - in image 2 coordinates
%
%
[dimc,img1_offsets_c,img2_offsets_c] = ComputeCombinedImageInfo(handles);

ys1 = ([1:dimc(1)]-1-img1_offsets_c(1))*handles.images(1).voxelsize(1)*handles.images(1).voxel_spacing_dir(1) + handles.images(1).origin(1);
xs1 = ([1:dimc(2)]-1-img1_offsets_c(2))*handles.images(1).voxelsize(2)*handles.images(1).voxel_spacing_dir(2) + handles.images(1).origin(2);
zs1 = ([1:dimc(3)]-1-img1_offsets_c(3))*handles.images(1).voxelsize(3)*handles.images(1).voxel_spacing_dir(3) + handles.images(1).origin(3);

ys2 = ([1:dimc(1)]-1-img2_offsets_c(1))*handles.images(2).voxelsize(1)*handles.images(2).voxel_spacing_dir(1) + handles.images(2).origin(1);
xs2 = ([1:dimc(2)]-1-img2_offsets_c(2))*handles.images(2).voxelsize(2)*handles.images(2).voxel_spacing_dir(2) + handles.images(2).origin(2);
zs2 = ([1:dimc(3)]-1-img2_offsets_c(3))*handles.images(2).voxelsize(3)*handles.images(2).voxel_spacing_dir(3) + handles.images(2).origin(3);

if ~exist('viewdir','var')
	vecs(1).xs = xs1;
	vecs(1).ys = ys1;
	vecs(1).zs = zs1;
	vecs(2).xs = xs2;
	vecs(2).ys = ys2;
	vecs(2).zs = zs2;
else
	switch(viewdir)
		case 1
			vecx1 = xs1;
			vecy1 = zs1;
			vecx2 = xs2;
			vecy2 = zs2;
		case 2
			vecx1 = ys1;
			vecy1 = zs1;
			vecx2 = ys2;
			vecy2 = zs2;
		case 3
			vecx1 = xs1;
			vecy1 = ys1;
			vecx2 = xs2;
			vecy2 = ys2;
	end

	vecs(1).xs = vecx1;
	vecs(1).ys = vecy1;
	vecs(2).xs = vecx2;
	vecs(2).ys = vecy2;
end


