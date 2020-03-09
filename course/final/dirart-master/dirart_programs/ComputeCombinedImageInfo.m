function [dimc,img1_offsets_c,img2_offsets_c] = ComputeCombinedImageInfo(handles)
%
%	[dimc,img1_offsets_c,img2_offsets_c] = ComputeCombinedImageInfo(handles)
%
dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);

image_current_offsets = handles.reg.images_setting.image_current_offsets;
yoffs = (1:dim2(1))+image_current_offsets(1);	% Image 1 voxel positions corresponding to image 2
xoffs = (1:dim2(2))+image_current_offsets(2);
zoffs = (1:dim2(3))+image_current_offsets(3);

% compute the common dimension if image 1 and 2 are different in dimension
yoffsc = min(yoffs(1),1):max(yoffs(end),dim1(1));	% voxels positions of the common dimension respecting to image 1
xoffsc = min(xoffs(1),1):max(xoffs(end),dim1(2));
zoffsc = min(zoffs(1),1):max(zoffs(end),dim1(3));
img1_offsets_c = 1 - [yoffsc(1) xoffsc(1) zoffsc(1)];		% image 1 offets in the common dimension
img2_offsets_c = img1_offsets_c + image_current_offsets;	% image 2 offets in the common dimension
dimc = [length(yoffsc) length(xoffsc) length(zoffsc)];	% Dimension of the common image

