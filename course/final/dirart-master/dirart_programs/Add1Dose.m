function Add1Dose(handles,newdose)
%
%
%
if isempty(handles.ART.dose)
	handles.ART.dose{1} = newdose;
else
	handles.ART.dose{end+1} = newdose;
end
if isempty(newdose.Description)
	setinfotext(sprintf('Dose %d is added',length(handles.ART.dose)));
else
	setinfotext(sprintf('Dose [%s] is added',newdose.Description));
end
GenerateDoseMenu(handles);
if sum(handles.gui_options.DoseDisplayOptions.dose_to_display) > 0
	RefreshDisplay(handles);
end
handles.gui_options.DoseDisplayOptions.dose_to_display(:) = 0;
guidata(handles.gui_handles.figure1,handles);

