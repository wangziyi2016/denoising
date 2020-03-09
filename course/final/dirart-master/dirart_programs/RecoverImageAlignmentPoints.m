function handles = RecoverImageAlignmentPoints(handles)
%
%	handles = RecoverImageAlignmentPoints(handles)
%
image_current_offsets = handles.reg.images_setting.image_current_offsets;

[ys1,xs1,zs1] = get_image_XYZ_vectors(handles.images(1));
[ys2,xs2,zs2] = get_image_XYZ_vectors(handles.images(2));

if isfield(handles.reg.images_setting,'images_alignment_points')
	% After resampling, the images are actually aligned on the slice-by-slice base, therefore 
	% the actual alignment_points are slightly off the original
	% alignment_points
	handles.reg.images_setting.images_alignment_points_original = handles.reg.images_setting.images_alignment_points;
	c1 = handles.reg.images_setting.images_alignment_points(1,:);	% the alignment points in image 1
	
	dsty = abs(ys1-c1(1,1));
	[dummy,ys1idx] = min(dsty);
	dstx = abs(xs1-c1(1,2));
	[dummy,xs1idx] = min(dstx);
	dstz = abs(zs1-c1(1,3));
	[dummy,zs1idx] = min(dstz);
	
	c1 = [ys1(ys1idx) xs1(xs1idx) zs1(zs1idx)];
	if isequal(handles.images(1).voxelsize,handles.images(2).voxelsize)
		c2idxes = [ys1idx xs1idx zs1idx] - image_current_offsets;
		c2 = [ys2(c2idxes(1)) xs2(c2idxes(2)) zs2(c2idxes(3))];
	else
		c2 = handles.reg.images_setting.images_alignment_points(2,:);	% the alignment points in image 1
		dsty = abs(ys2-c2(1,1));
		[dummy,ys2idx] = min(dsty);
		dstx = abs(xs2-c2(1,2));
		[dummy,xs2idx] = min(dstx);
		dstz = abs(zs2-c2(1,3));
		[dummy,zs2idx] = min(dstz);
		c2 = [ys2(ys2idx) xs2(xs2idx) zs2(zs2idx)];
	end
	handles.reg.images_setting.images_alignment_points = [c1; c2];
else
	c1 = [0 0 0];
	c2 = [0 0 0];
	vecs1 = {ys1,xs1,zs1};
	vecs2 = {ys2,xs2,zs2};
	dim1 = size(handles.images(1).image);
	dim2 = size(handles.images(2).image);
	for k = 1:3
		if image_current_offsets(k) > 0
			% Use center slice position in the image 2
			p = round((dim2(k)+1)/2);
			c2(k) = vecs2{k}(p);
			c1(k) = vecs1{k}(p+image_current_offsets(k));
		else
			% Use center slice position in the image 1
			p = round((dim1(k)+1)/2);
			c1(k) = vecs1{k}(p);
			c2(k) = vecs2{k}(p-image_current_offsets(k));
		end
	end
	handles.reg.images_setting.images_alignment_points = [c1;c2];
	handles.reg.images_setting.images_alignment_points_original = handles.reg.images_setting.images_alignment_points;
end

