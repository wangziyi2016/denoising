function Align_Image_Mouse(handles,current_mouse_point)
%
%
%
idx = handles.gui_options.current_axes_idx;
displaymode = handles.gui_options.display_mode(idx,2);
if ~any(displaymode==[3 6 7 19 20])
	% Only in difference image display
	return;
end
viewdir = handles.gui_options.display_mode(idx,1);
limits = handles.gui_options.display_limits(idx,displaymode);

cx = mean(limits.xlimits);
cy = mean(limits.ylimits);
cz = mean(limits.zlimits);

wx = diff(limits.xlimits)/2;
wy = diff(limits.ylimits)/2;
wz = diff(limits.zlimits)/2;

x = current_mouse_point(1,1);
y = current_mouse_point(1,2);

image_offsets = handles.reg.images_setting.image_offsets;

switch viewdir
	case 1
		dx = round((x - cx)/wx*6);
		dz = round((y - cz)/wz*6);
		image_offsets(2) = image_offsets(2) + dx;
		image_offsets(3) = image_offsets(3) + dz;
	case 2
		dy = round((x - cy)/wy*6);
		dz = round((y - cz)/wz*6);
		image_offsets(1) = image_offsets(1) + dy;
		image_offsets(3) = image_offsets(3) + dz;
	case 3
		dx = round((x - cx)/wx*6);
		dy = round((y - cy)/wy*6);
		image_offsets(1) = image_offsets(1) + dy;
		image_offsets(2) = image_offsets(2) + dx;
end

if ~isequal(image_offsets,handles.reg.images_setting.image_offsets)
	offsets = image_offsets
	assignin('base','offsets',offsets);
	handles.reg.images_setting.image_offsets = image_offsets;
	handles.reg.images_setting.image_current_offsets = image_offsets;
	handles = Logging(handles,'Image offsets are changed to %s', num2str(image_offsets,'%g  '));
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
end

