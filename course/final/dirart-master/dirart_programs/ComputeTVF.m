function tvf = ComputeTVF(dvf,fixed_image,moving_image,offsets)
%
% Convert deformation vector field (DVF) to transformation vector field (TVF)
%
%	tvf = ComputeTVF(dvf,fixed_image,moving_image,offsets)
%	
%	dvf is assumed to be defined on the voxels of the fixed image
%


dim = size(fixed_image.image);
[ysm,xsm,zsm] = get_image_XYZ_vectors(moving_image);
xs = (1:dim(2)) + offsets(2);
ys = (1:dim(1)) + offsets(1);
zs = (1:dim(3)) + offsets(3);
ysm2 = ysm(ys);
xsm2 = xsm(xs);
zsm2 = zsm(zs);

[xx,yy,zz] = meshgrid(xsm2,ysm2,zsm2);

% the original coordinate vectors
tvf = rmfield_from_struct(fixed_image,{'image','original_voxelsize','structure_mask','image_deformed','filename','structure_name'});
[ys,xs,zs] = get_image_XYZ_vectors(fixed_image);
tvf.xs = xs;	
tvf.ys = ys;
tvf.zs = zs;
tvf.dim = dim;

% the mapping points
tvf.x = xx-dvf.x*fixed_image.voxelsize(2)*moving_image.voxel_spacing_dir(2);
tvf.y = yy-dvf.y*fixed_image.voxelsize(1)*moving_image.voxel_spacing_dir(1);
tvf.z = zz-dvf.z*fixed_image.voxelsize(3)*moving_image.voxel_spacing_dir(3);


