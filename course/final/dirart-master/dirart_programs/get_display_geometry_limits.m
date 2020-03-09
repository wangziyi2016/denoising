function [xlimits,ylimits]= get_display_geometry_limits(handles,idx,display_geometry_limit_mode,imgidx)
%
%	[xlimits,ylimits]=get_display_geometry_limits(handles,idx,display_geometry_limit_mode,imgidx)
%
displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);

if ~exist('imgidx','var')
	imgidx = WhichImageCoordinateToUse(displaymode);
end

if ~exist('display_geometry_limit_mode','var') || isempty(display_geometry_limit_mode)
	display_geometry_limit_mode = handles.gui_options.display_geometry_limit_mode(idx);
end
display_geometry_limit_mode = ConvertDisplayLimitModes(displaymode,display_geometry_limit_mode);

if ~isequal(handles.images(1).voxelsize,handles.images(2).voxelsize) && display_geometry_limit_mode == 5
	display_geometry_limit_mode = 4;
end

if display_geometry_limit_mode == 5
	dim1 = mysize(handles.images(1).image);
	dim2 = mysize(handles.images(2).image);

	images_alignment_points = handles.reg.images_setting.images_alignment_points;
	image_current_offsets = handles.reg.images_setting.image_current_offsets;

	vecs_img1 = GetImageCoordinateVectors(handles,1);
	vecs_img2 = GetImageCoordinateVectors(handles,2);

	% Where are the two images aligned
	ori_idx_1 = image_current_offsets;
	ori_idx_2 = [0 0 0];

	% Find some points inside both image 1 and image 2


	yoffs = [1 dim2(1)]+image_current_offsets(1);	% Image 1 voxel positions corresponding to image 2
	xoffs = [1 dim2(2)]+image_current_offsets(2);
	zoffs = [1 dim2(3)]+image_current_offsets(3);

	% compute the combined dimension if image 1 and 2 are different in dimension
	yoffsc = min(yoffs(1),1):max(yoffs(end),dim1(1));	% voxels positions of the common dimension respecting to image 1
	xoffsc = min(xoffs(1),1):max(xoffs(end),dim1(2));
	zoffsc = min(zoffs(1),1):max(zoffs(end),dim1(3));

	% compute the intersected dimension if image 1 and 2 are different in dimension
	yoffsj = max(yoffs(1),1):min(yoffs(end),dim1(1));	% voxels positions of the common dimension respecting to image 1
	xoffsj = max(xoffs(1),1):min(xoffs(end),dim1(2));
	zoffsj = max(zoffs(1),1):min(zoffs(end),dim1(3));

	img1_offsets_c = 1 - [yoffsc(1) xoffsc(1) zoffsc(1)];		% image 1 offets in the combined dimension
	img2_offsets_c = img1_offsets_c + image_current_offsets;	% image 2 offets in the combined dimension
	imgj_offsets_c = img1_offsets_c + [yoffsj(1) xoffsj(1) zoffsj(1)] - 1;	% the intersected dimension offets in the combined dimension

	dimc = [length(yoffsc) length(xoffsc) length(zoffsc)];	% Dimension of the common image
	dimj = [length(yoffsj) length(xoffsj) length(zoffsj)];	% Dimension of the common image

end


switch display_geometry_limit_mode
	case 2	% In fixed image dimension (image 2)
		vecs = GetImageCoordinateVectors(handles,2,viewdir,imgidx);
	case 3	% In moving image dimension (image 1)
		vecs = GetImageCoordinateVectors(handles,1,viewdir,imgidx);
	case 4	% In the combined image dimension
		vecs = GetCombinedImageCoordinateVectors(handles,viewdir);
		vecs = vecs(imgidx);
	case 5	% In the intersected image dimension
		vecs = GetCombinedImageCoordinateVectors(handles,viewdir);
		vecs = vecs(imgidx);
		dim_idxes = GetDimensionIdxes(viewdir);
		vecs.xs = vecs.xs((1:dimj(dim_idxes(1)))+imgj_offsets_c(dim_idxes(1)));
		vecs.ys = vecs.ys((1:dimj(dim_idxes(2)))+imgj_offsets_c(dim_idxes(2)));
end


xlimits = GetLimitsFromVector(vecs.xs);
ylimits = GetLimitsFromVector(vecs.ys);




