function handles = Load_Images_From_Temp_Folder(handles,seq)
%
%
%
load([handles.info.temp_storage_path filesep 'image1-' num2str(seq) '.mat']);
handles.images(1).class = class(image_data);
handles.images(1).image = single(image_data);
handles.images(1).voxelsize = voxel_size;
handles.images(1).origin = origin;
handles.images(1).voxel_spacing_dir = voxel_spacing_dir;
handles.images(1).filename = image_filename;

load([handles.info.temp_storage_path filesep 'image2-' num2str(seq) '.mat']);
handles.images(2).class = class(image_data);
handles.images(2).image = single(image_data);
handles.images(2).voxelsize = voxel_size;
handles.images(2).origin = origin;
handles.images(2).voxel_spacing_dir = voxel_spacing_dir;
handles.images(2).filename = image_filename;

