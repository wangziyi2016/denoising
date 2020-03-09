% --------------------------------------------------------------------
function handles = Crop_Image_Callback(handles,mode,display)

if ~exist('display','var')
	display = 1;
end

handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

saved_display_mode = handles.gui_options.display_mode;
saved_display_enabled = handles.gui_options.display_enabled;
if ~any(handles.gui_options.display_mode(1,2) == [1 4 6 7 19 20])
	handles.gui_options.display_mode(1,2) = 1;	
end

handles.gui_options.display_mode(2,2) = 2;
handles.gui_options.display_enabled(1:2) = 1;
handles.gui_options.display_maxprojection = 1;
preproecessing_on_images = Read_Preprocessing_selection(handles);

for k = 2:-1:1
	if preproecessing_on_images(k) == 0
		continue;
	end
	
	if mode == 1
		update_display(handles,k);	% Show image k in the separated figure window
		figure(k+10);
		title('To crop the image, drag the mouse to mark the region')
		axis on;
		[x1,y1,x2,y2] = GetCropBoundaries(k+10,1);
		close(k+10);
		if isempty(x1)
			continue;
		end

		vecs = GetImageCoordinateVectors(handles,k,handles.gui_options.display_mode(k,1));
		x1 = GetIndexFromCoordinate(vecs.xs,x1);
		x2 = GetIndexFromCoordinate(vecs.xs,x2);
		y1 = GetIndexFromCoordinate(vecs.ys,y1);
		y2 = GetIndexFromCoordinate(vecs.ys,y2);
		[x1,x2]=SortTwoValues(x1,x2);
		[y1,y2]=SortTwoValues(y1,y2);
		
		dim = mysize(handles.images(k).image);
		ymin = 1;
		ymax = dim(1);
		xmin = 1;
		xmax = dim(2);
		zmin = 1;
		zmax = dim(3);
		switch handles.gui_options.display_mode(k,1)
			case 1	% coronal
				zmin = max(1,y1);
				xmin = max(1,x1);
				zmax = min(dim(3),y2);
				xmax = min(dim(2),x2);
			case 2	% sagittal
				zmin = max(1,y1);
				ymin = max(1,x1);
				zmax = min(dim(3),y2);
				ymax = min(dim(1),x2);
			case 3	% transverse
				ymin = max(1,y1);
				xmin = max(1,x1);
				ymax = min(dim(1),y2);
				xmax = min(dim(2),x2);
		end
	else
		prompt={'Y min','Y max','X min','X max','Z min','Z max'};
		name=sprintf('Enter cropping boundary for image %d',k);
		numlines=1;
		dim = mysize(handles.images(k).image);
		defaultanswer={'1',num2str(dim(1)),'1',num2str(dim(2)),'1',num2str(dim(3))};
		options.Resize = 'on';
		answer=inputdlg(prompt,name,numlines,defaultanswer,options);

		if isempty(answer)
			continue;
		end

		ymin = str2num(answer{1});
		ymax = str2num(answer{2});
		xmin = str2num(answer{3});
		xmax = str2num(answer{4});
		zmin = str2num(answer{5});
		zmax = str2num(answer{6});
	end

	if k == 2 
		if ~isempty(handles.images(1).image_deformed)
			handles.images(1).image_deformed = handles.images(1).image_deformed(ymin:ymax,xmin:xmax,zmin:zmax);
		end
	end

	handles.images(k).image = handles.images(k).image(ymin:ymax,xmin:xmax,zmin:zmax);
	handles.reg.images_setting.cropped_image_offsets_in_original(k,:) = handles.reg.images_setting.cropped_image_offsets_in_original(k,:) + [ymin xmin zmin] - [1 1 1];
	handles.images(k).image = handles.images(k).image;
	handles = Logging(handles,'Image #%d is cropped using [%d-%d,%d-%d,%d-%d]\n\tImage size after cropping = [%s]',...
		k,ymin,ymax,xmin,xmax,zmin,zmax, num2str(size(handles.images(k).image),'%d '));
% 	handles = Logging(handles,'\tImage size becomes [%s]',num2str(size(handles.images(k).image),'%d '));

	if k == 1
		% recompute the offsets
		handles.reg.images_setting.image_offsets = handles.reg.images_setting.image_offsets - [ymin-1 xmin-1 zmin-1];
		handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_current_offsets - [ymin-1 xmin-1 zmin-1];
	else
		handles.reg.images_setting.image_offsets = handles.reg.images_setting.image_offsets + [ymin-1 xmin-1 zmin-1];
		handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_current_offsets + [ymin-1 xmin-1 zmin-1];
		for idx = 1:7
			handles.gui_options.slidervalues(idx,:) = handles.gui_options.slidervalues(idx,:) - [ymin-1 xmin-1 zmin-1];
			handles.gui_options.slidervalues(idx,:) = max(handles.gui_options.slidervalues(idx,:),1);
			handles.gui_options.slidervalues(idx,:) = min(handles.gui_options.slidervalues(idx,:),mysize(handles.images(2).image));
		end
	end
	
	handles.images(k).origin = handles.images(k).origin + handles.images(1).voxelsize .* handles.images(k).voxel_spacing_dir .* [ymin-1 xmin-1 zmin-1];
	
	setinfotext('Images have been cropped');
end

handles.gui_options.display_maxprojection = 0;
handles.gui_options.display_mode = saved_display_mode;
handles.gui_options.display_enabled = saved_display_enabled;

if display == 1
	handles = reconfigure_sliders(handles);
	guidata(handles.gui_handles.figure1,handles);
	RefreshDisplay(handles);
end


return;

