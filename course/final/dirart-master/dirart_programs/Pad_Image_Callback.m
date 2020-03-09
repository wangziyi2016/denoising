function Pad_Image_Callback(handles)
%
%	Pad_Image_Callback(handles)
%
handles = RemoveUndoInfo(handles);	% Remove previous undo information
handles.undo_handles = handles;		% Enable undo

dim1 = mysize(handles.images(1).image);
dim2 = mysize(handles.images(2).image);

for k = 1:2
	prompt={'y','x','z','Val (a number or nan)'};
	name=sprintf('To pad the image %d, please enter boundary size (in pixels) and padding value',k);
	numlines=1;
	defaultanswer={'0','0','0','nan'};
	options.Resize = 'on';
	answer=inputdlg(prompt,name,numlines,defaultanswer,options);

	if isempty(answer)
		fprintf('Padding is cancelled for image %d\n',k);
		continue;
	else
		ys = str2num(answer{1});
		xs = str2num(answer{2});
		zs = str2num(answer{3});
		padsize = [ys,xs,zs];
		padsize = max(padsize,0);

		if max(padsize) == 0
			fprintf('No padding for image %d\n',k);
			continue;
		end
	end

	if strcmpi(answer{4},'nan') == 1
		padval = nan;
	else
		padval = str2num(answer{4});
	end

	handles.images(k).image = padarray(handles.images(k).image,double(padsize),padval);
	if k == 1
		handles.reg.images_setting.image_offsets = handles.reg.images_setting.image_offsets + padsize;
	else
		handles.reg.images_setting.image_offsets = handles.reg.images_setting.image_offsets - padsize;
	end

	handles.images(k).origin = handles.images(k).origin - handles.images(1).voxelsize .* handles.images(k).voxel_spacing_dir .* padsize;

	handles.reg.images_setting.image_current_offsets = handles.reg.images_setting.image_offsets;
	handles = Logging(handles,sprintf('Image %d is pad with boundary = [%s]',k,num2str(padsize,'%d ')));
end

handles = reconfigure_sliders(handles);
guidata(handles.gui_handles.figure1,handles);
RefreshDisplay(handles);


