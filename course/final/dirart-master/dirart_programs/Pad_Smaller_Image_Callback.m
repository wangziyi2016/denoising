function Pad_Smaller_Image_Callback(handles)
%
%	Pad_Smaller_Image_Callback(handles)
%
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);

if isequal(dim1,dim2) && isequal(handles.reg.images_setting.image_offsets,[0 0 0])
	disp('No need of padding ');
	return;
end

padval = Input_Image_Padding_Value;
if isempty(padval)
	disp('Padding is cancelled');
	return;
end

% img2 = ones(dim1)*padval;
img2 = ones([dim1(1) dim1(2) dim2(3)])*padval;

% img2((1:dim2(1))+handles.reg.images_setting.image_offsets(1),(1:dim2(2))+handles.reg.images_setting.image_offsets(2),(1:dim2(3))+handles.reg.images_setting.image_offsets(3)) = handles.images(2).image;
img2((1:dim2(1))+handles.reg.images_setting.image_offsets(1),(1:dim2(2))+handles.reg.images_setting.image_offsets(2),:) = handles.images(2).image;
handles.reg.images_setting.cropped_image_offsets_in_original(2,:) = handles.reg.images_setting.cropped_image_offsets_in_original(2,:) - [handles.reg.images_setting.image_offsets(1:2) 0];
handles.images(2).image = img2;

handles.images(2).origin(1:2) = handles.images(2).origin(1:2) - handles.images(2).voxelsize(1:2) .* handles.images(2).voxel_spacing_dir(1:2) .* handles.reg.images_setting.image_offsets(1:2);

% handles.reg.images_setting.image_offsets = [0 0 0];
handles = Logging(handles,'Image 2 is padded to match size of image 1\n\tBefore padding, image 2 size = %s, offsets = %s', ...
		num2str(dim2,'%d '), num2str(handles.reg.images_setting.image_offsets,'%d '));
handles.reg.images_setting.image_offsets(1:2) = [0 0];
handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;

handles = reconfigure_sliders(handles);
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);


