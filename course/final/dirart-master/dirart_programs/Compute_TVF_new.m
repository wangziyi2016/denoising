function tvf = Compute_TVF_new(dvf,origin,target_img_info,target_origin)
%
% Convert deformation vector field (DVF) to transformation vector field (TVF)
%
%	tvf = Compute_TVF_new(dvf,origin,target_img_info,target_origin)
%
dim = size(dvf.x);
[ysm,xsm,zsm] = get_image_XYZ_vectors(dvf.info,dim);

% the original coordinates
tvf.info = dvf.info;
tvf.xs = xsm;	
tvf.ys = ysm;
tvf.zs = zsm;
tvf.dim = dim;

[xxm,yym,zzm] = meshgrid(xsm,ysm,zsm);

deltax = dvf.x * dvf.info.voxelsize(2) * dvf.info.voxel_spacing_dir(2);
deltay = dvf.y * dvf.info.voxelsize(1) * dvf.info.voxel_spacing_dir(1);
deltaz = dvf.z * dvf.info.voxelsize(3) * dvf.info.voxel_spacing_dir(3);

yym = yym - deltay;
xxm = xxm - deltax;
zzm = zzm - deltaz;

% convert to relative coordinates
yym = yym - origin(1);	
xxm = xxm - origin(2);
zzm = zzm - origin(3);

samedir = target_img_info.voxel_spacing_dir .* dvf.info.voxel_spacing_dir;

yym = yym * samedir(1);		% correct the direction
xxm = xxm * samedir(2);
zzm = zzm * samedir(3);

% Transfer to the target coordinate

yym = yym + target_origin(1);
xxm = xxm + target_origin(2);
zzm = zzm + target_origin(3);

tvf.x = xxm;
tvf.y = yym;
tvf.z = zzm;

