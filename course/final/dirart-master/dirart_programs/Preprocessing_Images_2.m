function handles = Preprocessing_Images_2(handles,action)
%
%	handles = Preprocessing_Images_2(handles,action)
%

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

preproecessing_on_images(1) = Check_MenuItem(handles.gui_handles.Apply_2_Image_1_Menu_Item,0);
preproecessing_on_images(2) = Check_MenuItem(handles.gui_handles.Apply_2_Image_2_Menu_Item,0);

handles2 = handles;
switch lower(action)
	case 'histogram_equalization'
		handles2 = Histogram_Equalization_Callback(handles,preproecessing_on_images);
		setinfotext('Histogram equalization has been applied to correct images intensity');
	case 'clahe'
		handles2 = CLAHE_Callback(handles,preproecessing_on_images);
		setinfotext('CLAHE filter has been applied to correct images intensity');
	case 'intensity_correction'
		handles2 = Intensity_Correction_Callback(handles);
		setinfotext('Images intensity has been normalized');
	case 'gpreduce'
		handles2 = GPReduce_Callback(handles,preproecessing_on_images);
		setinfotext('Images have been halved by using Laplician pyramid filter');
	otherwise
		setinfotext(sprintf('Unknown image preprocessing action: %s',action));
end

if isequalwithequalnans(handles,handles2)
	handles = handles2;
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
end

return;
