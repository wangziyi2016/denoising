function handles = set_display_geometry_limits(handles,idx)
%
%	handles = set_display_geometry_limits(handles)
%	handles = set_display_geometry_limits(handles,idx)
%
if ~exist('idx','var')
	idxes = 1:handles.gui_options.num_panels;
else
	idxes = idx;
end

if isempty(handles.images(1).image)
	limits.xlimits = [1 1];
	limits.ylimits = [1 1];
	limits.zlimits = [1 1];
	for displaymode = 1:30
		handles.gui_options.display_limits(1:7,displaymode) = limits;
		handles.gui_options.display_limits_without_zoom(1:7,displaymode) = limits;
	end
else
	display_mode_save = handles.gui_options.display_mode;
	for k = 1:length(idxes)
		idx = idxes(k);
		for displaymode = 1:30
			handles.gui_options.display_mode(idx,2) = displaymode;
			handles.gui_options.display_mode(idx,1) = 3;
			[xlimits,ylimits]= get_display_geometry_limits(handles,idx);
			handles.gui_options.display_mode(idx,1) = 1;
			[xlimits,zlimits]= get_display_geometry_limits(handles,idx);
			limits.xlimits = xlimits;
			limits.ylimits = ylimits;
			limits.zlimits = zlimits;
			handles.gui_options.display_limits(idx,displaymode) = limits;
			handles.gui_options.display_limits_without_zoom(idx,displaymode) = limits;
		end
	end
	handles.gui_options.display_mode = display_mode_save;
end
