function [ys,xs,zs] = get_image_XYZ_vectors(imginfo,dim)
%
%	[ys,xs,zs] = get_image_XYZ_vectors(imginfo)
%	[ys,xs,zs] = get_image_XYZ_vectors(imginfo,dim)
%	[ys,xs,zs] = get_image_XYZ_vectors(imginfo,imgarray)
%
ys = [];
xs = [];
zs = [];

if isempty(imginfo)
	return;
end

if ~exist('dim','var')
	dim = [size(imginfo.image) 1 1];
elseif numel(dim)>4
	dim = [size(dim) 1 1];
end

ys = ([1:dim(1)]-1)*imginfo.voxelsize(1)*imginfo.voxel_spacing_dir(1)+imginfo.origin(1);
xs = ([1:dim(2)]-1)*imginfo.voxelsize(2)*imginfo.voxel_spacing_dir(2)+imginfo.origin(2);
zs = ([1:dim(3)]-1)*imginfo.voxelsize(3)*imginfo.voxel_spacing_dir(3)+imginfo.origin(3);

