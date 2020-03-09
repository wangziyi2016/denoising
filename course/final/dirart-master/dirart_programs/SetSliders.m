function handles = SetSliders(handles,idx)
%
%
%
if handles.gui_options.display_enabled(idx) == 0
	set(handles.gui_handles.sliderhandles,'enable','off');
	set(handles.gui_handles.sliderinputhandles,'enable','off');
else
	displaymode = handles.gui_options.display_mode(idx,2);
% 	[dim,offs] = GetImageDisplayDimensionAndOffsets(handles,displaymode);
	dim = GetImageDisplayDimensionAndOffsets(handles,displaymode);

	set(handles.gui_handles.sliderhandles,'enable','on');
	set(handles.gui_handles.sliderinputhandles,'enable','on');
	
	slider_steps = [1 1 1;1 1 1];
	slider_steps(1,:) = [1 1 1]./(dim-1);
	slider_steps(2,:) = [5 5 5]./(dim-1);
	
	set(handles.gui_handles.csno,'sliderstep',slider_steps(:,1),'max',dim(1),'min',1,'Value',handles.gui_options.slidervalues(idx,1));
	set(handles.gui_handles.csmax,'String',num2str(dim(1)));
	set(handles.gui_handles.csinput,'String',num2str(handles.gui_options.slidervalues(idx,1)));

	set(handles.gui_handles.ssno,'sliderstep',slider_steps(:,2),'max',dim(2),'min',1,'Value',handles.gui_options.slidervalues(idx,2));
	set(handles.gui_handles.ssmax,'String',num2str(dim(2)));
	set(handles.gui_handles.ssinput,'String',num2str(handles.gui_options.slidervalues(idx,2)));

	if dim(3) > 1
		set(handles.gui_handles.tsno,'sliderstep',slider_steps(:,3),'max',dim(3),'min',1,'Value',handles.gui_options.slidervalues(idx,3));
		set(handles.gui_handles.tsmax,'String',num2str(dim(3)));
		set(handles.gui_handles.tsinput,'String',num2str(handles.gui_options.slidervalues(idx,3)));
	else
		% Turn off slider controls for 2D
		EnableSliderControls(handles);
	end
end
