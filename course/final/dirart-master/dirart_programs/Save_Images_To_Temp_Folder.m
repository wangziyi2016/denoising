function Save_Images_To_Temp_Folder(handles,seq)
if ~isempty(handles.images(1).image)
	if ~exist(handles.info.temp_storage_path,'dir')
		mkdir(handles.info.temp_storage_path);
	end
	
	fprintf('Saving image data into folder: %s\n',handles.info.temp_storage_path);
	image_data = cast(handles.images(1).image,handles.images(1).class);
	voxel_size = handles.images(1).voxelsize;
	origin = handles.images(1).origin;
	voxel_spacing_dir = handles.images(1).voxel_spacing_dir;
	image_filename = handles.images(1).filename;

	save([handles.info.temp_storage_path filesep 'image1-' num2str(seq) '.mat'],'image_data','voxel_size','origin','voxel_spacing_dir','image_filename');

	image_data = cast(handles.images(2).image,handles.images(2).class);
	voxel_size = handles.images(2).voxelsize;
	origin = handles.images(2).origin;
	voxel_spacing_dir = handles.images(2).voxel_spacing_dir;
	image_filename = handles.images(2).filename;

	save([handles.info.temp_storage_path filesep 'image2-' num2str(seq) '.mat'],'image_data','voxel_size','origin','voxel_spacing_dir','image_filename');
end

