function handles = GPReduce_Callback(handles,preproecessing_on_images)
%
%
%

answer = questdlg('Half sample the image in transverse view only?','Half Sampling the Image','No','Yes','No');

if preproecessing_on_images(1) == 1
	if strcmp(answer,'No')
		handles.images(1).image = GPReduce(handles.images(1).image,1);
	else
		handles.images(1).image = GPReduce2D(handles.images(1).image,1);
	end
	handles.images(1).image = handles.images(1).image;
	handles = Logging(handles,'Image #1 is GPReduced');
end

if preproecessing_on_images(2) == 1
	if strcmp(answer,'No')
		handles.images(2).image = GPReduce(handles.images(2).image,1);
	else
		handles.images(2).image = GPReduce2D(handles.images(2).image,1);
	end
	handles.images(2).image = handles.images(2).image;
	handles = Logging(handles,'Image #2 is GPReduced');
end

if strcmp(answer,'No')
	handles.reg.images_setting.image_offsets = round(handles.reg.images_setting.image_offsets/2);
	handles.reg.images_setting.image_current_offsets = round(handles.reg.images_setting.image_current_offsets/2);
	handles.images(1).origin = handles.images(1).origin + handles.images(1).voxelsize .* handles.images(1).voxel_spacing_dir / 2;
	handles.images(2).origin = handles.images(2).origin + handles.images(2).voxelsize .* handles.images(2).voxel_spacing_dir / 2;
	handles.images(1).voxelsize = handles.images(1).voxelsize*2;
	handles.images(2).voxelsize = handles.images(2).voxelsize*2;
else
	handles.reg.images_setting.image_offsets(1:2) = round(handles.reg.images_setting.image_offsets(1:2)/2);
	handles.reg.images_setting.image_current_offsets(1:2) = round(handles.reg.images_setting.image_current_offsets(1:2)/2);
	handles.images(1).origin(1:2) = handles.images(1).origin(1:2) + handles.images(1).voxelsize(1:2) .* handles.images(1).voxel_spacing_dir(1:2) / 2;
	handles.images(2).origin(1:2) = handles.images(2).origin(1:2) + handles.images(2).voxelsize(1:2) .* handles.images(2).voxel_spacing_dir(1:2) / 2;
	handles.images(1).voxelsize(1:2) = handles.images(1).voxelsize(1:2)*2;
	handles.images(2).voxelsize(1:2) = handles.images(2).voxelsize(1:2)*2;
end


