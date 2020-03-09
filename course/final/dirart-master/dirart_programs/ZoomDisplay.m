function ZoomDisplay(handles,mode,center_point)
%
% mode =	0	-	zoom reset
%			1	-	zoom in
%			2	-	zoom out
%
idx = handles.gui_options.current_axes_idx;
displaymode = handles.gui_options.display_mode(idx,2);
viewdir = handles.gui_options.display_mode(idx,1);
hAxes = handles.gui_handles.axes_handles(idx);
limits = handles.gui_options.display_limits(idx,displaymode);
limits_wo = handles.gui_options.display_limits_without_zoom(idx,displaymode);

if mode == 0
	handles.gui_options.display_mode(idx,1) = 3;
	[xlimits,ylimits]= get_display_geometry_limits(handles,idx);
	handles.gui_options.display_mode(idx,1) = 1;
	[xlimits,zlimits]= get_display_geometry_limits(handles,idx);
	handles.gui_options.display_mode(idx,1) =  viewdir;
	limits.xlimits = xlimits;
	limits.ylimits = ylimits;
	limits.zlimits = zlimits;
else
	[rx,ry] = ComputeAxesLimitToPositionRatio(hAxes);	% rx * xlimits = # of pixels displayed in the x dir
	posa = get(hAxes,'Position');
	posf = get(handles.gui_handles.figure1,'Position');
	posa = posa.*[posf(3:4) posf(3:4)];	% In pixels

	f = 0.8;
	if mode == 1
		rx = rx/f;
		ry = ry/f;
	else
		rx = rx*f;
		ry = ry*f;
	end
	
	newplotwx = posa(3)/rx;
	newplotwy = posa(4)/ry;

	
	if exist('center_point','var')
		cx = center_point(1,1);
		cy = center_point(1,2);
	else
		switch viewdir
			case 1
				cx = mean(limits.xlimits);
				cy = mean(limits.zlimits);
			case 2
				cx = mean(limits.ylimits);
				cy = mean(limits.zlimits);
			case 3
				cx = mean(limits.xlimits);
				cy = mean(limits.ylimits);
		end
	end
	
	new_xlimits = [cx-newplotwx/2 cx+newplotwx/2];
	new_ylimits = [cy-newplotwy/2 cy+newplotwy/2];
	
	switch viewdir
		case 1
			new_xlimits(1) = max(new_xlimits(1),limits_wo.xlimits(1));
			new_xlimits(2) = min(new_xlimits(2),limits_wo.xlimits(2));
			new_ylimits(1) = max(new_ylimits(1),limits_wo.zlimits(1));
			new_ylimits(2) = min(new_ylimits(2),limits_wo.zlimits(2));
			limits.xlimits = new_xlimits;
			limits.zlimits = new_ylimits;
		case 2
			new_xlimits(1) = max(new_xlimits(1),limits_wo.ylimits(1));
			new_xlimits(2) = min(new_xlimits(2),limits_wo.ylimits(2));
			new_ylimits(1) = max(new_ylimits(1),limits_wo.zlimits(1));
			new_ylimits(2) = min(new_ylimits(2),limits_wo.zlimits(2));
			limits.ylimits = new_xlimits;
			limits.zlimits = new_ylimits;
		case 3
			new_xlimits(1) = max(new_xlimits(1),limits_wo.xlimits(1));
			new_xlimits(2) = min(new_xlimits(2),limits_wo.xlimits(2));
			new_ylimits(1) = max(new_ylimits(1),limits_wo.ylimits(1));
			new_ylimits(2) = min(new_ylimits(2),limits_wo.ylimits(2));
			limits.xlimits = new_xlimits;
			limits.ylimits = new_ylimits;
	end

end

if ~isequal(handles.gui_options.display_limits(idx,displaymode),limits)
	handles.gui_options.display_limits(idx,displaymode) = limits;
	guidata(handles.gui_handles.figure1,handles);
	update_display(handles,idx);
end


