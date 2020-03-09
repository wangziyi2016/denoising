function Align_Image(handles,direction,step)
%
%
%
if isequal(size(handles.images(1).image),size(handles.images(2).image))
	return;
end

image_offsets = handles.reg.images_setting.image_offsets;
image_offsets(direction) = image_offsets(direction)+step;
if ~isequal(image_offsets,handles.reg.images_setting.image_offsets)
	offsets = image_offsets
	assignin('base','offsets',offsets);
	handles.reg.images_setting.image_offsets = image_offsets;
	handles.reg.images_setting.image_current_offsets = image_offsets;
	handles = Logging(handles,'Image offsets are changed to %s', num2str(image_offsets,'%g  '));
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
end

