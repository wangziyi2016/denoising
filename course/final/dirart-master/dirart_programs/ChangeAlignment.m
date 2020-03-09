function handles = ChangeAlignment(handles,newoffsets)
%
%	handles = ChangeAlignment(handles,newoffsets)
%
if ~isequal(newoffsets,handles.reg.images_setting.image_offsets)
	assignin('base','offsets',newoffsets);
	
	diff = newoffsets - handles.reg.images_setting.image_offsets;
	c = handles.reg.images_setting.images_alignment_points(2,:);
	c = c - diff .* handles.images(1).voxelsize .* handles.images(1).voxel_spacing_dir;
	handles.reg.images_setting.images_alignment_points(2,:) = c;
	
	handles.reg.images_setting.image_offsets = newoffsets;
	handles.reg.images_setting.image_current_offsets = newoffsets;
	handles = Logging(handles,'Image offsets is updated to %s', num2str(newoffsets,'%g  '));
	handles = set_display_geometry_limits(handles);
	
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
end
