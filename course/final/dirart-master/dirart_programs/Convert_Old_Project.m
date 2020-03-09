function handles = Convert_Old_Project(handles)
%
%
%
image_fields = {'voxelsizes','physical_origins','voxel_spacing_dirs','image_classes',...
	'image_filenames','image_types','structure_masks','structure_names'};

img1.image = handles.images{1};
img1.voxelsize = handles.voxelsizes{1};
img1.origin = handles.physical_origins{1};
img1.voxel_spacing_dir = handles.voxel_spacing_dirs{1};
img1.class = handles.image_classes{1};
img1.filename = handles.image_filenames{1};
img1.type = handles.image_types{1};
img1.transM = eye(4);
img1.image_deformed = handles.i1vx;
img1.structure_mask = handles.structure_masks{1};
img1.structure_name = handles.structure_names{1};

img2.image = handles.images{2};
img2.voxelsize = handles.voxelsizes{2};
img2.origin = handles.physical_origins{2};
img2.voxel_spacing_dir = handles.voxel_spacing_dirs{2};
img2.class = handles.image_classes{2};
img2.filename = handles.image_filenames{2};
img2.type = handles.image_types{2};
img2.transM = eye(4);
img2.image_deformed = handles.i2vx;
img2.structure_mask = handles.structure_masks{2};
img2.structure_name = handles.structure_names{2};

handles = rmfield_from_struct(handles,{'images','voxelsizes','physical_origins','voxel_spacing_dirs',...
	'image_classes','image_filenames','image_types','i1vx','i2vx','structure_masks','structure_names'});

handles.images(1) = img1;
handles.images(2) = img2;

handles.reg.dvf.x = handles.mvx;
handles.reg.dvf.y = handles.mvy;
handles.reg.dvf.z = handles.mvz;

handles.reg.idvf.x = handles.imvx;
handles.reg.idvf.y = handles.imvy;
handles.reg.idvf.z = handles.imvz;

handles = rmfield_from_struct(handles,{'mvx','mvy','mvz','imvx','imvy','imvz'});

names = fieldnames(handles.gui_handles);
for k = 1:length(names)
	if isfield(handles,names{k})
		handles = rmfield(handles,names{k});
	end
end

gui_fields = {'display_mode','display_enabled','display_geometry_limit_mode','checkerboard_size',...
	'motion_grid_size','motion_vector_line_width','window_center','window_width',...
	'contour_line_thickness','slidervalues','colormap','difference_image_range','slidermins','slidermaxs'};

for k = 1:length(gui_fields)
	if isfield(handles,gui_fields{k})
		handles.gui_options.(gui_fields{k}) = handles.(gui_fields{k});
		handles = rmfield(handles,gui_fields{k});
	end
end


img_info_fields = {'image_offsets','image_current_offsets','cropped_image_offsets_in_original',...
	'ratio','voxelsize','max_intensity_value'};

for k = 1:length(img_info_fields)
	if isfield(handles,img_info_fields{k})
		handles.reg.images_setting.(img_info_fields{k}) = handles.(img_info_fields{k});
		handles = rmfield(handles,img_info_fields{k});
	end
end


reg_fields = {'Multigrid_Stages','maxiters','max_motion_per_iteration','minimal_max_motion_per_pass',...
	'minimal_max_motion_per_iteration','Save_Temp_Results','Generate_Reverse_Consistent_Motion_Field',...
	'passes_in_stages','last_registration_method','smoothing_in_iteration','smoothing_after_pass',...
	'multigrid_filter_type','Intensity_Modulation','Use_Both_Image_Gradients','Log_Output'};


for k = 1:length(reg_fields)
	if isfield(handles,reg_fields{k})
		handles.reg.(reg_fields{k}) = handles.(reg_fields{k});
		handles = rmfield(handles,reg_fields{k});
	end
end

% handles.gui_handles.image_offsets = [0 0 0];
% handles.gui_handles.image_current_offsets = [0 0 0];
% handles.gui_handles.max_intensity_value = max([handles.images(1).image(:);handles.images(2).image(:)]);
% handles.gui_handles.cropped_image_offsets_in_original = [0 0 0; 0 0 0];

info_fields = {'program_fullpath','program_path','program_name','temp_storage_path',...
	'name','log'};

for k = 1:length(info_fields)
	if isfield(handles,info_fields{k})
		handles.info.(info_fields{k}) = handles.(info_fields{k});
		handles = rmfield(handles,info_fields{k});
	end
end

handles = rmfield_from_struct(handles,{'use_original_voxelsizes','button_down_axis_idx','button_down_axis','current_mouse_point'});

