function Add_Subtract_Constant_Value_Callback(handles)
%
%
%
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

preproecessing_on_images = Read_Preprocessing_selection(handles);

new_processed_image_1 = handles.images(1).image;
if preproecessing_on_images(1) == 1
	answer=inputdlg('Constant value','Add / Subtract a constant value for image 1',1,{'0'});
	if ~isempty(answer)
		value = str2num(answer{1});
		new_processed_image_1 = handles.images(1).image + value;
	end
end
	
new_processed_image_2 = handles.images(2).image;
if preproecessing_on_images(2) == 1
	answer=inputdlg('Constant value','Add / Subtract a constant value for image 2',1,{'0'});
	if ~isempty(answer)
		value = str2num(answer{1});
		new_processed_image_2 = handles.images(2).image + value;
	end
end

if ~isequal(new_processed_image_1,handles.images(1).image) || ~isequal(new_processed_image_2,handles.images(2).image)
	handles.images(1).image = new_processed_image_1;
	handles.images(2).image = new_processed_image_2;
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
	setinfotext('Image values are updated');
else
	setinfotext('Image values are not updated');
end

