function itvf = ComputeITVF(idvf,fixed_image,moving_image,offsets)
%
% Convert inverse deformation vector field (IDVF) to inverse transformation vector field (ITVF)
%
%	itvf = ComputeITVF(idvf,fixed_image,moving_image,offsets)
%	
%	idvf is assumed to be defined on the voxels of the moving image
%	idvf has the same dimension as either the moving image, or the fixed image
%
dim = size(idvf.x);

% the original coordinate vectors
itvf = rmfield_from_struct(moving_image,{'image','original_voxelsize','structure_mask','image_deformed','filename','structure_name'});

[ysm,xsm,zsm] = get_image_XYZ_vectors(moving_image);
if isequal(dim,size(fixed_image.image))
	xs = (1:dim(2)) + offsets(2);
	ys = (1:dim(1)) + offsets(1);
	zs = (1:dim(3)) + offsets(3);
	ysm2 = ysm(ys);
	xsm2 = xsm(xs);
	zsm2 = zsm(zs);
	itvf.origin = [ysm2(1) xsm2(1) zsm2(1)];
else
	ysm2 = ysm;
	xsm2 = xsm;
	zsm2 = zsm;
end

itvf.xs = xsm2;	
itvf.ys = ysm2;
itvf.zs = zsm2;
itvf.dim = dim;

[xx,yy,zz] = meshgrid(xsm2,ysm2,zsm2);

% the mapping points
itvf.x = xx-idvf.x*moving_image.voxelsize(2)*fixed_image.voxel_spacing_dir(2);
itvf.y = yy-idvf.y*moving_image.voxelsize(1)*fixed_image.voxel_spacing_dir(1);
itvf.z = zz-idvf.z*moving_image.voxelsize(3)*fixed_image.voxel_spacing_dir(3);

offs = offsets .* moving_image.voxelsize .* moving_image.voxel_spacing_dir;
offs = offs + moving_image.origin - fixed_image.origin;
itvf.x = itvf.x - offs(2);
itvf.y = itvf.y - offs(1);
itvf.z = itvf.z - offs(3);

