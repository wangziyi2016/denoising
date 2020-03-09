function infos = GenerateMultigridImageInfo(image)
%
%
%
infos(1) = rmfield(image,'image');
for stageno = 2:5
	newinfo = infos(stageno-1);
	newinfo.origin = newinfo.origin + newinfo.voxelsize.*newinfo.voxel_spacing_dir;
	newinfo.voxelsize = newinfo.voxelsize*2;
	infos(stageno) = newinfo;
end
