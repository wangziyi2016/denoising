function MoveDisplay(handles,current_point,init_point)
%
%
%
idx = handles.gui_options.current_axes_idx;
displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);
limits = handles.gui_options.display_limits(idx,displaymode);

x = current_point(1,1);
y = current_point(1,2);
cx = init_point(1,1);
cy = init_point(1,2);

dx = (x - cx)/2;
dy = (y - cy)/2;
switch viewdir
	case 1
		limits.xlimits = limits.xlimits - dx;
		limits.zlimits = limits.zlimits - dy;
		set(handles.gui_handles.button_down_axis,'xlim',limits.xlimits,'ylim',limits.zlimits);
	case 2
		limits.ylimits = limits.ylimits - dx;
		limits.zlimits = limits.zlimits - dy;
		set(handles.gui_handles.button_down_axis,'xlim',limits.ylimits,'ylim',limits.zlimits);
	case 3
		limits.xlimits = limits.xlimits - dx;
		limits.ylimits = limits.ylimits - dy;
		set(handles.gui_handles.button_down_axis,'xlim',limits.xlimits,'ylim',limits.ylimits);
end


% labelObj = findobj(handles.gui_handles.figure1,'tag',['label' num2str(idx)]);
% if ~isempty(labelObj)
% 	pos = get(labelObj,'Position');
% 	pos(1) = pos(1)+dx/2;
% 	pos(2) = pos(2)+dy/2;
% 	set(labelObj,'Position',pos);
% end




