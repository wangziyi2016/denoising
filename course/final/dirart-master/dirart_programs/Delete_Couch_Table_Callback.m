function Delete_Couch_Table_Callback(handles)
%
%	Delete_Couch_Table_Callback(handles)
%
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

saved_display_mode = handles.gui_options.display_mode;
saved_display_enabled = handles.gui_options.display_enabled;
handles.gui_options.display_mode(1:2,2) = [1 2];	
handles.gui_options.display_mode(1:2,1) = 3;

handles.gui_options.display_enabled(1:2) = 1;
handles.gui_options.display_maxprojection = 1;
preproecessing_on_images = Read_Preprocessing_selection(handles);
handles.gui_options.display_destination = 2;

for k = 1:2
	if preproecessing_on_images(k) == 0
		continue;
	end
	
	hfig = update_display(handles,k);	% Show image k in the separated figure window
	title('Drag the mouse to mark the couch table region')
	axis on;
	[x1,y1,x2,y2] = GetCropBoundaries(k+10,1);
	if isempty(x1)
		close(hfig);
		continue;
	end
	
	vecs = GetImageCoordinateVectors(handles,k);
	dim = mysize(handles.images(k).image);
	ymin = 1;
	ymax = dim(1);
	xmin = 1;
	xmax = dim(2);
	zmin = 1;
	zmax = dim(3);
	
	switch handles.gui_options.display_mode(k,1)
		case 1	% coronal
			xmin = max(1,GetIndexFromCoordinate(vecs.xs,x1));
			xmax = min(dim(1),GetIndexFromCoordinate(vecs.xs,x2));
			zmin = max(1,GetIndexFromCoordinate(vecs.zs,y1));
			zmax = min(dim(3),GetIndexFromCoordinate(vecs.zs,y2));
		case 2	% sagittal
			ymin = max(1,GetIndexFromCoordinate(vecs.ys,x1));
			ymax = min(dim(1),GetIndexFromCoordinate(vecs.ys,x2));
			zmin = max(1,GetIndexFromCoordinate(vecs.zs,y1));
			zmax = min(dim(3),GetIndexFromCoordinate(vecs.zs,y2));
		case 3	% transverse
			ymin = max(1,GetIndexFromCoordinate(vecs.ys,y1));
			ymax = min(dim(1),GetIndexFromCoordinate(vecs.ys,y2));
			xmin = max(1,GetIndexFromCoordinate(vecs.xs,x1));
			xmax = min(dim(2),GetIndexFromCoordinate(vecs.xs,x2));
	end
	
	[xmin,xmax]=SortTwoValues(xmin,xmax);
	[ymin,ymax]=SortTwoValues(ymin,ymax);
	[zmin,zmax]=SortTwoValues(zmin,zmax);

	close(hfig);
	
	temp = handles.images(k).image;
	handles.images(k).image(ymin:ymax,xmin:xmax,zmin:zmax) = 0;
	handles.images(k).image(isnan(temp)) = nan;
	handles.images(k).image = handles.images(k).image;
	handles = Logging(handles,'Image #%d is set to 0 for region [%d-%d,%d-%d,%d-%d]',k,ymin,ymax,xmin,xmax,zmin,zmax);

	setinfotext('Couch table in images have been deleted');
end

handles.gui_options.display_destination = 1;
handles.gui_options.display_mode = saved_display_mode;
handles.gui_options.display_enabled = saved_display_enabled;
handles.gui_options.display_maxprojection = 0;

guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);

