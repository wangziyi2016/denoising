function DoseMenuCallback(hObject,handles,doseidx)
%
%	DoseMenuCallback(hObject,handles,idx)
%
val = Check_MenuItem(hObject,0);
set(get(get(hObject,'parent'),'child'),'checked','off');
if val == 0
	set(hObject,'checked','on');
end

if handles.gui_options.lock_between_display == 1
	if val == 0
		handles.gui_options.DoseDisplayOptions.dose_to_display(:) = doseidx;
	else
		handles.gui_options.DoseDisplayOptions.dose_to_display(:) = 0;
	end
	RefreshDisplay(handles);
else
	if val == 0
		handles.gui_options.DoseDisplayOptions.dose_to_display(handles.gui_options.current_axes_idx) = doseidx;
	else
		handles.gui_options.DoseDisplayOptions.dose_to_display(handles.gui_options.current_axes_idx) = 0;
	end
	update_display(handles,handles.gui_options.current_axes_idx);
end
guidata(handles.gui_handles.figure1,handles);

